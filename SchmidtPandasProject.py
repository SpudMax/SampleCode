#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Nov 26 00:31:20 2022

@author: Hannah Schmidt

Purpose: Understand and implement a solution that pulls 'live' data and interacts with Matplotlib to be 
usable and produce meaningful displays of information
"""

#import necessary packages/modules from our library to be able to use pre-made functions, including dataframes
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt

#I define a function to initialize our data frame and rename columns
def prepareMainDataFrame():
    #for easier reference later, we'll rename out columns to use underscores instead of spaces (this will help us with column referencing later)
    #I pulled this syntax from the following post: https://stackoverflow.com/questions/13757090/pandas-column-access-w-column-names-containing-spaces
    #I want to be able to use the dot notation for column reference later when I'm sectioning out data, which was the motivation for the name swap
    data.columns = [spaces.replace(' ', '_') for spaces in data.columns]
    #Making a second edit to the names of the 3rd and fourth columns so they don't begin with numbers
    #For syntax, I referenced this: https://www.geeksforgeeks.org/how-to-rename-columns-in-pandas-dataframe/
    data.rename(columns = {"1st_Dose_Allocations" : "First_Dose_Allocations", "2nd_Dose_Allocations" : "Second_Dose_Allocations"}, inplace = True)
    return data
    
    
def subsettingDataFrame(data):    
    week = data.Week_of_Allocations #creating a truncated series from the whole data set to easily work with unique dates
    independentWeeks = week.drop_duplicates() #Dropping all duplicate dates 
    #Using a shortcut to not have to fiddle with reversing a series, so we create an identical list to the series independentWeeks
    weeksList = []
    for index in independentWeeks:
        weeksList.append(index)
    
    indexOfDates = independentWeeks.index #Saving the first index where each of those dates occur (will later use this to create the ranges to sum over to get the proper total allocations for vaccines for 1st and 2nd doses)
    
    #empty arrays to be able to store total allocations for 1st and second doses
    firstDoseAllocations = []
    secondDoseAllocations = []
    
    #In this for loop, we split our data frame based on the column of interest (either first or second doses) and then sum each "section" or range of dates to find the number of doses of vaccines that were sent during each week range
    for index in range(0, len(indexOfDates)):
        if index == len(indexOfDates)-1:
            firstDoseAllocations.append(data.First_Dose_Allocations.loc[indexOfDates[index]:len(data)].sum())
            secondDoseAllocations.append(data.Second_Dose_Allocations.loc[indexOfDates[index]:len(data)].sum())
        else:
            firstDoseAllocations.append(data.First_Dose_Allocations.loc[indexOfDates[index]:indexOfDates[index+1]-1].sum())
            secondDoseAllocations.append(data.Second_Dose_Allocations.loc[indexOfDates[index]:indexOfDates[index+1]-1].sum())

#After we sum and store all of our values, since we want our data to be shown from the oldest to newest date, we recognize that we need to reverse our lists. Now, we do that to plot in sequential order. 
    firstDoseAllocations.reverse()
    secondDoseAllocations.reverse()
    weeksList.reverse()
    return firstDoseAllocations, secondDoseAllocations, weeksList

#Here we begin defining parameters for our plot to make it readable and specify the data we're using for each bar as well as setting axes labels
#I looked up an example of how to plot this and used their result to make my graph as legible as possible. Here's the reference site I used: https://matplotlib.org/stable/gallery/lines_bars_and_markers/barchart.html
def boxPlotForDoseData(firstDoseAllocations, secondDoseAllocations, weeksList):
    xAxisLabels = weeksList
    x = np.arange(len(weeksList))
    barWidth = 0.35 
    
    
    fig, ax = plt.subplots()
    firstDoseBars = ax.bar(x - barWidth/2, firstDoseAllocations, barWidth, label = 'First Dose Allocations')
    secondDoseBars = ax.bar(x + barWidth/2, secondDoseAllocations, barWidth, label = 'Second Dose Allocations')
    
    ax.set_ylabel('Number of Allocated Doses')
    ax.set_xticks(x, xAxisLabels, rotation = 90) #rotating the x-axis labels so they don't overlap each other but give the correct information 
    ax.set_title("1st and 2nd Dose Allocations")
    ax.set_xlabel('Week of Allocations')
    ax.legend()
    
    fig.tight_layout()
    
    plt.show()


if __name__ == "__main__":
    #Making the call to the website to get our desired data
    data = pd.read_csv("https://data.cdc.gov/api/views/b7pe-5nws/rows.csv?accessType=DOWNLOAD") #reading in data from the CSV from the provided web address
    prepareMainDataFrame() #calling the function to edit the way our df has columns named
    firstDoseAllocations, secondDoseAllocations, weeksList = subsettingDataFrame(data)
    boxPlotForDoseData(firstDoseAllocations, secondDoseAllocations, weeksList)
    
    









