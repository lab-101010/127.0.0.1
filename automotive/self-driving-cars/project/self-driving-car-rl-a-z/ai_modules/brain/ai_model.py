# ai_model.py : deep learning model (DFF) 
# Description : AI deep feed forward (DFF) model 
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
#   <settings> : local module 
#       - provides parameters calibrations for model tuning
#       - provides config parameters and constant for the App

# File history :
# Afondiel  |  11.11.2022 | Creation 
# Afondiel  |  15.11.2022 | Last modification 

# Importing the libraries
import os
import sys
import random
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
# Variable and Tensor already merged since the torch v0.4.x
# No need to convert tensor to variable no more 
import torch.autograd as autograd
from torch.autograd import Variable

import ai_settings

# Neural Network architecture

class Network(nn.Module):
    """ Deep Feed Forward (DFF) Neural Network """
    def __init__(self, input_size, hidden_size, nb_action):
        """object constructor
        - self: this object
        - input_size : inputs layers (5 nodes : 3 sensor signals, +orientation, -orientation)
        - hidden_size : hidden layer (30 nodes)
        - nb_action : output layer (3 signals : left, straight, right )
        """
        super(Network, self).__init__()
        self.input_size = input_size
        self.nb_action  = nb_action
        self.fc1        = nn.Linear(input_size, hidden_size)
        self.fc2        = nn.Linear(hidden_size, nb_action)
        # activation function
        self.activation = nn.ReLU()
    
    def forward(self, state):
        # x = F.relu(self.fc1(state))
        x        = self.fc1(state)
        _x       = self.activation(x)
        q_values = self.fc2(_x)
        return q_values
