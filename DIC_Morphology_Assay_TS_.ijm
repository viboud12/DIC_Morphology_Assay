// This troubleshooting plugin uses the selected image for quantification from the 
// DIC_Morphology_Assay_.ijm plugin and displays what the threshold of your choice is quantifying.

run("Set Measurements...", "area mean standard min perimeter shape integrated median stack display redirect=None decimal=4");

DICviboud = getImageID();

selectImage(DICviboud);
//run("Set Scale...", "distance=9.3197 known=1 pixel=1 unit=µm");
t = getTitle();
t2= t +' processed';
setBatchMode(true);
selectImage(DICviboud);

major = getImageID();
getDimensions(width, height, channels, slices, frames);
for (l = 0; l < slices; l++) {
	m = l + 1;
	selectImage(major);
	Stack.setPosition(1,m,1);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=100");
	majorBlur = getImageID();
	imageCalculator("Subtract create 32-bit", majorBlur,major);
	run("Gaussian Blur...", "sigma=2");
	major2 = getImageID();
	selectImage(majorBlur);
	close();
	selectImage(major2);
	run("Find Edges");
	getStatistics(area, mean, min, max, std, histogram);
	// The 0.07 below is the value that should be adjusted if modifications are to be made
	// for use with different data sets
	favThresh = min + 0.07*(max-min);
	setThreshold(favThresh, max);
	run("Convert to Mask");
	run("Despeckle");
	run("Fill Holes");
	run("Minimum...", "radius=10");
}
run("Images to Stack", "name=thresholdedCroppedStack title=[] use");
cytokinesis = getImageID();



roiManager("reset");
run("Clear Results"); 

setBatchMode("exit & display");