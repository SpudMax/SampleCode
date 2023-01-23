#!/usr/bin/env python
# coding: utf-8

# In[1]:


import requests as rq
import tkinter as tk
import math
import re


# In[2]:


#a function that splits each string read from the website into a list of strings that we will later use to populate our dictionary 
def splitString(info):
   for airport in range(len(info)):
       info[airport] = info[airport].split(" ") #splitting the string and storing back in the original structure to avoid clurrtering our workspace with extra data stores
   return info
   


# In[28]:



def dictionaryOfData(data):
    airportInfo = {} #Empty dictionary
    airports = []
    #We'll need these regular expressoins later to classify the temperature and dew points
    formattedTempString = re.compile(r'\d\d/\d\d')
    formattedTempString2 = re.compile(r'[M]\d\d/[M]\d\d')
    formattedTempString3 = re.compile(r'[M]\d\d/\d\d')
    formattedTempString4 = re.compile(r'\d\d/[M]\d\d')
    #Creating keys based on the number of airports with all of the corresponding keys and 'empty' values for those keys. 
    for airport in range(len(data)):
        airportInfo[data[airport][0]] = dict.fromkeys(['date', 'utc', 'windDir', 'windSpeed', 'windGust', 'vis', 'degrees', 'dewPoint', 'altimeter']) #setting a key with mult. values that we'll update later  
        #making a list of the airport names so we can easily reference these keys later
        airports.append(data[airport][0])
    #We want to assign values to each of the keys that serve as the value of the airport (which is the 'main' key) 
        for item in range(1,len(data[airport])): #need to replace this length with the smallest vector otherwise we'll run into an error evaluating

            #Finding the date/time data and populating the appropriate spots in our dictionary with it if it exists
            if (data[airport][item].endswith('Z') == True) & (len(data[airport][item]) == 7):
                dateTimeToSplit = data[airport][item]
                date = dateTimeToSplit[:2]
                zuluTime = dateTimeToSplit[2:len(dateTimeToSplit)-1]
                airportInfo[airports[airport]]['date'] = date
                airportInfo[airports[airport]]['utc'] = zuluTime
                # if (isinstance(airportInfo[airports[airport]]['date'], None) == True) | (isinstance(airportInfo[airports[airport]]['utc'], None) == True):
                #     raise TypeError("Each key must have a value that is not NoneType. Please enter a complete data set.")
            
            #checking for wind speed data and storing it in dictionary if it does exist
            #Since we want whole numbers for wind speed, I decided to take the ceiling of the converted speed values (technically taking the floor of it also would've worked, but this was the simplification I chose to make)
            elif data[airport][item].endswith('KT') == True:
                windInfoToSplit = data[airport][item]
                windDirection = windInfoToSplit[:3]
                airportInfo[airports[airport]]['windDir'] = windDirection
                #we account for the case where gust data is included and populate the field in the dictionary if it is. if not, we assume it's zero
                if 'G' in data[airport][item]:
                    indexOfG = data[airport][item].find("G")
                    gustInfo = windInfoToSplit[indexOfG+1:len(windInfoToSplit)-2]
                    airportInfo[airports[airport]]['windGust'] = math.ceil(1.15*int(gustInfo))
                    windSpeed = math.ceil(1.15*int(windInfoToSplit[3:indexOfG]))
                    
                else:
                    windSpeed = math.ceil(1.15*int(windInfoToSplit[3:len(windInfoToSplit)-2] )) 
                    airportInfo[airports[airport]]['windGust'] = '0'

                airportInfo[airports[airport]]['windSpeed'] = windSpeed
                
            #We check to see if we have visbility data and if it's scaled by a greater than or less than distance and if our distance is fractional. We do all appropriate calculations based on data and then store values in our structure    
        
            elif data[airport][item].endswith('SM') == True:
                visibilityDataToSplit = data[airport][item]
                if ('/' in visibilityDataToSplit) & (len(visibilityDataToSplit) < 8):
                    if visibilityDataToSplit.startswith('P'):
                        numerator = int(visibilityDataToSplit[1])
                        denominator = int(visibilityDataToSplit[3])
                        airportInfo[airports[airport]]['vis'] = 'P' + str(numerator/denominator)
                    elif visibilityDataToSplit.startswith('M'):
                        numerator = int(visibilityDataToSplit[1])
                        denominator = int(visibilityDataToSplit[3])
                        airportInfo[airports[airport]]['vis'] = 'M' + str(numerator/denominator)
                    else:
                        numerator = int(visibilityDataToSplit[0])
                        denominator = int(visibilityDataToSplit[2])
                        airportInfo[airports[airport]]['vis'] = str(numerator/denominator)
                else:
                    airportInfo[airports[airport]]['vis'] = visibilityDataToSplit[0:len(visibilityDataToSplit)-2]
            
            #Looking for and transforming altimeter data        
            elif (data[airport][item].startswith('A') == True) & (len(data[airport][item]) == 5):
                altData = data[airport][item]
                airportInfo[airports[airport]]['altimeter'] = f'{altData[1:3]}.{altData[3:]}'
            
            
            #Obtaining and reshaping temp data
            elif (formattedTempString.search(data[airport][item])) or (formattedTempString2.search(data[airport][item])) or (formattedTempString3.search(data[airport][item])) or (formattedTempString4.search(data[airport][item])):
                tempData = data[airport][item]
                if 'M' in tempData:
                    tempData = tempData.replace('M', '-')
                    if ((tempData[0] == '-') & (tempData[4] == '-') ): #Will also be the same for the case where (tempData[0] == 'M') & (tempData[4] != 'M')
                        airportInfo[airports[airport]]['degrees'] = int(tempData[:3])*9/5 + 32 #since we need this conversion, we might as well do it now.
                        airportInfo[airports[airport]]['degrees'] = str(airportInfo[airports[airport]]['degrees'])
                        airportInfo[airports[airport]]['dewPoint'] = int(tempData[4:])*9/5 + 32 #Also converting string here from deg C to deg F
                        airportInfo[airports[airport]]['dewPoint'] = str(airportInfo[airports[airport]]['dewPoint'])
                    elif ((tempData[0] == '-') & (tempData[4] != '-')):
                        airportInfo[airports[airport]]['degrees'] = int(tempData[:3])*9/5 + 32 #since we need this conversion, we might as well do it now.
                        airportInfo[airports[airport]]['degrees'] = str(airportInfo[airports[airport]]['degrees'])
                        airportInfo[airports[airport]]['dewPoint'] = int(tempData[4:])*9/5 + 32 #Also converting string here from deg C to deg F
                        airportInfo[airports[airport]]['dewPoint'] = str(airportInfo[airports[airport]]['dewPoint'])
                    elif (tempData[0] != '-') & (tempData[3] == '-'): #Accounts for the other two cases where you have an M on the dew point or no M's at all 
                        airportInfo[airports[airport]]['degrees'] = int(tempData[:2])*9/5 + 32 #since we need this conversion, we might as well do it now.
                        airportInfo[airports[airport]]['degrees'] = str(airportInfo[airports[airport]]['degrees'])
                        airportInfo[airports[airport]]['dewPoint'] = int(tempData[3:])*9/5 + 32 #Also converting string here from deg C to deg F
                        airportInfo[airports[airport]]['dewPoint'] = str(airportInfo[airports[airport]]['dewPoint'])
                elif len(data[airport][item]) < 8:
                    airportInfo[airports[airport]]['degrees'] = int(tempData[:2])*9/5 + 32 #since we need this conversion, we might as well do it now.
                    airportInfo[airports[airport]]['degrees'] = str(airportInfo[airports[airport]]['degrees'])
                    airportInfo[airports[airport]]['dewPoint'] = int(tempData[3:])*9/5 + 32 #Also converting string here from deg C to deg F
                    airportInfo[airports[airport]]['dewPoint'] = str(airportInfo[airports[airport]]['dewPoint'])
                    
                else:
                    airportInfo[airports[airport]]['degrees'] = int(tempData[:2])*9/5 + 32 #since we need this conversion, we might as well do it now.
                    airportInfo[airports[airport]]['degrees'] = str(airportInfo[airports[airport]]['degrees'])
                    airportInfo[airports[airport]]['dewPoint'] = int(tempData[3:5])*9/5 + 32 #Also converting string here from deg C to deg F
                    airportInfo[airports[airport]]['dewPoint'] = str(airportInfo[airports[airport]]['dewPoint'])
#This section should work to check and make sure we've assigned all of our required values. If not, it'll break the execution since all of the
#necessary information was not provided for every field of every airport. We wait until we've filled in every field for each airport before executing otherwise we get an error every time. 
    keysForAL = airportInfo[airports[airport]].keys()
    lists = []
    for i in keysForAL:
        lists.append(i)
    for keyVal in range(len(lists)):
        if (type(airportInfo[airports[airport]][lists[keyVal]]) == type(None)):
            raise TypeError("Each key must have a value that is not NoneType. Please enter a complete data set.")
        
        
              
    return airportInfo, airports


# In[29]:


#defining a function that applies the formatting changes that we'll want for our GUI to a copy of our dictionary
def formattedDict(airportInfo, airports):
    formattedAirportInfo = airportInfo.copy() #Doing this so we can format our data
    #We reformat all of our data at once so we can just make our appropriate calls to it later when plotting
    #changes fit the specifications given in the problem statement
    for airport in airports:  
        #PLEASE NOTE THAT TIME IS STILL IN ZULU TIME, NOT IN EASTERN TIME
        if int(airportInfo[airport]['utc']) in range(0, 1160):
            if int(airportInfo[airport]['utc']) < 60:
                formattedAirportInfo[airport]['utc'] = str(1200 + int(airportInfo[airport]['utc'])) + 'am'
            else:
                formattedAirportInfo[airport]['utc'] = airportInfo[airport]['utc'] + 'am'
            if airportInfo[airport]['utc'][0] == '0':
                formattedAirportInfo[airport]['utc'] = airportInfo[airport]['utc'][1:]
        else:
            formattedAirportInfo[airport]['utc'] = str(int(airportInfo[airport]['utc']) - 1200) + 'pm' 
            if airportInfo[airport]['utc'][0] == '0':
                formattedAirportInfo[airport]['utc'] = airportInfo[airport]['utc'][1:]
        
        formattedAirportInfo[airport]['altimeter'] = airportInfo[airport]['altimeter']
        
        if (formattedAirportInfo[airport]['vis'].startswith('P') == True):
            formattedAirportInfo[airport]['vis'] = formattedAirportInfo[airport]['vis'].replace('P', '>')
            formattedAirportInfo[airport]['vis'] = str(airportInfo[airport]['vis']) + 'SM'
        elif (formattedAirportInfo[airport]['vis'].startswith('M')):
            formattedAirportInfo[airport]['vis'] = formattedAirportInfo[airport]['vis'].replace('M', '<')
            formattedAirportInfo[airport]['vis'] = str(airportInfo[airport]['vis']) + 'SM'
        else: 
            formattedAirportInfo[airport]['vis'] = str(airportInfo[airport]['vis']) + 'SM'
            
        formattedAirportInfo[airport]['degrees'] = str(airportInfo[airport]['degrees']) + 'F'
        formattedAirportInfo[airport]['dewPoint'] = str(airportInfo[airport]['dewPoint']) + 'F'
        if airportInfo[airport]['windSpeed'] == 0:
                formattedAirportInfo[airport]['windSpeed'] = "CALM" #300, 220
        elif airportInfo[airport]['windGust'] != '0':
            formattedAirportInfo[airport]['windGust'] = 'Gust: ' + str(airportInfo[airport]['windGust'])+'MPH'
            formattedAirportInfo[airport]['windSpeed'] = str(airportInfo[airport]['windSpeed'])+'MPH'
        else:
            formattedAirportInfo[airport]['windSpeed'] = str(airportInfo[airport]['windSpeed'])+'MPH'
            
    return formattedAirportInfo


# In[30]:


def run(metar, airports):
    # Create the root Tk()
    root = tk.Tk()
    # Set the title
    root.title("COSC505 - Weather")
    # Create two frames, the list is on top of the Canvas
    list_frame = tk.Frame(root)
    draw_frame = tk.Frame(root)
    # Set the list grid in c,r = 0,0
    list_frame.grid(column=0, row=0)
    # Set the draw grid in c,r = 0,1
    draw_frame.grid(column=0,row=1)

    # Create the canvas on the draw frame, set the width to 800 and height to 600
    canvas = tk.Canvas(draw_frame, width=800, height=600)
    # Reset the size of the grid    
    canvas.pack()
    
    #Creating our objects to draw onto the canvas; note that they are already placed and you don't have to pack/place/etc to put them where you want them
    mainWindCircle = canvas.create_oval(300, 100, 400, 200, fill = '#5c5a5a')
    miniWindCircle = canvas.create_oval(345, 145, 355, 155, fill = '#e31717')
    
    
    altGauge = canvas.create_oval(300, 250, 400, 350, fill = '#0f0f0f')
    
    canvas.create_rectangle(500, 100, 600, 300, outline="black", width=4)
    canvas.create_rectangle(300, 400, 700, 500, outline="black", width=4)
    
    
    # These are the airport names based on the data that we've read from the website
    choices = airports

    # Create variables that will store the currently selected choice and subsequent values that are displayed to be updated.
    listvar = tk.StringVar(root)
    dateVar = tk.StringVar(root)
    altVar = tk.StringVar(root)
    visVar = tk.StringVar(root)
    degVar = tk.StringVar(root)
    dewPtVar = tk.StringVar(root)
    windVar = tk.StringVar(root)
    gustVar = tk.StringVar(root)
    windDirVar = tk.IntVar(root)
    
    # Immediately set the choice to the first element. Double check to make sure choices[0] is valid!
    listvar.set(choices[0])

    
    #Setting other values that will show up on our GUI; writing as a function so we can be sure to update them on every call 
    def updatingValues(listvar):
        metar[listvar.get()]['windDir'] = int(metar[listvar.get()]['windDir'])
        dateVar.set(metar[listvar.get()]['utc'])
        altVar.set(metar[listvar.get()]['altimeter']) #350, 300 (position)
        visVar.set(metar[listvar.get()]['vis']) #300, 520 (position)
        degVar.set(metar[listvar.get()]['degrees']) #525, 320
        dewPtVar.set(metar[listvar.get()]['dewPoint'])  #525, 340
        if metar[listvar.get()]['windSpeed'] == 'CALM':
                 windVar.set("CALM") #300, 220
        elif metar[listvar.get()]['windGust'] != '0':
            gustVar.set(metar[listvar.get()]['windGust'])
            windVar.set(metar[listvar.get()]['windSpeed'])
        else:
             windVar.set(metar[listvar.get()]['windSpeed']) #300, 220
#This function was taken from this stackExchange post--I couldn't recall the formula I was looking for to make the line rotate
#https://stackoverflow.com/questions/29989792/rotate-line-in-tkinter-canvas
    def rotateLine(angle):
        angleInDegrees = angle
        angleInRadians = -angleInDegrees * math.pi / 180
        #The following three values are hard coded since we aren't resizing or moving any of our widgets
        lineLength = 50
        centerX = 350
        centerY = 150
        endX = centerX + lineLength * math.cos(angleInRadians)
        endY = centerY + lineLength * math.sin(angleInRadians)
        altLine = canvas.create_line(centerX, centerY, endX, endY, arrow=tk.LAST)
        return altLine 

    #Creating other objects (color bars) for our temp and sight bars
    if (metar[listvar.get()]['vis'].startswith('>') == True) | (metar[listvar.get()]['vis'].startswith('<') == True):
        canvas.create_rectangle(300, 400, float(metar[listvar.get()]['vis'][1:len(metar[listvar.get()]['vis'])-2])*40 + 300, 500, outline = "black", fill = "orange", width = 2)
    else:
        canvas.create_rectangle(300, 400, float(metar[listvar.get()]['vis'][:len(metar[listvar.get()]['vis'])-2])*40 + 300, 500, outline = "black", fill = "orange", width = 2)

    canvas.create_rectangle(500, 300, 600, 300 - (math.ceil(float(metar[listvar.get()]['degrees'][:len(metar[listvar.get()]['degrees'])-1])*(20/9)) ), fill = "red", width = 2)
    canvas.create_rectangle(500, 300, 600, 300 - math.ceil(float(metar[listvar.get()]['dewPoint'][:len(metar[listvar.get()]['dewPoint'])-1])*(20/9)), fill = "blue", width = 2)

    
    # Create the dropdown menu with the given choices and the update variable. This is stored on the
    # list frame. You must make sure that choices is already fully populated.
    dropdown = tk.OptionMenu(list_frame, listvar, *choices)
    # The dropdown menu is on the top of the screen. This will make sure it is in the middle.
    dropdown.grid(row=0,column=1)
    # This function is called whenever the user selects another. Change this as you see fit.
    def drop_changed(*args):
        #deleting all data and figs off our canvas so we can replace them with new data after the user makes a new selection 
            canvas.delete("airport_text")
            canvas.delete("airport_date")
            canvas.delete("airport_alt")
            canvas.delete("airport_vis")
            canvas.delete("airport_deg")
            canvas.delete("airport_dewPt")
            canvas.delete("airport_wind")
            canvas.delete("airport_gust")
            canvas.delete("all")
            #Used this link to change the size and font of my text fields on the LHS: https://www.tutorialspoint.com/how-to-set-the-font-size-of-a-tkinter-canvas-text-item
            #Putting all of our widgets and text fields back on our canvas after we delete them
            canvas.create_text(100, 100, text=listvar.get(), fill="red",font=('Helvetica','30'), tags="airport_text")

            updatingValues(listvar)

            canvas.create_text(100, 140, text = dateVar.get(), fill = "blue", font=('Helvetica','30'), tags = "airport_date")
            canvas.create_text(550, 320, text = degVar.get(), fill = "red", font=('Helvetica','20'), tags = "airport_deg")
            canvas.create_text(550, 340, text = dewPtVar.get(), fill = "blue", font=('Helvetica','20'), tags = "airport_dewPt")
            canvas.create_text(335, 215, text = windVar.get(), fill = "black", font=('Helvetica','14'), tags = "airport_wind")
            if metar[listvar.get()]['windGust'] != '0':
                canvas.create_text(350, 227, text = gustVar.get(), fill = "black", font=('Helvetica','14'), tags = "airport_gust")
            else: 
                canvas.create_text(350, 227, text = '', fill = "black", font=('Helvetica','14'), tags = "airport_gust")

            mainWindCircle = canvas.create_oval(300, 100, 400, 200, fill = '#5c5a5a')
            miniWindCircle = canvas.create_oval(345, 145, 355, 155, fill = '#e31717')
             
            if metar[listvar.get()]['windSpeed'] == 'CALM':
                altLine = rotateLine(metar[listvar.get()]['windDir'])
                canvas.delete(altLine)
            else: 
                altLine = rotateLine(metar[listvar.get()]['windDir'])

            altGauge = canvas.create_oval(300, 250, 400, 350, fill = '#0f0f0f')
            canvas.create_text(350, 300, text = altVar.get(), fill = "white",font=('Helvetica','20'), tags = "airport_alt")

            canvas.create_rectangle(500, 100, 600, 300, outline="black", width=4)
            canvas.create_rectangle(300, 400, 700, 500, outline="black", width=4)
            
            if (metar[listvar.get()]['vis'].startswith('>') == True) | (metar[listvar.get()]['vis'].startswith('<') == True):
                canvas.create_rectangle(300, 400, float(metar[listvar.get()]['vis'][1:len(metar[listvar.get()]['vis'])-2])*40 + 300, 500, outline = "black", fill = "orange", width = 2)
            else:
                canvas.create_rectangle(300, 400, float(metar[listvar.get()]['vis'][:len(metar[listvar.get()]['vis'])-2])*40 + 300, 500, outline = "black", fill = "orange", width = 2)

            canvas.create_rectangle(500, 300, 600, 300 - (math.ceil(float(metar[listvar.get()]['degrees'][:len(metar[listvar.get()]['degrees'])-1])*(20/9)) ), fill = "red", width = 2)
            canvas.create_rectangle(500, 300, 600, 300 - math.ceil(float(metar[listvar.get()]['dewPoint'][:len(metar[listvar.get()]['dewPoint'])-1])*(20/9)), fill = "blue", width = 2)
            canvas.create_text(320, 520, text = visVar.get(), fill = "green", font=('Helvetica','20'), tags = "airport_vis")

    # Listen for the dropdown to change. When it does, the function drop_changed is called.
    listvar.trace('w', drop_changed)
    # You need to draw the text manually with the first choice.
    drop_changed()
    # mainloop() is necessary for handling events
    tk.mainloop()
    
    
    


# In[31]:


# Entry point for running programs
if __name__ == "__main__":
    #Need these lines so we can read in the data from the website and store it
        data = rq.get("https://aviationweather.gov/metar/data?ids=KLAS,KDFW,KBOS,KSTL,KTYS,KCLT&format=raw&date=&hours=0")
        needle = "<!-- Data starts here -->" 
        needle_position = data.text.find(needle) + len(needle) 
        data = data.text[needle_position:] 
        needle = "<!-- Data ends here -->" 
        needle_position = data.find(needle) 
        data = data[:needle_position]

        metars = []
        needle = "<code>"
        while True: 
            pos_s = data.find(needle) 
            if pos_s == -1: 
                break 
            pos_e = data.find("</code>") 
            if pos_e != -1: 
                apt = data[pos_s + len(needle):pos_e] 
                data = data[pos_e + len(needle) + 1:] 
            else: 
                apt = data[pos_s + len(needle):] 
                data = ""
            metars.append(apt) 
        
        #Making call so we can begin to split the data we just read in
        splitString(metars)
        
        #Getting our original dictionary and list of airports instantiated
        airportInfo, airports = dictionaryOfData(metars)
        
        #copying our dictionary and formatting it for our GUI
        formattedAirports = formattedDict(airportInfo, airports)
        
        #Making the call to our function for our canvas+widgets to be able to dynamically display data
        run(formattedAirports, airports)


#  

# In[ ]:





# In[ ]:





# In[ ]:





# In[ ]:




