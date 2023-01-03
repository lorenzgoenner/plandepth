# -*- coding: utf-8 -*-
"""
Created on Tue Jan  3 09:38:31 2023

@author: goenner
"""

import pylab as plt
import numpy as np
import pandas as pd
import torch
import sys
import scipy.io as io
import json

sys.path.append('../')
from tasks import SpaceAdventure
from agents import BackInduction
from simulate import Simulator


def inverse_sigmoid(x):
    # Inverse function of torch.sigmoid
    if x == 1:
        return np.inf
    elif x == 0:
        return - np.inf
    else:
        return -np.log(1.0 / x - 1)





    
torch.manual_seed(16324)
#pyro.enable_validation(True)

#sns.set(context='talk', style='white', color_codes=True)

runs0 = 100 # 100 # 40            #number of simulations 
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



#datapath = 'H:\Sesyn\TRR265-B09\Analysis_SAT-PD2_Sophia\SAT_PD_Inference_Scripts\Results_discount_Noise_theta'
#df_exc_pd1_oa = pd.read_csv(datapath + '\exc_PD1_oa_discount_Noise_theta_0cost.csv')
#df_exc_pd2_oa = pd.read_csv(datapath + '\exc_PD2_oa_discount_Noise_theta_0cost.csv')
#df_exc_pd3_oa = pd.read_csv(datapath + '\exc_PD3_oa_discount_Noise_theta_0cost.csv')
#file = np.load(datapath + '/oa_plandepth_stats_B03_discount_Noise_theta_0cost.npz', allow_pickle=True)
#df_params_all = pd.read_csv(datapath + '/pars_post_samples_discount_Noise_theta_0cost.csv')

datapath = 'H:\Sesyn\TRR265-B09\Analysis_SAT-PD2_Sophia\SAT_PD_Inference_Scripts\Results_inference_group_NLL_0cost_1000it_lr0-01_20220706'
df_exc_pd1_oa = pd.read_csv(datapath + '\exc_PD1_oa_0cost.csv')
df_exc_pd2_oa = pd.read_csv(datapath + '\exc_PD2_oa_0cost.csv')
df_exc_pd3_oa = pd.read_csv(datapath + '\exc_PD3_oa_0cost.csv')
file = np.load(datapath + '/oa_plandepth_stats_B03.npz', allow_pickle=True)
df_params_all = pd.read_csv(datapath + '/pars_post_samples_0cost.csv')

fs = file.files # names of the stored arrays (['post_depth_oa', 'm_prob_oa', 'exc_count_oa'])
post_meanPD_firstAction_oa = np.matmul(file[fs[1]][0,:,:,:], np.arange(1,4))
exc_count_firstAction_oa = file[fs[2]][0,:,:,:]
pd_map_estimate_oa = np.argmax(file[fs[2]][0,:,:,:], 0)

file.close()




id_list_oa = np.unique(df_params_all['IDs'][df_params_all['group']=='OA'])

mean_beta_oa = np.nan * np.ones(len(id_list_oa))
mean_theta_oa = np.nan * np.ones(len(id_list_oa))
mean_gamma_oa = np.nan * np.ones(len(id_list_oa))
mean_theta_oa = np.nan * np.ones(len(id_list_oa))
mean_alpha_oa = np.nan * np.ones(len(id_list_oa))


agents = []
states = []
simulations = []
performance = []

trans_pars_depth = [] # LG
points_depth = [] # LG
responses_depth = [] # LG

mean_gain_per_miniblock_oa = np.nan * np.ones([len(id_list_oa), 3, mini_blocks0])
mixed_gain_per_miniblock_map_oa = np.nan * np.ones([len(id_list_oa), mini_blocks0])
parameters_oa = np.nan * np.ones([len(id_list_oa), 3])


# TODO:
# For each subject, add a simulation of 100 (?) agents based on the inferred parameters, for 3 planning depths!
# Store gain per plannning depth for each subject.   
# Based on the MAP estimate of planning depth (alternatively, based on a mixture model),
# "mix" the gain per miniblock according to the estimated planning depth per miniblock.


for i_subj in range(len(id_list_oa)):
    # 1. set simulation parameters    
    # 2. simulate
    # 3. calculate "mixed" gain
    
    print("Subject ", id_list_oa[i_subj])  

    df_params_all['parameter'][df_params_all['IDs']==id_list_oa[i_subj]]    
    filtered_ind_beta = np.where( (df_params_all['IDs']  == id_list_oa[i_subj]) & (df_params_all['parameter'] == "$\\beta$" ))[0]
    filtered_ind_theta = np.where( (df_params_all['IDs']  == id_list_oa[i_subj]) & (df_params_all['parameter'] == "$\\theta$" ))[0]    
    filtered_ind_gamma = np.where( (df_params_all['IDs']  == id_list_oa[i_subj]) & (df_params_all['parameter'] == "$\\gamma$" ))[0]    
    filtered_ind_alpha = np.where( (df_params_all['IDs']  == id_list_oa[i_subj]) & (df_params_all['parameter'] == "$\\alpha$" ))[0]        
    mean_beta_oa[i_subj] = df_params_all['value'][filtered_ind_beta].mean()
    mean_theta_oa[i_subj] = df_params_all['value'][filtered_ind_theta].mean()    
    mean_gamma_oa[i_subj] = df_params_all['value'][filtered_ind_gamma].mean()    
    mean_alpha_oa[i_subj] = df_params_all['value'][filtered_ind_alpha].mean()        

    #m0 = [np.log(torch.tensor(float(str(mean_beta_oa[i_subj])))), \ # String conversion to ensure correct type
    #      torch.tensor(float(str(mean_theta_oa[i_subj]))), \
    #      torch.tensor(float(str(mean_gamma_oa[i_subj])))]        

    m0 = [np.log(torch.tensor(float(str(mean_beta_oa[i_subj])))), \
          torch.tensor(float(str(mean_theta_oa[i_subj]))), \
          inverse_sigmoid(torch.tensor(float(str(mean_alpha_oa[i_subj]))))]        

    parameters_oa[i_subj, :] = m0

    for i_pd in range(3):
    # define space adventure task with aquired configurations
    # set number of trials to the max number of actions per mini-block
        space_advent0 = SpaceAdventure(conditions0,
                                  outcome_likelihoods=confs0,
                                  init_states=starts0,
                                  runs=runs0,
                                  mini_blocks=mini_blocks0,
                                  trials=max_trials0)

        agent0 = BackInduction(confs0,
                              runs=runs0,
                              mini_blocks=mini_blocks0,
                              trials=3,
                              costs = torch.tensor([0., 0.]), # Neu (LG)                              
                              planning_depth=i_pd+1)
            
        #fixed values for parameters
        trans_pars0 = torch.tensor(m0).repeat(runs0,1) # this line sets beta, theta and alpha / gammma
        agent0.set_parameters(trans_pars0)


        # simulate behavior
        sim0 = Simulator(space_advent0,
                    agent0,
                    runs=runs0,
                    mini_blocks=mini_blocks0,
                    trials=3)
        sim0.simulate_experiment()

        simulations.append(sim0)
        agents.append(agent0)
        states.append(space_advent0.states.clone())

        responses0 = simulations[-1].responses.clone() #response actions in simulation for every mini-block 
        responses0[torch.isnan(responses0)] = -1.
        responses0 = responses0.long()
        points0 = (costs0[responses0] + fuel0[simulations[-1].outcomes])  #reward for landing on a certain planet in simulation

        points0[simulations[-1].outcomes < 0] = 0 #set MB in which points go below 0 on 0 ?
        performance.append(points0.sum(dim=-1))   #sum up the gains 
        
        mean_gain_per_miniblock_oa[i_subj, i_pd, :] = points0.sum(dim=-1).mean(0)
    
        #trans_pars_depth.append(trans_pars0)
        #points_depth.append(points0)
        #responses_depth.append(responses0) 
        
        if i_pd==2: print("beta = %f, Mean gain PD%i: %s" %(round(mean_beta_oa[i_subj], 2), i_pd+1, points0.sum(dim=-1).mean(0).sum()))
        
        # TODO: "Mix" gain of simulated agents to obtainn a reference
        for i_mb in range(0, 120):
            #print(i_mb, (mean_gain_per_miniblock_oa[i_subj, pd_map_estimate_oa[i_mb+20, i_subj], i_mb] ))
            mixed_gain_per_miniblock_map_oa[i_subj, i_mb] = mean_gain_per_miniblock_oa[i_subj, pd_map_estimate_oa[i_mb+20, i_subj], i_mb]
    

dict_gain_PDagents_oa = {}
dict_gain_PDagents_oa['Gain_PD1_agent'] = mean_gain_per_miniblock_oa[:, 0, :]
dict_gain_PDagents_oa['Gain_PD2_agent'] = mean_gain_per_miniblock_oa[:, 1, :]
dict_gain_PDagents_oa['Gain_PD3_agent'] = mean_gain_per_miniblock_oa[:, 2, :]
dict_gain_PDagents_oa['Parameters'] = parameters_oa

df_gain_per_mb_pd1_oa = pd.DataFrame(data=dict_gain_PDagents_oa['Gain_PD1_agent'])
df_gain_per_mb_pd2_oa = pd.DataFrame(data=dict_gain_PDagents_oa['Gain_PD2_agent'])
df_gain_per_mb_pd3_oa = pd.DataFrame(data=dict_gain_PDagents_oa['Gain_PD3_agent'])
df_parameters_oa = pd.DataFrame(data=dict_gain_PDagents_oa['Parameters'])

df_gain_per_mb_pd1_oa.to_csv(datapath + '/simulated_gain_pd1_oa.csv')     
df_gain_per_mb_pd2_oa.to_csv(datapath + '/simulated_gain_pd2_oa.csv') 
df_gain_per_mb_pd3_oa.to_csv(datapath + '/simulated_gain_pd3_oa.csv') 
df_parameters_oa.to_csv(datapath + '/simulation_params_oa.csv')     

dict_mixed_gain_map_oa = {}
dict_mixed_gain_map_oa['Gain_Mixed_agents_MAP'] = mixed_gain_per_miniblock_map_oa.transpose()
df_mixed_gain = pd.DataFrame(dict_mixed_gain_map_oa['Gain_Mixed_agents_MAP'])
# With IDs:
#df_mixed_gain = np.transpose(pd.DataFrame(id_list_oa)).append(pd.DataFrame(dict_mixed_gain_map_oa['Gain_Mixed_agents_MAP'])) # With subject IDs
df_mixed_gain.to_csv(datapath + '/Gain_Mixed_agents_MAP_oa.csv')     