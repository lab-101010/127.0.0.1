# File : main.py 
# Description : launch the main application 
#
# Libraries requirements : 
#   <os> : standard library
#		- Provides a portable way of using operating system dependent functionality.
#   <sys> : standard library
#		- provides access to some variables used or maintained by the interpreter and 
#         to functions that interact strongly with the interpreter.
#   <random> : standard library
#		- Random variables generators
#   <numpy> : standard library
#		- Provides multidimensional arrays and linear algebra tools, optimized for speed
#   <torch> : Deep learning library
#		- Provides data structures for multi-dimensional tensors and defines mathematical operations over these tensors
#       - provides also many utilities for efficient serializing of Tensors and arbitrary types, and other useful utilities.
#       - It has a CUDA counterpart, that enables you to run your tensor computations on an NVIDIA GPU with compute capability >= 3.0.
#

# File history :
# Afondiel  |  11.11.2022 | Creation 
# Afondiel  |  11.14.2022 | Last modification 

import os
import sys
import time
import random
import logging
# kivy pkg to run the app
from kivy.app import App


from ai_modules.environment.car_map import CarApp

""" 
Main module
    - runs the App
"""
# include file access outside src package
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

if __name__ == '__main__' :
    """ initializes App object and runs it"""
    # starting the app
    print("engine on ... ")

    # creating the car_app object
    car_app = CarApp()

    # running the app
    car_app.run()

    # leaving the Chat
    print("engine off ...")

