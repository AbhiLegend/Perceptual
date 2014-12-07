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

public class Swarm3 extends PApplet {



/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/2799*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */
// Gravity Swarm II
// Claudio Gonzales, July 2009
// Albuquerque, New Mexico

particle[] Z = new particle[10000];
float colour = random(1);
boolean tracer = false;
boolean night = true;
float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();

public void setup() {
  smooth();
  size(500,500,P2D); 
 session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
{
println("Failed to initialize the PXCUPipeline!!!");
    exit();
} 
  background(255);
  frameRate(30);
  
  float r;
  float phi;
  
  for(int i = 0; i < Z.length; i++) {
        
    r = sqrt( random( sq(width/2) + sq(height/2) ) );
    phi = random(TWO_PI);
    Z[i] = new particle( r*cos(phi)+width/2, r*sin(phi)+height/2, 0, 0, random(2.5f)+0.5f );
  }
  
}

public void draw() {

  float r;
  if(session.AcquireFrame(false))
  {
    if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
    {
      mHandPos[0] = hand.positionImage.x;
      mHandPos[1] = hand.positionImage.y;
      mHandPos[2] = hand.positionWorld.y;
      mHandPos[3] = hand.openness;
    }
    session.ReleaseFrame();

  if( night )
    filter(INVERT);

  if( tracer ) {
    stroke(255,100);
    fill(255,100);
    rect(0,0,width,height);
  }
  else {
    background(250);
  }
  
  colorMode(HSB,1);
  int X=(int)mHandPos[0];
  int Y=(int)mHandPos[0];
  for(int i = 0; i < Z.length; i++) {
    if( X>40 && Y>40 ) {
      Z[i].gravitate( new particle(  mHandPos[0],  mHandPos[1], 0, 0, 50 ) );
    }
    else if( X<10 && Y<10 ) {
      Z[i].repel( new particle(  mHandPos[0],  mHandPos[1], 0, 0, 50 ) );
    }
    Z[i].deteriorate();
    Z[i].update();
    r = PApplet.parseFloat(i)/Z.length;
    if( sq(Z[i].magnitude)/50 < 0.15f ) {
      stroke( colour, pow(r,0.1f), 1-r, sq(Z[i].magnitude)/50 );
    }
    else {
      stroke( colour, pow(r,0.1f), 1-r, 0.15f );
    }
    
    //if( i < Z.length-1 )
      //line( Z[i].x, Z[i].y, Z[i+1].x, Z[i+1].y );
    Z[i].display();
  }
  
  colorMode(RGB,255);
  
  colour+=random(0.01f);
  if( colour > 1 ) { 
    colour = colour%1;
  }
  
  if( night )
    filter(INVERT);
  
}


}

class particle {
  
  float x;
  float y;
  float px;
  float py;
  float magnitude;
  float angle;
  float mass;
  
  particle( float dx, float dy, float V, float A, float M ) {
    x = dx;
    y = dy;
    px = dx;
    py = dy;
    magnitude = V;
    angle = A;
    mass = M;
  }
  
  public void reset( float dx, float dy, float V, float A, float M ) {
    x = dx;
    y = dy;
    px = dx;
    py = dy;
    magnitude = V;
    angle = A;
    mass = M;
  }
  
  public void gravitate( particle Z ) {
    float F, mX, mY, A;
    if( sq( x - Z.x ) + sq( y - Z.y ) != 0 ) {
      F = mass * Z.mass;
      F /= sqrt( sq( x - Z.x ) + sq( y - Z.y ) );
      //F /= ( sq( x - Z.x ) + sq( y - Z.y ) );
      if( sqrt(sq( x - Z.x ) + sq( y - Z.y )) < 10 ) {
        F = 0.1f;
      }
      mX = ( mass * x + Z.mass * Z.x ) / ( mass + Z.mass );
      mY = ( mass * y + Z.mass * Z.y ) / ( mass + Z.mass );
      A = atan2( mY-y, mX-x );
      
      mX = F * cos(A);
      mY = F * sin(A);
      
      mX += magnitude * cos(angle);
      mY += magnitude * sin(angle);
      
      magnitude = sqrt( sq(mX) + sq(mY) );
      angle = findAngle( mX, mY );
    }
  }

  public void repel( particle Z ) {
    float F, mX, mY, A;
    if( sq( x - Z.x ) + sq( y - Z.y ) != 0 ) {
      F = mass * Z.mass;
      F /= sqrt( sq( x - Z.x ) + sq( y - Z.y ) );
      if( sqrt(sq( x - Z.x ) + sq( y - Z.y )) < 10 ) {
        F = 0.1f;
      }
      mX = ( mass * x + Z.mass * Z.x ) / ( mass + Z.mass );
      mY = ( mass * y + Z.mass * Z.y ) / ( mass + Z.mass );
      A = atan2( y-mY, x-mX );
      
      mX = F * cos(A);
      mY = F * sin(A);
      
      mX += magnitude * cos(angle);
      mY += magnitude * sin(angle);
      
      magnitude = sqrt( sq(mX) + sq(mY) );
      angle = findAngle( mX, mY );
    }
  }
  
  public void deteriorate() {
    magnitude *= 0.9f;
  }
  
  public void update() {
    
    x += magnitude * cos(angle);
    y += magnitude * sin(angle);
    
  }
  
  public void display() {
    line(px,py,x,y);
    px = x;
    py = y;
  }
  
  
}

public float findAngle( float x, float y ) {
  float theta;
  if(x == 0) {
    if(y > 0) {
      theta = HALF_PI;
    }
    else if(y < 0) {
      theta = 3*HALF_PI;
    }
    else {
      theta = 0;
    }
  }
  else {
    theta = atan( y / x );
    if(( x < 0 ) && ( y >= 0 )) { theta += PI; }
    if(( x < 0 ) && ( y < 0 )) { theta -= PI; }
  }
  return theta;
}
 
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--full-screen", "--bgcolor=#666666", "--stop-color=#cccccc", "Swarm3" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
