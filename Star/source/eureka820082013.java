import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import controlP5.*; 
import intel.pcsdk.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class eureka820082013 extends PApplet {





ligne[] lignes;
float ix=0,ig=0;
float centre =100;
float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();

 
public void setup(){
  size(1024,768,P3D);
  background(0);stroke(255);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
  {
    println("Failed to initialize the PXCUPipeline!!!");
    exit();
  }
  lignes = new ligne[0];
  colorMode(HSB,100,1,1);
  for(int a=0;a<50;a++){
    new ligne();
  }
  sphereDetail(5);
  noFill();strokeWeight(2);
   smooth();
}
 
public void draw(){
  background(0);
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
  float invertedPositionImageX = map(mHandPos[0], 0, 320, 640, 0);
  float invertedPositionImageY = map(mHandPos[1], 0, 320, 640, 0);
  ix-=(invertedPositionImageX-width/2)*0.0005f;
  ig+=(invertedPositionImageY-height/2)*0.0005f;
  translate(width/2, height/2);
  rotateY(ix);  rotateX(ig);
  sphere(100);
  for(int a=0;a<lignes.length;a++){
    lignes[a].dessine();
  }
}
 
class ligne{
  float x,y,z,vx,vy,vz,c;
  PVector[] v=new PVector[1];
  ligne(){
    v[0]=new PVector(0,0,0);
    x=y=z=0;c=random(100);
    vx=random(-1,1);
    vy=random(-1,1);
    vz=random(-1,1);
    lignes = (ligne[]) append(lignes, this);
  }
  public void dessine(){
    c+=0.1f;c%=100;
    vx+=random(-0.3f,0.3f);
    vy+=random(-0.3f,0.3f);
    vz+=random(-0.3f,0.3f);
    float nx=x+vx, ny=y+vy, nz=z+vz;
    float d = dist(0,0,0,nx,ny,nz);
    if(d>200){
      nx=(nx/d)*200;
      ny=(ny/d)*200;
      nz=(nz/d)*200;
      vx = x-nx;vy=y-ny;vz=z-nz;
      vx+=random(-0.1f,0.1f);
      vy+=random(-0.1f,0.1f);
      vz+=random(-0.1f,0.1f);
       
    }
    stroke(c,1,1);
    v = (PVector[]) append(v, contrains(new PVector(nx,ny,nz)));
    if(v.length>100){
      v = (PVector[]) subset(v, 1);
    } 
    line((nx/d)*centre,(ny/d)*centre,(nz/d)*centre,nx,ny,nz);
     
     
    beginShape(LINES);
    for(int a=0;a<v.length;a++){
      vertex(v[a].x, v[a].y, v[a].z);
    }
    endShape();
    x=nx;y=ny;z=nz;
  }
}
 
public PVector contrains(PVector v){
  float d = dist(0,0,0,v.x, v.y, v.z);
  if(d<centre){
   v.x=(v.x/d)*centre;
    v.y=(v.y/d)*centre;
    v.z=(v.z/d)*centre;
     
  }
  return v;
}
 
public void keyPressed(){
  save("truc.png");
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "eureka820082013" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
