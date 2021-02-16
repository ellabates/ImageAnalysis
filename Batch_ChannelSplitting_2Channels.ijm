//Batch Photobleach Correction Macro for stimulated respsonse (2 Channel).
//Ella Bates.
//What it does:
//1)Opens first stack in directory. Creates a Hyperstack of the trimmed stack.
// Separates the two channels and saves them as seperate tiffs with _green and _red.
// Saves the new tif to a second directory with the name _PBCorrected.
// Opens next stack in the directory and repeats.

//Reset everything.
roiManager("reset");
run("Clear Results");

//Define directory and path.
dir1 = getDirectory("Choose a Directory ");
dir2 = getDirectory("Choose Green/Red Destination Directory ");
setBatchMode(true); 
list = getFileList(dir1);
//list = getFileList(dir1);

//Open an image from dir1 chronolocically.
i=0
do {
	
	run("Bio-Formats Importer", "open=["+ dir1 + list[i] +"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	path = getDirectory("image");
	//Reset ROI Manager, Log and Results table. 
	rename("Hyperstack");
	roiManager("reset");
	run("Select None");
	run("Clear Results");

	//Set to measure mean intensity values of ROIs, select tool.
	run("Set Measurements...", "  mean redirect=None decimal=12");
	setTool("rectangle");

	//Set ROI of the entire image and add it. 
	run("Select All");
	roiManager("Add");
	roiManager("Select", 0);


	//Get the stack dimentions.
	getDimensions(width, height, channels, slices, frames);
	nF = frames;

	//Select each channel.
	s = 1;
	do { 
		//Define yref - the mean grey value of the first frame of your channel.
		selectWindow("Hyperstack");
		setSlice(s);
		Stack.setFrame(1);
		run("Enhance Contrast", "saturated=0.35");
	 
		s = s + 1;
	
	} while(s<=2);
         
	//Split Channels and save.
	selectWindow("Hyperstack");
	setSlice(1);
	Stack.setFrame(1);
	run("Duplicate...", "duplicate channels=1");
	run("Green");
	//run("8-bit");
	//Save PB corrected stacks.
	saveAs("Tiff",dir2+list[i]+"_PBCGreen");

	selectWindow("Hyperstack");
	setSlice(2);
	Stack.setFrame(1);
	run("Duplicate...", "duplicate channels=2");
	run("Red");
	//run("8-bit");
	//Save PB corrected stacks.
	saveAs("Tiff",dir2+list[i]+"_PBCRed");

	//Close all wondows.
	run("Close All");

	i=i+1;
	}

	while (i < list.length);


