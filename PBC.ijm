
//Photobleach Correction Macro for stimulated respsonse. 
//Ella Bates. 
//What it does: 
//1)Creates a Hyperstack of the trimmed stack. 
//2)Takes first 39 frames and last 20 frames of the stack and fits an exponential with offset to it. 
//3)Extracts the parameters of the exponential fit and extrapolates the fit for 150 frames. 
//4)Divides the original stack by each value of the exponential fit at that time. 
//5)Relative to the reference fluorescence taken from the Mean grey value of the first frame from the first stack.
//Rename stack to Hyperstack. 
//Load stack and set it to current window
//Reset ROI Manager, Log and Results table. 
rename("Hyperstack"); 
roiManager("reset"); 
run("Select None"); 
run("Clear Results");
//Make a hyperstack. 
//run("Stack to Hyperstack...", "order=xyctz channels=1 slices=100 frames=150 display=Grayscale");
//Set to measure mean intensity values of ROIs, select tool 
run("Set Measurements...", " mean redirect=None decimal=12"); 
setTool("rectangle");
//Set ROI of the entire image and add it. 
run("Select All"); 
roiManager("Add"); roiManager("Select", 0);
//Define yref - the mean grey value of the first frame. 
Stack.setSlice(1); Stack.setFrame(1); 
roiManager("Measure"); 
yref = getResult("Mean",0)
//Define variables: nS(number of stacks), s(stack sumber), nF(number of frames). 
//y=newArray; 
//yexpo=newArray(); 
//nS = 100; 
nF= nSlices; 
//s=1;
// do { //Get the x,y valyes of the current slice //selectWindow("Hyperstack.tif"); 
//Stack.setSlice(s); 
run("Plot Z-axis Profile", "profile=time"); Plot.getValues(xpoints, ypoints);
//Concatenate the first 39 and last 20 points. 
xstart= Array.slice(xpoints, 0, 40); 
ystart= Array.slice(ypoints, 0, 40);
xend= Array.slice(xpoints, xpoints.length-5); 
yend= Array.slice(ypoints, ypoints.length-5);
v = Array.concat(xstart, xend); 
w = Array.concat(ystart, yend);
Fit.doFit("Exponential with Offset", v, w); 
Fit.plot;
a=Fit.p(0); 
b=Fit.p(1); 
c=Fit.p(2);
       f = 1;
           do {      
                  y=a*exp(-b*f)+c;
                  z=y/yref;
                  selectWindow("Hyperstack");
                  //Stack.setSlice(s);
                  Stack.setFrame(f);
                  run("Divide...", "value="  + z + " slice");
                  //Stack.getPosition(channel, slice, frame);
                  //Stack.setFrame(frame + 1);
                  f = f +1;

            } while(f<=nF);
//Close plots // close("Hyperstack.tif-0-0"); // close("y = a*exp(bx)"); // s = s+1; // } while(s<=nS);
//} while(s<=20);
Stack.setSlice(1); Stack.setFrame(1);
saveAs("Tiff");