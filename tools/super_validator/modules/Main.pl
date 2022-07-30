#!/usr/bin/perl
#=================================================================================
# ==                                                                            ==
# == !File              : Main.pl                                               ==
# == !Coding language   : Perl                                                  ==
# == !Description       : create a CAPL module inteded to validate the Comm     ==
# ==                      stack FlexRay/CAN for the projet INV                  ==
# ================================================================================
# == Historic :                                                                 ==
# == 27/02/18   : Creation (aDiela )                                            ==
#  ==                                                                           ==
#  ==                                                                           ==
#  ==                                                                           ==
# ================================================================================
#                START PERL HEADER                                            
# ================================================================================
use strict;
use warnings;
# ================================================================================
#    START PERL MODULE DECLARATION                                         
# ================================================================================
use Cwd;
use Cwd qw(abs_path);
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);
use File::Basename;
use XML::Simple qw(:strict);
use Data::Dumper;
use lib dirname(__FILE__);
# ================================================================================
#     START PERL LOCAL MODULE DECLARATION                                     
# ================================================================================

######
# Includes Module
######
use Modules::ConfDBC;
use Modules::GeneDBC2Xml;
use Modules::GeneCapl;
use Modules::Variables;
my %G_HashModuleList  = (
   "GeneDBC2Xml" => 0, 
   "GeneCapl"    => 0,
);
#
# ================================================================================
#     START GLOBALS VARIABLES CALL                                    
# ================================================================================
#
my $G_ConfigFile          = "CanNetworkCfg.ini";
my $G_templateFileEmpty   = "TemplateFile.xml";          #@TODO : remplancer le nom du fichier par le nom de la DBC
my $G_DBCToXmlFile        = "TemplateDataFile.xml";
my $G_CAPLFile            = "CAPLFileName.can";     
my $G_Verbose;
my %G_ConfigParameters;
my $G_Echo                 = 0; 
my $G_Network;
my $returnval = `echo %cd%`;
# print STDOUT "$G_MainScriptPath\n";
# print STDOUT "$test\n";
# print STDOUT "$G_ModuleDIRPath\n"
# ================================================================================
#                            SUBROUTINES CALL                                
# ================================================================================
# == 
# == !MAIN Treatement! 
# ==
# ================================================================================
#
# Read command line arguments (from command line)
#
ManageOption();
#
#Consolidations of all the Variables 
# 
VariablesConsolidation();
#
# Create Network instance
#
$G_Network = NewInstance($G_Echo, $G_ConfigFile);
#print Dumper ($G_Network);
#
#CallModules
#
CallModules(%G_HashModuleList, $G_Network, $G_Echo, $G_DBCToXmlFile, $G_CAPLFile);
#
#

# ================================================================================
#                        START SUBROUTINES                                   
# ================================================================================
#
#
#
#
# ================================================================================
# FUNCTION: VariablesConsolidation                                       
# DESC:                                                                  
# ================================================================================
sub VariablesConsolidation
{
  #my $L_ConfigFile = shift;

   print STDOUT"\n=====================================================================\n" ;#if ($G_Verbose);
   print STDOUT"====================== PROJECT DETAILS ==============================\n" ; #if ($G_Verbose);
   print STDOUT"=====================================================================\n\n"; # if ($G_Verbose);

   #=================================================================
   ###     Test the configuration file ###
   #=================================================================
   if (($G_ConfigFile) and (-f $G_ConfigFile) and ($G_ConfigFile =~ /.*\.ini$/i))
   {
      print STDOUT "INFOS --- Configuration File: \n\t ->$G_ConfigFile\n"; #if ($G_Verbose);
   }
   else 
   {
      DisplayHelp("ERROR *** Configuration File Not Found!\n\n");
   }
   #=================================================================
   ###     Test the XML file ###
   #=================================================================
   if (($G_DBCToXmlFile) and (-f $G_DBCToXmlFile) and ($G_DBCToXmlFile =~ /.*\.xml$/i))
   {
      print STDOUT "INFOS --- XML File: \n\t ->$G_DBCToXmlFile\n"; #if ($G_Verbose);
   }
   else 
   {
      DisplayHelp("ERROR *** XML File Not Found!\n\n");
   }
   #=================================================================
   ###     Test the CAPL file ###
   #=================================================================
   if (($G_CAPLFile) and (-f $G_CAPLFile) and ($G_CAPLFile =~ /.*\.can$/i))
   {
      print STDOUT "INFOS --- CAPL File: \n\t ->$G_CAPLFile\n"; #if ($G_Verbose);
   }
   else 
   {
      DisplayHelp("ERROR *** CAPL File Not Found!\n\n");
   }
   
   ###DisplayHelp(); 
}
#=================================================================
# FUNCTION: NewInstance
# DESC: 
#=================================================================
sub NewInstance
{
   ### Input parameters ###
   my ($Echo, $ConfigFile) = @_;

   ### Internal variables ###
   
   my $Network = ConfDBC->new($Echo, $ConfigFile); 
   ### Treatement ###
   if (defined $Network)
   {
      print STDOUT "Object created\n";
   }
   else
   {
      DisplayHelp("ERROR *** Can't create object Network : $Network ***\n\n");
   }

   # Create Log file if required 
   print $Network->getLog() if (defined $Network && $Echo == 1);

   return $Network;
}
# =============================================
# FUNCTION: ManageOption
# DESC: Manage specified options
# =============================================
sub ManageOption
{
   ### Input parameters ###
   ### Internal variables ###
   my $Help;
   my $Verbose;
   my $ConfigFile;
   my $DBCToXmlFile;
   my $CAPLFile;
   ##my $ProgramName = basename($0);

   ### Treatement ###
   GetOptions(
      'input|i=s'  =>\$ConfigFile,
      'xml|x=s'    =>\$DBCToXmlFile,
      'output|o=s' =>\$CAPLFile,
      'V|v'        =>\$Verbose,
      'h|?|helps'  =>\$Help,
   ) or die "Usage: perl.exe ProgramName [][--help][--files \"file1 file2 ...\"] \n"; 
#or die "Usage: perl.exe $ProgramName [][--help][--files \"file1 file2 ...\"] \n"; 

   DisplayHelp("\t\nHelp Description!\n") if $Help; 

   #### Read Argument and Parameters  ####
   #=================================================================
   # Get the configuration file name
   #=================================================================

   if (($ConfigFile) and (-f $ConfigFile) and ($ConfigFile =~ /^.*\.ini$/))
   {
      $G_ConfigFile = $ConfigFile;
   }

   #=================================================================
   # Get the XML file name
   #=================================================================
    if (($DBCToXmlFile) and (-f $DBCToXmlFile) and ($DBCToXmlFile =~ /^.*\.xml$/))
   {
      $G_DBCToXmlFile = $DBCToXmlFile;
      $G_HashModuleList{GeneDBC2Xml}=1;
   }
   #=================================================================
   # Get the CAPL file name
   #=================================================================
   if (($CAPLFile) and (-f $CAPLFile) and ($CAPLFile =~ /^.*\.can$/))
   {
      $G_CAPLFile = $CAPLFile;
      $G_HashModuleList{GeneCapl}=2;
   }
   #=================================================================
   # Get verbose 
   #=================================================================
   if ($Verbose)
    {
      $G_Verbose = $Verbose;
    }

}

#=================================================================
# FUNCTION: CallModules
# DESC: 
#=================================================================
sub CallModules
{
   ### Input parameters ###
   my (%HashModuleList, $Network, $Echo, $DBCToXmlFile, $CAPLFile) = @_;
   ### Internal variables ###

   ### Treatement ###
   #Manage components to call 
   foreach my $mod (keys %HashModuleList)
   {
      if ($HashModuleList{$mod} == 1) 
      {
         print STDOUT "Bienvenu au module XML\n";
         my $call1 = $mod."::getCompName";
         my $call2 = $mod."::generateXML";
         
         my $CompCalled = &$call1();
         print "Component Called : $CompCalled with configuration $G_ConfigFile file\n";
         &$call2($Network,$Echo);
      }
       if ($HashModuleList{$mod} == 2) 
      {
         print STDOUT "Bienvenu au module GeneCapl\n";
         my $call1 = $mod."::getCompName";
         my $call2 = $mod."::generateCapl";
         
         my $CompCalled = &$call1();
         print "Component Called : $CompCalled with configuration $G_ConfigFile file\n";
         &$call2($Network,$Echo);
      }
   }

   print STDOUT "SUCCESS!\n";
   exit(0);
}
#=================================================================
# FUNCTION: DisplayHelp
# DESC: Display ConvertEnvProj synopsys
#=================================================================
sub DisplayHelp
{
   #Input Arguments
   my $helpContent = shift;
   
   #Treatment
   $helpContent .=  "\n======================================================================\n";
   $helpContent .=  "============          ==       HELP        ==      ===================\n";
   $helpContent .=  "======================================================================\n";
   $helpContent .=  "=                                                                    =\n";
   $helpContent .=  "=                             (__)                                   =\n";
   $helpContent .=  "=                             (oo)                                   =\n";
   $helpContent .=  "=                    /---------\\/                                    =\n";
   $helpContent .=  "=                   /|    |   ||                                     =\n";
   $helpContent .=  "=                  * |__|-----||                                     =\n";
   $helpContent .=  "=                     ||      ||                                     =\n";
   $helpContent .=  "=                                                                    =\n";
   $helpContent .=  "=    This SOFTWARE tool was built in order to validate               =\n"; 
   $helpContent .=  "=    the specification of CAN and FlexRay communication              =\n"; 
   $helpContent .=  "=    intarface of BSW for the project 'inverter eRAD PSA'            =\n"; 
   $helpContent .=  "=                                                                    =\n"; 
   $helpContent .=  "=                                                                    =\n"; 
   $helpContent .=  "=                                                                    =\n"; 
   $helpContent .=  "=                                                                    =\n";
   $helpContent .=  "=  Usage:                                                            =\n"; 
   $helpContent .=  "=                                                                    =\n"; 
   $helpContent .=  "=  Before using the tool, copy the config.ini beside your            =\n"; 
   $helpContent .=  "=  SRC directory and edit it.                                        =\n"; 
   $helpContent .=  "=                                                                    =\n"; 
   $helpContent .=  "=  Exemple Of Use:                                                   =\n";  
   $helpContent .=  "=  => To generate only the DBCfileName.XML:                          =\n";  
   $helpContent .=  "=  \>AutocommValid.exe [-i configFileName.ini] [-x DBCName.xml ]      =\n";
   $helpContent .=  "=  => To generate the configFile.can                                 =\n";
   $helpContent .=  "=  \>AutocommValid.exe [-i configFileName.ini] [-o CAPLFileName.can ] =\n"; 
   $helpContent .=  "=  ==> This option will generate the DCB.xml File automatically      =\n"; 
   $helpContent .=  "=                                                                    =\n"; 
   $helpContent .=  "=                                                                    =\n"; 
   $helpContent .=  "=  List of arguments                                                 =\n";
   $helpContent .=  "=  -i // --input  : ConfigFile.ini                                   =\n";
   $helpContent .=  "=  -x // --output : DBCName.XML                                      =\n";
   $helpContent .=  "=  -o // --output : CAPLFile.can                                     =\n";
   $helpContent .=  "=  -h // --help // -? : Help ?                                       =\n";
   $helpContent .=  "=  -v // --verbose    : Hide the addictional informations of         =\n"; 
   $helpContent .=  "=                       the projet in CMD                            =\n";   
   $helpContent .=  "=                                                                    =\n";
   $helpContent .=  "======================================================================\n\n";

   print STDOUT $helpContent;

  exit;
}




