#!/usr/bin/perl
# /******************************************************************************/
# /* !File              : SuperFlasher.pl                                       */
# /*                      [configfile.ini]                                      */
# /* !Coding language   : Perl                                                  */
# /* !Description       : Flash script for TC2xx infineon Microcontrollers      */
# /*                                                                            */
# /* ****************************************************************************/
# /* !Last Author       : W. Nguimfack       !Date:: 04 Ago 16                  */
# /******************************************************************************/
#
#
#                 SCRIPT!
#
#
# --------------------------------------------------------------------#
#     START PERL MODULE DECLARATION                                   #
# --------------------------------------------------------------------#
#
use Cwd;
use strict;
use warnings;
use File::Basename;
use Cwd qw(abs_path);
use File::Copy qw(copy);
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);
use lib dirname(abs_path $0);
use Text::Levenshtein qw(distance);

#
# --------------------------------------------------------------------#
#     END PERL MODULE DECLARATION                                     #
# --------------------------------------------------------------------#
# 

#----------------------------------------------------------------------------------------------------#


# --------------------------------------------------------------------#
#     START GLOBALS VARIABLES DECLARATION                             #
# --------------------------------------------------------------------#
#
my $G_ConfigFile;      # full path, with name also
my $G_CfgBoardName;#     = "TriBoard_TC23x_das.cfg"; # default
my $G_FlashToolFullName;
my $G_Flashingtool;
my $G_ConfigFileName   = "configFile.ini";
my $G_MemtoolVersion;
my $G_CfgMCUPathName;
my $G_ListOfItemsMenu  = {};
my @G_ListOfExtention;
my $G_InputFolderName;
my $G_InputFolderPath;
my %G_ConfigParameters;
my $G_ToolScriptFileName;
my @G_BinExecutableFiles;
my @G_RunableFilesList = qw();
my @G_InputFilesFromCmd = qw();
my $G_telecommULPFileName = "TelecommInputFile.ulp";
my $G_PerlScriptPath = dirname(__FILE__);
my $G_CfgMCUPath     = "$G_PerlScriptPath\\Targets\\";
my $G_decryptCfgProtocol;
my $G_decryptCfgDevice;
my $G_decryptCfgDLC;
my $G_decryptCfgTarget;
my $G_decryptCfgFunctionalAdr;
my $G_decryptCfgAI;
my $G_decryptCfgPort;
my $G_decryptCfgBAUD; 
my $G_decryptCfgFRAME;
my $G_decryptDwldDWNL;
my $G_decryptDwldSERIAL;
my $G_CRYPTLIBPath;
my $G_Verbose;
my $G_MemtoolEraseAll;
my $G_MCUEraseFile;
my $G_MCUEraseFileName;
my $G_tranforPath;      

# --------------------------------------------------------------------#
#     END GLOBALS VARIABLES DECLARATION                               #
# --------------------------------------------------------------------#

#
#----------------------------------------------------------------------------------------------------#
#

# --------------------------------------------------------------------#
#     START MAIN CODE                                                 #
# --------------------------------------------------------------------#
# START
#
# --------------------------------------------------------------------
#     Read command line arguments (from command line)
# -------------------------------------------------------------------- 
ManageOption();

# --------------------------------------------------------------------
#     Read configuration arguments (from config.ini)
# -------------------------------------------------------------------- 
( $G_ConfigFile, %G_ConfigParameters) = GetConfiguration($G_InputFolderPath, $G_ConfigFileName, $G_ConfigFile, $G_PerlScriptPath);

# --------------------------------------------------------------------
#     Check the correctness of variables and parameters
# -------------------------------------------------------------------- 
VariablesConsolidation(\%G_ConfigParameters);

# --------------------------------------------------------------------
#     Collect the binary files (Read ulp, hex, mot etc. from BUILD dir)
# -------------------------------------------------------------------- 
@G_RunableFilesList = CollectRunableBinaryFiles($G_InputFolderPath, $G_ConfigFileName, @G_ListOfExtention);

# --------------------------------------------------------------------
#     Build the menu items (with the list of binary files found)
#         [The tool will run as soon as user select a file]
# -------------------------------------------------------------------- 
$G_ListOfItemsMenu = GenerateMenuChoices(
                                          $G_ToolScriptFileName, 
                                          $G_telecommULPFileName, 
                                          $G_FlashToolFullName, 
                                          $G_Flashingtool, 
                                          $G_CfgMCUPathName, 
                                          $G_InputFolderPath, 
                                          join(';', @G_RunableFilesList), 
                                          \%G_ConfigParameters, 
                                          $G_decryptCfgProtocol, 
                                          $G_decryptCfgDevice,
                                          $G_decryptCfgDLC, 
                                          $G_decryptCfgTarget,
                                          $G_decryptCfgFunctionalAdr,
                                          $G_decryptCfgAI,
                                          $G_decryptCfgPort, 
                                          $G_decryptCfgBAUD,
                                          $G_decryptCfgFRAME, 
                                          $G_decryptDwldDWNL, 
                                          $G_decryptDwldSERIAL,
                                          $G_FlashToolFullName,
                                          $G_CRYPTLIBPath,
                                          @G_InputFilesFromCmd);

# --------------------------------------------------------------------
#     Display the menu and wait for the choice
# -------------------------------------------------------------------- 
DisplayMenu($G_ListOfItemsMenu);
#
# END
# --------------------------------------------------------------------#
#     END MAIN CODE                                                   #
# --------------------------------------------------------------------#


#----------------------------------------------------------------------------------------------------#


# --------------------------------------------------------------------#
#     START SUBROUTINES                                               #
# --------------------------------------------------------------------#

# -------------------------------------------------------------------- #
# FUNCTION: VariablesConsolidation 
# DESC:  Check all important global variables
#      
# -------------------------------------------------------------------- #
sub VariablesConsolidation
{
  my $config = shift;

  print STDOUT"\n=================================================================\n" if ($G_Verbose);
  print STDOUT"==================== PROJECT DETAILS ============================\n" if ($G_Verbose);
  print STDOUT"=================================================================\n\n" if ($G_Verbose);
  # --------------------------------------------------------------------
  #     Test the project name
  # -------------------------------------------------------------------- 
  if ($G_InputFolderName){
    print STDOUT "INFOS --- Project Name: \n\t ->$G_InputFolderName\n" if ($G_Verbose);
  } else {
    DisplayHelp("ERROR *** Unknow Project Name!\n\n");
  }

  # --------------------------------------------------------------------
  #     Test the project path
  # -------------------------------------------------------------------- 
  if (($G_InputFolderPath) and (-d $G_InputFolderPath)){
    print STDOUT "INFOS --- Project Location: \n\t ->$G_InputFolderPath\n" if ($G_Verbose);
  } else {
    DisplayHelp("ERROR *** Project Directory Not Found!\n\n");
  }

  # --------------------------------------------------------------------
  #     Test the configuration file
  # -------------------------------------------------------------------- 
  if (($G_ConfigFile) and (-f $G_ConfigFile) and ($G_ConfigFile =~ /.*\.ini$/i)){
    print STDOUT "INFOS --- Configuration File: \n\t ->$G_ConfigFile\n" if ($G_Verbose);
  } else {
    DisplayHelp("ERROR *** Configuration File Not Found!\n\n");
  }

  # --------------------------------------------------------------------
  #     Get the flashing tool selected
  # -------------------------------------------------------------------- 
  if (not $G_Flashingtool)
  {
     $G_Flashingtool = $config->{FlashingTool}->{Name};
  }
  if ((not $G_Flashingtool) or ((not ($G_Flashingtool =~ /memtool/i)) and (not ($G_Flashingtool =~ /telecom.*/i))))
  {
     while (1) 
     {
         my $tmpi;
         print STDOUT "\n## =============================================\n";
         print STDOUT "#  TOOL CHOICE \n";
         print STDOUT "# ==============================================\n\n";;
         print STDOUT "1 - memtool\n";
         print STDOUT "2 - telecomm\n";
         print STDOUT "3 - Exit\n";
         print STDOUT "Select the Flashing tool:";
         chomp ($tmpi  = <STDIN>);
         exit if ($tmpi eq '3');
         $G_Flashingtool = "memtool" if ($tmpi eq '1');
         $G_Flashingtool = "telecomm" if ($tmpi eq '2');
         last if ($tmpi eq '1' or $tmpi eq '2');
      }
  }
  # --------------------------------------------------------------------
  #     Get Transfor path
  # --------------------------------------------------------------------  
   $G_tranforPath = $config->{FileExtention}->{TransforPath};
   if($G_tranforPath){
      $G_tranforPath =~ s/\s//g;
      $G_tranforPath =~ s/^\"|\"$//g;
   }
   else {
    DisplayHelp("ERROR *** Tranfor Path *** Not Found!\n\n");
   }
  # --------------------------------------------------------------------
  #     Get MCU configuration path + name
  # --------------------------------------------------------------------  
  if ($G_Flashingtool =~ /memtool/) 
  { 
      $G_CfgMCUPathName =~ s/\\\\/\\/g if $G_CfgMCUPathName;
      $G_CfgMCUPathName =~ s-////-\\-g if $G_CfgMCUPathName;

      if (not $G_CfgMCUPathName)
      {
         $G_CfgMCUPathName = $G_ConfigParameters{Memtool}{CfgBoardFile};
         $G_CfgMCUPathName =~ s/\s//g;
         $G_CfgMCUPathName =~ s/^\"|\"$//g;
      }
      if(($G_CfgMCUPathName) and ($G_CfgMCUPathName =~ m/.*\.cfg$/i)and (-e $G_CfgMCUPathName))
      {
         my $tmpname = basename ($G_CfgMCUPathName);
         print STDOUT "INFOS --- MCU Configuration File: \n\t ->$tmpname\n"if ($G_Verbose);
         print STDOUT "INFOS --- MCU Location: \n\t ->$G_CfgMCUPathName\n" if ($G_Verbose);
      } 
      else
      {
         DisplayHelp("ERROR *** Unable to read MCU configuration file (please check configFile.ini)\n\n");
      }
      $G_MCUEraseFileName = $config->{Memtool}->{MemtoolEraseFileName};
      if ($G_CfgMCUPathName) 
      {
         $G_MCUEraseFile = dirname($G_CfgMCUPathName);
       	$G_MCUEraseFile = dirname($G_MCUEraseFile);
       	my $tmpbd = $G_CfgMCUPathName;
         $tmpbd =~ s/.*(_TC.*_das).*/$1/;
         $G_MCUEraseFile = $G_MCUEraseFile . "\\EraseFiles\\$G_MCUEraseFileName" . $tmpbd . ".hex";
      }
      else{
       	DisplayHelp("ERROR *** Unable to read MCU erase file :\n (Dir $G_MCUEraseFile) \n\n");
      }
  }

  # --------------------------------------------------------------------
  #     Get Parameters according to the tool selected
  # -------------------------------------------------------------------- 
  if ($G_Flashingtool =~ /memtool/i){ 
       # --------------------------------------------------------------------
       #     Get the name of the script file read by memtool
       # -------------------------------------------------------------------- 
       if (not $G_ToolScriptFileName){
         $G_ToolScriptFileName = $config->{Memtool}->{ScriptFileName}; 
       }
       if (not $G_ToolScriptFileName)
       {
         DisplayHelp("ERROR *** memtool script file name not specified (please check configFile.ini)\n\n");
       }
       # --------------------------------------------------------------------
       #     Test memtool script file in full path
       # -------------------------------------------------------------------- 
       if (($G_ToolScriptFileName) and (-f "$G_InputFolderPath\\$G_ToolScriptFileName")){
         print STDOUT "INFOS --- Memtool Script file: \n\t ->$G_InputFolderPath\\$G_ToolScriptFileName\n" if ($G_Verbose);
       }
       # --------------------------------------------------------------------
       #     Get the version of memtool
       # --------------------------------------------------------------------     
       $G_MemtoolVersion = $config->{Memtool}->{Version} if (not $G_MemtoolVersion); 
       if (not $G_MemtoolVersion)
       {
         DisplayHelp("ERROR *** memtool version not specified (please check configFile.ini)\n\n");
       }

       # --------------------------------------------------------------------
       #     Get the version of memetool
       # --------------------------------------------------------------------     
       if (not $G_FlashToolFullName)
       {
         $G_FlashToolFullName = $config->{Memtool}->{ExePath};
         $G_FlashToolFullName =~ s/"//g; # test if usefull      
       }
       if (not $G_FlashToolFullName) 
       {
         $G_FlashToolFullName = GetMemtoolPath($G_MemtoolVersion, $G_FlashToolFullName);
       }
       if ((not $G_FlashToolFullName) or  (not $G_FlashToolFullName =~ /^.*\.exe$/))
       {
         DisplayHelp("ERROR *** MemTool executable file not found. type the full path in cmd or in ini file\n\n");    
       }
       else
       {
         print STDOUT "INFOS --- Memtool tool: \n\t ->$G_FlashToolFullName\n" if ($G_Verbose);
       }
    } # End if $G_Flashingtool eq memtool
    elsif ($G_Flashingtool =~ /telecom.*/i)
    {
       if (not $G_FlashToolFullName)
       { 
         $G_FlashToolFullName = $config->{Telecomm}->{ExePath};
         #$G_FlashToolFullName =~ s/"//g; # test if usefull
         $G_FlashToolFullName =~ s/\s//g;
         $G_FlashToolFullName =~ s/^\"|\"$//g;
       }
       if (($G_FlashToolFullName) and ($G_FlashToolFullName =~ /.*\.exe$/) and (-e $G_FlashToolFullName))
       {
         print STDOUT "INFOS --- Telecomm tool: \n\t ->$G_FlashToolFullName\n" if ($G_Verbose);
       }
       else
       {
         DisplayHelp("ERROR *** Telecomm executable file *** not found.\n\n");
       }

       # --------------------------------------------------------------------
       #     Get crypt tool path
       # --------------------------------------------------------------------  
       $G_CRYPTLIBPath = $G_ConfigParameters{Telecomm}{CRYPTLIBPath}; 
       $G_CRYPTLIBPath =~ s/\s//g;
       $G_CRYPTLIBPath =~ s/^\"|\"$//g;
       if(($G_CRYPTLIBPath) and (-e $G_CRYPTLIBPath))
       {
          my $tmpname = basename ($G_CRYPTLIBPath);
          print STDOUT "INFOS --- CRYPTLIB File: \n\t ->$tmpname\n" if ($G_Verbose);
          print STDOUT "INFOS --- CRYPTLIB Location: \n\t ->$G_CRYPTLIBPath\n" if ($G_Verbose); 
       }
       else 
       {
         DisplayHelp("ERROR *** $G_CRYPTLIBPath *** not found.\n\n");
       }
    
       # --------------------------------------------------------------------
       #     Get Telecomm protocol
       # --------------------------------------------------------------------
       $G_decryptCfgProtocol = $G_ConfigParameters{Telecomm}{Protocol};  
       if (not $G_decryptCfgProtocol){
          DisplayHelp("ERROR *** Unknow Telecomm protocol (please check configFile.ini)\n\n");
       }
       # --------------------------------------------------------------------
       #     Get Telecomm Device
       # --------------------------------------------------------------------
       $G_decryptCfgDevice = $G_ConfigParameters{Telecomm}{Device};  
       if (not $G_decryptCfgDevice){
          DisplayHelp("ERROR *** Unknow Telecomm Device (please check configFile.ini)\n\n");
       }

       # --------------------------------------------------------------------
       #     Get Telecomm DLC
       # --------------------------------------------------------------------
       $G_decryptCfgDLC = $G_ConfigParameters{Telecomm}{DLC};  
       if (not $G_decryptCfgDLC){
          DisplayHelp("ERROR *** Unknow Telecomm DLC (please check configFile.ini)\n\n");
       }

       # --------------------------------------------------------------------
       #     Get Telecomm Target
       # --------------------------------------------------------------------
       $G_decryptCfgTarget = $G_ConfigParameters{Telecomm}{Target};  
       if (not $G_decryptCfgTarget){
          DisplayHelp("ERROR *** Unknow Telecomm Target (please check configFile.ini)***\n\n");
       }

       # --------------------------------------------------------------------
       #     Get Telecomm FunctionalAddress
       # --------------------------------------------------------------------
       $G_decryptCfgFunctionalAdr = $G_ConfigParameters{Telecomm}{FunctionalAddress};  
       if (not $G_decryptCfgFunctionalAdr){
          DisplayHelp("ERROR *** Unknow Telecomm FunctionalAddress (please check configFile.ini)\n\n");
       }

       # --------------------------------------------------------------------
       #     Get Telecomm AI
       # --------------------------------------------------------------------
       $G_decryptCfgAI = $G_ConfigParameters{Telecomm}{AI};  
       if (not $G_decryptCfgAI){
          DisplayHelp("ERROR *** Unknow Telecomm AI (please check configFile.ini)\n\n");
       }

       # --------------------------------------------------------------------
       #     Get Telecomm Port
       # --------------------------------------------------------------------
       $G_decryptCfgPort = $G_ConfigParameters{Telecomm}{Port};  
       if (not $G_decryptCfgPort){
          DisplayHelp("ERROR *** Unknow Telecomm Port (please check configFile.ini)\n\n");
       }
       # --------------------------------------------------------------------
       #     Get Telecomm BAUD
       # --------------------------------------------------------------------
       $G_decryptCfgBAUD = $G_ConfigParameters{Telecomm}{BAUD};  
       if (not $G_decryptCfgBAUD){
          DisplayHelp("ERROR *** Unknow Telecomm Port (please check configFile.ini)\n\n");
       }
       # --------------------------------------------------------------------
       #     Get Telecomm FRAME
       # --------------------------------------------------------------------
       $G_decryptCfgFRAME = $G_ConfigParameters{Telecomm}{FRAME};  
       if (not $G_decryptCfgFRAME){
          DisplayHelp("ERROR *** Unknow Telecomm FRAME (please check configFile.ini)\n\n");
       }
       # --------------------------------------------------------------------
       #     Get Telecomm DWNL
       # --------------------------------------------------------------------
       $G_decryptDwldDWNL = $G_ConfigParameters{Telecomm}{DWNL};  
       if (not $G_decryptDwldDWNL){
          DisplayHelp("ERROR *** Unknow Telecomm DWNL (please check configFile.ini)\n\n");
       }

       # --------------------------------------------------------------------
       #     Get Telecomm SERIAL
       # --------------------------------------------------------------------
       $G_decryptDwldSERIAL = $G_ConfigParameters{Telecomm}{SERIAL};  
       if (not $G_decryptDwldSERIAL){
          DisplayHelp("ERROR *** Unknow Telecomm SERIAL (please check configFile.ini)\n\n");
       }
       
       # --------------------------------------------------------------------
       #     Get the name of the script file to be encrypted
       # -------------------------------------------------------------------- 
       if (not $G_ToolScriptFileName){
            $G_ToolScriptFileName = $config->{Telecomm}->{DecryptFileName}; 
            $G_ToolScriptFileName =~s/\.txt$/$1/i; 
            $G_ToolScriptFileName = "$G_ToolScriptFileName"."\_"."$G_decryptCfgDevice"."\_"."$G_decryptCfgPort"."\_"."$G_InputFolderName";
            $G_ToolScriptFileName =~ s/^(.+)$/$1\.txt/;
       }
       if (not $G_ToolScriptFileName)
       {
         DisplayHelp("ERROR *** Telecomm script file name not specified (please check configFile.ini)\n\n");
       }
       if (($G_ToolScriptFileName) and (-f "$G_InputFolderPath\\$G_ToolScriptFileName")){
         print STDOUT "INFOS --- Telecomm Script file: \n\t ->$G_InputFolderPath\\$G_ToolScriptFileName\n" if ($G_Verbose);
       }
   } # End if $G_Flashingtool eq telecomm
  else 
  {
    DisplayHelp("ERROR *** Unknow Flashing Tool. Type the full name in cmd or in ini file\n\n");
  } # End if $G_Flashingtool 

  @G_ListOfExtention = split /;/, $config->{FileExtention}->{EXT}; # to be consolidate
  @G_BinExecutableFiles = split /;/, $config->{InputFiles}->{SelectedFilesNames}; # to be consolidate

}

# =============================================
# FUNCTION: ManageOption
# DESC: Manage specified options
# =============================================
sub ManageOption
{
    #Internal Variables Declaration
    my $help;
    my $Verbose;
    my @Infiles;
    my $configFile;
    my $Projectpath;
    my $Memtoolpath;
    my $MemtoolEraseAll;                
    my $telecommpath;
    my $cfgboardname;
    my $Flashingtool; 
    my $Toolfullnamepath;
    my $toolScriptFileName;    
    my $ProgramName = basename($0);

    #Treatment
    GetOptions(
        'Project|p=s' => \$Projectpath,
        'Files|f=s' => \@Infiles,
        'h|?|helps' =>\$help,
        'config|c=s' => \$configFile,
        'mcu|m=s' => \$cfgboardname,
        'Toolfullnamepath|tp=s' => \$Toolfullnamepath,
        'Tool|t=s' => \$Flashingtool,
        'StopEraseAll|e' => \$MemtoolEraseAll,                                                                               
        'V|v' => \$Verbose,
        'inputCfgScript|i=s' => \$toolScriptFileName,
    ) or die "Usage: perl.exe $ProgramName [][--help][--files \"file1 file2 ...\"] \n"; 
    
    DisplayHelp("\t\nHelp Univers!\n") if $help; 

    # Read Argument and Parameters
    # --------------------------------------------------------------------
    #     Get the project path
    # -------------------------------------------------------------------- 
    if ($Projectpath){
      ($G_InputFolderPath, $G_InputFolderName) = GetProjectPath($Projectpath);
    } else {
      ($G_InputFolderPath, $G_InputFolderName) = GetFolderPath();
    }

    # --------------------------------------------------------------------
    #     Get File(s) to Download
    # -------------------------------------------------------------------- 
    if (@Infiles){
      @G_InputFilesFromCmd = split(/ |,|;/,join(' |,|;',@Infiles));
    }

    # --------------------------------------------------------------------
    #     Get the configuration file of the mcu
    # --------------------------------------------------------------------     
    if($cfgboardname)
    {
      $G_CfgMCUPathName = GetCfgMCUPath($G_InputFolderPath, $cfgboardname); 
    }

    # --------------------------------------------------------------------
    #     Get the type of the flash tool (memtool or telecom)
    # -------------------------------------------------------------------- 
    if ($Flashingtool)
    {
      $G_Flashingtool = lc $Flashingtool;
      if ((not ($G_Flashingtool =~ /memtool/i)) and (not ($Flashingtool =~ /telecom.*/i)))
      {
        DisplayHelp("\nERROR *** Unknow Flashing Tool. type memtool or telecomm\n\n");
      }
    }

    # --------------------------------------------------------------------
    #     Get the configuration file name
    # -------------------------------------------------------------------- 
    if (($configFile) and (-f $configFile) and ($configFile =~ /^.*\.ini$/)){
      $G_ConfigFile   = $configFile;
    }

    # --------------------------------------------------------------------
    #     Get the path of tool 
    # -------------------------------------------------------------------- 
    if (($Toolfullnamepath) and (-e $Toolfullnamepath) and ($Toolfullnamepath =~ /^.*\.exe$/)){
      $G_FlashToolFullName  = $Toolfullnamepath;
    }

    # --------------------------------------------------------------------
    #     Get verbose 
    # -------------------------------------------------------------------- 
    if ($Verbose)
    {
      $G_Verbose = $Verbose;
    }

    # --------------------------------------------------------------------
    #     Get the MemTool Erase option for all memory sections 
    # -------------------------------------------------------------------- 
    if ($MemtoolEraseAll) {
       $G_MemtoolEraseAll = $MemtoolEraseAll;	
    }
    # --------------------------------------------------------------------
    #     Get the script file from CMD 
    # -------------------------------------------------------------------- 
    if ($toolScriptFileName) {
       $G_ToolScriptFileName = $toolScriptFileName;   
    }
}


# -------------------------------------------------------------------- #
# FUNCTION: GetConfiguration
# DESC:  Collect configuration parameters from .ini file 
#        
# -------------------------------------------------------------------- #
sub GetConfiguration
{
  #Get Input
  my $FolderPath     = shift;
  my $ConfigFileName = shift;
  my $ConfigPath     = shift;
  my $PerlScriptPath = shift;

  #Internal Variables Declaration
  my %hash;
  my $value;
  my $section;
  my $keyword;
  my $MyIniFile;
  my $cd = getcwd;
  my $exepath = abs_path(__FILE__);

  #Treatment
  $exepath = dirname($exepath); 
  if (($ConfigPath) and (-f $ConfigPath) and ($ConfigPath =~ /^.*\.ini$/)){
    $MyIniFile= "$ConfigPath";
  } elsif (($FolderPath) and (-f "$FolderPath\\$ConfigFileName")){
    $MyIniFile= "$FolderPath\\$ConfigFileName";
  }elsif (($FolderPath) and (-f "$cd\\$ConfigFileName")){
    $MyIniFile= "$cd\\$ConfigFileName";
  } elsif (($FolderPath) and (-f "$FolderPath\\BUILD\\$ConfigFileName")){
    $MyIniFile= "$FolderPath\\BUILD\\$ConfigFileName";
  } elsif (($FolderPath) and (-f "$FolderPath\\SRC\\$ConfigFileName")){
    $MyIniFile= "$FolderPath\\SRC\\$ConfigFileName";
  } elsif (($exepath) and (-f "$exepath\\$ConfigFileName")){
    $MyIniFile= "$exepath\\$ConfigFileName";
  } elsif (($PerlScriptPath) and (-d $PerlScriptPath) and (-e "$PerlScriptPath\\$ConfigFileName")){
    $MyIniFile= "$PerlScriptPath\\$ConfigFileName";
  } else { 
    DisplayHelp("ERROR: *** Please specify a configuration file by adding the following line to your command:\n--config configfilePath\n\n");
  }
  $MyIniFile =~ s/\//\\/g if $MyIniFile;
  $MyIniFile =~ s/\\\\/\\/g if $MyIniFile;
  
  open (INI, "$MyIniFile") || die DisplayHelp("ERROR *** Can't open $MyIniFile\n\n");
  while (<INI>) {
    chomp;
    if (/^\s*\[(\w+)\].*/) 
    {
      $section = $1;
    }
    if (/(^.*)=(.*$)/) 
    {
      $keyword = $1;
      $value = $2 ;
      $hash{$section}{$keyword} = $value;
    }
  }
  close (INI);

  return ($MyIniFile, %hash);
}

# -------------------------------------------------------------------- #
# FUNCTION: CollectRunableBinaryFiles
# DESC:  Collect executables files names into 
#        .ini file 
#		   
# -------------------------------------------------------------------- #
sub CollectRunableBinaryFiles
{
   my ($FolderPath, $ConfigFileName, @ListOfExtention) = @_;

   #Internal Variables Declaration
   my $RunableFile;
   my @RunableFilesList = qw();
   my $folder           = "$FolderPath\\BUILD";

   #Treatment
   
   if(($folder)and(-d $folder)){
      opendir (DIR, $folder) or die DisplayHelp("ERROR *** Could not open BUILD directory. \n(Location (if any): $FolderPath\\BUILD)\n\n");
      while (my $Obj = readdir(DIR)) 
      {
         for my $extention (@ListOfExtention) 
         {
            push @RunableFilesList, "$Obj" if ($Obj =~ /^.*\.$extention$/);   

         } 
      }
      $RunableFile = join(';',@RunableFilesList);
      close DIR;
   }
   elsif(($FolderPath)and(-d $FolderPath)){
      opendir (DIR, $FolderPath) or die DisplayHelp("ERROR *** Could not open the SF main directory. \n(Location (if any): $FolderPath)\n\n");
      while (my $Obj = readdir(DIR)){
         for my $extention (@ListOfExtention) 
         {
            push @RunableFilesList, "$Obj" if ($Obj =~ /^.*\.$extention$/);
         }      
      }
      $RunableFile = join(';',@RunableFilesList);
      close DIR;
   }

   else{"ERROR *** Could not found the project directory: $FolderPath\n\n"}
   return @RunableFilesList;
}

# -------------------------------------------------------------------- #
# FUNCTION: GenerateMenuChoices
# DESC: Generate the menu options 
#		                               
# -------------------------------------------------------------------- #
sub GenerateMenuChoices 
{
  my ($ToolScriptFileName, 
      $telecommULPFileName, 
      $ToolFullName, 
      $Flashingtool, 
      $CfgMCUPathName,
      $ScriptFilePath, 
      $RunableFilesList, 
      $ConfigParameters,
      $decryptCfgProtocol, 
      $decryptCfgDevice,
      $decryptCfgDLC, 
      $decryptCfgTarget,
      $decryptCfgFunctionalAdr,
      $decryptCfgAI,
      $decryptCfgPort, 
      $decryptCfgBAUD, 
      $decryptCfgFRAME, 
      $decryptDwldDWNL, 
      $decryptDwldSERIAL,
      $FlashToolFullName,
      $CRYPTLIBPath,
      @CMDInfiles) = @_;

  #Internal Variables Declaration
  my $deviceNum;
  my $ListOfItemsMenu = {};
  my $ExecutableInputFileName;
  my @SelectedExecutableFiles = split /;/, $ConfigParameters->{InputFiles}->{SelectedFilesNames}; # to consolidate 
  my @DetectedExecutableFiles = split /;/, $RunableFilesList;
  my @ExecutableFiles = qw();

  #Treatment
  @ExecutableFiles = @CMDInfiles if (@CMDInfiles);
  @ExecutableFiles = @SelectedExecutableFiles if (@SelectedExecutableFiles && !@CMDInfiles);
  @ExecutableFiles = @DetectedExecutableFiles if (!@SelectedExecutableFiles && !@CMDInfiles);

  # Case1: There is no binary file found
  if( scalar(@ExecutableFiles) eq 0){
    print STDOUT "ERROR *** Executable file not found. BUILD folder is empty?\n";
    DisplayHelp();
  }

  if ($Flashingtool =~ /memtool/i) 
  {

    # Case 2: The binary file is already selected
    if( scalar(@ExecutableFiles) eq 1)
    {
      $ExecutableInputFileName = $ExecutableFiles[0];
      WriteMemtoolInputScript($ScriptFilePath, $ToolScriptFileName, $ExecutableInputFileName);
      RunMemtool($ToolFullName, $ScriptFilePath, $ToolScriptFileName, $CfgMCUPathName);
      exit;
    }  
    
    #Case 3: There are many binary file available? Ask for selection
    $ListOfItemsMenu = 
    {
      "title"    => "FLASH TC2xxx : Select a file to flash",
      "InputMSG" => "Select",
    };
   
    for (my $i = 0; $i < scalar(@ExecutableFiles); $i++) 
    {
      push @{$ListOfItemsMenu->{"choices"}}, [$ExecutableFiles[$i], sub {
         my $selectedChoice = shift;
         $ExecutableInputFileName = $ExecutableFiles[$selectedChoice];
         $ExecutableInputFileName = $ExecutableFiles[0];
         WriteMemtoolInputScript($ScriptFilePath, $ToolScriptFileName, $ExecutableInputFileName);
         RunMemtool($ToolFullName, $ScriptFilePath, $ToolScriptFileName, $CfgMCUPathName);

      }];
    } 
    push @{$ListOfItemsMenu->{"choices"}}, [ "Exit" , sub { print STDOUT "\n## =============\n#  End !\n# ==============\n"; exit; }];
    return $ListOfItemsMenu;

  } 
  elsif($Flashingtool =~ /telecomm.*/i)
  {
    # Case 2: The binary file is already selected
    if( scalar(@ExecutableFiles) eq 1)
    {
      $ExecutableInputFileName = $ExecutableFiles[0];
         WriteTelecomInputScript(
                              $ScriptFilePath, 
                              $ToolFullName, 
                              $ToolScriptFileName,
                              $decryptCfgProtocol, 
                              $decryptCfgDevice,
                              $decryptCfgDLC, 
                              $decryptCfgTarget,
                              $decryptCfgFunctionalAdr,
                              $decryptCfgAI,
                              $decryptCfgPort, 
                              $decryptCfgBAUD,
                              $decryptCfgFRAME,                  
                              $ExecutableInputFileName, 
                              $decryptDwldDWNL, 
                              $decryptDwldSERIAL,
                              $FlashToolFullName,      
                              $CRYPTLIBPath);
          Runtelecomm         (
                              $ScriptFilePath,
                              $ToolFullName, 
                              $ToolScriptFileName);
    }
   
     #Case 3: There are many binary file available? Ask for selection
     $ListOfItemsMenu = 
     {
      "title"    => "FLASH ECU : Select a file to flash",
      "InputMSG" => "Select",
     };
     for (my $i = 0; $i < scalar(@ExecutableFiles); $i++) 
     {
      push @{$ListOfItemsMenu->{"choices"}}, [$ExecutableFiles[$i], sub {
                                                                           my $selectedChoice = shift;
                                                                           $ExecutableInputFileName = $ExecutableFiles[$selectedChoice];
                                                                              WriteTelecomInputScript(
                                                                                 $ScriptFilePath, 
                                                                                 $ToolFullName, 
                                                                                 $ToolScriptFileName,
                                                                                 $decryptCfgProtocol, 
                                                                                 $decryptCfgDevice,
                                                                                 $decryptCfgDLC, 
                                                                                 $decryptCfgTarget,
                                                                                 $decryptCfgFunctionalAdr,
                                                                                 $decryptCfgAI,
                                                                                 $decryptCfgPort, 
                                                                                 $decryptCfgBAUD,  
                                                                                 $decryptCfgFRAME,               
                                                                                 $ExecutableInputFileName, 
                                                                                 $decryptDwldDWNL, 
                                                                                 $decryptDwldSERIAL,
                                                                                 $FlashToolFullName,      
                                                                                 $CRYPTLIBPath);
                                                                              Runtelecomm(
                                                                                 $ScriptFilePath,
                                                                                 $ToolFullName, 
                                                                                 $ToolScriptFileName);
                                                                        }]; 
     }
    push @{$ListOfItemsMenu->{"choices"}}, [ "Exit" , sub { print STDOUT "\n## =============\n#  End !\n# ==============\n"; exit; }];
    return $ListOfItemsMenu;
   }
   else { 
      DisplayHelp("ERROR *** Unknow flash tool (memtool or telecomm?)\n\n");
   }
}

# -------------------------------------------------------------------- #
# FUNCTION: DisplayMenu
# DESC: Print on the std output the menu and
#       get the user choice  
#                                  
# -------------------------------------------------------------------- #
sub DisplayMenu 
{
  # Get Input
  my $args  = shift;
  
  #Internal Variables Declaration
  my $title = $args->{title};
  my $choices  = $args->{choices};
  my $InputMsg = $args->{InputMSG};

  # Display the menu
  while (1) {
    print STDOUT "\n## =============================================\n";
    print STDOUT "#  $title\n";
    print STDOUT "# ==============================================\n";
    print STDOUT "# \n\n";
    for (my $i = 1; $i <= scalar(@$choices); $i++) {
      my $itemHeading = $choices->[$i-1][0];
      print STDOUT "$i.\t $itemHeading\n";
    }
    print STDOUT "\n$InputMsg ?: ";
    my $i = <STDIN>; chomp $i;
    if ($i && $i =~ m/[0-9]+/ && $i <= scalar(@$choices)) {
      &{$choices->[$i-1][1]}($i-1);
    } else {
      print STDOUT ("\nInvalid input.\n\n");
    }
  }
}


# --------------------------------------------------------------------#
#     END   SUBROUTINES                                               #
# --------------------------------------------------------------------#


#----------------------------------------------------------------------------------------------------#


# --------------------------------------------------------------------#
#     START 'UTILITIES' SUBROUTINES                                   #
# --------------------------------------------------------------------#
#
# -------------------------------------------------------------------- #
# FUNCTION: WriteMemtoolInputScript
# DESC: Write memtool script
#                                  
# -------------------------------------------------------------------- #
sub WriteMemtoolInputScript
{
  #Get Input
  my $Path         = shift;
  my $Name         = shift;
  my $FileName     = shift;
  #my $transforPath = shift;                                      
      
  #Internal Variables Declaration
  my $transforPath = $G_tranforPath;
  my $newULPfile   = $FileName;
  my @splitedFiles = split (/\.ulp|\.mot|\.hex|\.elf/,$newULPfile); 
  $Path=~s/(^.*)\\$/$1/g;

  #Treatement 
 if($G_CfgMCUPathName=~/.*_TC26x*.*$|.*_TC27x*.*$/)  #In case we have to test another targets than TC26x has a futur/.*_TC26x*.*|.*_TC27x*.*$/
  {
      while (1) {
     
         my $tmpi;
         print STDOUT "\nWARNING!!!\nDelete All the RAM section of \"$FileName\" (Y/N) ?\n";
         chomp ($tmpi  = <STDIN>);
         if ($tmpi =~ /n/i){
            open(SCRIPT_FILE, "> $Path\\$Name") or die "ERROR *** Could not open $Name: $!";
            print SCRIPT_FILE ("connect\n");
            if(not $G_MemtoolEraseAll) 
            {                                                                                                                                                                                                                                   
               print SCRIPT_FILE ("open_file \"$G_MCUEraseFile\"\n");
               print SCRIPT_FILE ("select_all_sections\n"); 
               print SCRIPT_FILE ("add_selected_sections\n"); 
               print SCRIPT_FILE ("program\n");
            }
            print SCRIPT_FILE ("open_file \"$Path\\BUILD\\$FileName\"\n");
            print SCRIPT_FILE ("select_all_sections\n"); 
            print SCRIPT_FILE ("add_selected_sections\n"); 
            print SCRIPT_FILE ("program\n");
            print SCRIPT_FILE ("disconnect\n");
            print SCRIPT_FILE ("exit\n");
            close(SCRIPT_FILE); 
         }
         elsif ($tmpi =~ /y/i){
            if(not ($newULPfile   =~ m/.*_Ram_SectionExtracted\.ulp$/)){
               $newULPfile  = ("$splitedFiles[0]"."_Ram_SectionExtracted\.ulp"); 
               #system("$transforPath \/psa \/cpu:motorola \/cmd:extract \/src_file:$Path\\BUILD\\$FileName \/dest_file:$Path\\BUILD\\$newULPfile \/addr_src:80000000 \/size:280000 \/format:h86");
               system("echo open /file_name=$Path\\BUILD\\$FileName /buf_dest=1 >%TEMP%\\transfor.tfm");
               system("echo extract /buf_src:1 /addr_src:80000000 /size:280000 /buf_dest:2 >>%TEMP%\\transfor.tfm");
               system("echo save /buf_src:2 /file_name:$Path\\BUILD\\$FileName /format:mot >>%TEMP%\\transfor.tfm");
               system("$transforPath \/psa \/cpu:motorola \@%TEMP%\\transfor.tfm");
            }
            if($newULPfile   =~ m/.*_Ram_SectionExtracted\.ulp$/){
               open(SCRIPT_FILE, "> $Path\\$Name") or die "ERROR *** Could not open $Name: $!";
               print SCRIPT_FILE ("connect\n");
               if(not $G_MemtoolEraseAll) 
               {
                  print SCRIPT_FILE ("open_file \"$G_MCUEraseFile\"\n");
                  print SCRIPT_FILE ("select_all_sections\n"); 
                  print SCRIPT_FILE ("add_selected_sections\n"); 
                  print SCRIPT_FILE ("program\n");
               }                                                                                        
                  print SCRIPT_FILE ("open_file \"$Path\\BUILD\\$newULPfile\"\n");              #Test when build file not there???
                  print SCRIPT_FILE ("select_all_sections\n"); 
                  print SCRIPT_FILE ("add_selected_sections\n"); 
                  print SCRIPT_FILE ("program\n");
                  print SCRIPT_FILE ("disconnect\n");
                  print SCRIPT_FILE ("exit\n");
                  close(SCRIPT_FILE);
            }
         }
         last if(($tmpi =~ /n/i) or ($tmpi =~ /y/i))
       }
  }
  else
  {
      open(SCRIPT_FILE, "> $Path\\$Name") or die "ERROR *** Could not open $Name: $!";
      print SCRIPT_FILE ("connect\n");
      if(not $G_MemtoolEraseAll) 
      {
         print SCRIPT_FILE ("open_file \"$G_MCUEraseFile\"\n");
         print SCRIPT_FILE ("select_all_sections\n"); 
         print SCRIPT_FILE ("add_selected_sections\n"); 
         print SCRIPT_FILE ("program\n");
      }
      print SCRIPT_FILE ("open_file \"$Path\\BUILD\\$FileName\"\n");
      print SCRIPT_FILE ("select_all_sections\n"); 
      print SCRIPT_FILE ("add_selected_sections\n"); 
      print SCRIPT_FILE ("program\n");
      print SCRIPT_FILE ("disconnect\n");
      print SCRIPT_FILE ("exit\n");
      close(SCRIPT_FILE);
  }
}
# -------------------------------------------------------------------- #
# FUNCTION: RunMemtool
# DESC:  Call Memtool wtih written script
#   RunMemtool   as argument
# -------------------------------------------------------------------- #
sub RunMemtool
{
   #Get Input
   my $ToolPath       = shift;
   my $ScriptPath     = shift;
   my $MtbFileName    = shift;
   my $CfgMCUPathName = shift;
   
   #Internal Variables Declaration
   my $Cmd = "\"$ToolPath\"";
   my $ScriptFilePath = "\"$ScriptPath\\$MtbFileName\"";
    
   #Treatement
   system("$Cmd $ScriptFilePath -c $CfgMCUPathName") if $CfgMCUPathName;
   system("$Cmd $ScriptFilePath") if !$CfgMCUPathName;
}
# -------------------------------------------------------------------- #
# FUNCTION: WriteTelecomInputScript
# DESC:  generate a script for telecomm to be encrypted
#      
# -------------------------------------------------------------------- #                                                       
sub WriteTelecomInputScript 
{
   # Get Input
   my $InputFolderPath          = shift;  
   my $FlashToolPath            = shift;
   my $DecryptFileName          = shift;      
   my $decryptCfgProtocol       = shift;
   my $decryptCfgDevice         = shift;
   my $decryptCfgDLC            = shift;
   my $decryptCfgTarget         = shift;
   my $decryptCfgFunctionalAdr  = shift;
   my $decryptCfgAI             = shift;
   my $decryptCfgPort           = shift;
   my $decryptCfgBAUD           = shift;
   my $decryptCfgFRAME          = shift;
   my $decryptDwldULP           = shift;
   my $decryptDwldDWNL          = shift;
   my $decryptDwldSERIAL        = shift;  
   my $FlashToolPaths           = shift;
   my $CRYPTLIBPath             = shift;                            

   #Internal Variables Declaration
  my $build = "BUILD";
  my $UlpFile = "$InputFolderPath$build\\$decryptDwldULP";
  $UlpFile =~ s/\\/\//g;
  my $decryptScriptPath = "$InputFolderPath\\$DecryptFileName";

   if ((-f $decryptScriptPath) and ($decryptScriptPath=~ /^.*\.txt$/))
   {
      print "INFOS --- Old telecomm script file used\n\n";      
   }
   else
   {
      open(my $fhd, "> $decryptScriptPath") or die "ERROR *** Could not open $DecryptFileName: $!";
      print $fhd ("\nConfig "); 
      print $fhd ("/Protocol:$decryptCfgProtocol "); 
      print $fhd ("/Device:$decryptCfgDevice "); 
      print $fhd ("/DLC:$decryptCfgDLC "); 
      print $fhd ("/Target:$decryptCfgTarget "); 
      print $fhd ("/FunctionalAddress:$decryptCfgFunctionalAdr "); 
      print $fhd ("/AI:$decryptCfgAI "); 
      print $fhd ("/Port:$decryptCfgPort "); 
      print $fhd ("/BAUD:$decryptCfgBAUD\n\n"); 
      print $fhd ("#Initialize communication\n");
      print $fhd ("InitCom\n\n");  
      print $fhd ("SendFrame \/FRAME:$decryptCfgFRAME\n\n");
      print $fhd ("SendFrame \/FRAME:$decryptCfgFRAME\n\n");
      print $fhd ("#Download \"mot, ulp, ...\" file\n");
      print $fhd ("Download ");
      print $fhd ("/ULP:$InputFolderPath$build\\$decryptDwldULP "); 
      print $fhd ("/DWNL:$decryptDwldDWNL "); 
      print $fhd ("/SERIAL:$decryptDwldSERIAL\n\n"); 
         
      print $fhd ("#Close communication \(using \"End Of Communication\" process\)\n");
      print $fhd ("CloseCom\n");
      close($fhd);  
      print "INFOS --- NEW script file created for telecomm.\n\n";                                        
   }  
   my @argss = ($CRYPTLIBPath, $decryptScriptPath);
   system(@argss) == 0 or die "ERROR *** : @argss\n\n";
   #system ("del $decryptScriptPath");    
 
}

# -------------------------------------------------------------------- #
# FUNCTION: Runtelecomm
# DESC:  Call telecomm wtih written script
#      as argument
# -------------------------------------------------------------------- #
sub Runtelecomm
{
   #Get Input
   my $ScriptFilePath         = shift;
   my $ToolPath               = shift;
   my $telecommScriptFileName = shift;

   #Internal Variables Declaration
   my $Cmd = "$ToolPath";  
   my $telecommScriptFileNamePath;   

   #Treatement
   $telecommScriptFileNamePath = "$ScriptFilePath$telecommScriptFileName";

   if($telecommScriptFileNamePath =~/.*_encrypted.*/){
      $telecommScriptFileNamePath = "$telecommScriptFileNamePath";
   }
   else{
         $telecommScriptFileNamePath =~ s/(.*)\.txt/$1_encrypted.txt/;
   }
   print STDOUT "Downloading...\n\n";   
   my @argss = ($Cmd, $telecommScriptFileNamePath);
   system(@argss) == 0 or die "ERROR *** : @argss\n\n";
   exit;
}

# -------------------------------------------------------------------- #
# FUNCTION: DisplayHelp
# DESC: Display ConvertEnvProj synopsys
# -------------------------------------------------------------------- #
sub DisplayHelp
{
   #Internal Variables Declaration
   my $helpContent = shift;
   
   #Treatment
   $helpContent .=  "\n=================================================================\n";
   $helpContent .=  "============       HELP : FLASH / SuperFlasher       ============\n";
   $helpContent .=  "=================================================================\n";
   $helpContent .=  "=                                                               =\n";
   $helpContent .=  "=                             (__)                              =\n";
   $helpContent .=  "=                             (oo)                              =\n";
   $helpContent .=  "=                    /---------\\/                               =\n";
   $helpContent .=  "=                   /|    |   ||                                =\n";
   $helpContent .=  "=                  * |__|-----||                                =\n";
   $helpContent .=  "=                     ||      ||                                =\n";
   $helpContent .=  "=                                                               =\n";
   $helpContent .=  "=                                                               =\n";
   $helpContent .=  "=    This SOFTWARE tool was build in order to improve           =\n"; 
   $helpContent .=  "=    the developpement speed on Aurix platforms.                =\n"; 
   $helpContent .=  "=    With the help of Memtool or Telecomm, it automatically     =\n"; 
   $helpContent .=  "=    erase and download a selected binary file                  =\n"; 
   $helpContent .=  "=    on the microcontroller flash memory.                       =\n"; 
   $helpContent .=  "=                                                               =\n"; 
   $helpContent .=  "=                                                               =\n";
   $helpContent .=  "=    Usage:                                                     =\n"; 
   $helpContent .=  "=                                                               =\n"; 
   $helpContent .=  "=    Before use the tool, copy the config.ini beside your       =\n"; 
   $helpContent .=  "=    BUILD directory and edit it.                               =\n"; 
   $helpContent .=  "=                                                               =\n"; 
   $helpContent .=  "=    Exemple Of Use:                                            =\n"; 
   $helpContent .=  "=    \>SuperFlasher.exe [-t telecomm] [-f file]                  =\n"; 
   $helpContent .=  "=                                                               =\n";
   $helpContent .=  "=    For fast execution (flash a file directly):                =\n";
   $helpContent .=  "=    \>SuperFlasher.exe [-t memtool] [-c configFile.ini]         =\n";
   $helpContent .=  "=                       [-f file] [-m TriBoard_TC23] [-e]       =\n"; 
   $helpContent .=  "=                                                               =\n"; 
   $helpContent .=  "=                                                               =\n"; 
   $helpContent .=  "=    List of arguments                                          =\n";
   $helpContent .=  "=    -h // --help // -? : help                                  =\n";
   $helpContent .=  "=    -d // --debug      : debug (for special debug section)     =\n";
   $helpContent .=  "=    -f // --file       : Name of the file to flash             =\n";
   $helpContent .=  "=    -c // --config     : Configuration file                    =\n";
   $helpContent .=  "=                                                               =\n";
   $helpContent .=  "=    -m // --mcu        : Specify the type of the board         =\n";
   $helpContent .=  "=    -p // --project    : Specify the project path to flash     =\n";
   $helpContent .=  "=    --tp //            : Specify the path to memetool/telecomm =\n";
   $helpContent .=  "=    -v   // --verbose  : Hide the addictional informations of  =\n";
   $helpContent .=  "=                         the projet in CMD                     =\n";
   $helpContent .=  "=    -e   //            : Stop the erase of all the flash       =\n";     
   $helpContent .=  "=                         before each download                  =\n";     
   $helpContent .=  "=    -i   //            : memetool/telecomm input script from   =\n";     
   $helpContent .=  "=                         CMD                                   =\n";     
   $helpContent .=  "=================================================================\n\n";

   print STDOUT $helpContent;

   exit;
}



# -------------------------------------------------------------------- #
# FUNCTION: GetProjectPath 
# DESC:  Get the current folder path
#      
# -------------------------------------------------------------------- #
sub GetProjectPath
{
    #Get Input
    my $ProjcetPathfromcmd = shift;

    #Internal Variables Declaration
    my $projectfull;
    my $projectname;
    my $projectpath;
    my $cd = getcwd;


    #Treatment
    #filter
    $projectfull = $ProjcetPathfromcmd if ((-d $ProjcetPathfromcmd) and ($ProjcetPathfromcmd =~ /[a-zA-Z]:(\\|\/)/)); 
    $projectfull = abs_path(".$ProjcetPathfromcmd") if ($ProjcetPathfromcmd =~ m/^(\\|\/)/); 
    $projectfull = abs_path(".\\$ProjcetPathfromcmd") if ((-d ".\\$ProjcetPathfromcmd") and (".\\$ProjcetPathfromcmd") and (not $ProjcetPathfromcmd =~ m/^(\\|\/)/) and (not $ProjcetPathfromcmd =~ /[a-zA-Z]:(\\|\/)/)); 
    $projectfull = abs_path($ProjcetPathfromcmd) if ((-d $ProjcetPathfromcmd) and (($ProjcetPathfromcmd =~ m/^\.(\\|\/)/) or ($ProjcetPathfromcmd =~ m/^\.\.(\\|\/)/))); 

    $projectfull =~ s/\//\\/g if $projectfull;
    $projectname = basename($projectfull) if $projectfull;
    $projectpath = dirname ($projectfull) if $projectfull;
    $projectname = $1 if (($projectname) and ($projectname=~/(.*)\/$/));
    $projectpath.= "\\" if(($projectfull) and (not $projectpath =~/\/$/));
    return ("$projectpath$projectname", $projectname) if (($projectfull) and (-d $projectfull) and (-d "$projectfull\\BUILD"));
    
    $projectname = basename($cd) if $cd;
    $projectpath = dirname ($cd) if $cd;
    $projectname = $1 if($projectname=~/(.*)\/$/);
    $projectpath.="\\" if(not $projectpath =~/\/$/ );
    return ("$projectpath$projectname", $projectname) if ((-d $cd) and (-d "$cd\\BUILD"));
    
    DisplayHelp("ERROR *** BUILD or Project Path not found.\n\n");
}


# =============================================
# FUNCTION: GetCfgMCUPath
# DESC: 
# =============================================
sub GetCfgMCUPath
{
  # Get Input
  my $CfgMCUPath   = shift;
  my $cfgboardname = shift;  

  #Internal Variables Declaration
  my $tmp;
  my $rootproj;
  my $targetspath;
  my $cfgboardname_local;
  my @files       = qw();
  my @filesOrigin = qw();
  my $cd          = getcwd;
  my $exepath = abs_path(__FILE__);
  $exepath = dirname($exepath);

  #Treatment
  return $cfgboardname if (($cfgboardname) and (-f $cfgboardname) and ($cfgboardname =~ /.*\.cfg$/));

  $cfgboardname = abs_path(".$cfgboardname") if (($cfgboardname) and (-e $cfgboardname) and ($cfgboardname =~ m/^(\\|\/)/)); 
  return $cfgboardname if (($cfgboardname) and (-f $cfgboardname) and ($cfgboardname =~ /.*\.cfg$/));
 
  $rootproj = dirname ($CfgMCUPath) if (($CfgMCUPath) and (-d $CfgMCUPath));
  if (($CfgMCUPath) and (-d "$CfgMCUPath\\Targets")){
    $targetspath = "$CfgMCUPath\\Targets";
  } elsif (($CfgMCUPath) and (-d "$CfgMCUPath\\BUILD\\Targets")) {
    $targetspath = "$CfgMCUPath\\BUILD\\Targets";
  } elsif (($CfgMCUPath) and (-d "$CfgMCUPath\\SRC\\Targets")) {
    $targetspath = "$CfgMCUPath\\SRC\\Targets";
  } elsif (($rootproj) and (-d "$rootproj\\Targets")) {
    $targetspath = "$rootproj\\Targets";
  } elsif (-d "$cd\\Targets") {
    $targetspath = "$cd\\Targets";
  } elsif (-d "$exepath\\Targets") {
    $targetspath = "$exepath\\Targets";
  }
      
  if ($cfgboardname and $targetspath)
  {
    $targetspath =~ s/\//\\/g if $targetspath;
    opendir my $dir, $targetspath or die DisplayHelp("ERROR *** Unable to open $targetspath\n\n");
    @files = grep !/^\.\.?$/, readdir ($dir);
    @filesOrigin = @files;
    $_=lc for @files;
    closedir $dir;

    $cfgboardname=lc $cfgboardname;
    $cfgboardname =~ s/\/$//; 
    $cfgboardname =~ basename ($cfgboardname);
    my @dist=distance($cfgboardname,@files);
    my $idmin=0;
    $dist[$idmin] < $dist[$_] or $idmin = $_ for 1..$#dist;

    return "$targetspath\\$filesOrigin[$idmin]" if ($filesOrigin[$idmin] and $filesOrigin[$idmin] =~ m/^.*\.cfg$/);
  }

}


# -------------------------------------------------------------------- #
# FUNCTION: GetMemtoolPath
# DESC: Get Memtool Path using Registery 
#                     
# -------------------------------------------------------------------- #
sub GetMemtoolPath
{
   #Get Input
   my $MemtoolVersion = shift;
   my $MemtoolPath    = shift;

   #Internal Variables Declaration
   my $cle = "HKEY_LOCAL_MACHINE\\SOFTWARE\\Wow6432Node\\Infineon\\Memtool4\\$MemtoolVersion";
   my $valeur = "Path";
   my $Registery;
 
   #Treatment
   return $MemtoolPath if ((-e $MemtoolPath) and ($MemtoolPath =~ /.*\.exe$/));

   RESTART:
   $Registery = `reg query $cle /v $valeur`;
   if($Registery =~ /([a-zA-Z]:\\(.*))/)
   {
      $MemtoolPath = $1;
      $MemtoolPath = "$MemtoolPath"."\\IMTMemtool.exe";
   }  
   if (not ((-e $MemtoolPath) and ($MemtoolPath =~ /.*\.exe$/)) && $MemtoolVersion eq "4.7") 
   { 
     $MemtoolVersion = "4.6";
     goto RESTART;
   }   

   return $MemtoolPath;
}

# -------------------------------------------------------------------- #
# FUNCTION: GetFolderPath 
# DESC:  Get the current folder path
#      
# -------------------------------------------------------------------- #
sub GetFolderPath
{
    #Internal Variables Declaration
    my $projectname;
    my $path      = getcwd;
    my $returnval = `echo %cd%`;

    #Treatment
    $returnval   =~ s/\r?\n$//;
    $projectname = basename($returnval) if ((-d $returnval) and (-d $returnval));
    return ("$returnval\\", $projectname) if $returnval;

    $projectname = basename($path) if ((-d $path) and ($path));
    return ("$path\\", $projectname) if $path;
}   
 
# --------------------------------------------------------------------#
#     END 'UTILITIES' SUBROUTINES                                     #
# --------------------------------------------------------------------#
#
#----------------------------------------------------------------------------------------------------#
#
##                                  --------- End Of File ----------                                ##
# 
#----------------------------------------------------------------------------------------------------#