PImage img;
import oscP5.*;
import netP5.*;

OscP5 osc;
NetAddress receiver;


//HashMap<String, ImageRepresentation> representations = new HashMap<String, ImageRepresentation>();
ArrayList<ImageRepresentation> representations = new ArrayList<ImageRepresentation>();



int current = 0;


void setup(){
  size(700, 600);
  
  imageMode(CENTER);
}


void draw(){
  background(255);
  if (img != null){
    ImageRepresentation rep = representations.get(current);
   image(rep.visual, 300,300); 
   fill(0);
   textSize(14);
   text(rep.name, 610, 50);
   
   
    
    int imouseX = mouseX - (300 - img.width/2);
    int imouseY = mouseY - (300 - img.height/2);
    
    if (imouseX >= 0 && imouseX < img.width && imouseY >= 0 && imouseY < img.height){
     for (ImageRepresentation r: representations){
       r.visual.loadPixels();
       println(r.name, r.raw[imouseX + imouseY*img.width], red(r.visual.pixels[imouseX + imouseY*img.width])); 
     }
    }
  }
}
  
  
void keyTyped(){
  switch(key){
     case 'i':
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
    representations.clear();
    representations.add(new ImageRepresentation(tmp, "raw"));
    representations.add(computeLuminance(tmp));
    representations.add(computeHighPass(tmp));
    representations.add(computeLowPass(tmp));
    representations.add(computeSobelX(tmp));
    representations.add(computeSobelY(tmp));
    
    current = 0;
    
    
    img = tmp;
    
  }
}
