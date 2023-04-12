# In[0]:
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov  8 11:01:19 2021

@author: Sophia-Helen Sass for adaptaions
"""
"""
Created on Fri Dec 21 17:23:10 2018
Here we will test the validity of the inference procedure for estimating free parameters of the behavioural model.
In a frist step we will simulate behaviour from the agents with a fixed planning depth and try to recover model
parameters as mini-block dependent planning depth. In the second step, we will simulate behaviour from agents
with varying planning depth and try to determine the estimation accuracy of the free model paramters and
mini-block dependent planning depth.
@author: Dimitrije Markovic
"""

import torch
import pyro
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import sys
import scipy.io as io
import json
import scipy.stats as st
import pandas as pd

sys.path.append('../')
from tasks import SpaceAdventure
from agents import BackInduction
from agents_discount_Noise_theta import BackInductionDiscountNoiseTheta
from simulate import Simulator
from inference import Inferrer

# In[1]:  #### simulation and recovery for SAT PD version 2.0 ###########################################
# changes in task: new planet configs, no action costs, 140 trials in total, first 20 are training trials
#                  noise conditions are pseudo-randomized (no blocks), only mini-blocks of 3 actions 

# set global variables
torch.manual_seed(16324)
pyro.enable_validation(True)

sns.set(context='talk', style='white', color_codes=True)

runs0 = 1000 # 40            #number of simulations 
mini_blocks0 = 120     #+20 for training which will be removed in the following
max_trials0 = 3        #maximum number of actions per mini-block
max_depth0 = 3         #maximum planning depth
na0 = 2                #number of actions
ns0 = 6                #number of states
no0 = 5                #number of outcomes
starting_points = 350  #number of points at the beginning of task

# load task configuration file 
#read_file = open('/home/sass/Dokumente/plandepth/config_file/space_adventure_pd_config_task_new_orig.json',"r")
read_file = open('config_file/space_adventure_pd_config_task_new_orig.json',"r")
exp1 = json.load(read_file)
read_file.close()

# load starting positions of each mini-block 
starts0 = exp1['startsExp']
import numpy
starts0 = numpy.asarray(starts0)
starts0 = starts0[19:139]
starts0 = starts0 -1

# load planet configurations for each mini-block
planets0 = exp1['planetsExp']
planets0 = numpy.asarray(planets0)
planets11 = planets0
planets0 = planets0[19:139,:]
planets0 = planets0 -1


vect0 = np.eye(5)[planets0]

ol0 = torch.from_numpy(vect0)

starts0 = torch.from_numpy(starts0)


# load noise condition (low -> 0, high -> 1)
noise0 = exp1['conditionsExp']['noise']
for i in range(len(noise0)):
  if noise0[i] == 'high':
    noise0[i] = 1

for i in range(len(noise0)):
  if noise0[i] == 'low':
    noise0[i] = 0
    
noise0 = numpy.asarray(noise0)
noise0 = noise0[19:139]

# number of actions for each mini-block 
trials0 = exp1['conditionsExp']['notrials']
trials0 = numpy.asarray(trials0)
trials0 = trials0[19:139]

# load action costs (all zero)
costs0 = numpy.asarray(exp1['actionCost'])
costs0 = torch.FloatTensor(costs0)

# load fuel rewards/punishment for each planet type [-20,-10,0,10,20]
fuel0 = numpy.asarray(exp1['planetRewards'])
fuel0 = torch.FloatTensor(fuel0)  


confs0 = ol0.repeat(runs0,1,1,1).float()

starts0 = starts0.repeat(runs0,1).float()

# build tensors for conditions described by number of actions and noise condition
conditions0 = torch.zeros(2, runs0, mini_blocks0, dtype=torch.long)
conditions0[0] = torch.tensor(noise0, dtype=torch.long)[None, :]
conditions0[1] = torch.tensor(trials0, dtype=torch.long)


# In[2]:
#agents = []
#states = []
#simulations_rational = []
#performance_rational = []
#trans_pars_depth_rational = [] # LG
#points_depth_rational = [] # LG
#responses_depth_rational = [] # LG

simulations = {}
simulations['rational'] = []
simulations['discount_noise_theta'] = []
simulations['discount_noise_theta2'] = []

performance = {}
performance['rational'] = []
performance['discount_noise_theta'] = []
performance['discount_noise_theta2'] = []

trans_pars_depth = {}
trans_pars_depth['rational'] = []
trans_pars_depth['discount_noise_theta'] = []
trans_pars_depth['discount_noise_theta2'] = []

points_depth = {}
points_depth['rational'] = []
points_depth['discount_noise_theta'] = []
points_depth['discount_noise_theta2'] = []

responses_depth = {}
responses_depth['rational'] = []
responses_depth['discount_noise_theta'] = []
responses_depth['discount_noise_theta2'] = []

agents = {}

m0 = {} # mean parameter values
trans_pars0 = {}

#agent_key = 'rational'
for agent_key in ['rational', 'discount_noise_theta', 'discount_noise_theta2']:

    for i in range(3):
    # define space adventure task with aquired configurations
    # set number of trials to the max number of actions per mini-block
        space_advent0 = SpaceAdventure(conditions0,
                                  outcome_likelihoods=confs0,
                                  init_states=starts0,
                                  runs=runs0,
                                  mini_blocks=mini_blocks0,
                                  trials=max_trials0)

    # define the optimal agent, each with a different maximal planning depth
        if agent_key == 'rational':    
            agents['rational'] = BackInduction(confs0,
                          runs=runs0,
                          mini_blocks=mini_blocks0,
                          trials=3,
                          costs = torch.tensor([0., 0.]), # Neu (LG)                              
                          planning_depth=i+1)

            # set beta, theta and alpha parameters as a normal distribution around a certain value
            m0['rational'] = torch.tensor([1.099, 0., 0.0])# beta= 3, because 1.099=np.log(3)    
            
        elif agent_key == 'discount_noise_theta': 
            agents['discount_noise_theta'] = BackInductionDiscountNoiseTheta(confs0,
                          runs=runs0,
                          mini_blocks=mini_blocks0,
                          trials=3,
                          costs = torch.tensor([0., 0.]), # Neu (LG)                              
                          planning_depth=i+1)

            # set beta, theta and gamma (discounting) parameters 
            m0['discount_noise_theta'] = torch.tensor([1.099, 0., 0.85])# beta= 3, because 1.099=np.log(3) // gamma=0.7=sigmoid(0.85)

        elif agent_key == 'discount_noise_theta2': 
            agents['discount_noise_theta2'] = BackInductionDiscountNoiseTheta(confs0,
                          runs=runs0,
                          mini_blocks=mini_blocks0,
                          trials=3,
                          costs = torch.tensor([0., 0.]), # Neu (LG)                              
                          planning_depth=i+1)

            # set beta, theta and gamma (discounting) parameters 
            m0['discount_noise_theta2'] = torch.tensor([1.099, 0., -0.85])# beta= 3, because 1.099=np.log(3) // gamma=0.3=sigmoid(-0.85)  

        
        #trans_pars0[agent_key] = torch.distributions.Normal(m0[agent_key], 1.).sample((runs0,))
        trans_pars0[agent_key] = torch.distributions.Normal(m0[agent_key], 0.5).sample((runs0,)) # lower variability in parameters!
   
        agents[agent_key].set_parameters(trans_pars0[agent_key])
     
    #fixed values for parameters
       #trans_pars0[agent_key] = torch.tensor([2.,0.,0.5]).repeat(runs0,1) # this line sets beta, theta and alpha
       #agents[agent_key].set_parameters(trans_pars0[agent_key])


    # simulate behavior
        sim0 = Simulator(space_advent0,
                    agents[agent_key],
                    runs=runs0,
                    mini_blocks=mini_blocks0,
                    trials=3)
        sim0.simulate_experiment()

        simulations[agent_key].append(sim0)

        responses0 = simulations[agent_key][-1].responses.clone() #response actions in simulation for every mini-block 
        responses0[torch.isnan(responses0)] = -1.
        responses0 = responses0.long()
        points0 = (costs0[responses0] + fuel0[simulations[agent_key][-1].outcomes])  #reward for landing on a certain planet in simulation

        points0[simulations[agent_key][-1].outcomes < 0] = 0 #set MB in which points go below 0 on 0 ?
        performance[agent_key].append(points0.sum(dim=-1))   #sum up the gains 
    
        trans_pars_depth[agent_key].append(trans_pars0[agent_key])
        points_depth[agent_key].append(points0)
        responses_depth[agent_key].append(responses0)

# In[3]
# plotting agent's behavior for planning depth 1:3
'''#
for i in range(3):
    plt.figure()
    #plt.plot(performance['rational'][i].numpy().cumsum(axis=-1).T + starting_points, 'b')
    plt.plot(performance['rational'][i].numpy().cumsum(axis=-1).T + starting_points, 'C'+str(i))    
    plt.ylabel('points')
    plt.xlabel('nb of mini-blocks')
    plt.ylim([0,2700])
    #plt.savefig('score_PD'+str(i+1)+'.pdf', bbox_inches='tight', transparent=True, dpi=600)    
    #plt.savefig('score_PD'+str(i+1)+'.png', bbox_inches='tight', transparent=True, dpi=600)        


plt.figure(figsize=(10, 5))
labels = [r'd=1', r'd=2', r'd=3']
plt.hist(torch.stack(performance['rational']).numpy().cumsum(axis=-1)[..., -1].T+ starting_points, bins=30, stacked=True)
plt.legend(labels)
plt.ylabel('count')
plt.xlabel('score')
#plt.savefig('finalscore_exp.pdf', bbox_inches='tight', transparent=True, dpi=600)
#plt.savefig('finalscore_exp.png', bbox_inches='tight', transparent=True, dpi=600)
'''

plt.figure()
bp1 = plt.boxplot([points_depth['rational'][2][:,:,:].numpy().sum(2).sum(1), #.mean(0),
                   points_depth['discount_noise_theta'][2][:,:,:].numpy().sum(2).sum(1),
                   points_depth['discount_noise_theta2'][2][:,:,:].numpy().sum(2).sum(1)], \
                positions=[1, 1.6, 2.2], showmeans=True,
                patch_artist=True, boxprops=dict(facecolor="C0", alpha=0.3))
bp2 = plt.boxplot([points_depth['rational'][1][:,:,:].numpy().sum(2).sum(1),
                   points_depth['discount_noise_theta'][1][:,:,:].numpy().sum(2).sum(1),
                   points_depth['discount_noise_theta2'][1][:,:,:].numpy().sum(2).sum(1)], \
                positions=[3, 3.6, 4.2], showmeans=True,
                patch_artist=True, boxprops=dict(facecolor="C1", alpha=0.3))   
ax=plt.gca()
ax.set_xticklabels(['PD3 \n rational','PD3 \n discounting \n $\gamma=0.7$', 'PD3 \n discounting \n $\gamma=0.3$', \
                    'PD2 \n rational','PD2 \n discounting \n $\gamma=0.7$', 'PD2 \n discounting \n $\gamma=0.3$'], fontsize=9)
#ax.legend([bp1["boxes"][0], bp2["boxes"][0]], ['All'], loc='upper center')
plt.ylabel('Mean points') #  per miniblock
#Tstat, pval = st.ttest_ind(points_depth['rational'][0][:,:,:].numpy().sum(2).mean(0)[index_difficult], \
#             points_depth['rational'][2][:,:,:].numpy().sum(2).mean(0)[index_difficult])
#plt.text(3.1, 44, '***')    
#plt.text(3.1, 42, 'p='+str(round(pval,5)), fontsize=13)    
plt.savefig('Distribution_agents_points.png', bbox_inches='tight', dpi=600)  