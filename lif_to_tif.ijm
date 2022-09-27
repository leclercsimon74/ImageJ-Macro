// open the file manager to select a folder of lif file to break it into TIFFs
// in this case, only the metadata specific to a series will be written
// recursive, save the tiff in the same folder than the lif

dir = getDirectory("Choose directory"); 
setBatchMode(true); //do not display the images open by imageJ => gain of speed

count = 1;
listFiles(dir); 

function listFiles(dir) {
   list = getFileList(dir);
   for (i=0; i<list.length; i++) {
      if (endsWith(list[i], "/")) // recursive
         listFiles(""+dir+list[i]);
      if (endsWith(list[i], ".lif")) //only lif file
      	 processImage(dir+list[i]);
   }
}

function processImage(path){
	run("Bio-Formats Macro Extensions");
	Ext.setId(path);
	Ext.getCurrentFile(file);
	Ext.getSeriesCount(seriesCount);
	
	for (s=1; s<=seriesCount; s++) {
		run("Bio-Formats Importer", "open=&path autoscale color_mode=Default view=Hyperstack stack_order=XYCZT series_"+s);
		title = getTitle()+"_"+ s + ".tif";
		title = title.replace("[/:*?\"<>|]", "");
		print(getDirectory("image") + title);
		saveAs("Tiff", getDirectory("image") +title);
		close();
	}
}