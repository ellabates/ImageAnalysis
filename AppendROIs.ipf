#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Start by manually getting the average Image then run this code //to append selected ROIs onto the image

Function A()
String AveStack = Wavelist("*PBCGreen_Ave","","")
String ROIlist 
Variable n


ROIlist = WaveList("ROI*",";","")
n = ItemsInList(wavelist("ROI*",";",""))
print n
Display;DelayUpdate
AppendImage $AveStack

Variable i


for(i=0; i<n; i++)
String ROIname = stringfromlist(i,ROIlist)
AppendImage $ROIname
ModifyImage $ROIname cindex= $ROIname,minRGB=(65535,0,0),maxRGB=NaN

endfor

ModifyGraph nticks=0,noLabel=2,axThick=0
ModifyGraph margin=-1
SavePICT/E=-7/B=72  // Saves as a .png file with no border
end