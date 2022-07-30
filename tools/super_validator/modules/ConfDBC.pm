# ==============================================================================
# ==
# == Version  :   1.0
# ==
# == Function :   S
# ==
# == Parameters : None
# ==
# ==============================================================================
# ==
# == History
# ==
# ==  xx/xx/xx   : Creation
# ==  21/03/2018 : Management of misssing ttributes ( aDiela)
# ==============================================================================
package ConfDBC;

use strict;
# use warnings;

# set autoflush
local $| = 1;

our $VERSION = '1.00';

#= Generic Variables
my $GenConfFile = "CanNetworkCfg.ini";

# Define
my $NB_MAX_DATA_CAN = 64;


#==============================================================================================================================================================
#= External Functions
#==============================================================================================================================================================

#===============================================================================
#
#===============================================================================
sub getCompName
{
   my $self=shift;
   
   return "confDBC";
}

#===============================================================================
#
#===============================================================================
sub getNbOfNetwork
{
    my $self=shift;

   return "";
}

#===============================================================================
#
#===============================================================================
sub toString
{
    my $self=shift;
   my $ConfFile = $self->{ConfFile};
   
   my $Return = "";
   
   $Return = $Return."\nMy configuration file : $ConfFile\n";
   $Return = $Return."\nNetwork Used : ";
   
   foreach my $Network (keys %{$self->{Network}})
   {
      $Return = $Return."$Network ";      
   }
   
   return "$Return\n";
}
#===============================================================================
#
#===============================================================================
sub getLog
{
   my $self=shift;
   return $self->{Log};
}

#==============================================================================================================================================================
#= Internal Functions
#=============================================================================================================================================================

# =============================================
# FUNCTION: Subroutines
# DESC: 
# =============================================
my $debug = sub 
{

   my $self=shift;
   
   my(@args) = @_;
   
   if ($self->{Echo} == 1) 
   {    
      print("#############DEBUG###############\n");
      foreach my $element (@args)
      {
         print "$element\n";
      }
      print("#################################\n\n");
   }
};

my $Trim = sub
{
   my $self=shift;
   my $return = shift;
   $return =~ s/^\s+|\s+$//g;
   return $return;
};

my $DecToNumBase = sub
{
  my $self=shift;
  my $decNumber = $_[0];
  my $numBase = $_[1];
  my $numNumber = '';

  while($decNumber ne 'end') 
  {
    my $temp = $decNumber % $numBase;
    if($temp > 9) 
    {
      $temp = chr($temp + 55);
    }
    $numNumber = $temp . $numNumber;
    $decNumber = int($decNumber / $numBase);
    if($decNumber < $numBase) 
    {
      if($decNumber > 9) 
      {
        $decNumber = chr($decNumber + 55);
      }
      $numNumber = $decNumber . $numNumber;
      $decNumber = 'end'; 
    } 
  }
  return $numNumber;
};

# =============================================
# FUNCTION: RemoveUselessSpace
# DESC: Remove useless space from specified line
# IN : Line to treat
# OUT : Treated line
# =============================================
my $RemoveUselessSpace = sub {
    
   my $self=shift;
   my $line = shift;
    
    
   $line =~ s/^\s+//;  # Remove First lines spaces
   $line =~ s/\s+$//;  # Remove Last line spaces
   $line =~ s/\s+/ /;  # Remove multiple spaces, don't work , TODO
   $line =~ s/  / /;   # For remove 2 space 
    
   return $line;
};

# =========================================================================
# Error Message definition:
# =========================================================================
my %ErrMsg = (
   'SUCCESS'           => [0, "\n\n%s generated !!\n\n"],
   'ERROR_NO_TXRX'     => [-1, "\nWarning: Message id %s has no Rx or Tx attribute, not included in the current Network\n"],       
   'TOO_MANY_DATAS'    => [-1, "\nWarning: Message id %s has too many datas > 64bits\n"],    
   'ENDIANESS'         => [-1, "\nWarning: Message id %s no Endianess attribute\n"], 
   'WARNING_FILE'      => [-1, "\nWarning: Not found '%s' file\n"],
   'EMPTY_FILE'        => [-1, "\nWarning: File '%s' is empty\n"], 
   'BAD_ARG'           => [1, "\nError: Not managed '%s' argument\n\n"],
   'BAD_FOLDER'        => [2, "\nError: Not found '%s' folder\n\n"],
   'ERROR_FILE'        => [3, "\nError: Not found '%s' file\n\n"],
   'CANT_OPEN_FILE'    => [4, "\nUnable to open %s file\n\n"],
   'ERROR_CONF'        => [5, "\nError : Occured in %s file -> Wrong network, missing mandatory informations or file structure\n\n"],   
   'ECU_NOT_FOUND'     => [6, "\nError : Specified Ecu not found in %s filea\n\n"],
   'ERROR_ID'          => [7, "\nError: Message id : %s is defined multiples times in the network\n"],     
   'ERROR_TAG'         => [8, "\nError: Occured in %s file ->  Check Concistency between Tag and PHYSICAL_CAN\n"],
   'ERROR_SYNTAX'      => [9, "\nError: Detected Syntax in %s file (line %d)\n"],
   'ERROR_UINT'        => [10, "\nError: Detected uint upper to 32bits in %s \n"]
   #'ERROR_TYPE'        => [11, "\nError: Message id : %s has no Type \"GenMsgSendType\"\n"]
);

# =============================================
# FUNCTION: $self->$RaiseErr
# DESC: Format  and display detected error
#       Exit from process if necessary
# =============================================
my $RaiseErr = sub {
    
    my $self=shift;
    
    my $Err = shift;
    my @ErrParam = @_;
        
    # Display message if exit is not required
    print STDERR sprintf ($ErrMsg{$Err}[1], @ErrParam);
    
    # Set the Error level
    return $ErrMsg{$Err}[0];
};


# =============================================
# FUNCTION: LogFile
# DESC: Display & logFile Messages
# =============================================
my $LogFile = sub
{
   my $self=shift;
   my %Messages = @_;
   
   my $dest_log = "";

   $dest_log = $dest_log."# =========================================================================\n";
   $dest_log = $dest_log."# === PROCESS DBC === \n";
   $dest_log = $dest_log."# =========================================================================\n";
   # $dest_log = $dest_log."NUMBER OF ECU'S ="." $NbOfEcus"." (" ;
   
   # foreach my $ECU (@EcusKeys)
   # {
      # $dest_log = $dest_log."$ECU,";
   # } 
   # $dest_log = $dest_log.")\n" ;
   $dest_log = $dest_log."NUMBER OF MESSAGES ="." "."\n\n" ;

   foreach my $Message_ID (keys %Messages) 
   {
      
      my $ID_Hex = $self->$DecToNumBase($Message_ID, 16);
      # $dest_log = $dest_log."ID DEC-> "."$Message_ID "; # Print in DEC
      # print $dest_log 
      # $dest_log = $dest_log."|| ";
      $dest_log = $dest_log."ID HEX -> 0x$ID_Hex"; # print in HEX
      $dest_log = $dest_log." || ";
      $dest_log = $dest_log."NAME -> "."$Messages{$Message_ID}{Name}"." ";
      $dest_log = $dest_log."["."$Messages{$Message_ID}{Size}"."Bits]"."\n";
      $dest_log = $dest_log."Transmitter : $Messages{$Message_ID}{Transmitter}\n";
      $dest_log = $dest_log."Receivers : ";
      foreach my $Receiver (sort keys %{$Messages{$Message_ID}{Receivers}})
      {
         $dest_log = $dest_log."$Receiver,";     
      }
      
      $dest_log = $dest_log."\n"; 
      if(exists $Messages{$Message_ID}{Periodicity})
      {
         $dest_log = $dest_log."Periodicity = ";
         $dest_log = $dest_log."$Messages{$Message_ID}{Periodicity}"."ms  ";
         $dest_log = $dest_log."Type = "."$Messages{$Message_ID}{Type}"."\n";
      }
      
      my $NbOfDatas = $Messages{$Message_ID}{NumberOfDatas};
      for(my $index = 0;$index < $NbOfDatas;$index++)
      {
         my $DataBeginAt = $Messages{$Message_ID}{Spot}[$index]{BeginAt};
         my $DataEndAt;
         if($Messages{$Message_ID}{Spot}[$index]{Endian} eq "Big")
         {
            $DataEndAt = $DataBeginAt - $Messages{$Message_ID}{Spot}[$index]{Size}+1;         
         }         
         if($Messages{$Message_ID}{Spot}[$index]{Endian} eq "Little")
         {
            $DataEndAt = $DataBeginAt + $Messages{$Message_ID}{Spot}[$index]{Size}-1;         
         }

         my $DataType    = "";
         my $DataEndian  = $Messages{$Message_ID}{Spot}[$index]{Endian};
         my $DataComment = "";
         if($Messages{$Message_ID}{Spot}[$index]{Type} eq "+")
         {
            $DataType = "UNSIGNED";
         }
         if($Messages{$Message_ID}{Spot}[$index]{Type} eq "-")
         {
            $DataType = "SIGNED";
         }
         if(exists $Messages{$Message_ID}{Spot}[$index]{Comment})
         {
            $DataComment = "Comment : ".$Messages{$Message_ID}{Spot}[$index]{Comment};        
         }
         $dest_log = $dest_log."                                     -> [";
         $dest_log = $dest_log."$DataBeginAt";  
         $dest_log = $dest_log."-";
         $dest_log = $dest_log."$DataEndAt";  
         $dest_log = $dest_log."] --";  
         $dest_log = $dest_log." $Messages{$Message_ID}{Spot}[$index]{Name}"." ";  
         $dest_log = $dest_log."--[";
         $dest_log = $dest_log."$Messages{$Message_ID}{Spot}[$index]{Size}";  
         $dest_log = $dest_log."bit] ";
         $dest_log = $dest_log."$DataEndian Endian - ";
         $dest_log = $dest_log."$DataType  ";
         $dest_log = $dest_log."$DataComment ";
         $dest_log = $dest_log."\n";
      }   
      $dest_log = $dest_log."\n";
   }
   
   $self->{Log} = $self->{Log}.$dest_log;
};


# =============================================
# FUNCTION: ProcessDbc
# DESC: Read the specified dbc file
# IN : Dbc_File,$Ecu_Name
# OUT : %LocalMessages
# =============================================
my $ProcessDbc = sub 
{
   my $self=shift;
   my($DbcFile, $Ecu_Name, $Physical_Can) = @_;
 
   my $errCode = 0;   
   my %LocalMessages = ();
   my @GenMsgSendType = ();

   # Try extracting content of DbcFile
   open(SRC,"< $DbcFile") or return $self->$RaiseErr("ERROR_FILE",$DbcFile);
   my @lines = <SRC>;
   close(SRC);

   # Check empty file
   $errCode = $self->$RaiseErr('EMPTY_FILE', $DbcFile) if (@lines == 0);

   my $NbOfLines = @lines;
   for(my $index = 0; $index <= $NbOfLines; $index++)
   {
         my $line = $lines[$index];         
         $line = $self->$RemoveUselessSpace($line);
         
         # =============================================   
         # DESC: BU_ Ecu's section
         # =============================================    
         if($line  =~ /^BU_:/) 
         {
            my $Ecu_Found = 0;
            $line =~ s/BU_://;   
            $line = $self->$RemoveUselessSpace($line);
            
            my @ECUS = split(/\s+/, "$line");
            my $NbOfEcus = @ECUS;
            foreach my $ECU (@ECUS) 
            {
               $Ecu_Found = 1 if($ECU eq $Ecu_Name);
            }
            
            return $self->$RaiseErr("ECU_NOT_FOUND",$DbcFile) unless ($Ecu_Found == 1);
         } 
         
         # =============================================   
         # DESC: BO_ Message section
         # =============================================         
         elsif($line  =~ /^BO_ /) 
         {
            my $Message_Name;
            my $Message_ID;
            my $Message_Size;
            my $Message_Transmitter;
            my $Message_Receiver = "";
            # =========================================================================
            # == $LocalMessages{ID} -> {Name}
            # ==               -> {Size} 
            # ==               -> {Transmitter}
            # ==               -> {Receivers} # Hash of multiple receivers
            # ==               -> {NumberOfDatas}  
            # ==               -> {Periodicity} 
            # ==               -> {Type} # SendType
            # ==               -> {Spot} -> [0] -> {Name}
            # ==                                -> {BeginAt}
            # ==                                -> {Size}       
            # ==                                -> {SizeScaled} # Scaled data to 8,16,32    
            # ==                                -> {Endian} Big Little
            # ==                                -> {Factor}         
            # ==                                -> {Offset}         
            # ==                                -> {Min}        
            # ==                                -> {Max}        
            # ==                                -> {Receivers}
            # ==                                -> {Type} # Signed + Unsigned -
            # ==                                -> {Init}            
            # ==                                -> {Unit}            
            # ==                                -> {Comment}                  
            # ==                         -> [1] Spot correspond to how you add Signals in the DBC, may be randomatic 
            # ==                          ......
            # =========================================================================
            # Supress BO_
            $line =~ s/BO_ //;
            
            # Fill in Message section -> ID, Size, Name, Transmitter...
            # =========================================================================
            my @MessageInfos = split(/\:/, "$line");

            return $self->$RaiseErr("ERROR_SYNTAX", $DbcFile, $index) unless (@MessageInfos == 2);
               
            $MessageInfos[0] = $self->$RemoveUselessSpace($MessageInfos[0]);                 
            $MessageInfos[1] = $self->$RemoveUselessSpace($MessageInfos[1]);

            my @SubMessageInfos = split(/ /, $MessageInfos[0]);        
            my @SubMessageInfos2 = split(/ /, $MessageInfos[1]);
            
            # ex : 3221225472 VECTOR__INDEPENDENT_SIG_MSG: 0 Vector__XXX
            $Message_ID   = $SubMessageInfos[0];
            $Message_Name = $SubMessageInfos[1];
            $Message_Size = $SubMessageInfos2[0];
            $Message_Transmitter = $SubMessageInfos2[1];

            $LocalMessages{"$Message_ID"}{Name} = "$Message_Name";
            $LocalMessages{"$Message_ID"}{Size} = "$Message_Size";
            $LocalMessages{"$Message_ID"}{Transmitter} = "$Message_Transmitter";
            
            # =========================================================================

            # Get the number of data's by parsing it 
            # =========================================================================           
            my $Subindex = $index;
            while($lines[++$Subindex] =~ /\w/){}        
            my $NbOfDatas = $Subindex - $index - 1;
            $LocalMessages{"$Message_ID"}{NumberOfDatas} = $NbOfDatas;
            return $self->$RaiseErr("TOO_MANY_DATAS", $Message_ID) if ($NbOfDatas > $NB_MAX_DATA_CAN);
            $Subindex = $index;
            
            # Fill in Spot section
            # Spot correspond to how you add Signals in the DBC, may be randomatic
            # maybe need to implement an algorithm to fill in spot regardless to each bit of the CAN message, from 0 to 63, use the startbit and endianess ?  
            # ======================================================================== 
            for(my $DataIndex = $NbOfDatas-1 ;$DataIndex >= 0; $DataIndex--)
            {
               my $Data_Name;
               my $Data_BeginAt;
               my $Data_Size;
               
               $line = $lines[++$Subindex];
               $line = $self->$RemoveUselessSpace($line);
               
               # ex : SG_ BSL_UBat : 16|8@1+ (0.05,5) [5|17.7] "V"  TRW_ESP,Lenkhilfe_APA
               if($line =~ /^SG_/)
               {
                  $line =~ s/SG_//;
                  # ex : BSL_UBat : 16|8@1+ (0.05,5) [5|17.7] "V"  TRW_ESP,Lenkhilfe_APA
                  my @DatasInfos = split(/\:/, "$line");
                  return $self->$RaiseErr("ERROR_SYNTAX", $DbcFile, $Subindex) unless (@DatasInfos == 2);                 
           
                  # ex : BSL_UBat
                  $DatasInfos[0] = $self->$RemoveUselessSpace($DatasInfos[0]);
                  
                  # ex : 16|8@1+ (0.05,5) [5|17.7] "V"  TRW_ESP,Lenkhilfe_APA                  
                  $DatasInfos[1] =$self->$RemoveUselessSpace($DatasInfos[1]);

                  my $DataName = $DatasInfos[0];
                  my $DataBeginAt;            
                  my $DataSize;
                  my $DataSizeScaled; 
                  my $DataType;
                  my $DataEndian = undef;           
                  my $DataFactor = undef;
                  my $DataOffset = undef;
                  my $DataMin    = undef;
                  my $DataMax    = undef; 
                  my $Unit       = undef;
                  my $InitValue  = undef;      
                  my @DataReceivers = ();
                
                  my @SubDatasInfos = split(/ /, $DatasInfos[1]);
                  
                  # ex : 16|8@1+
                  if($SubDatasInfos[0] =~ /^(\d+)\|(\d+)@([01])([\+\-])$/)
                  {
                     $DataBeginAt = $1;
                     $DataSize    = $2;
                     
                     # Size Scaled 8,16,32,64
                     $DataSizeScaled = "8"  if($DataSize <= 8);
                     $DataSizeScaled = "16" if(($DataSize > 8) && ($DataSize <= 16));
                     $DataSizeScaled = "32" if(($DataSize > 16) && ($DataSize <= 32));
                     $DataSizeScaled = "64" if(($DataSize > 32) && ($DataSize <= 64));
                     $DataSizeScaled = "128" if(($DataSize > 64) && ($DataSize <= 128));
                     return $self->$RaiseErr("ERROR_UINT", $Message_ID) unless ($DataSize <= 128);

                     # Endianess
                     $DataEndian = "Big" if ( $3 eq "0");                     
                     $DataEndian = "Little" if ($3 eq "1");
                     return $self->$RaiseErr("ENDIANESS", $Message_ID) unless (defined $DataEndian);
                     
                     $DataType   = $4;
                  }
                  
                  # ex : (0.05,5)
                  if($SubDatasInfos[1] =~ /^\((\-?\d+\.?\d*),(\-?\d+\.?\d*)/)
                  {
                     $DataFactor = $1;
                     $DataOffset = $2;
                  }
                  
                  # ex : [5|17.7]
                  if($SubDatasInfos[2] =~ /^\[(\-?\d+\.?\d*)\|(\-?\d+\.?\d*)/)
                  {
                     if(($1 ne "0") || ($2 ne "0"))
                     {
                        $DataMin = $1;
                        $DataMax = $2;
                     }
                  }

                  # ex : "V"
                  $Unit = $1 if($SubDatasInfos[3] =~ /^"(.+)"/);
                  
                  # ex : TRW_ESP,Lenkhilfe_APA
                  if($SubDatasInfos[4] !~ //)
                  {
                     @DataReceivers = split(/\,/, $SubDatasInfos[4]);                     
                  }
                  
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Name}          = $DataName;
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Size}          = $DataSize;
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{SizeScaled}    = $DataSizeScaled;
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{BeginAt}       = $DataBeginAt;               
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Type}          = $DataType;
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Endian}        = $DataEndian;         
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Factor}        = $DataFactor;             
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Offset}        = $DataOffset;                        
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Receivers}     = @DataReceivers;            
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Init}          = $InitValue;
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Min}           = $DataMin; 
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Max}           = $DataMax;
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Unit}          = $Unit;
                  $LocalMessages{"$Message_ID"}{Spot}[$DataIndex]{Comment}       = "";
                  
                  # Determine the Frame receivers
                  foreach my $Ecu_Data_Receiver (@DataReceivers)
                  {
                     $LocalMessages{"$Message_ID"}{Receivers}{$Ecu_Data_Receiver} = 1;
                  }
               }   
            }
            # ======================================================================
         }
         
         # =============================================   
         # DESC: BA_DEF_ BO_ Attributes generic informations
         # =============================================             
         elsif($line  =~ /^BA_DEF_ BO_ /)
         {
            $line =~ s/BA_DEF_ BO_ //; 
            my @EnuGenericInfos = split(/ /, "$line");
            
            # =============================================   
            # DESC: Send Type enumeration 
            # ============================================= 
            if($EnuGenericInfos[0] =~ /"GenMsgSendType"/)
            {  
               $EnuGenericInfos[3] =~ s/;//;
               $EnuGenericInfos[3] =~ s/"//ig;
               @GenMsgSendType = split(/,/,$EnuGenericInfos[3]);
            }
         }
         # =============================================   
         # DESC: BA_ Attributes informations
         # =============================================     
         elsif($line  =~ /^BA_ /) 
         {
            $line =~ s/BA_ //; 
            
            my $AttribType   = "";
            my $Message_ID   = "";
            
            my @CyclicInfos = split(/ /, $line);
            $AttribType = $CyclicInfos[0];
            $AttribType =~ s/^"(.+)"$/$1/;
            
            # =============================================   
            # DESC: Attribute GenMsgCycleTime
            # ============================================= 
            if($AttribType eq "GenMsgCycleTime")
            {
               my $CyclicTime    = "";
               $Message_ID = $CyclicInfos[2];
               $CyclicTime  = $CyclicInfos[3];
               $CyclicTime  =~ s/;$//;
               if($Message_ID ne "")
               {
                  $LocalMessages{"$Message_ID"}{Periodicity} = $CyclicTime;
               }
            }
            
            # =============================================   
            # DESC: Attribute GenMsgSendType (cyclic,cyclicX...)
            # =============================================             
            if($AttribType eq "GenMsgSendType")
            {
                           
               my $CyclicType    = "";
               my $CyclicTypeNumber;
               $Message_ID = $CyclicInfos[2];
               $CyclicTypeNumber  = $CyclicInfos[3];
               $CyclicTypeNumber  =~ s/;$//;  
               $CyclicType = $GenMsgSendType[$CyclicTypeNumber];              
               if($Message_ID ne "")
               {
                  $LocalMessages{"$Message_ID"}{Type} = $CyclicType;
               }
            }

            if($AttribType eq "GenMsgCycleTimeFast")
            {
               # Noting to do here
            }  

            if($AttribType eq "GenMsgAutoGenSnd")
            {
               # Noting to do here
            } 

            if($AttribType eq "GenMsgAutoGenDsp")
            {
               # Noting to do here
            }         
         }
         
         # =============================================   
         # DESC: CM_ Comment section
         # =============================================              
         if($line  =~ /^CM_ /) 
         {
            # Supress CM_
            $line =~ s/^CM_ //;
            if($line  =~ /^SG_ /) 
            {
               if ($line =~ /^SG_\s+(\w+)\s+(\w+)\s+\"([^\"]*)\"/ )
               {
                  my $Message_ID = $1;
                  my $SignalName = $2;
                  my $Comment = $3;
                  $Comment =~ s/\;//;
                  if(exists $LocalMessages{$Message_ID})
                  {
                     for(my $CommentIndex = 0; $CommentIndex < $LocalMessages{"$Message_ID"}{NumberOfDatas}; $CommentIndex++)
                     {
                        if($LocalMessages{$Message_ID}{Spot}[$CommentIndex]{Name} eq $SignalName)
                        {
                           $LocalMessages{$Message_ID}{Spot}[$CommentIndex]{Comment} = $Comment;
                        }               
                     } 
                  }               
               }
            } 
         }
         
         if($line  =~ /^\s*$/)
         {
            # Noting to do here  
         }
   }
   
   # check if each message has a type
   foreach my $Message_ID (keys %LocalMessages)
   {
      return $self->$RaiseErr("ERROR_TYPE", $Message_ID) unless defined $LocalMessages{$Message_ID}{Type};
   }
   
   # Fill extracted parameter in configuration object
   %{ $self->{Network}{$Physical_Can}{$DbcFile}{DbcMessages} } = %LocalMessages;
   
   return $errCode;
};

# =============================================
# FUNCTION: ManageNetwork
# DESC: 
# =============================================
my $ManageNetwork = sub 
{
   my $self=shift;
   
   my $errCode = 0;
   
  # =============================================   
   # DESC: Manage each Network
   # =============================================   
   foreach my $Physical_Can (keys %{ $self->{Network} })
   {
      # =============================================   
      # DESC: Manage Each DBC in the Network
      # =============================================      
      foreach my $Dbc_File (keys %{$self->{Network}{$Physical_Can}})
      {
         my $MeEcu = $self->{Network}{$Physical_Can}{$Dbc_File}{MeEcu};
         $self->$debug("Manage Network", $Dbc_File, $MeEcu);
         
         $errCode = $self->$ProcessDbc($Dbc_File,$MeEcu, $Physical_Can);
         return $errCode if ($errCode > 0); 
         
         # Log file and debug 
         $self->$LogFile(%{$self->{Network}{$Physical_Can}{$Dbc_File}{DbcMessages}});
         
         # =============================================   
         # DESC: Manage each Message of Each DBC of each Network
         # =============================================          
         foreach my $Message_ID (sort keys %{$self->{Network}{$Physical_Can}{$Dbc_File}{DbcMessages}}) 
         {
            my $RxTx = "";
            
            # =============================================   
            # DESC: Check if there is Same ID in network
            # =============================================             
            return $self->$RaiseErr("ERROR_ID", $Message_ID) if exists $self->{Network}{$Physical_Can}{NetworkMessages}{Rx}{$Message_ID}; 
            return $self->$RaiseErr("ERROR_ID", $Message_ID) if exists $self->{Network}{$Physical_Can}{NetworkMessages}{Tx}{$Message_ID};          
            
            # =============================================   
            # DESC: Check if Rx or Tx Message 
            # =============================================
            foreach my $Receivers (sort keys %{$self->{Network}{$Physical_Can}{$Dbc_File}{DbcMessages}{$Message_ID}{Receivers}}) 
            {
               $RxTx = "Rx" if($Receivers eq $MeEcu);
            }
            if($MeEcu eq $self->{Network}{$Physical_Can}{$Dbc_File}{DbcMessages}{$Message_ID}{Transmitter})
            {
               $RxTx = "Tx";  
            }
            
            # =============================================   
            # DESC: Transfer Messages from LocalMessages to NetworkMessages
            # =============================================            
            if ($RxTx ne "")
            {
               $self->{Network}{$Physical_Can}{NetworkMessages}{$RxTx}{$Message_ID} = $self->{Network}{$Physical_Can}{$Dbc_File}{DbcMessages}{$Message_ID};
            }
            else
            {
               $errCode = $self->$RaiseErr("ERROR_NO_TXRX", $Message_ID);
            }
         }       
      }
   } 
   
   return $errCode;
};

# =============================================
# FUNCTION: ProcessCfg
# DESC: Read the specified Network configuration
# fill in %Network
# =============================================
my $ParseCfg = sub 
{
   my $self=shift;
   
   my $errCode = 0;
   
   my @Lines = ();
   my %PhysicalCanToTag = ();
   my %TagToPhysicalCan = ();
   
   return $self->$RaiseErr("ERROR_FILE", "mandatory Network Configuration") unless (-e $self->{ConfFile});
   
   open(CFG, $self->{ConfFile}) or return $self->$RaiseErr("ERROR_FILE", "Can't open $self->{ConfFile} file");
   @Lines = <CFG>;
   close(CFG);

   # Check empty file
   $errCode = $self->$RaiseErr('EMPTY_FILE', $self->{ConfFile}) if (@Lines == 0);
   
   # =========================================================================
   # == $Network {$Physical_Can} -> {$Dbc_File}
   # ==                                   -> {$ECU} 
   # ==                                   -> {%DbcMessages} : get from ProcessDbc function
   # ==                          -> {$Dbc_File}...
   # ==                          -> {%NetworkMessages} -> {"Rx"}
   # ==                                                -> {"Tx"}
   # =========================================================================
   
   for(my $index = 0;$index <= @Lines; $index++)
   {
      if($Lines[$index] =~ /^\[(.*)\]$/)
      {
         my $TagNetworkName = $1;
         
         my $Dbc_File     = ""; 
         my $Ecu_Name     = "";
         my $Physical_Can = "";
         
         # =============================================   
         # DESC: Process one configuration [...]
         # ============================================= 
         while(($Lines[$index+1] !~ /\[(.*)\]/) && ($index <= @Lines))
         {
            if($Lines[$index] =~ /(.*)=(.*)/)
            {
               # =============================================   
               # DESC: dbc file Name
               # =============================================   
               if($1 eq "DBC")
               {
                  $Dbc_File = $self->$Trim($2);
               }               
               
               # =============================================   
               # DESC: Ecu Name
               # =============================================   
               if($1 eq "ECU_NAME")
               {
                  $Ecu_Name = $self->$Trim($2);
               }               
               
               # =============================================   
               # DESC: Physical CAN Driver
               # =============================================   
               if($1 eq "PHYSICAL_CAN")
               {
                  $Physical_Can = $self->$Trim($2);
                  
                  # =============================================   
                  # DESC: Check tag consistency
                  # =============================================
                  $PhysicalCanToTag{$Physical_Can} = $TagNetworkName if(not exists $PhysicalCanToTag{$Physical_Can});
                  $TagToPhysicalCan{$TagNetworkName} = $Physical_Can if(not exists $TagToPhysicalCan{$TagNetworkName});                 
                  
                  return $self->$RaiseErr("ERROR_TAG", $self->{ConfFile}) if(($PhysicalCanToTag{$Physical_Can} ne $TagNetworkName)||($TagToPhysicalCan{$TagNetworkName} ne $Physical_Can));                 
               }
            }
            $index++;
         }
         
         $self->$debug("In Process CFG","Physical Can : $Physical_Can","Network Name Tag : $TagNetworkName","Dbc Name : $Dbc_File","Ecu Name : $Ecu_Name");
         
         # =============================================   
         # DESC: Check consistency
         # =============================================         
         if(($Dbc_File eq "") || ($Ecu_Name eq "") || ($Physical_Can eq ""))
         {
            return $self->$RaiseErr("ERROR_CONF", $self->{ConfFile});
         }
         
         $self->{Network}{$Physical_Can}{$Dbc_File}{MeEcu} = $Ecu_Name; 
      }
   }
   
   return $self->$RaiseErr("ERROR_CONF", $self->{ConfFile}) if keys %{ $self->{Network} } == 0; 
   
   return $errCode;
};

# =============================================
# FUNCTION: InitInstance
# DESC: Instance Initialization (Parse configuration file, ...) 
# =============================================
my $InitInstance = sub 
{
    my $self=shift;

    my $errCode = 0;

    # Try to parse configuration file
    $errCode = $self->$ParseCfg();
    return $errCode if ($errCode > 0); 

    # Manage le Network
    $errCode = $self->$ManageNetwork();
    return $errCode if ($errCode > 0);
};

# =============================================
# FUNCTION: new
# DESC: Create new instance 
# =============================================
sub new {
    my $invoking = shift;
    my $echo = shift || 0;
    my $confFile = shift || $GenConfFile;

    # Create the Network Instance
    my $self = bless(
    {
       ConfFile => $confFile,
       Echo     => $echo,
       Network  => {},
       Log      => ""
     }, 
    ref ($invoking) || $invoking);

   # Init instance
   my $errCode = $self->$InitInstance();

   # Return initialized instance if no error, undef otherwise
   return $errCode > 0 ? undef : $self;
}


1;