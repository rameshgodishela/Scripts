#!/usrbin/env python

"""
#Strengths:
This script will show the duplicate files list so that you can decide to clear up the space for better consumption of disk space.

#Weeknesses:
This script will not go into subdirectories to compare the the files within.

"""
###importing supported modules
import filecmp
import os
from os import listdir
from os.path import isfile, join
import sys

###Checking whether the directory is passed as a argument otherwise program exits.
if len(sys.argv) > 1:
   path=sys.argv[1]
else:
   print "you must pass a directory as a argument!"
   sys.exit()

### Created a function delete the duplicates
def unify(seq): 
   checked = []
   for e in seq:
       if e not in checked:
           checked.append(e)
   return checked

### Used list comprehension concept to get all filenames as a list
files = [f for f in listdir(path) if isfile(join(path, f))]

### Created an empty dictionary, two empty lists 
final = {}
matched_list = []
total_list = [] 

### Created a nested loop to match the files and store them in a list and add the list to another list 
for i in files:
   for j in files:
      if filecmp.cmp(i, j):
         matched_list.append(j)
         continue
   total_list.append(matched_list)
   matched_list = []

### remove the duplicate lists from the final list
unique_list = unify(total_list)

### add the unique list to a dictionary
final["matches"] = unique_list

### print the output as requested in the problem statement
print final