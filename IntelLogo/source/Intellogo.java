import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import intel.pcsdk.*; 
import java.math.BigDecimal; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Intellogo extends PApplet {


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
int c1 = 0xff000000;
int c2 = 0xffffffff;

PFont tinyFont;
ArrayList pishape;
PVector center0, center;
int w, h, x0, y0, r, digits;
int bg, fg;
float tweener;
String s;

boolean positive, invert=true;


public void setup() {  
 
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

public void setupDigits() {

  // load symbol image
  PImage img = loadImage("pi1.jpg");
  
  // pick sample color
  pickColors(0xff000000, 0xffffffff, positive);

  // sample digits
  pishape = new ArrayList();
  int y = y0 + th-1;
  int x = x0, i = 0;
  while(i < s.length() && y<=h) {
    //sample current position
    int sample = img.get(x + tw/2, y - th/2);
    if(sample == fg) { pishape.add(new PVector(x, y)); i++; }
    // go to next position
    x = x + tw;
    if(x >= w) { x = x0; y += th; } 
  }
  digits = i;
  
} 


public void draw() {
  
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

public void pickColors(int c1, int c2, boolean pick) {
  bg = color(pick ? c1 : c2);
  fg = color(pick ? c2 : c1); 
}

// switch modes
public void keyPressed() {
  switch(key) {
    case 'p' : positive = ! positive; setupDigits(); break;
    case 'i' : invert   = ! invert;   break;
  }
}






// Calculate PI with arbitrary precision
// ( source: http://java.sun.com/docs/books/tutorial/rmi/client.html )


BigDecimal FOUR = BigDecimal.valueOf(4);
int round = BigDecimal.ROUND_HALF_EVEN;

// Machins Formula :  pi/4 = 4*arctan(1/5) - arctan(1/239) 
public BigDecimal PI(int n) {
  int s = n + 5;
  BigDecimal atan5 = atan(5, s);
  BigDecimal atan239 = atan(239, s);
  BigDecimal pi = atan5.multiply(FOUR).subtract(atan239).multiply(FOUR);
  return pi.setScale(n, BigDecimal.ROUND_HALF_UP);
}

// Power Series expansion : atan(x) = x - (x^3)/3 + (x^5)/5 - (x^7)/7 +  (x^9)/9 ...
public BigDecimal atan(int invx, int s) {
  BigDecimal r, n, t, invx2 = BigDecimal.valueOf(invx * invx);
  r = n = BigDecimal.ONE.divide(BigDecimal.valueOf(invx) , s, round);
  int i = 1;
  do {
    n = n.divide(invx2, s, round);
    t = n.divide(BigDecimal.valueOf(2*i+1), s, round);
    r = (i%2 == 0) ? r.add(t) : r.subtract(t);
    i++;
  } while (t.compareTo(BigDecimal.ZERO) != 0);
  return r;
}



// Swarming behaviour for digits of PI

// digit position inside the precalculated pi-shape
public PVector pishape(int i) {
  return (PVector) pishape.get(i);
}

// digit position on the rotating ring
public PVector circle(int i, int dir) {
  float dr = .40f +  PApplet.parseFloat(i)/digits * .45f;
  float theta = -TWO_PI / w * 4;
  float delta = -frameCount * theta * .3f ;
  float x = w/2 + r * dr * cos(i*theta + delta);
  float y = h/2 + r * dr * sin(i*theta + delta) * dir;
  return new PVector(x*.8f + y*.2f, x*.2f + y*.8f);
}

// interpolated digit position
public PVector digit(int i) { 
  PVector v1 = circle(i, -1);
  PVector v2 = pishape(i);
  PVector v3 = circle(i, 1);
  float d = (mHandPos[0]-center.x)/w*2;
  float d1 = d > 0 ? d : 0;
  float d2 = d < 0 ? -d : 0;
  PVector v = lerp(lerp(v2, v3, d1), v1, d2);
  return lerp(center0, v, 1 + (center.y-mHandPos[1])/h);
}

// move center to mouse position if the mouse is pressed
public void centerTween() {
  PVector mouseV = new PVector(mHandPos[0], mHandPos[1]);
  tweener = constrain(tweener +  (mousePressed ? 1 : -1), 0, tween);
  center = lerp(center0, mouseV, tweener/tween);
}

// linear interpolation between vectors
public PVector lerp(PVector v1, PVector v2, float d) {
  return new PVector(lerp(v1.x, v2.x, d), lerp(v1.y, v2.y, d));  
}

  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "Intellogo" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
