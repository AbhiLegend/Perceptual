import intel.pcsdk.*;
int cubesPerSide = 20;
int numCubes = cubesPerSide*cubesPerSide;
cubegrid cubeGrid = new cubegrid();
float[] mHandPos = new float[4];
PVector hand1Point, hand2Point, phand1Point, phand2Point;
PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
 
 
void setup()
{
  size(500,500,P3D);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
    exit();
}
 
void draw()
{
  background(0,0,0);
  tr();
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
  cubeGrid.render();
}
 
void tr()
{
  PXCMGesture.GeoNode hand1Thumb=new PXCMGesture.GeoNode();
      if(!session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_FINGER_THUMB, hand1Thumb))
  cubeGrid.attractCubes(mHandPos[0],mHandPos[1]);
}
class cube
{
  float x, y, z, w;
  color cubeColor, selectionColor, finalColor;
  boolean selected;
  
  cube(float xpos, float ypos, float boxWidth)
  {
    selected = false;
    x = xpos;
    y = ypos;
    z = 0;
    w = boxWidth;
  }
   
  void render()
  {
    cubeColor = color(255,0,255,30);
    if(selected)
    {
      selectionColor = color(255,255,255,255);
    }
    else
    {
      selectionColor = color(constrain((red(selectionColor)*8+red(cubeColor))/9,0,255),
                             constrain((green(selectionColor)*8+green(cubeColor))/9,0,255),
                             constrain((blue(selectionColor)*8+blue(cubeColor))/9,0,255),
                             constrain((alpha(selectionColor)*8+alpha(cubeColor))/9,0,255));
    }
    pushMatrix();
      translate(x,y,z);
      if(selected)
      {
        fill(selectionColor);
      }
      else
      {
        fill(selectionColor);
      }
      stroke(0,0,0,255);
      box(30,30,w);
    popMatrix();
  }
}
class cubegrid
{
  cube[] cubes = new cube[numCubes];
   
  cubegrid()
  {
    for(int x = 0; x < cubesPerSide; x++)
    {
      for(int y = 0; y < cubesPerSide; y++)
      {
        cubes[x+y*cubesPerSide] = new cube(x*30,y*30,30);
      }
    }
  }
   
  void attractCubes(float xPos, float yPos)
  {
    for(int i = 0; i < numCubes; i++)
    {
      float distance = dist(xPos,yPos,cubes[i].x,cubes[i].y);
      cubes[i].w = distance / 10;
      if(distance<40)
      {
        cubes[i].selected = true;
      }
      else
      {
        cubes[i].selected = false;
      }
    }
     
  }
   
  void render()
  {
    for(int i = 0; i < numCubes; i++)
   {
      cubes[i].render();
   }
  }
}


