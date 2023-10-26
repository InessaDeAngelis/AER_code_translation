** installs all dependencies locally and sets root folder, and should be run once.

net install grc1leg,from( http://www.stata.com/users/vwiggins/)
 
/*
set pathway to folder
*/

global root //"[set pathway here to the local folder of replication package]"
mkdir "$root/Results" 
mkdir "$root/Data/Output" 
 
