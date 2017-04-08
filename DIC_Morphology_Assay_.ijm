// This plugin segments isolated objects (cells in culture, for now) in DIC images and analyzes their shapes.
// The assay was used to measure shape changes as cells progressed from metaphase to anaphase as a measure 
// of cytokinesis dynamics.




run("Set Measurements...", "area mean standard min perimeter shape integrated median stack display redirect=None decimal=4");


dir2 = getDirectory("Choose Destination Directory ");
CELLviboud = getImageID();
t = getTitle();


selectImage(CELLviboud);
getDimensions(width, height, channels, slices, frames);
for (i = 0; i < slices; i++) {
	selectImage(CELLviboud);
	j = i + 1;
	Stack.setPosition(1,j,1);
	// Modify two last values (number of pixels) to modify box size
	makeRectangle(20, 20, 375, 375);
  	title = "Select the area you want to quantify and click OK";
  	waitForUser(title);
	run("Duplicate...", "getTitle(viboud)");
}
selectImage(CELLviboud);
close();
run("Images to Stack", "method=[Copy (center)] name=Stack title=[] use");
DICviboud = getImageID();

t5= t + ' DIC';
rename(t5);
saveAs("Tiff", dir2 + t5 + ".tif"); 



selectImage(DICviboud);
//run("Set Scale...", "distance=9.3197 known=1 pixel=1 unit=µm");

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
	// The 0.42 below is the value that should be adjusted if modifications are to be made
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
selectImage(cytokinesis);
t3= t + ' segmented';
rename(t3);
saveAs("Tiff", dir2 + t3 + ".tif"); 

selectImage(cytokinesis);
run("Analyze Particles...", "size=200-900 add stack");
roiManager("Measure");

t4= t + ' measurements';
if (nResults==0) exit("Results table is empty");
   saveAs("Measurements", dir2 + t4 + ".xls");
selectImage(cytokinesis);
close();
selectImage(DICviboud);
close();
roiManager("reset");
run("Clear Results"); 

setBatchMode("exit & display");


