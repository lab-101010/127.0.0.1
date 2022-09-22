import os
import sys
import re


new_file_line = ""
# Add full path of the file that containt the pattern to extract  
file_path_read="..."
# Add path of new file to write the final result
new_file_write="..."

# where "DATA_RECORD_SIZE" the pattern to match
pattern = "^.*DATA_RECORD_SIZE.*$(\r?\n)"

# super main
if __name__ == '__main__':

    with open(file_path_read, 'r') as file_appl:
        for line in file_appl.readlines():
            new_file_line = line
            # print(line)
            res = re.sub(pattern,"", new_file_line)
            with open(new_file_write, 'a') as new_file_appl:
                # res += '\n'
                new_file_appl.write(res)
                # print(line, end='')
