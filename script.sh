#!/bin/bash
## This application helps you to download and save the images of a valid website address you entered.

#   This script is tested on the Amazon Linux-2 instance on AWS .

_current_label="entry"
getURL_function(){
echo "Enter a valid URL:"
read URL  # get URL input from user
VALID='(https?|ftp|file)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]' # VALID is a variable to check if the URL format is appropriate or not according to given conditions below.

if [[ $URL =~ $VALID ]]; then 
    echo "Valid URL:$URL."
	_current_label="done"
else
    echo "Invalid URL!!!"
   _current_label="invalid"
fi
}
while [ "$_current_label" != "done" ];
do
  getURL_function ; 
done


_current_label="entry"
getDIRPATH_function(){
# Write down the correct path of directory to save the images downloaded or press enter to save in default directory.   
echo "Enter image download directory: [ $PWD/downloads ] for default press Enter"
read DIRPATH # get DIRPATH input 
DIRPATH=${DIRPATH:-$PWD\/downloads} # Create a default "downloads" directory to be used in case of not entered by the user.

if [ -d $DIRPATH ]; then
     echo "Image download directory exists, removing png files under $DIRPATH"
     rm -rf ${DIRPATH}/*.png
	 _current_label="done"
else
     echo "$DIRPATH Not exist!!!, creating it..."
     mkdir ${DIRPATH}
     _current_label="done"	 
fi
}
while [ "$_current_label" != "done" ];
do
  getDIRPATH_function ; 
done

# Optional username and password entry and Basic Auth usage.
echo "Please enter your username (if not just press Enter): "  
read USERNAME  #Assign input value into a variable 
echo "Please enter your password (if not just press Enter): "  
read PASSWORD  # Assign input value into a variable 

if [-z $USERNAME]; then
     wget -k -O webpage.html --content-disposition $URL # Download index page with wget, "k" option converts local links to global.
else
     wget -k -O webpage.html --content-disposition --user=$USERNAME --password=$PASSWORD $URL 
     # Download index page with wget, "k" option converts local links to global.
fi

# Extraction rules for the script download. 

cat webpage.html | grep .png | sed -E -n '/<img/s/.*src="([^"]*)".*/\1/p' > $DIRPATH/links.txt
# get the downloaded webpage.html file, grep .png extentioned lines case-insensitively only from <img> tagged sources in HTML file, save them as are to links.txt file in DIRPATH directory

cat ${DIRPATH}/links.txt | sed -e 's/\.png.*$/.png/' > $DIRPATH/links2.txt
# get the links.txt file, remove all the characters of the lines which are after the .png extension and save them to links2.txt

cat | awk '!seen[$0]++' ${DIRPATH}/links2.txt > ${DIRPATH}/links.txt
# remove the duplicate lines of .png extensioned images from the links2.txt file and save them to links.txt file 

cd ${DIRPATH} && rm -f links2.txt && wget -i $DIRPATH/links.txt --append-output=logfile  
# go to the image download directory, remove links2.txt, get the final URLs from links.txt file and save the images to logfile and download them. Upon seeing the message for "Converted xxx files in yyy seconds."  press enter to exit. 

# Finally,check the DIRPATH or default "downloads" directory for the final links.txt file, logfile including "download" and "save" processes and see the downloaded images. Compare the URLs lines in links.txt  and the number of downloaded images from the URL. Run the script again for another URL, see that links.txt and downloaded images are updated and previous ones deleted. And logfile is also updated including previous logs on each test. 

#   The output of this script is tested on the Amazon Linux-2 instance on AWS ********