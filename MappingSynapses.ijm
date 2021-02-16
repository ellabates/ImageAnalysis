//Overlays two images and allows to measure synapse distances from the soma.

path_ROI = File.openDialog("Load ROI Overlay image");
open(path_ROI);
run("Duplicate...", "title=ROI");
run("Enhance Contrast", "saturated=0.35");
run("Size...", "width=512 height=64 depth=1 average interpolation=None");
run("Flip Vertically");
path_Stack = File.openDialog("Load image Stack");
open(path_Stack);
run("Enhance Contrast", "saturated=0.35");
path_Snap = File.openDialog("Load Snap image");
open(path_Snap);
run("Enhance Contrast", "saturated=0.35");
run("Add Image...", "image=ROI x=0 y=0 opacity=33");
run("ROI Manager...");
run("To ROI Manager");
roiManager("Select", 0);
showMessageWithCancel("Protocol: Multiloader","Summary of protocol steps:\n"+
					"1: Align Images\n"+
					"2: Draw line to the Soma\n"+
					"3: Press m after each line\n"+
					"Press OK on this dialog to begin")
setTool("polyline");