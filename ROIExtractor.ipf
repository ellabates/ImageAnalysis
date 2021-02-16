#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Finds the active ROIs and makes a new ROI mask with them.
Function ROI(Value)
Variable Value
Wave MTROIWave
Variable nRows, nColumns
Variable i, j
Variable Value2
String wavename = num2str(Value)
String ROIname = "ROI"+wavename

Duplicate /O MTROIWave, inputwave
nRows = dimSize(inputwave,0)
nColumns = dimSize(inputwave,1)
Value2=-Value-1
Make/O/N=(nRows, nColumns) tempwave
tempwave=1
for(j=0; j<nColumns; j++)	
for(i=0; i<nRows; i++)	
if (inputwave[i][j] == Value2)
tempwave[i][j] = Value2
Duplicate /O tempwave, $ROIname
endif
endfor
endfor

end


