# ai.py : the brain module of the car
# Description : AI for Self Driving Car
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

# File history :
# Afondiel  |  11.11.2022 | Last modification 

# Importing the libraries
import os
import sys
import random
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import torch.autograd as autograd
from torch.autograd import Variable

import ai_settings
from module.ai_model import Network 

# Implementing Deep Q-Network (DQN)

class ReplayMemory(object):
    """ experience replay fo DQN reduce the correlation of sequence data  
        - stores past experiences in a memory : e(t) <- (a(t), s(t), a(t+1), r(t+1))
        - sample from it during the sample phase     
        - allows the network to avoid overfitting 
        - allows the network to avoid overfitting
        - batch-based (parallel approach) faster training time 
    """
    def __init__(self, capacity):
        """ 
            - Creates a new class object and sets all internal variables
            - self : this object 
            - capacity : capacity of the memory ?
        """
        self.capacity = capacity
        self.memory = []
    
    def push(self, event):
        """
            - add experience(element) in the memory
            - self : this object 
            - event : experience to be stored in the memory
        """
        self.memory.append(event)
        if len(self.memory) > self.capacity:
            del self.memory[0] # pop/del the old batch
    
    def sample(self, batch_size):
        """
            - return map
            - self : this object 
            - batch_size : 
        """
        samples = zip(*random.sample(self.memory, batch_size))
        return map(lambda x: Variable(torch.cat(x, 0)), samples)

# Implementing Deep Q Learning

class Dqn():
    """ Deep Q Learning class """
    def __init__(self, input_size, hidden_size, nb_action, gamma):
        """ Creates a new class object and sets all internal variables """
        self.gamma = gamma
        self.reward_window = []
        self.model = Network(input_size, hidden_size, nb_action)
        self.memory = ReplayMemory(100000)
        self.optimizer = optim.Adam(self.model.parameters(), lr = 0.001)
        self.last_state = torch.Tensor(input_size).unsqueeze(0)
        self.last_action = 0
        self.last_reward = 0
    
    def select_action(self, state):
        probs = F.softmax(self.model(Variable(state, volatile = True))*100) # T=100
        action = probs.multinomial()
        return action.data[0,0]
    
    def learn(self, batch_state, batch_next_state, batch_reward, batch_action):
        outputs = self.model(batch_state).gather(1, batch_action.unsqueeze(1)).squeeze(1)
        next_outputs = self.model(batch_next_state).detach().max(1)[0]
        target = self.gamma*next_outputs + batch_reward
        td_loss = F.smooth_l1_loss(outputs, target)
        self.optimizer.zero_grad()
        td_loss.backward(retain_variables = True)
        self.optimizer.step()
    
    def update(self, reward, new_signal):
        new_state = torch.Tensor(new_signal).float().unsqueeze(0)
        self.memory.push((self.last_state, new_state, torch.LongTensor([int(self.last_action)]), torch.Tensor([self.last_reward])))
        action = self.select_action(new_state)
        if len(self.memory.memory) > 100:
            batch_state, batch_next_state, batch_action, batch_reward = self.memory.sample(100)
            self.learn(batch_state, batch_next_state, batch_reward, batch_action)
        self.last_action = action
        self.last_state = new_state
        self.last_reward = reward
        self.reward_window.append(reward)
        if len(self.reward_window) > 1000:
            del self.reward_window[0]
        return action
    
    def score(self):
        return sum(self.reward_window)/(len(self.reward_window)+1.)
    
    def save(self):
        torch.save({'state_dict': self.model.state_dict(),
                    'optimizer' : self.optimizer.state_dict(),
                   }, 'last_brain.pth')
    
    def load(self):
        if os.path.isfile('last_brain.pth'):
            print("=> loading checkpoint... ")
            checkpoint = torch.load('last_brain.pth')
            self.model.load_state_dict(checkpoint['state_dict'])
            self.optimizer.load_state_dict(checkpoint['optimizer'])
            print("done !")
        else:
            print("no checkpoint found...")