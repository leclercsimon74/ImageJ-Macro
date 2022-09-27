run("Close All"); //security
dir = getDirectory("Choose directory");
listFiles(dir);


function listFiles(dir) {
   list = getFileList(dir);
   for (i=0; i<list.length; i++) {
      if (endsWith(list[i], "/")) //folder
         listFiles(""+dir+list[i]);
      if (endsWith(list[i], ".tif")){ //images
      	if (list[i].contains("_clear")){continue;}
      	else{processImage(dir+list[i]);}
      }
   }
}



function processImage(path){
	open(path); //open
	name = getTitle();
	getDimensions(width, height, channels, slices, frames);
	
	if (Stack.isHyperstack){
		for(n=1;n<=frames;n++){
			//select window and extract the timeframe
			selectWindow(name);
			Stack.setFrame(n);
			run("Reduce Dimensionality...", "channels slices keep");
	
			//dialog and interaction
			Dialog.createNonBlocking("Manual crop");
			Dialog.addCheckbox("Pass this image", false); //if checked, will NOT process this image at all
			Dialog.show();
			continue_choice = Dialog.getCheckbox();
			
			if (continue_choice == 0){
				if(selectionType != -1){ //if selection, clear outisde, otherwise do nothing
					run("Grays"); // Gray LUT, security
					run("Clear Outside", "stack");
				}
				t = getTitle();
				t = t.replace("1.tif","");
				rename(t+n);
			}
			else{ // image is to be NOT process anymore, close it
				close();
				break; //exit the loop at this stage
			}
		}
		imgs = nImages;
		imgs--; //remove the original image from the count
		base_name = name.replace(".tif","");
		new_stack = name+"_clear";
		new_stack = new_stack.replace(".tif","");
		//Copy each frame stack and channel in the new hyperstack -- POWER method
		newImage(new_stack, "8-bit grayscale-mode", width, height, channels, slices, imgs);
		for(f=1;f<=imgs;f++){
			for (c=1;c<=channels;c++){
				for (s=1;s<=slices;s++){
					selectWindow(base_name+"-"+f);
					run("Select None");
					Stack.setChannel(c);
					Stack.setSlice(s);
					run("Copy");
					selectWindow(new_stack);
					Stack.setPosition(c, s, f);
					run("Paste");
				}
			}
			selectWindow(base_name+"-"+f);
			close();
		}
		//close and save everything
		selectWindow(new_stack);
		run("Save");
		close();
		selectWindow(name);
		close();
	}
}
