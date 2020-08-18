import os
import sys

# Make sure the path of the framework is included in the import path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

# Framework imports
from MonteCarlo import *
from control import SimpleMonteCarloControl, SgdMonteCarloControl

# 3rd-party imports
import pandas as pd
from tqdm import tqdm
from matplotlib import pyplot as plt

number_of_trials = 4
number_of_episodes = 1000
blocks_world_size = 7
planning_horizon = 6
planning_factors = [0.5, 0.6, 0.7]

def run_trial(planning_factor):

    blocks_world = BlocksWorld(blocks_world_size)
    ctrl = SimpleMonteCarloControl(blocks_world)
    mc = MonteCarlo(blocks_world, control=ctrl, max_episode_length=blocks_world_size*2, 
                    planning_factor=planning_factor, plan_on_empty_policy=False, planning_horizon=planning_horizon)
    mc.learn_policy(discount_rate=1, number_episodes=number_of_episodes, show_progress_bar=True)

    data = pd.DataFrame({
        'episode': range(len(mc.return_ratios)),
        'return_ratio': mc.return_ratios,
        'observed_returns' : mc.returns,
        'optimal_returns': mc.optimal_returns
    })
    
    return data

df = pd.DataFrame()
for trial_number, planning_factor in enumerate(tqdm(planning_factors * number_of_trials, desc='Running trials')):
    data = run_trial(planning_factor)
    data['trial_number'] = trial_number
    data['planning_factor'] = planning_factor
    df = df.append(data, ignore_index=True)

df.to_csv('exp1c_data.csv')
