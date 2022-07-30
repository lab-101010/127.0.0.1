#!/usr/bin/perl
#=================================================================================
# ==                                                                            ==
# == !File              : GeneCapl.pm                                           ==
# == !Coding language   : Perl                                                  ==
# == !Description       : create Capl file to be use by CANoe 			        ==
#							      												==
# ================================================================================
# == Historic :                                                                 ==
# == 27/02/18   : Creation (aDiela )                                            ==
# ==                                                                            ==
# ==                                                                            ==
# ==                                                                            ==
# ================================================================================
#                START PERL HEADER                                            
# ================================================================================
package GeneCapl;

use strict;
use warnings;
use Encode qw(encode decode);

# set autoflush
# local $| = 1;

# use Exporter;
# use vars qw(@ISA @EXPORT @EXPORT_OK $VERSION);

# @ISA = qw/ Exporter /;
# @EXPORT = qw(getcompName generate);
# @EXPORT_OK = qw(getcompName generate);
#my $G_CAPLfileModuleName = "$G_MainScriptPath\\ECU_CANoe_VF_C_CAN_Module.can";

#
#===============================================================================
#
#===============================================================================
sub getCompName
{
   return "GeneCapl";
}
# ================================================================================
#     FUNCTION: WriteCAPLCfgFromXML                                        
#     DESC:                                                                  
# ================================================================================
#Exemples : http://search.cpan.org/~grantm/XML-Simple-2.24/lib/XML/Simple.pm
sub WriteCAPLCfgFromXML
{

	 # Collect the -i and -o options from the command line.
        #my %opts;
 #    # The colons specify that the preceeding flags take
 #    # arguments (file names in this case)
 #    getopts('i:o:', %opts);
    
 #    # Check we got the flags and arguments we need.
 #    unless($opts{'i'} and $opts{'o'}) {
 #        die usage();
 #    }
    
 #    # Now we've got the input and output file names.
 #    my $input = $opts{'i'};
 #    my $output = $opts{'o'};
    
 #    # Try to open the input file.
 #    unless(open INPUT, $input) {
 #        die "\nUnable to open '$input'\n";
 #    }
    
 #    # Try to create the output file
 #    # (open it for writing)
 #    unless(open OUTPUT, '>'.$output) {
 #        die "\nUnable to create '$output'\n";
 #    }
    
 #    # Read one line at a time from the input file
 #    # till we've read them all.
 #    while(my $line = <INPUT>) {
    
 #        # Change dog to cat
 #        $line =~ s/dog/cat/ig;
        
 #        # Write the line to the output file.
 #        print OUTPUT $line;
        
 #        # Print a progress indicator.
 #        print '.';
 #    }
    
 #    # Close the files.
 #    close INPUT;
 #    close OUTPUT;


}


1;