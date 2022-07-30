# @author Afonso DIELA 
# @date 25/05/2022


import sys
import re
import os
from os import walk


def extract_include_files(filename):
    """
        @brief :
        @details
        @param 
    """
    incl_files = ''
    # pass
    include_file_pattern = "^#incl.*?[h\"h>]$(\r?\n)"
    with open(filename, 'r') as c_file:
        for idx, line in enumerate(c_file.readlines()): # lines and save as a list
            # print(line)
            res = re.match(include_file_pattern, line)
            if res:
                incl_files += str(line)
    # print(incl_files)
    return incl_files

def extract_header_files():
    """
        @brief :
        @details
        @param 
    """
    pass 
    
def extract_sources_files(modulename):
    """
        @brief :
        @details
        @param 
    """
    src_files = []
    src_path_f = root_folder_path + modulename + '\\Source\\'
    src_files = next(walk(src_path_f), (None, None, []))[2]  # [] if no filesrc_files.append('')
    return src_files 

def extract_header_funtions():
    """
        @brief :
        @details
        @param 
    """
    pass 


# super main
if __name__ == '__main__':
    """
    If the user passes too few or too much params, it ignores execution.
    """
    print('Start \'Super Parseur\' ...\n')
    

    if(len(sys.argv) == 2):
        
        # Root/target folder SHALL be passed in absolute path
        # ex : root_folder_path = 'C:\svn\DEVREPO\ECU\SRC14-34_31\M2\Build\WORK\Function\\'
        root_folder_path = sys.argv[1]

        # This a sub-folder/ specific folder
        src_path_test = root_path + sys.argv[1] + '\\Source\\'

        src_path_f = ''

        mod_header_file_name = []
        # header file to retrieve
        mod_pattern = "^[a-zA-Z].*h$(\r?\n)"
        # pattern to extract function header
        # x_file_pattern = "^extern|static|void|uint8|int8|uint16|uint16.*$(\r?\n)"
        x_file_pattern = "^(uds|static|void|bool|uint8|int8|uint16|uint16).*?[){]$(\r?\n)"

        # new_file_line = ""
        new_file = sys.argv[1] + '_headers' + '.txt'

        # clean file
        f  = open(new_file, 'w')
        f.close()

        # get all the files from the module : mod_name_dic[key]
        list_src_path = extract_sources_files(sys.argv[1])

        for _f in list_src_path: 
            # concatenate file path + extracted name 
            new_src_path_f = src_path_test + _f
            _file  = open(new_file, 'a')
            _file.write(str(str('#'*50) +'\n' + 'Functions from file : ' + str(_f) +'\n' + str('#'*50) +'\n'))
            # add include files
            _file.write(extract_include_files(new_src_path_f))
            _file.close()
            with open(new_src_path_f, 'r') as x_files:
                for idx, line in enumerate(x_files.readlines()):
                    # print(line)
                    res = re.match(x_file_pattern, line)
                    if res:
                        # print(line)
                        # Write the new line (after cleaning) into the new file
                        with open(new_file, 'a') as new_x_file:
                            new_x_file.write(str(line))

    else:
        print("Usage:")
        print("python3 main.py [root_folder_path] ")

