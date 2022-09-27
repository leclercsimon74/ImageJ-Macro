run("Close All"); //security
dir = getDirectory("Choose directory");
listFiles(dir);

function listFiles(dir) {
   list = getFileList(dir);
   for (i=0; i<list.length; i++) {
      if (endsWith(list[i], "/")) //folder
         listFiles(""+dir+list[i]);
      if (endsWith(list[i], ".tif")) //images
      	 processImage(dir+list[i]);
   }
}

function processImage(path){
	open(path); //open
	run("HiLo");
	//User need to click on OK to proceed!
	//waitForUser('Manual crop');
	Dialog.createNonBlocking("Manual crop");
	Dialog.addCheckbox("Pass this image", false); //if checked, will NOT process this image at all
	Dialog.show();
	continue_choice = Dialog.getCheckbox();

	if (continue_choice == 0){
		if(selectionType != -1){ //if selection, clear outisde, otherwise do nothing
			run("Clear Outside", "stack");
		}
	
		run("Grays"); // Gray LUT
		path_to_save = File.getDirectory(path);
		path_to_save = path_to_save + File.separator + "Split";
		if (File.exists(path_to_save) != 1){ //Folder does not exist!
			File.makeDirectory(path_to_save); //make the folder
		}
		
		getDimensions(width, height, channels, slices, frames);
		if (channels > 1){
			run("Split Channels"); // split the channel
		}
		
		ch_nbr = nImages;
		for (c=1; c<=ch_nbr; c++){	
			selectImage(c);
			img_name = getTitle();
			saveAs("Tiff", path_to_save+File.separator+img_name);
		}
		
		run("Close All");
	}
	else{ // image is to be NOT process, close it
		run("Close");
	}
}

print("Finished!");