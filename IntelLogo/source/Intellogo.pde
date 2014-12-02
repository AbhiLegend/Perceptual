import intel.pcsdk.*;
/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/8233*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */


  ////////////////////////////
  //                        //
  //        PI DAY          //
  //                        //
  ////////////////////////////

  // (c) Martin Schneider 2010
  float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
  

int lucent = 80;
int tween = 20;
int th = 6, tw = 4;
color c1 = #000000;
color c2 = #ffffff;

PFont tinyFont;
ArrayList pishape;
PVector center0, center;
int w, h, x0, y0, r, digits;
color bg, fg;
float tweener;
String s;

boolean positive, invert=true;


void setup() {  
 
  // center image
  size(401, 403);
  w = width;
  h = height;
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
{
println("Failed to initialize the PXCUPipeline!!!");
    exit();
}
  center0 = new PVector(w/2, h/2);
  center = new PVector(w/2, h/2);
  x0 = ((w+1)%tw)/2;
  y0 = ((h+1)%th)/2;
  r =  min(w/2, h/2);
  
  // load font
  tinyFont = loadFont("tinyfont.vlw");
  textFont(tinyFont);
  textAlign(LEFT);

  // calculate PI
  int maxdigits =  (w/tw) * (h/th) - 2;
  s = (PI(maxdigits)).toString();
  
  // do the graphics
  setupDigits();
  
}

void setupDigits() {

  // load symbol image
  PImage img = loadImage("pi1.jpg");
  
  // pick sample color
  pickColors(#000000, #ffffff, positive);

  // sample digits
  pishape = new ArrayList();
  int y = y0 + th-1;
  int x = x0, i = 0;
  while(i < s.length() && y<=h) {
    //sample current position
    color sample = img.get(x + tw/2, y - th/2);
    if(sample == fg) { pishape.add(new PVector(x, y)); i++; }
    // go to next position
    x = x + tw;
    if(x >= w) { x = x0; y += th; } 
  }
  digits = i;
  
} 


void draw() {
  
  centerTween();
  pickColors(c1, c2, invert);
  if(session.AcquireFrame(false))
  {
    if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
    {
      mHandPos[0] = hand.positionImage.x;
      mHandPos[1] = hand.positionImage.y;
      mHandPos[2] = hand.positionWorld.y;
      mHandPos[3] = hand.openness;
    }
    session.ReleaseFrame(); //must do tracking before frame is released
  }
  background(bg);
  fill(fg, lucent);  
  for(int i=0; i < digits; i++) {
    PVector v = digit(i);
    text(s.charAt(i), v.x, v.y);
  }
}

void pickColors(color c1, color c2, boolean pick) {
  bg = color(pick ? c1 : c2);
  fg = color(pick ? c2 : c1); 
}

// switch modes
void keyPressed() {
  switch(key) {
    case 'p' : positive = ! positive; setupDigits(); break;
    case 'i' : invert   = ! invert;   break;
  }
}




