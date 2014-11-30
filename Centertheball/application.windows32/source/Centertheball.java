import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import intel.pcsdk.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Centertheball extends PApplet {



/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/100392*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */
/*
Sal Spring
allonestring.co.uk
June 2013

playing with rotating arcs here called Rings
separate classes for the Ring and its
\u2022 Orbit = distance from the centre
\u2022 Colour
\u2022 Display = strokeWeight and blob size
separated out as the Ring class got too big

keyboard input for 
\u2022 [m]ore and [f]ewer Rings
\u2022 [r]andom, [u]niform and [t]unnel arrangements of Rings

beware - [t]unnel mode is a little nauseating!
*/

Ring[] rings;
Colour[] colours;
Orbit[] orbits;
Display displayInfo;

float a=0;
float b=0;
float posX;
float posY;
float change=0.05f;

float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();


int numShapes = 31;
int numVisible = 17;

float minRadius = 55;
float maxRadius = 270;
float orbitalSpacing;

Colour bgcolour;
int dark = color(20, 20, 30);
int medium = color(80, 100, 100);
int light = color(250, 240, 240);

String pattern = "RANDOM";//"UNIFORM";//"RANDOM";//TUNNEL


public void setup()
{
  size(550, 550);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
{
println("Failed to initialize the PXCUPipeline!!!");
    exit();
}

  bgcolour = new Colour();
  if (pattern == "UNIFORM")
  {
    bgcolour.target = dark;
  }
  else if (pattern == "TUNNEL")
  {
    bgcolour.target = medium;
  }
  else
  {
    bgcolour.target = light;
  }

  background(bgcolour.current);
  smooth();

  rings = new Ring[numShapes];
  orbits = new Orbit[numShapes];
  colours = new Colour[numShapes];
  displayInfo = new Display();

  for (int i = 0; i < numShapes; i++)
  {
    colours[i] = new Colour(i);
    colours[i].initialise();
    colours[i].renew();

    orbits[i] = new Orbit(i);
    orbits[i].initialise();
    orbits[i].renew();

    rings[i] = new Ring();
    rings[i].initialise();

    if (i < numVisible) rings[i].visible = true;
  }

  setOrbitalSpacing();
  displayInfo.renew();
}


public void draw()
{
  background(bgcolour.current);
  if(session.AcquireFrame(false))
  {
    getGesture();
    if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
    {
      mHandPos[0] = hand.positionImage.x;
      mHandPos[1] = hand.positionImage.y;
      mHandPos[2] = hand.positionWorld.y;
      mHandPos[3] = hand.openness;
    }
    session.ReleaseFrame(); 
    drawGesture();//must do tracking before frame is released
  }
  fill(60, 100, 0);
  ellipse(a, b, 20, 20);
  float invertedPositionImageX = map(mHandPos[0], 0, 320, 640, 0); 
  float invertedPositionImageY = map(mHandPos[1], 0, 320, 640, 0); 
 
  posX = invertedPositionImageX - a;
  posY = invertedPositionImageY - b;
 
  a += posX*change;
  b += posY*change;

  pushMatrix();
  translate(width/2, height/2);

  displayInfo.easeToStroke();
  displayInfo.easeToBlob();
  bgcolour.easeTo(bgcolour.target);

  for (int i = 0; i < numShapes; i++)
  {
    if (pattern == "TUNNEL") colours[i].renew();
    colours[i].easeTo(colours[i].target);
    orbits[i].easeTo();

    rings[i].colour = colours[i].current;
    rings[i].orbit = orbits[i].currentRadius;
    rings[i].update();
    rings[i].display();
  }

  popMatrix();
}

public void setOrbitalSpacing()
{
  orbitalSpacing = (maxRadius - minRadius) / numVisible;
  for (int s = 0; s < numVisible; s++)
  {
    orbits[s].renew();
  }
}


public void keyPressed()
{
  if (keyCode == 'm' || keyCode == 'M') 
  {
    if (numVisible < numShapes)
    {
      orbits[numVisible].initialise();
      orbits[numVisible].renew();
      colours[numVisible].initialise();
      colours[numVisible].renew();
      rings[numVisible].initialise();
      rings[numVisible].visible = true;
      numVisible = min(numVisible+=1, numShapes);
      if (pattern == "UNIFORM" || pattern == "TUNNEL")
      {
        setOrbitalSpacing();
        displayInfo.renew();
      }
    }
  }
  if (keyCode == 'f' || keyCode == 'F') 
  {
    if (numVisible >= 5)
    {
      numVisible = max(numVisible -= 1, 5);
      orbits[numVisible].targetRadius = 0.8f * width;
      colours[numVisible].target = color(255, 255, 255);
      if (pattern == "UNIFORM" || pattern == "TUNNEL")
      {
        setOrbitalSpacing();
        displayInfo.renew();
      }
    }
  }

  if (keyCode == 'u' || keyCode == 'U') 
  {
    pattern = "UNIFORM";
    for (int s = 0; s < numShapes; s++)
    { 
      setOrbitalSpacing();
      orbits[s].renew();
      colours[s].renew();
      displayInfo.renew();
      bgcolour.target = dark;
    }
  }
  if (keyCode == 't' || keyCode == 'T') 
  {
    pattern = "TUNNEL";
    for (int s = 0; s < numShapes; s++)
    { 
      setOrbitalSpacing();
      orbits[s].renew();
      colours[s].renew();
      displayInfo.renew();
      bgcolour.target = medium;
    }
  }
  if (keyCode == 'r' || keyCode == 'R') 
  {
    pattern = "RANDOM";
    for (int s = 0; s < numShapes; s++) 
    {
      orbits[s].renew();
      colours[s].renew();
      displayInfo.renew();
      bgcolour.target = light;
    }
  }
}

//a class for holding colours and transitions
class Colour
{
  int current, target;
  float easing = 0.1f;

  int index;
  
  float tunnelAngle = 0;
  float tunnelInc = 0.05f;

  Colour(int index)
  {
    this.index = index;
    this.current = current;
    this.target = target;
  }
  Colour() {}

  public void initialise()
  {
    current = color(0, 0, 0);
  }

  public void renew()
  {
    if (pattern == "UNIFORM")
    {
      target = color(index*96/numShapes, (numShapes - 1.25f*index)*255/numShapes, 2*index*255/numShapes);
    }
    else if(pattern == "TUNNEL")
    {
      float mappedIndex = map(index, 0, numVisible, 0, TWO_PI);
      float grey = (sin(mappedIndex + tunnelAngle) * 128) + 128; 
      tunnelAngle -= tunnelInc;
      target = color(2*(255-grey)/3, 255-grey, (255-grey)/2);
    }
    else
    {
      target = color(random(128, 240), random(64, 192), random(32, 128));
    }
  }

  public void easeTo(int target)
  {
    float redbit = red(current);
    float greenbit = green(current);
    float bluebit = blue(current);
    redbit += (red(target) - red(current)) * easing;
    greenbit += (green(target) - green(current)) * easing;
    bluebit += (blue(target) - blue(current)) * easing;

    if (abs(red(target) - red(current)) < 1) redbit = red(target);
    if (abs(green(target) - green(current)) < 1) greenbit = green(target);
    if (abs(blue(target) - blue(current)) < 1) bluebit = blue(target);
    current = color (redbit, greenbit, bluebit);
  }
}

//a class for holding the strokeWeight and blobSize and their transitions
class Display
{
  float currentStroke, targetStroke;
  float currentBlob, targetBlob;
  float defaultStroke;
  float defaultBlob;
  
  float easing = 0.1f;

  Display()
  {
    this.currentStroke = currentStroke;
    this.targetStroke = targetStroke;
    this.currentBlob = currentBlob;
    this.targetBlob = targetBlob;
    
    this.defaultStroke = defaultStroke;
    this.defaultBlob = defaultBlob;
  }

  public void renew()
  {
    if(pattern == "UNIFORM")
    {
      targetStroke = 0.5f * (maxRadius - minRadius) / numVisible;
      targetBlob = 0.5f * (maxRadius - minRadius) / numVisible;
    }
    else if(pattern == "TUNNEL")
    {
      targetStroke = 0.9f * (maxRadius - minRadius) / numVisible;
      targetBlob = 0.9f * (maxRadius - minRadius) / numVisible;
    }
    else
    {
      targetStroke = random(2) * (maxRadius - minRadius) / numVisible;
      targetBlob = random(1, 2) * (maxRadius - minRadius) / numVisible;
    }
  }

  public void easeToStroke()
  {
    currentStroke += (targetStroke - currentStroke) * easing;
    if (abs(targetStroke - currentStroke) < 0.2f) currentStroke = targetStroke;
  }
  public void easeToBlob()
  {
    currentBlob += (targetBlob - currentBlob) * easing;
    if (abs(targetBlob - currentBlob) < 0.2f) currentBlob = targetBlob;
  }
}

//a class holding radii and transitions
class Orbit
{

  float easing = 0.1f;

  float currentRadius, targetRadius;
  int index;

  Orbit(int index)
  {
    this.index = index;
    this.currentRadius = currentRadius;
    this.targetRadius = targetRadius;
  }

  public void initialise()
  {
    currentRadius = 0;
  }

  public void renew()
  {
    if (pattern == "UNIFORM")
    {
      targetRadius = minRadius + index * orbitalSpacing;
    }
    else if(pattern == "TUNNEL")
    {
      targetRadius = minRadius + index * orbitalSpacing;
    }
    else
    {
      targetRadius = random(minRadius, maxRadius);
    }
  }

  public void easeTo()
  {
    currentRadius += (targetRadius - currentRadius) * easing;
    if (abs(targetRadius - currentRadius) < 2) currentRadius = targetRadius;
    if (currentRadius > width * 0.75f) 
    {
      rings[index].visible = false;
    }
  }
}  

//a class holding start and end angles of arc centred on (0, 0)
//with ring and end blob update and display
class Ring
{
  float startAngle, startAngleInc;
  float endAngle, endAngleInc;
  PVector startPos, endPos;

  float minRotInc = -0.015f;
  float maxRotInc = 0.015f;

  float orbit;
  int colour;
  float strokeWidth;
  float blobSize;

  boolean visible;


  Ring()
  {
    this.startAngle = startAngle;
    this.startAngleInc = startAngleInc;
    this.endAngle = endAngle;
    this.endAngleInc = endAngleInc;
    this.startPos = startPos;
    this.endPos = endPos;

    this.orbit = orbit;
    this.colour = colour;
    this.strokeWidth = strokeWidth;
    this.blobSize = blobSize;
    
    this.visible = visible;

    initialise();
  }

  public void initialise()
  {
    orbit = 0;
    startAngle = random(0, TWO_PI);
    startAngleInc = random(minRotInc, maxRotInc);
    endAngle = random(0, TWO_PI);
    endAngleInc = random(minRotInc, maxRotInc);
    startPos = new PVector(0, 0);
    endPos = new PVector(0, 0);
    visible = false;
  }

  public void display()
  {
    if (visible)
    {
      stroke(colour);
      strokeWeight(displayInfo.currentStroke);
      noFill();
      pushMatrix();
      rotate(startAngle);

      if (endAngle < TWO_PI) 
      {
        arc(0, 0, 2*orbit, 2*orbit, 0, endAngle);
      }
      else //TWO_PI < startAngle < FOUR_PI
      {
        arc(0, 0, 2*orbit, 2*orbit, endAngle, TWO_PI * 2);
      }

      float blobDiam = displayInfo.currentBlob;
      noStroke();
      fill(colour);
      float x1 = orbit * cos(endAngle);
      float y1 = orbit * sin(endAngle);
      ellipse(x1, y1, blobDiam, blobDiam);
      float x2 = orbit * cos(0);
      float y2 = orbit * sin(0);
      ellipse(x2, y2, blobDiam, blobDiam);
      popMatrix();
    }
  }

  public void update()
  {
    endAngle += endAngleInc;
    startAngle += startAngleInc;
    endAngle %= TWO_PI*2;
    startAngle %= TWO_PI*2;
    if (endAngle < 0) endAngle += TWO_PI*2;
    if (startAngle < 0) startAngle += TWO_PI*2;

    findEndPositions();
  }

  public void findEndPositions()
  {
    startPos.x = orbit * cos(endAngle);
    startPos.y = orbit * sin(endAngle);
    endPos.y = orbit * cos(startAngle);
    endPos.y = orbit * sin(startAngle);
  }
}

int gState = -1;

public void getGesture()
{
  PXCMGesture.Gesture gest = new PXCMGesture.Gesture();
  if(session.QueryGesture(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY, gest))
  {
    if(gest.active)
    {
      if(gest.label==PXCMGesture.Gesture.LABEL_NAV_SWIPE_LEFT)
        gState = 0;
      if(gest.label==PXCMGesture.Gesture.LABEL_NAV_SWIPE_RIGHT)
        gState = 1;
      if(gest.label==PXCMGesture.Gesture.LABEL_NAV_SWIPE_UP)
        gState = 2;
      if(gest.label==PXCMGesture.Gesture.LABEL_NAV_SWIPE_DOWN)
        gState = 3;
      if(gest.label==PXCMGesture.Gesture.LABEL_HAND_CIRCLE)
        gState = 4;
    }
  }
}

public void drawGesture()
{
  pushMatrix();
  translate(320,0);
  //image(irImage, 0,0);

  float rad = 10;
  pushStyle();
  noStroke();
  //ellipseMode(RADIUS);  
  switch(gState)
  {
    case 0:
    {
      if (numVisible < numShapes)
    {
      orbits[numVisible].initialise();
      orbits[numVisible].renew();
      colours[numVisible].initialise();
      colours[numVisible].renew();
      rings[numVisible].initialise();
      rings[numVisible].visible = true;
      numVisible = min(numVisible+=1, numShapes);
      if (pattern == "UNIFORM" || pattern == "TUNNEL")
      {
        setOrbitalSpacing();
        displayInfo.renew();
      }
    }
      break;
    }
    case 1:
    {if (numVisible >= 5)
    {
      numVisible = max(numVisible -= 1, 5);
      orbits[numVisible].targetRadius = 0.8f * width;
      colours[numVisible].target = color(255, 255, 255);
      if (pattern == "UNIFORM" || pattern == "TUNNEL")
      {
        setOrbitalSpacing();
        displayInfo.renew();
      }
    }
    break;
    }    
    case 2:
    {
      pattern = "UNIFORM";
    for (int s = 0; s < numShapes; s++)
    { 
      setOrbitalSpacing();
      orbits[s].renew();
      colours[s].renew();
      displayInfo.renew();
      bgcolour.target = dark;
    }
      break;
    }    
    case 3:
    {
      pattern = "TUNNEL";
    for (int s = 0; s < numShapes; s++)
    { 
      setOrbitalSpacing();
      orbits[s].renew();
      colours[s].renew();
      displayInfo.renew();
      bgcolour.target = medium;
    }
      break;
    }    
    case 4:
    {
      pattern = "RANDOM";
    for (int s = 0; s < numShapes; s++) 
    {
      orbits[s].renew();
      colours[s].renew();
      displayInfo.renew();
      bgcolour.target = light;
    }
      break;
    }    
  }
  //fill(255);
  //rect(0,0,125,30);
  fill(0);
  text("Gesture Based Maze Game",10,20);
  popStyle();
  popMatrix();  
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "Centertheball" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
