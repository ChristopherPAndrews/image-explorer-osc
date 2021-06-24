
float luminance(color c){
  return (0.299 * red(c) + 0.587 * green(c) + 0.114 * blue(c));
}


ImageRepresentation computeLuminance(PImage img) {
  img.loadPixels();
  float[] result = new float[img.pixels.length];

  for (int i = 0; i < img.pixels.length; i++) {
    result[i] = luminance(img.pixels[i]) / 255;
  }
  return new ImageRepresentation(result, img.width, img.height, "luminance");
}


ImageRepresentation computeHighPass(PImage img){
  float[] kernel = {0, -1, 0, -1, 4, -1, 0, -1, 0};
  
  
  float[] data = applyFilter(img, kernel, 1);
  return new ImageRepresentation(data, img.width, img.height, "high-pass");
}


ImageRepresentation computeSobelX(PImage img){
  float[] kernel = {1, 0, -1, 2, 0, -2, 1, 0, -1};
  
  
  float[] data = applyFilter(img, kernel, 1);
  return new ImageRepresentation(data, img.width, img.height, "sobelX");
}

ImageRepresentation computeSobelY(PImage img){
  float[] kernel = {1, 2, 1, 0, 0, 0, -1, -2, -1};
  
  
  float[] data = applyFilter(img, kernel, 1);
  return new ImageRepresentation(data, img.width, img.height, "sobelY");
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



float[] applyFilter(PImage img, float[]  kernel, float constant){
  float[] result = new float[img.pixels.length];
 
  for (int index = 0; index < img.pixels.length; index++){
      int y = (int) index /img.width;
      int x = (int) index % img.width;
      int value = 0;
      for (int j = -1; j <= 1; j++){
        int y1 = y + j;
        if (y1 >= 0 && y1 < img.height){
          for (int i = -1; i<= 1; i++){
            int x1 = x + i;
            if (x1 >= 0 && x1 < img.width){
              value += kernel[(i+1) + (j+1)*3] * luminance(img.pixels[x1 + y1*img.width]);
            }
          }
        }
      }
      
      result[index] = constant * value;
  }
  
  return result;
  
}





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
      raw[i] = map(raw[i], low, high, 0, 1);
      int value = (int)(raw[i] * 255);
      visual.pixels[i] = color(value, value, value);
    }
    visual.updatePixels();
  }
  
  
}
