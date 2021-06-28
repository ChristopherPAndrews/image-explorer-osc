/**
This sketch allows the user to explor an image sonically. 

Behind the scenes a collection of image metrics are generated, and as the user mouses over the image, the 
values are shared over OSC. 

Currently, this shares seven float values over OSC:

- x position of the mouse
- y position of the mouse
- raw value of the pixel (currently this is just the grayscale value)
- grayscale value of the pixel
- highpass value (highlights details and change)
- lowpass value (average pixel value over the local neighborhood)
- edges (0 or 1 depending on whether or not the user us over an edge)

All values are currently normalized to fall between 0 and 1


The image browser itself is very simple. It resizes all images to 600x600 and allows the user to mouse 
over the image.

There are two keyboard controls

- 'i': allows the user to pick a new image
- 'n': allows the user to cycle through visual representations of the different filters (this doesn't change
the OSC output -- it is mostly for debugging)


[To function, this code requires `image_utils.pde` to be in the same directory.]
**/

String OSC_RECIEVER_ADDR = "127.0.0.1";
int OSC_RECEIVER_PORT = 4560;


PImage img;
import oscP5.*;
import netP5.*;

OscP5 osc;
NetAddress receiver;

ArrayList<ImageRepresentation> representations = new ArrayList<ImageRepresentation>();



int current = 0;


void setup(){
  size(700, 600);
  
  imageMode(CENTER);
  
  /* create a new instance of OscP5, the second parameter indicates the listening port */
  osc = new OscP5( this , 12000 );
  
  /* create a NetAddress which requires the receiver's IP address and port number */
  receiver = new NetAddress( OSC_RECIEVER_ADDR , OSC_RECEIVER_PORT );
  
  noLoop();
  selectInput("Select an image", "imageSelected");
}


void draw(){
  background(255);
  if (img != null){
    ImageRepresentation rep = representations.get(current);
    // display the image
    image(rep.visual, 300,300);
    fill(0);
    textSize(14);
    text(rep.name, 610, 50);
    
    // get the mouse location
    int imouseX = mouseX - (300 - img.width/2);
    int imouseY = mouseY - (300 - img.height/2);
    
    if (imouseX >= 0 && imouseX < img.width && imouseY >= 0 && imouseY < img.height){
      // assemble the OSC message
      OscMessage m = new OscMessage("/image-metrics");
      m.add(imouseX/(float)img.width);
      m.add(imouseY/(float)img.height);
      
      // iterate the various features
      for (ImageRepresentation r: representations){
        m.add(r.raw[imouseX + imouseY*img.width]);
      }
      
     osc.send(m, receiver);
    }
   }
}
  
  
void keyTyped(){
  switch(key){
     case 'i':
     noLoop();
       selectInput("Select an image", "imageSelected");
       break;
    case 'n':
      current = (current + 1) % representations.size();
      break;
      
  }
 
}


void imageSelected(File selection){
  PImage tmp;
  
  if (selection != null){
    tmp = loadImage(selection.getAbsolutePath());
    if (tmp.width > tmp.height){
      tmp.resize(600, 0);
    }else{
      tmp.resize(0, 600);
    }
    
    img = null;
    representations.clear();
    representations.add(new ImageRepresentation(tmp, "raw"));
    representations.add(computeLuminance(tmp));
    representations.add(computeHighPass(tmp));
    representations.add(computeLowPass(tmp));
    representations.add(computeEdgeDetect(tmp));

    
    current = 0;
    
    
    img = tmp;
   loop(); 
  }
}
