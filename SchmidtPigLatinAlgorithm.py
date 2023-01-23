#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Nov  6 15:44:23 2022

@author: Hannah Schmidt

Purpose: Decoding pig latin by reading in a file containing pig latin and then using subsequent functions to 
decode the phrases contained in the file, with the final output being the translated word/phrase(s).

Here are the rules we follow for translation: 
If a word begins with a consonant, take all of the letters before the first vowel 
and move them to the end of the word, then add ay to the end of the word. Examples: pig → igpay, there → erethay.

If a word begins with a vowel (a, e, i, o, u, or y), simply add yay to the end of the word. 
For this problem, y is always a vowel. Examples: and → andyay, ordinary → ordinaryyay.
"""

def translate(word):
    #Defining list of consonants to check against for first character of a string
    consonants = ['b', 'c', 'd', 'f', 'g', 'h', 'j', 'k', 'l', 'm', 'n', 'p', 'q', 'r', 's', 't', 'v', 'w', 'x','z']
    #defining list of vowels to check the first character of a string (i.e. word that's inputted into function)
    vowels = ['a', 'e', 'i', 'o', 'u', 'y']
    #creating an empty string within the function so it is empty every time we call the function to store the 
    #variables we want to move from the front of the string to the back
    consonantsToMove = ''
    #Checking if first character in string is a consonant. If so, we step into the statement and begin iterating over
    #every character in the string
    if word[0] in consonants:
        for i in range(len(word)):
            if word[i] in consonants:
                #we're checking if every character is a consonant--if it is, we're adding it to the list to move
                consonantsToMove += word[i]
                #we need this statement so we can stop addiing consonants to our list to move since the first vowel
                #will have occurred
                if word[i+1] in vowels:
                    break
        #Creating an empty string to put our output in 
        newString =''
        #adding the truncated original word, the list of consonants and 'ay' to create the correct output string
        newString = word[len(consonantsToMove):] + consonantsToMove + 'ay'
        
    #If the word begins with a vowel, we simply append 'yay' to the end of the word and return the new word 
    elif word[0] in vowels:
        newString = ''
        newString = word + 'yay'
    #Added this elif in case there's an empty line, otherwise the algorithm will break when it encounters one
    #when translate() is called from parse_lines
    elif word == '\n': 
        newString =''
    return newString


def read_input(file_name):
    #Using a try-catch to properly handle the failure to open the file. This will also 'kill' the execution
    #if we fail to open the file so we don't get stuck with the program trying to do an impossible task
    try:
        fileToOpen = open(file_name) #opening file
        
        lines = fileToOpen.readlines() #reading every line and storing each line as element of list
        
        fileToOpen.close() #closing the file since we can't leave it open, otherwise our code will break
        
        return lines #finally returning the list of lines read from the file
    
    #if the file cannot be opened/read, we throw an IOError and provide a personlized message telling the user
    #we can't process the file and return an empty list as per instructed
    except IOError:
        lines = []
        return lines
    
    
#I accidentally combined the functionality of parse_lines and parse_all_lines, but this is more intuitive to me to
#process everything at once anyway...

def parse_lines(line):
    #makes sense to store each line in one dimension of an array, with each element in the array being 
    #a word from the orginial string; this will create a jagged array if each line doesn't contain the 
    #same number of elements, but that really doesn't matter, we just need to be careful when we iterate
   
   #Please note that I used this link: https://www.educba.com/multidimensional-array-in-python/
   #to be able to concisely instantiate my jagged array; I thought using this syntax was more clear and less prone
   #to error 
   
    jaggedArrayForStringStorage = [lines[i].split(" ")  for i in range(len(lines))] #Creates a jagged array
    #with the proper strings stored in each position
    
    translatedAndUncattedStrings = [[0]*len(lines[i].split(" "))  for i in range(len(lines))]
    #Creates the same jagged array, but with 0's initially stored in each position. We'll later add the
    #translated word into this array.
    
    translatedStrings = [ [] for i in range(len(lines)) ]
    #Whenever we go to concatenate our strings, we'll want to store those somewhere (this is where)
    
    
    for j in range(len(jaggedArrayForStringStorage)): #Gives the number of rows of strings that exist (i.e. # of lines in file)
        for k in range(len(jaggedArrayForStringStorage[j])): #length of each sub-list (i.e. # of strings in a list)
            jaggedArrayForStringStorage[j][k] = jaggedArrayForStringStorage[j][k].strip( ) #removing leading/trailing space from string
            translatedAndUncattedStrings[j][k] = translate(jaggedArrayForStringStorage[j][k]) #passing each string from our jagged array to 
            #our translate function and taking that translation into our translated and unconcatenated list

        translatedStrings[j] = " ".join(translatedAndUncattedStrings[j]) #concatenating all strings in a given sub list (from the same orig. line)
    return  translatedStrings #returning all translated strings/rows

    
    


if __name__ == "__main__":
    file_name = input()
    lines = read_input(file_name)
    if len(lines) == 0:
        print("Unable to open input file.") #Since this is here, I removed the error message I was throwing with the IOError
    else:
        for line in parse_lines(lines):
            print(line)


#When using given example lines of text, algorithm properly returns 

#ethay uickqay ownbray oxfay
#umpsjay overyay ethay azylay ogday
#andyay ordinaryyay oxesfay
#ontday umpjay overyay azylay ogsday