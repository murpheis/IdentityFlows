#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct  1 21:22:35 2018

@author: murpheis
"""

import csv
import numpy as np
import pandas as pd




# FIXED WIDTH COLUMNS
colspecs=[[0,4], [4,9], [9,11], [11,21], [21,35], [35,37], [37,39], [39,40],
                  [40,44], [44,49], [49,51], [51,53], [53,58], [58,59], [59,61],
                  [61,75], [75,89], [89,93], [93,95], [95,96], [96,99], [99,100],
                  [100,101], [101,103], [103,104], [104,108], [108,112],
                  [112,115], [115,118], [118,121], [121,125], [125,128],
                  [128,130], [130,133], [133,136], [136,139], [139,142],
                  [142,145], [145,148], [148,149], [149,151], [151,154],
                  [154,155], [155,157], [157,160], [160,162]]


# VARIABLE NAMES
names=['year', 'serial', 'month', 'hwtfinl', 'cpsid', 'region','statefip',
       'metro','metarea', 'county', 'statecensus', 'cbsasz', 'metfips',
       'individcc','pernum','wtfinl', 'cpsidp', 'relate', 'age', 'sex',
       'race','marst','popstat', 'empstat', 'labforce', 'occ', 'occ2010',
       'occ1990','ind1990','occ1950', 'ind', 'ind1950', 'classwkr', 'uhrsworkt',
       'uhrswork1','uhrswork2','ahrsworkt', 'ahrswork1', 'ahrswork2', 'absent',
       'durunem2','durunemp','whyunemp','wkstat','educ','educ99']


# READ IN DATA ACCORDING TO FIXED WIDTHS
cps = pd.read_fwf("/accounts/grad/emily.eisner/Documents/CPS/data/cps_00006",
                   colspecs=colspecs, names=names)


# DROP IF AGE IS BELOW 18 OR ABOVE 65
cps = cps[cps.age>17]
cps = cps[cps.age<66]

# COLLAPSE TO MONTH - INDUSTRY - GENDER - RACE COUNTS
indCounts = cps.groupby(['year','month','ind1990','sex','race']).size()
#indCounts = indCounts.unstack().unstack()
indCounts = indCounts.fillna(0)


# COLLAPSE TO MONTH - OCCUPATION - GENDER - RACE COUNTS
occCounts = cps.groupby(['year','month','occ1990','sex','race']).size()
#occCounts = occCounts.unstack().unstack()
occCounts = occCounts.fillna(0)


# EXPORT FILES
indCounts.to_csv("/accounts/grad/emily.eisner/Documents/CPS/output/indCounts.csv",
                 sep =",",header=True)
occCounts.to_csv("/accounts/grad/emily.eisner/Documents/CPS/output/occCounts.csv",
                 sep =",",header=True)
