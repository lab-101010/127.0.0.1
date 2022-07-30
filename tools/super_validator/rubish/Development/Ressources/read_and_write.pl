# Always define these two at the tops of
# your scripts.
use strict;
use warnings; 

# This turns off output buffering.
# Useful for real-time display of
# progress or error messages.
$|=1;

# This is for getting command-line options.
# Could alternatively use @ARGV instead.
use Getopt::Std;

# Return a usage message. Usually we'd indent the
# contents of a subroutine, but here we can't since
# that would affect the usage message.
sub usage {
return q|

usage:
    process.pl -i <input file> -o <output file>
    
Reads all lines in <input file>, changes all occurences of
'dog' to 'cat' and writes the results to <output file>.

<input file> itself is not changed.

|;
}

sub main {
    # Collect the -i and -o options from the command line.
    my %opts;
    
    # The colons specify that the preceeding flags take
    # arguments (file names in this case)
    getopts('i:o:', %opts);
    
    # Check we got the flags and arguments we need.
    unless($opts{'i'} and $opts{'o'}) {
        die usage();
    }
    
    # Now we've got the input and output file names.
    my $input = $opts{'i'};
    my $output = $opts{'o'};
    
    # Try to open the input file.
    unless(open INPUT, $input) {
        die "\nUnable to open '$input'\n";
    }
    
    # Try to create the output file
    # (open it for writing)
    unless(open OUTPUT, '>'.$output) {
        die "\nUnable to create '$output'\n";
    }
    
    # Read one line at a time from the input file
    # till we've read them all.
    while(my $line = <INPUT>) {
    
        # Change dog to cat
        $line =~ s/dog/cat/ig;
        
        # Write the line to the output file.
        print OUTPUT $line;
        
        # Print a progress indicator.
        print '.';
    }
    
    # Close the files.
    close INPUT;
    close OUTPUT;
    
}

main();

