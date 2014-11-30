import intel.pcsdk.*;

/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/100392*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */
/*
Sal Spring
allonestring.co.uk
June 2013

playing with rotating arcs here called Rings
separate classes for the Ring and its
• Orbit = distance from the centre
• Colour
• Display = strokeWeight and blob size
separated out as the Ring class got too big

keyboard input for 
• [m]ore and [f]ewer Rings
• [r]andom, [u]niform and [t]unnel arrangements of Rings

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
float change=0.05;

float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();


int numShapes = 31;
int numVisible = 17;

float minRadius = 55;
float maxRadius = 270;
float orbitalSpacing;

Colour bgcolour;
color dark = color(20, 20, 30);
color medium = color(80, 100, 100);
color light = color(250, 240, 240);

String pattern = "RANDOM";//"UNIFORM";//"RANDOM";//TUNNEL


void setup()
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


void draw()
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

void setOrbitalSpacing()
{
  orbitalSpacing = (maxRadius - minRadius) / numVisible;
  for (int s = 0; s < numVisible; s++)
  {
    orbits[s].renew();
  }
}


void keyPressed()
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
      orbits[numVisible].targetRadius = 0.8 * width;
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

