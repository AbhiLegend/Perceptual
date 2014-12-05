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

public class Photo_geek extends PApplet {


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

public void setup(){
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
      int c = loadedImg.pixels[y*loadedImg.width+x];
      Particle p = new Particle(x+(width/2)-loadedImg.width/2, y+(height/2)-loadedImg.height/2, c);
      p.place((c >> 16 & 0xFF)/255.0f*500, (c & 0xFF)/255.0f*500);
      particles.add(p);
    }
  }
  
  //initiating forces
  mouseForce = new Force(new PVector(0, 0), 300, false, false);
  
  forces.add(new Force(new PVector(0, 0), 500.0f, false, true));
  forces.add(new Force(new PVector(500, 0), 500.0f, false, true));
  forces.add(new Force(new PVector(500, 500), 500.0f, false, true));
  forces.add(new Force(new PVector(0, 500), 500.0f, false, true));
  forces.add(new Force(new PVector(220, 320), 200.0f, false, false));
  
}

public void draw(){
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
    int black = color(0);
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

public void keyPressed(){
  if(key == ' '){
    renderForces = !renderForces;
  } else if(key == DELETE){
    clear = !clear;
  } else if(key == TAB){
    mouseAttract = !mouseAttract;
    mouseForce.setAttract(mouseAttract);
  } else {
    float mass = 0.0f;
    boolean attract = mouseAttract;
    
    switch(key){
      case '1':
        mass = 100.0f;
        break;
      case '2':
        mass = 200.0f;
        break;
      case '3':
        mass = 300.0f;
        break;
      case '4':
        mass = 400.0f;
        break;
      case '5':
        mass = 500.0f;
        break;
      case '6':
        mass = 600.0f;
        break;
    }
    if(mass > 0) addForce(new PVector(mHandPos[0], mHandPos[1]), mass, attract, true);    
  }        
}

public void mousePressed(){
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

public void mouseDragged(){
  mouseForce.pos.set(mHandPos[0], mHandPos[1], 0);
  mouseForce.forceOn = true;
}

public void mouseReleased(){
  mouseForce.forceOn = false;
}

public void addForce(PVector pos, float mass, boolean attract, boolean on){
  forces.add(new Force(pos, mass, attract, on));
}

public boolean circleIntercept(PVector pos, PVector circlePos, float radius){
  float dis = dist(pos.x, pos.y, circlePos.x, circlePos.y);
  if(dis <= radius){
    return true;
  } else {
    return false;
  }
}
  



class Force {
  PVector pos;
  float mass, multiplier;
  boolean forceOn;
  
  Force(PVector p, float ms, boolean attract, boolean on){
    pos = p;
    mass = ms;
    if(attract){
      multiplier = 1.0f;
    } else {
      multiplier = -1.0f;
    }
    forceOn = on;
  }
  
  public PVector calculateForce(PVector pPos, float pMass){
    PVector f = PVector.sub(pos, pPos);
    float d = f.mag();
    d = constrain(d, 20.0f, 50000.0f);
    f.normalize();
    float force = (G * mass * pMass) / (d * d);
    f.mult(force * multiplier);
    return f;
  }

  public void setAttract(boolean attract){
    if(attract){
      multiplier = 1.0f;
    } else {
      multiplier = -1.0f;
    }
  }
  
  public void render(){
    if(forceOn){
      stroke(255);      
      noFill();
      ellipse(pos.x, pos.y, mass/2, mass/2);
    }

    if(forceOn){    
      stroke(255);
      fill(200);
    } else {
      stroke(200);
      fill(255, 0, 0);
    }
    ellipse(pos.x, pos.y, 10, 10);
  }
    
}
class Particle {
  PVector originalPos;
  PVector currentPos;
  PVector velocity;
  PVector acceleration;
  
  float mass;
  
  int particleColor;
  
  Particle(float xPos, float yPos, int c){
    originalPos = new PVector(xPos, yPos);
    currentPos = new PVector(xPos, yPos);
    velocity = new PVector(0.0f, 0.0f);
    acceleration = new PVector(0.0f, 0.0f);
    
    mass = 1;
    
    particleColor = c;
  }
  
  public void place(float xPos, float yPos){
    currentPos = new PVector(xPos, yPos);
  }    
  
  public void move(){
    acceleration = PVector.sub(originalPos, currentPos);
    acceleration.mult(0.001f);
    
    if(mouseForce.forceOn){
      acceleration.add(mouseForce.calculateForce(currentPos, mass));
    }
    
    for(int i = forces.size()-1; i>=0; i--){
      Force f = (Force) forces.get(i);
      if(f.forceOn)
        acceleration.add(f.calculateForce(currentPos, mass));
    }   
    velocity.add(acceleration);
    velocity.mult(0.99f);
    currentPos.add(velocity);
    if(currentPos.x > width-1){
      currentPos.x = width-1;
      velocity.x *= -1;
    } else if(currentPos.x < 0){
      currentPos.x = 0;
      velocity.x *= -1;
    }
    if(currentPos.y > height-1){
      currentPos.y = height-1;
      velocity.y *= -1;
    } else if(currentPos.y < 0){
      currentPos.y = 0;
      velocity.y *= -1;
    }      
  }
  
  public void render(){
    int xPos = constrain(floor(currentPos.x), 0, width-1);
    int yPos = constrain(floor(currentPos.y), 0, height-1);
    buffer.pixels[(yPos*width)+xPos] = particleColor;
  }
  
  public void run(){
    move();
    render();
  }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "Photo_geek" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
