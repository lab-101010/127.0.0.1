# File : train.py
# Description : Training the AI

import torch
import torch.nn.functional as F
from environment.envs import create_atari_env
from brain.model import ActorCritic
from torch.autograd import Variable
# Variable and Tensor already merged since the torch v0.4.x
# No need to convert tensor to variable no more 

def ensure_shared_grads(model, shared_model):
    """
    - self : this object
    - shared_model : what the agent will get during the exploration
    """
    for param, shared_param in zip(model.parameters(), shared_model.parameters()):
        if shared_param.grad is not None:
            return
        shared_param._grad = param.grad

def train(rank, params, shared_model, optimizer):
    """ returns the training model
    - rank : shift the seed. Allows the number of seeds to be different for each thread
    - params :  number of agents ? 
    - shared_model : what the agent will get during the exploration
    - optimizer : the optmizer
    """
    # generating a seed
    torch.manual_seed(params.seed + rank)
    # create the environment
    env = create_atari_env(params.env_name)
    # each agent will have its own environment
    env.seed(params.seed + rank)
    # model/brain object
    model = ActorCritic(env.observation_space.shape[0], env.action_space)
    state = env.reset()
    # converting state to tensor
    state = torch.from_numpy(state)
    done = True
    """episode : each of the repeated attempts by the agent to learn an environment"""
    episode_length = 0
    # training loop
    while True:
        # step by step increment
        episode_length += 1
        model.load_state_dict(shared_model.state_dict())
        # if game over
        if done:
            cx = Variable(torch.zeros(1, 256))
            hx = Variable(torch.zeros(1, 256))
        else:
            cx = Variable(cx.data)
            hx = Variable(hx.data)
        # list of actions from the model
        values = []
        # list of log probabilities
        log_probs = []
        # list of rewards
        rewards = []
        # list of entropies
        entropies = []

        # for all step in the exploration
        for step in range(params.num_steps):
            value, action_values, (hx, cx) = model((Variable(state.unsqueeze(0)), (hx, cx)))
            prob     = F.softmax(action_values)
            log_prob = F.log_softmax(action_values)
            # entropy
            entropy  = -(log_prob * prob).sum(1)
            entropies.append(entropy)
            action   = prob.multinomial().data
            log_prob = log_prob.gather(1, Variable(action))
            values.append(value)
            log_probs.append(log_prob)
            # play the action and jump to the next step as well as new reward
            state, reward, done, _ = env.step(action.numpy())
            # 
            done = (done or episode_length >= params.max_episode_length)
            reward = max(min(reward, 1), -1)
            if done:
                episode_length = 0
                state = env.reset()
            state = torch.from_numpy(state)
            rewards.append(reward)
            if done:
                break
        R = torch.zeros(1, 1)
        if not done:
            value, _, _ = model((Variable(state.unsqueeze(0)), (hx, cx)))
            R = value.data
        values.append(Variable(R))

        """ Computing the loss
            `A = Q(s, a) - V(s)`

            - if Q = V  => A ? 
            - if Q > V => A ? 
            - if Q < V => A ? 
        """
        policy_loss = 0
        value_loss  = 0
        # convert tensor to variable
        R = Variable(R)
        # general advantage estimator : A(s,a) = Q(s, a) - V(s)
        gae = torch.zeros(1, 1)
        
        for i in reversed(range(len(rewards))):
            """ computation of acumulative reward
            r = r_0 + gamma * r_l + gamma^2*r_2+ ...+gamma^(n-1)*r_{n-1}+gamma^nb_step*V(last_state)
            """
            R = params.gamma * R + rewards[i]
            advantage = R - values[i]
            # value loss
            value_loss = value_loss + 0.5 * advantage.pow(2) # Q*(a*,s) = V*(s)
            TD = rewards[i] + params.gamma * values[i + 1].data - values[i].data
            gae = gae * params.gamma * params.tau + TD # gae = sum_i(gamma*tau)î *TD(i)
            # policy loss
            policy_loss = policy_loss - log_probs[i] * Variable(gae) - 0.01 * entropies[i] # policy_loss = sum_i(log(pi_i)*gae + 0.01*H_i)
        # init to zero
        optimizer.zero_grad()
        # backprop
        (policy_loss + 0.5 * value_loss).backward()
        # gradient descent following normal distribution
        torch.nn.utils.clip_grad_norm(model.parameters(), 40)
        ensure_shared_grads(model, shared_model)
        optimizer.step()
