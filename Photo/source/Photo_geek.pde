import intel.pcsdk.*;
float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();


ArrayList particles;
ArrayList forces;

PImage buffer;
PImage loadedImg;

float G = 1;

boolean clear = true;
boolean renderForces = false;

Force mouseForce; //special Force for the mouse
boolean mouseAttract = false;
int gState = -1;

void getGesture()
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

void drawGesture()
{
  pushMatrix();
  translate(320,0);
 // image(irImage, 0,0);

  float rad = 10;
  pushStyle();
  noStroke();
  ellipseMode(RADIUS);  
  switch(gState)
  {
    case 0:
    {
      //mass = 100.0;
      PVector mousePos = new PVector(mHandPos[0], mHandPos[1]);
      for(int i = forces.size()-1; i>=0; i--){
        Force f = (Force) forces.get(i);
        if(circleIntercept(mousePos, f.pos, 5)){
          forces.remove(i);
        }
        else{
          mouseForce.pos.set(mHandPos[0], mHandPos[1], 0);
    mouseForce.forceOn = true;
        }
          
     // fill(255,0,0);
     // ellipse(320-rad,120,rad,rad);
      //mass = 100.0;
      break;
    }
    }
    case 1:
    {
     //renderForces = !renderForces;
      
      break;
    }    
    case 2:
    {
      clear = !clear;
      
      break;
    }    
    case 3:
    {
      mouseForce.pos.set(mHandPos[0], mHandPos[1], 0);
  mouseForce.forceOn = true;
      //fill(255,255,0);
      //ellipse(160,240-rad,rad,rad);
      break;
    }    
    case 4:
    {
      mouseForce.forceOn = false;
      
      
      break;
    }    
  }
  fill(255);
  //rect(0,0,125,30);
  fill(0);
  //text("Gesture Detection",10,20);
  popStyle();
  popMatrix();  
}

void setup(){
  size(500, 500);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
  {
    println("Failed to initialize the PXCUPipeline!!!");
    exit();
  }
  frameRate(999);
  background(0);
  
  particles = new ArrayList();
  forces = new ArrayList();
  
  buffer = createImage(width, height, RGB);
  
  loadedImg = loadImage("afx.jpg");
  loadedImg.resize(360, 0);
  loadedImg.loadPixels();
  for(int y = 0; y < loadedImg.height; y+= 3){
    for(int x = 0; x < loadedImg.width; x+= 3){
      color c = loadedImg.pixels[y*loadedImg.width+x];
      Particle p = new Particle(x+(width/2)-loadedImg.width/2, y+(height/2)-loadedImg.height/2, c);
      p.place((c >> 16 & 0xFF)/255.0*500, (c & 0xFF)/255.0*500);
      particles.add(p);
    }
  }
  
  //initiating forces
  mouseForce = new Force(new PVector(0, 0), 300, false, false);
  
  forces.add(new Force(new PVector(0, 0), 500.0, false, true));
  forces.add(new Force(new PVector(500, 0), 500.0, false, true));
  forces.add(new Force(new PVector(500, 500), 500.0, false, true));
  forces.add(new Force(new PVector(0, 500), 500.0, false, true));
  forces.add(new Force(new PVector(220, 320), 200.0, false, false));
  
}

void draw(){
  background(0);
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
   drawGesture(); //must do tracking before frame is released
  }
  
  buffer.loadPixels();
  if(clear){
    color black = color(0);
    for(int i = 0; i < buffer.pixels.length; i++){
      buffer.pixels[i] = 0;
    }
  }
  for(int i = particles.size()-1; i>=0; i--){
    Particle p = (Particle) particles.get(i);
    p.run();
  }
  buffer.updatePixels();
  image(buffer, 0, 0);  
  
  if(renderForces){
    for(int i = forces.size()-1; i>=0; i--){
      Force f = (Force) forces.get(i);
      f.render();
    }
  }
}

void keyPressed(){
  if(key == ' '){
    renderForces = !renderForces;
  } else if(key == DELETE){
    clear = !clear;
  } else if(key == TAB){
    mouseAttract = !mouseAttract;
    mouseForce.setAttract(mouseAttract);
  } else {
    float mass = 0.0;
    boolean attract = mouseAttract;
    
    switch(key){
      case '1':
        mass = 100.0;
        break;
      case '2':
        mass = 200.0;
        break;
      case '3':
        mass = 300.0;
        break;
      case '4':
        mass = 400.0;
        break;
      case '5':
        mass = 500.0;
        break;
      case '6':
        mass = 600.0;
        break;
    }
    if(mass > 0) addForce(new PVector(mHandPos[0], mHandPos[1]), mass, attract, true);    
  }        
}

void mousePressed(){
  if(keyPressed){
    if(key == BACKSPACE){
      PVector mousePos = new PVector(mHandPos[0], mHandPos[1]);
      for(int i = forces.size()-1; i>=0; i--){
        Force f = (Force) forces.get(i);
        if(circleIntercept(mousePos, f.pos, 5)){
          forces.remove(i);
          break;
        }
      }
    } else if(key == CODED){
      if(keyCode == CONTROL){ 
        PVector mousePos = new PVector(mHandPos[0], mHandPos[1]);
        for(int i = forces.size()-1; i>=0; i--){
          Force f = (Force) forces.get(i);
          if(circleIntercept(mousePos, f.pos, 5)){
            f.forceOn = !f.forceOn;
            break;
          }
        }
      }
    }    
  } else {
    mouseForce.pos.set(mHandPos[0], mHandPos[1], 0);
    mouseForce.forceOn = true;
  }    
}

void mouseDragged(){
  mouseForce.pos.set(mHandPos[0], mHandPos[1], 0);
  mouseForce.forceOn = true;
}

void mouseReleased(){
  mouseForce.forceOn = false;
}

void addForce(PVector pos, float mass, boolean attract, boolean on){
  forces.add(new Force(pos, mass, attract, on));
}

boolean circleIntercept(PVector pos, PVector circlePos, float radius){
  float dis = dist(pos.x, pos.y, circlePos.x, circlePos.y);
  if(dis <= radius){
    return true;
  } else {
    return false;
  }
}
  



