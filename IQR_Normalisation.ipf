#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
//Normalises traces using their interquartile range. 
//Saves them individually and creates a second concatenated wave.

Function IQR(inputwave,inputwave1,Delta)
Variable Delta
Wave inputwave, inputwave1
Variable nRows, nColumns, nTotal
nRows = dimSize(inputwave,0)
nColumns = dimSize(inputwave,1)
nTotal = nRows * nColumns

Duplicate/O/R=[][0] inputwave, $"tempwave1"
Make/O/N=(nRows, 0) tempwave1
StatsQuantiles/Q/BOX/QW tempwave1
V_IQR /= 1.35
MatrixOP/O IQRNormalised_Green = tempwave1/V_IQR
Make/O/N=(1, nColumns) IQRGreen



Variable j

for(j=1; j<nColumns; j++)	

Duplicate/O/R=[][j] inputwave, $"tempwave1"
Make/O/N=(nRows, 1) tempwave1
StatsQuantiles/Q/BOX/QW tempwave1
V_IQR /= 1.35
MatrixOP/O tempwave2 = tempwave1/V_IQR
Concatenate/NP=1 {tempwave2}, IQRNormalised_Green
SetScale /P x DimOffset(IQRNormalised_Green,0), Delta, WaveUnits(IQRNormalised_Green,0), IQRNormalised_Green

endfor



Duplicate/O/R=[][0] inputwave1, $"tempwave1"
Make/O/N=(nRows, 0) tempwave1
StatsQuantiles/Q/BOX/QW tempwave1
V_IQR /= 1.35
MatrixOP/O IQRNormalised_Red = tempwave1/V_IQR


for(j=1; j<nColumns; j++)	

Duplicate/O/R=[][j] inputwave1, $"tempwave1"
Make/O/N=(nRows, 1) tempwave1
StatsQuantiles/Q/BOX/QW tempwave1
V_IQR /= 1.35
MatrixOP/O tempwave2 = tempwave1/V_IQR
Concatenate/NP=1 {tempwave2}, IQRNormalised_Red
SetScale /P x DimOffset(IQRNormalised_Red,0), Delta, WaveUnits(IQRNormalised_Red,0), IQRNormalised_Red

endfor

KillWaves tempwave1, tempwave2

Duplicate/O IQRNormalised_Green, $"IQRN_Concatenated_Green"
Duplicate/O IQRNormalised_Red, $"IQRN_Concatenated_Red"
Wave IQRN_Concatenated_Green = $"IQRN_Concatenated_Green"
Wave IQRN_Concatenated_Red = $"IQRN_Concatenated_Red"      
Redimension/N=(nTotal) IQRN_Concatenated_Green
Redimension/N=(nTotal) IQRN_Concatenated_Red
SetScale /P x DimOffset(IQRN_Concatenated_Green,0), Delta, WaveUnits(IQRN_Concatenated_Green,0), IQRN_Concatenated_Green
SetScale /P x DimOffset(IQRN_Concatenated_Red,0), Delta, WaveUnits(IQRN_Concatenated_Red,0), IQRN_Concatenated_Red

end

