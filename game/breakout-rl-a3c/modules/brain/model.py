# File : model.py 
# Description : AI for Breakout

# Importing the librairies
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F

# Initializing and setting the variance of a tensor of weights

def normalized_columns_initializer(weights, std=1.0):
    """ return & Initializes and sets the variance of a tensor of weights
    - weight : weights values following a Normal distribution
    - std (standard deviation) : we want to set a different std for both actor (small:0.01) & critic weights(big:1.0) 

    """
    # Normal distribuition
    # variance = std^2 = 1/N * Sum(X - µ )^2 => 1/N  = std^2/Sum(X - µ )^2
    # create a random tensor of weight with same size as the input weight
    out = torch.randn(weights.size())
    # sqrt normalization
    out *= std / torch.sqrt(out.pow(2).sum(1).expand_as(out)) # var(out) = std^2
    return out

# Initializing the weights of the neural network in an optimal way for the learning
def weights_init(m):
    """ Initializes the weights of the neural network in an optimal way for the learning
    m : inheritance from class m which the new nn
    """
    classname = m.__class__.__name__
    # if the connection is a conv nn
    if classname.find('Conv') != -1:
        weight_shape = list(m.weight.data.size())
        fan_in  = np.prod(weight_shape[1:4])                    # dim1*dim2*dim3
        fan_out = np.prod(weight_shape[2:4]) * weight_shape[0]  # dim0*dim2*dim3
        w_bound = np.sqrt(6. / (fan_in + fan_out))
        m.weight.data.uniform_(-w_bound, w_bound)
        m.bias.data.fill_(0)
    # if the connection is a fully connected nn
    elif classname.find('Linear') != -1:
        weight_shape = list(m.weight.data.size())
        fan_in  = weight_shape[1]
        fan_out = weight_shape[0]
        w_bound = np.sqrt(6. / (fan_in + fan_out))
        m.weight.data.uniform_(-w_bound, w_bound)
        m.bias.data.fill_(0)

# Making the A3C brain

class ActorCritic(torch.nn.Module):
    """ This model combines the linear NN & CNN & RNN (LSTM : replace replay memory ? ) & controlled by A3C algo
    - torch.nn.Module : inheritance for ActorCritic class
    - 1 layer for Actor
    - 1 layer for Critic
    """

    def __init__(self, num_inputs, action_space):
        """
        - self : this object
        - num_inputs : nb of inputs
        - action_space : nb of actions 
        """
        super(ActorCritic, self).__init__()
        # 4 conv input layer
        self.conv1 = nn.Conv2d(num_inputs, 32, 3, stride=2, padding=1)
        self.conv2 = nn.Conv2d(32, 32, 3, stride=2, padding=1)
        self.conv3 = nn.Conv2d(32, 32, 3, stride=2, padding=1)
        self.conv4 = nn.Conv2d(32, 32, 3, stride=2, padding=1)
        # LSTM NN cell object
        self.lstm = nn.LSTMCell(32 * 3 * 3, 256)
        # n : number of actions
        num_outputs = action_space.n
        # critic object
        self.critic_linear = nn.Linear(256, 1)
        # actor object
        self.actor_linear  = nn.Linear(256, num_outputs)
        # apply init weights function
        self.apply(weights_init)
        self.actor_linear.weight.data = normalized_columns_initializer(self.actor_linear.weight.data, ai_settings.INIT_STD_ACTOR)
        self.actor_linear.bias.data.fill_(0)
        self.critic_linear.weight.data = normalized_columns_initializer(self.critic_linear.weight.data, ai_settings.INIT_STD_CRITIC)
        self.critic_linear.bias.data.fill_(0)
        self.lstm.bias_ih.data.fill_(0)
        self.lstm.bias_hh.data.fill_(0)
        # fitting 
        self.train()

    def forward(self, inputs):
        """ returns a tuple of the propagated outputs for actor & critic & lstm output tuple
        - self : this object
        - inputs : input values 
        - use elu (exponential linear unit) as activation function
        """
        # split input values as tuple of input images, hidden nodes(hx) & cells state of lstm(cx)
        inputs, (hx, cx) = inputs
        x = F.elu(self.conv1(inputs))
        x = F.elu(self.conv2(x))
        x = F.elu(self.conv3(x))
        x = F.elu(self.conv4(x))
        # flattening
        x = x.view(-1, 32 * 3 * 3)
        # hidden layer & cell for lstm
        hx, cx = self.lstm(x, (hx, cx))
        x = hx
        return self.critic_linear(x), self.actor_linear(x), (hx, cx)
