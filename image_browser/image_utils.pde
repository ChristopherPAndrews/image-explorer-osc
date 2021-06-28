
float luminance(color c){
  return (0.299 * red(c) + 0.587 * green(c) + 0.114 * blue(c));
}


float[] makeGrayScale(PImage img){
  img.loadPixels();
  float[] result = new float[img.pixels.length];

  for (int i = 0; i < img.pixels.length; i++) {
    result[i] = luminance(img.pixels[i]);
  }
  
  return result;
}


ImageRepresentation computeLuminance(PImage img) {
  float[] result = makeGrayScale(img);
  return new ImageRepresentation(result, img.width, img.height, "luminance");
}


ImageRepresentation computeHighPass(PImage img){

  float[] kernel = {-1, -1, -1, -1, -1,
                    -1, -1, -1, -1, -1,
                    -1, -1, 24, -1, -1,
                    -1, -1, -1, -1, -1,
                    -1, -1, -1, -1, -1};
  
  
  float[] data = applyFilter(makeGrayScale(img), img.width, img.height, kernel, 1);
  return new ImageRepresentation(data, img.width, img.height, "high-pass");
}



ImageRepresentation computeLowPass(PImage img){
  int size = 11;
  int half = size/2;
  float[] result = new float[img.pixels.length];
 
  for (int index = 0; index < img.pixels.length; index++){
      int y = (int) index /img.width;
      int x = (int) index % img.width;
      int value = 0;
      int counter = 0;
      for (int j = -half; j <= half; j++){
        int y1 = y + j;
        if (y1 >= 0 && y1 < img.height){
          for (int i = -half; i<= half; i++){
            int x1 = x + i;
            if (x1 >= 0 && x1 < img.width){
              counter+= 1;
              value += luminance(img.pixels[x1 + y1*img.width]);
            }
          }
        }
      }
      
      result[index] = (value / counter);
  }
  
  
  return new ImageRepresentation(result, img.width, img.height, "low-pass");
}



ImageRepresentation computeEdgeDetect(PImage img){
  int THRESHOLD = 50;
  float[] pixels = makeGrayScale(img);
  
  float[] kernelblur = {1,1,1,
                        1,1,1,
                        1,1,1};
    float[] kernelX = {1, 0, -1, 
                    2, 0, -2, 
                    1, 0, -1};
                    
   float[] kernelY = {1, 2, 1, 
                    0, 0, 0, 
                   -1, -2, -1};
                   
                   
   pixels =  applyFilter(pixels, img.width, img.height, kernelblur, 1/9.0);               
   float[] xdata = applyFilter(pixels, img.width, img.height, kernelX, 1);
   float[] ydata = applyFilter(pixels, img.width, img.height, kernelY, 1);
   
   float[] edges = new float[pixels.length];
   
   
   for (int i = 0; i < edges.length; i++){
    edges[i] = sqrt(xdata[i] * xdata[i] + ydata[i] * ydata[i]) > THRESHOLD ? 255 : 0;
   }
  
  return new ImageRepresentation(edges, img.width, img.height, "edges");
}



float[] applyFilter(float[] original, int w, int h, float[]  kernel, float constant){
  float[] result = new float[original.length];
  int size = (int)sqrt(kernel.length);
  int half = size/2;

 
  for (int index = 0; index < original.length; index++){
      int y = (int) index /w;
      int x = (int) index % w;
   
      int value = 0;
      
      if (x >= half && x < w - half && y >= half && y < h - half){
      
        for (int j = -half; j <= half; j++){
          int y1 = y + j;
          if (y1 >= 0 && y1 < h){
            for (int i = -half; i<= half; i++){
              int x1 = x + i;
              if (x1 >= 0 && x1 < w){
                value += kernel[(i+half) + (j+half)*size] * original[x1 + y1*w];
              }
            }
          }
        }
      }
      
      result[index] = constant * value;
  }
  
  return result;
  
}



/**
This class provides a standard image representation.
It includes a PImage for display, the raw, normalized data for sonification, and a name.
***/

class ImageRepresentation {
  String name;
  PImage visual;
  float[] raw;
  int img_w, img_h;

  ImageRepresentation(float[] data, int w, int h, String imageName) {
    name = imageName;
    raw = data;
    img_w = w;
    img_h = h;
    buildImage();
  }
  
  ImageRepresentation(PImage img, String imageName){
    name = imageName;
    visual = img;
    img_w = img.width;
    img_h = img.height;
    img.loadPixels();
    raw = new float[img.pixels.length];

    for (int i = 0; i < img.pixels.length; i++) {
      raw[i] = luminance(img.pixels[i]) / 255;
    }
  }
  
  private void buildImage(){
    // find the range of the raw data
    float low = raw[0];
    float high = raw[0];
 
    for (int i = 0; i < raw.length; i++){
      low = min(low, raw[i]);
      high = max(high, raw[i]);
    }
   
    
    // make an image from the data
    visual = createImage(img_w, img_h, RGB);
    visual.loadPixels();
    for (int i = 0; i < raw.length; i++){
      //int value = (int)max(0, min(255, abs(raw[i])));
      raw[i] = map(raw[i], low, high, 0, 1);
      int value = (int)(raw[i] * 255);
      visual.pixels[i] = color(value, value, value);
    }
    visual.updatePixels();
  }
  
  
}
