#!/usr/bin/perl
#=================================================================================
# ==                                                                            ==
# == !File              : GeneDBC2Xml.pm                                        ==
# == !Coding language   : Perl                                                  ==
# == !Description       : create xml files to be use as template for the  		  ==
#					a CAPL module for the CANoe	                  				                ==
# ================================================================================
# == Historic :                                                                 ==
# == 27/02/18   : Creation (aDiela )                                            ==
# ==                                                                            ==
# ==                                                                            ==
# ==                                                                            ==
# ================================================================================
#                START PERL HEADER                                            
# ================================================================================

package GeneDBC2Xml;

use strict;
use warnings;
use Encode qw(encode decode);

# set autoflush
local $| = 1;  #Libère la donnée du module à la fin du traitement et évite qu'elle bufferisée. 

our $VERSION = '1.00';

# use Exporter;
# use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

# @ISA       = qw(Exporter );
# @EXPORT    = qw(getcompName &WriteXMLTemplateFile generate $G_templateFileEmpty);
# @EXPORT_OK = qw(getcompName &WriteXMLTemplateFile generate);

my $TemplateFileEmpty   = "TemplateFile.xml";
my $TemplateDataFile    = "TemplateDataFile.xml";
# ================================================================================
# FUNCTION: Subroutines
# DESC: Convert Dec numbers to Hex (From Candbdev by FDOG)
# ================================================================================
sub DecToNumBase
{
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
}
# ================================================================================
#     FUNCTION: WriteXMLTemplateFile                                         
#     DESC:                                                                  
# ================================================================================
#
sub WriteXMLTemplateFile
{

    ### Input Arguments ###
    my ($Network,$Physical_Can,$Message_ID,$RxTx) = @_; 
 
    ### Local Variables ####
    my $IdHex      = DecToNumBase($Message_ID, 16);
    my $Line = "";

    ### Treatement ###

    $Line = $Line."$Network->{Network}{$Physical_Can}{NetworkMessages}{$RxTx}{$Message_ID}{Name}";


    # my $network = {
    #             'Name' => '',
    #             'Attribute' =>  {'Name' => '', 'Value' => ''},
    #             'Node' => [{

    #                         'Name' =>'',
    #                         'ID' =>'',
    #                         'DLC' =>'',
    #                         'ECU' => {'Name' => '', 'Tx' => '', 'Rx' => ''},      #Send : Tx=1;Rx=0 | Reception : Tx=0;Rx=1
    #                         'CycleTime' => '',
    #                         'FrameType' => '',
    #                         'Attribute' => '',
    #                         'Comment' => '',
    #                         'signal' => [{
    #                                         'Name' => '', 
    #                                         'Min' => '',
    #                                         'Max' => '',
    #                                         'Startbit' =>'',
    #                                         'Lenght' => '',
    #                                         'ByteOrder' => '',
    #                                         'valueType' =>'',
    #                                         'value' =>'',
    #                                         'Factor' => '',
    #                                         'Offset' => '',
    #                                         'Unit' => ''
    #                         }]
    #             }]
            
    # };

    # my $xs = XML::Simple->new(XMLDecl => "<?xml version=\"1.0 \"encoding=\"UTF-8\" standalone=\"yes\" ?>", 
    #                         NoAttr => 1, 
    #                         KeyAttr => 1, 
    #                         RootName => "Network"
    #                         );

    # open (my $Outfile, ">$inpuFile") or die "ERROR *** Could not open $inpuFile: $!";
    # # $L_xml = $xs->XMLout($network, OutputFile => $OUTFILE);
    # $xs->XMLout($network, OutputFile => $Outfile);
    # close($Outfile);

    # print "XML File generated \n";
    return  $Line;
}

# ================================================================================
#     FUNCTION: FillTemplateFromDBC                                     
#     DESC:                                                                  
# ================================================================================

sub FillTemplateFromDBC
{

    # ### Input ###
    # my ($Network,$Physical_Can,$Message_ID,$RxTx,$InpuDataFile) = @_; 

    # ### Local Variables ####
    # my $lines;
    

    # ### Treatement ###
    # open (XML_FILE, ">$InpuDataFile") or die "ERROR *** Could not open $InpuDataFile: $!";
    # close(XML_FILE);
    # while ($lines = <XML_FILE>) 
    # {

    # }
    #  # =============================================
    # # DESC:Network generation
    # # =============================================
   


}
#===============================================================================
#
#===============================================================================
sub getCompName
{
   return "GeneDBC2Xml";
}
# ================================================================================
# FUNCTION: generateXML
# DESC: Generate XML files
# ================================================================================
sub generateXML
{
    ### Input Arguments ###
    my($Network, $Echo) = @_;

    ### Local Variables ####
    my $OutLineXml = "";
    ### Treatement ###
   
           # =============================================   
           # DESC: FRAMES & PARAMETTERS MESSAGE RECEIVERS
           # =============================================   
           # foreach my $Physical_Can (keys %{ $Network->{Network} })
           # {
           #    foreach my $Message_ID (sort keys %{$Network->{Network}{$Physical_Can}{"NetworkMessages"}{"Rx"}})
           #    {
           #       $OutLineXml = $OutLineXml.WriteXMLTemplateFile($Network,$Physical_Can,$Message_ID,"Rx");
           #    }
           # }
           
           # =============================================   
           # DESC: FRAMES & PARAMETTERS MESSAGE TRANSMITTER
           # =============================================
           foreach my $Physical_Can (keys %{ $Network->{Network} })
           {
              foreach my $Message_ID (sort keys %{$Network->{Network}{$Physical_Can}{"NetworkMessages"}{"Tx"}})
              {
                 $OutLineXml = $OutLineXml.WriteXMLTemplateFile($Network,$Physical_Can,$Message_ID,"Tx");
              }
           } 

            # =============================================   
            # DESC: SIGNALS PARAMETTERS DEF
            # =============================================

            my $xs = XML::Simple->new(XMLDecl => "<?xml version=\"1.0 \"encoding=\"UTF-8\" standalone=\"yes\" ?>", 
                                    NoAttr => 1, 
                                    KeyAttr => 1, 
                                    RootName => "Network"
                                    );

            open (my $OUTFILE, ">$TemplateFileEmpty") or die "ERROR *** Could not open $TemplateFileEmpty: $!";
            $xs->XMLout($OutLineXml, OutputFile => $OUTFILE);
            close($OUTFILE);
            print "COOOL";
            # =============================================   
            # DESC: SIGNALS PARAMETTERS DEF
            # =============================================

            # my $xs = XML::Simple->new(XMLDecl => "<?xml version=\"1.0 \"encoding=\"UTF-8\" standalone=\"yes\" ?>", 
            #                         NoAttr => 1, 
            #                         KeyAttr => 1, 
            #                         RootName => "Network"
            #                         );

            # open (my $OUTFILE, ">$TemplateDataFile") or die "ERROR *** Could not open $InpuDataFile: $!";
            # # $L_xml = $xs->XMLout($network, OutputFile => $OUTFILE);
            # $xs->XMLout($network, OutputFile => $OUTFILE);
            # close($OUTFILE);    

}
1;