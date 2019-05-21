#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Sep 25 13:56:49 2018

@author: murpheis
"""


import csv
import numpy as np
import pandas as pd
import networkx as nx
import matplotlib.pyplot as plt


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
cps = pd.read_fwf("/Users/murpheis/Dropbox/UCB/IdentityFlows/clean/input/cps_00005",
                   colspecs=colspecs, names=names)


# CHECK WHAT DATES ARE COVERED IN THIS DATASET
type(cps)
cps.head()

cps.year.unique()
cps.month.unique()



# DROP IF AGE IS BELOW 18 OR ABOVE 65
cps = cps[cps.age>17]
cps = cps[cps.age<66]


# LABEL 1990 INDUSTRIES BY BROAD SECTOR
farm = (cps['ind1990'] > 0) & (cps['ind1990'] < 40)
mining = (cps['ind1990'] >= 40) & (cps['ind1990'] < 60)
construction = (cps['ind1990'] == 60)
manufacturing = (cps['ind1990'] >= 100) & (cps['ind1990'] < 400)
publicutils = (cps['ind1990'] >= 400) & (cps['ind1990'] < 500)
wholetrade = (cps['ind1990'] >= 500) & (cps['ind1990'] < 580)
retailtrade = (cps['ind1990'] >= 580) & (cps['ind1990'] < 700)
finance = (cps['ind1990'] >= 700) & (cps['ind1990'] < 721)
business = (cps['ind1990'] >= 721) & (cps['ind1990'] < 761)
personal = (cps['ind1990'] >= 761) & (cps['ind1990'] < 800)
entertainment = (cps['ind1990'] >= 800) & (cps['ind1990'] < 812)
health = (cps['ind1990'] >= 812) & (cps['ind1990'] < 841)
legal = (cps['ind1990'] == 841)
education = (cps['ind1990'] >= 842) & (cps['ind1990'] < 863)
othProf = (cps['ind1990'] >= 870) & (cps['ind1990'] < 900)
publicAdmin = (cps['ind1990'] >= 900) & (cps['ind1990'] < 940)
military = (cps['ind1990'] >= 940) & (cps['ind1990'] < 998)
unknown = (cps['ind1990'] == 998)
cps['broadInd'] = 0
cps.loc[farm,'broadInd'] = 1
cps.loc[mining,'broadInd'] = 2
cps.loc[construction,'broadInd'] = 3
cps.loc[manufacturing,'broadInd'] = 4
cps.loc[publicutils,'broadInd'] = 5
cps.loc[wholetrade,'broadInd'] = 6
cps.loc[retailtrade,'broadInd'] = 7
cps.loc[finance,'broadInd'] = 8
cps.loc[business,'broadInd'] = 9
cps.loc[personal,'broadInd'] = 10
cps.loc[entertainment,'broadInd'] = 11
cps.loc[health,'broadInd'] = 12
cps.loc[legal,'broadInd'] = 13
cps.loc[education,'broadInd'] = 14
cps.loc[othProf,'broadInd'] = 15
cps.loc[publicAdmin,'broadInd'] = 16
cps.loc[military,'broadInd'] = 17
cps.loc[unknown,'broadInd'] = 18

cps['broadInd'].unique()

# COLLAPSE TO MONTH - INDUSTRY - GENDER - RACE COUNTS
#indCounts = cps.groupby(['year','month','ind1990','sex','race']).size()
#indCounts = indCounts.unstack().unstack()
#indCounts = indCounts.fillna(0)


# COLLAPSE TO MONTH - OCCUPATION - GENDER - RACE COUNTS
#occCounts = cps.groupby(['year','month','occ1990','sex','race']).size()
#occCounts = occCounts.unstack().unstack()
#occCounts = occCounts.fillna(0)


# EXPORT FILES
#indCounts.to_csv("/Users/murpheis/Dropbox/UCB/cpsCleaning/output/indCounts.csv",
#                 sep =",",header=True)
#occCounts.to_csv("/Users/murpheis/Dropbox/UCB/cpsCleaning/output/occCounts.csv",
#                 sep =",",header=True)



# INDIVIDUAL TRANSITIONS, OCCUPATION
cpsOcc = cps[['year',  'month',  'cpsidp','occ1990']]
cpsOcc = cpsOcc.pivot_table(values = 'occ1990',
                              index = 'cpsidp' ,
                              columns = ['year', 'month'])
cpsOcc = cpsOcc.dropna()

# Build your graph
df = pd.DataFrame({'from':cpsOcc[2013,1],'to':cpsOcc[2013,2]})
G=nx.from_pandas_dataframe(df, 'from', 'to')
# Plot it
nx.draw(G, with_labels=True)
plt.show()

# INDIVIDUAL TRANSITIONS, INDUSTRY
cpsInds = cps[['year',  'month',  'cpsidp','ind1990']]
cpsInds = cpsInds.pivot_table(values = 'ind1990',
                              index = 'cpsidp' ,
                              columns = ['year', 'month'])
cpsInds = cpsInds.dropna()
# Build your graph
df = pd.DataFrame({'from':cpsInds[2013,1],'to':cpsInds[2013,2]})
G=nx.from_pandas_dataframe(df, 'from', 'to')
# Plot it
nx.draw(G, with_labels=True)
plt.show()


# INDIVIDUAL TRANSITIONS, SECTOR, BY GENDER
cps.sex.unique()
cpsXX = cps[cps.sex == 2]
cpsXY = cps[cps.sex == 1]
cpsSectorXX = cpsXX[['year',  'month',  'cpsidp','broadInd']]
cpsSectorXY = cpsXY[['year',  'month',  'cpsidp','broadInd']]

cpsSectorXX = cpsSectorXX.pivot_table(values = 'broadInd',
                              index = 'cpsidp' ,
                              columns = ['year', 'month'])

cpsSectorXY = cpsSectorXY.pivot_table(values = 'broadInd',
                            index = 'cpsidp' ,
                            columns = ['year', 'month'])
cpsSectorXX = cpsSectorXX.dropna()
cpsSectorXY = cpsSectorXY.dropna()

# Graph for women
df = pd.DataFrame({'from':cpsSectorXX[2013,1],'to':cpsSectorXX[2013,2]})
G=nx.from_pandas_dataframe(df, 'from', 'to')
# Plot it
nx.draw(G, with_labels=True)
plt.figure(1)
plt.title('Women')
plt.show()


# Graph for men
df = pd.DataFrame({'from':cpsSectorXY[2013,1],'to':cpsSectorXY[2013,2]})
G=nx.from_pandas_dataframe(df, 'from', 'to')
# Plot it
nx.draw(G, with_labels=True)
plt.figure(1)
plt.title("Men")
plt.show()


# TRANSITION MATRICES
cpsSectorXX['one'] = 1
list(cpsSectorXX)
transMatXX = cpsSectorXX.groupby([(2013,1),(2013,2)],)['one'].sum()
transMatXX.head()

type(transMatXX)
test = transMatXX.unstack(level=-1,fill_value = 0)
type(test)

# CREATE TRANSITION MATRIX (FOR SOME REASONS )


#
