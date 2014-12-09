import fisica.util.nonconvex.*;
import fisica.*;

import intel.pcsdk.*;

import blobDetection.*;
FWorld world;
short[] depth;
int[] lm = new int[2];
BlobDetection blobDetector;
ArrayList<FPoly> labelBlobs = new ArrayList();
PImage labelMap, depthMap;
PXCUPipeline session;

int circleCount = 20;
float hole = 50;
float topMargin = 50;
float bottomMargin = 300;
float sideMargin = 100;
float xPos = 0;

void setup() {
  size(400, 400);
  smooth();
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE|PXCUPipeline.DEPTH_QVGA))
    exit();
  if(session.QueryLabelMapSize(lm))
  {
    labelMap = createImage(lm[0],lm[1],RGB);
    depthMap = createImage(lm[0],lm[1],ALPHA);
    blobDetector = new BlobDetection(lm[0], lm[1]);  
    blobDetector.setPosDiscrimination(false);
    blobDetector.setThreshold(0.1);
  }
  if(session.QueryDepthMapSize(lm))
    depth = new short[lm[0]*lm[1]];

  

  Fisica.init(this);

  world = new FWorld();
  world.setGravity(0, -300);

  FPoly l = new FPoly();
  l.vertex(width/2-hole/2, 0);
  l.vertex(0, 0);
  l.vertex(0, height);
  l.vertex(0+sideMargin, height);
  l.vertex(0+sideMargin, height-bottomMargin);
  l.vertex(width/2-hole/2, topMargin);
  l.setStatic(true);
  l.setFill(0);
  l.setFriction(1);
  world.add(l);

  FPoly r = new FPoly();
  r.vertex(width/2+hole/2, 0);
  r.vertex(width, 0);
  r.vertex(width, height);
  r.vertex(width-sideMargin, height);
  r.vertex(width-sideMargin, height-bottomMargin);
  r.vertex(width/2+hole/2, topMargin);
  r.setStatic(true);
  r.setFill(0);
  r.setFriction(1);
  world.add(r);
}

void draw() {
  background(80, 120, 200);

  if ((frameCount % 20) == 1) {
    FBlob b = new FBlob();
    float s = random(30, 40);
    float space = (width-sideMargin*2-s);
    xPos = (xPos + random(s, space/2)) % space;
    b.setAsCircle(sideMargin + xPos+s/2, height-random(100), s, 20);
    b.setStroke(0);
    b.setStrokeWeight(2);
    b.setFill(255);
    world.add(b);
  }

  world.step();
  world.draw();
  if(session.AcquireFrame(false))
  {    
    session.QueryLabelMapAsImage(labelMap);
    session.QueryDepthMap(depth);
    session.ReleaseFrame();
  }    
    
  blobDetector.computeBlobs(labelMap.pixels);
  Blob current;
  EdgeVertex e0,e1;
  
  for(int b=0;b<blobDetector.getBlobNb();b++)
  {
    current=blobDetector.getBlob(b);
    FPoly p = new FPoly();
    p.setStaticBody(true);
    p.setStrokeWeight(2);
    p.setStroke(255,161,51);
    p.setFill(146,185,30);
    p.setDensity(1);
    p.setDrawable(true);
    p.setGrabbable(false);
    if(current!=null)
    {
      for(int e=0;e<current.getEdgeNb();e+=7)
      {
        e1 = current.getEdgeVertexB(e);
        p.vertex(e1.x*width,e1.y*height);
      }
    }
    world.add(p);
    labelBlobs.add(p);
  }
  world.step();
  world.draw(this);
  
  for(FPoly wp : labelBlobs)
  {
    world.remove(wp);
  }
  labelBlobs.clear(); 
}



void keyPressed() {
  try {
    saveFrame("screenshot.png");
  } 
  catch (Exception e) {
  }
}
