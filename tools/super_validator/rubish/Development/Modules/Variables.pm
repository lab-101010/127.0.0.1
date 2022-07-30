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
use Cwd qw(cwd getcwd);
use Getopt::Long qw(GetOptions);
Getopt::Long::Configure qw(gnu_getopt);
use File::Basename;
use XML::Simple qw(:strict);
use Data::Dumper;
use lib dirname(__FILE__);
# ================================================================================
#    GLOBAL VARIABLES DECLARATION                                           
# ================================================================================
our $G_MainScriptPath      = dirname(__FILE__);
our $G_ConfigFile          = "$G_MainScriptPath\\CanNetworkCfg.ini";
our @EXPORT = qw($G_ConfigFile );
our $G_templateFileEmpty   = "$G_MainScriptPath\\TemplateFile.xml";
our $G_templateDataFile    = "$G_MainScriptPath\\TemplateDataFile.xml";
my $returnval = `echo %cd%`;




#------------------- EOL ----------------------------#
1;