import intel.pcsdk.*;
ArrayList particules;
int compteur = 0;
float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
 
void setup ( ) {
   
  size(800,600) ;
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
    exit();
  smooth();
  colorMode(HSB);
  particules = new ArrayList();
   
}
 
 
void draw() {
 
  noStroke();
  fill(0,0,0,10);
  rect(0,0,width,height);
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
  int X=(int)invertedPositionImageX;
  int Y=(int)invertedPositionImageY;
  
 
  // ajouteur une particule
  Particule particule = new Particule( X,Y );
  particules.add(particule);
 
  for (int i = particules.size() - 1; i >= 0 ; i--) {
    Particule p = (Particule) particules.get(i);
    if ( p.draw() == false ) {
      particules.remove(i);
    }
  }
}
 
class Particule {
  float positionX, positionY;
  float velociteX,velociteY;
  float graviteX, graviteY;
  float hue;
 
  Particule (float x, float y) {
 
    positionX = x;
    positionY = y;
    // Un angle qui pointe vers le haut de la scene
    float radians = random(-PI,0);
    float grandeur = random(1,3);
    velociteX = cos(radians)*grandeur;
    velociteY = sin(radians)*grandeur;
    graviteX = 0;
    graviteY = 0.1;
    hue = random(0,256);
  }
 
  // Retourne true si la particule est encore a l'interieur
  // des limites de la scène
  boolean draw() {
     
    velociteX = velociteX + graviteX;
    velociteY = velociteY + graviteY;
    positionX =  velociteX  + positionX;
    positionY =  velociteY  + positionY;
    
    hue = (hue + 1) % 256;
     
    noStroke();
    fill(hue,255,255 );
    ellipse(positionX,positionY,10,10);
     
    return ( positionX > -5 && positionX < width+5 && positionY < height+5);
  
  }
}

