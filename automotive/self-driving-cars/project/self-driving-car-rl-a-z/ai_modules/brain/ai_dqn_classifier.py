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
#   <settings> : local module 
#       - provides parameters calibrations for model tuning
#       - provides config parameters and constant for the App
# 

# File history :
# Afondiel  |  11.11.2022 | Creation 
# Afondiel  |  18.11.2022 | Last modification 

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
# Variable and Tensor already merged since the torch v0.4.x
# No need to convert tensor to variable no more 
from torch.autograd import Variable

import ai_settings
from ai_modules.brain.ai_model import Network 

# Implementing Deep Q-Network (DQN)

class ReplayMemory(object):
    """ experience replay for DQN reduce the correlation of sequence data  
        - stores past experiences in a memory : e(t) <- (a(t), s(t), a(t+1), r(t+1))
        - sample from it during the sample phase     
        - allows the network to avoid overfitting
        - batch-based (parallel approach) faster training time
        - reduces number of interactions with the env and variance of each training update 
    """
    def __init__(self, capacity):
        """ 
            - Creates a new class object and sets all internal variables
            - self : this object 
            - capacity : memory size
            - 100k elements for training purpose
        """
        self.capacity = capacity
        self.memory = []
    
    def push(self, event):
        """
            - add experience(element) in the memory
            - the memory is filled each the future state is detected
            - handles memory overflow
            - self : this object 
            - event : event/numbers of transition to be stored in the memory buffer
            - event contains four elements M(s, s', a, r)
        """
        self.memory.append(event)
        if len(self.memory) > self.capacity:
            del self.memory[0] # pop/del the old batch
    
    def sample(self, batch_size):
        """
            - return random sample from the memory
            - self : this object 
            - batch_size : number of samples (structure of each batch : state, action, reward)
        """
        # agregate the memory batch in a pair values (t and t - 1) 
        samples = zip(*random.sample(self.memory, batch_size))
        # convert the sample to torch variable => tensor + gradient
        # concatanate to get the actions aligned with each state
        return map(lambda x: Variable(torch.cat(x, 0)), samples)


# Implementing Deep Q Learning

class Dqn():
    """ Deep Q-Learning algorithm 
    - action selection 
    - fit the algorithm
    - update the DQN
    - compute the score
    - save the model
    - load the model for future inferences
    """
    def __init__(self, input_size, nb_action, gamma):
        """ Creates a new model object and sets all internal variables 
        - input_size : number of input signals (states)
        - nb_action : number output layers/nodes (actions)
        - gamma : the discount factor
        - reward_window : slide window (number of sample reward to be observed)
        - model : network object
        - memory : memory object with 100k size/capacity
        - optimizer : gradient descent : adam function
        - last_state : last state of the system 
        - last_action : last action of the system
        - last_reward : last reward of the system       
        """
        self.gamma = gamma
        self.reward_window = []
        self.model = Network(input_size, nb_action)
        self.memory_obj = ReplayMemory(ai_settings.REPLAY_MEMORY_CAPACITY)
        self.optimizer = optim.Adam(self.model.parameters(), lr = 0.001)
        # Tensors on torch scale - scalar: 0D >> vector/signal: 1D >> matrice: 2D >> tensor: greater than 2D) 
        self.last_state = torch.Tensor(input_size).unsqueeze(0)
        self.last_action = 0
        self.last_reward = 0
    
    def select_action(self, state):
        """ returns the best action each time
        - applies the right direction : left, right, straight
        - avoid obstacles to reach the goal
        - softmax to play the final action
        - softmax provides the probability distribution of the q-values (q-left, q-right,q-straight)
        - self : this object
        - state: input state of the NN 
        """
        with torch.no_grad():
            # old statement from <v0.4 : probs = F.softmax(self.model(Variable(state, volatile = True))*100) # T=100 
            # solve: Variable and Tensor are merged since torch v0.4
            # state is tensor is wrapper into Variable, no gradient used in the computation
            # temperature set to max => model confidence set to max too!!! 
            probs = F.softmax(self.model(Variable(state))*ai_settings.TEMPERATURE_PARAM) 
            action = probs.multinomial(num_samples=1)   # generates random draws from probabilities
            return action.data[0,0]
    
    def learn(self, batch_state, batch_next_state, batch_reward, batch_action):
        """ fits the model + implements q-learning function
        - takes the transition function (M[s,a,r, s'] => MDP model) fromm batch memory
        - M[s,a,r, s'] formula is described in p8 of course
        - self : this object
        - batch_state : batch of current state
        - batch_next_state : batch of next state
        - batch_reward :  batch of reward
        - batch_action : batch of current action
        """
        # squeeze kills the fake batch values casts them into simple vector of 1D for output
        outputs      = self.model(batch_state).gather(1, batch_action.unsqueeze(1)).squeeze(1)
        # retrive the max q-value=action based on next state
        next_outputs = self.model(batch_next_state).detach().max(1)[0]
        target       = self.gamma*next_outputs + batch_reward
        td_loss      = F.smooth_l1_loss(outputs, target)
        # optimizer init with zero in beginning every of iteration
        self.optimizer.zero_grad()
        # td_loss.backward(retain_variables = True) #issue in the torch 1.13.0
        # backpropagation with gradient descent
        td_loss.backward(retain_graph = True)
        # update the input weights
        self.optimizer.step()
    
    def update(self, reward, new_signal):
        """ update the DQN parameters and return the action when reaching a new state 
        - reward : last reward
        - new_signal : list of input states/signals
        """
        # get the new state
        new_state = torch.Tensor(new_signal).float().unsqueeze(0)
        # print("$$$ DEBUG NEW STATE: ", new_state) #@TODO create a log file
        # fill the memory
        self.memory_obj.push((self.last_state, new_state, torch.LongTensor([int(self.last_action)]), torch.Tensor([self.last_reward])))
        action = self.select_action(new_state)
        if len(self.memory_obj.memory) > 100:
            # get the new transition Matrix
            batch_state, batch_next_state, batch_action, batch_reward = self.memory_obj.sample(100)
            # refitting the model with new values
            self.learn(batch_state, batch_next_state, batch_reward, batch_action)
        # else
        self.last_action = action
        self.last_state  = new_state
        self.last_reward = reward
        self.reward_window.append(reward)
        # Moving average of reward ?
        if len(self.reward_window) > 1000:
            del self.reward_window[0]
        return action
    
    def score(self):
        """ returns the score """
        return sum(self.reward_window)/(len(self.reward_window)+1.)  # +1 to avoid divising by zero
    
    def save(self):
        """ save the model """
        torch.save({'state_dict': self.model.state_dict(),
                    'optimizer' : self.optimizer.state_dict(),
                   }, 'last_brain.pth')
    
    def load(self):
        """" load the model """
        if os.path.isfile('last_brain.pth'):
            print("=> loading checkpoint... ")
            checkpoint = torch.load('last_brain.pth')
            self.model.load_state_dict(checkpoint['state_dict'])
            self.optimizer.load_state_dict(checkpoint['optimizer'])
            print("done !")
        else:
            print("no checkpoint found...")