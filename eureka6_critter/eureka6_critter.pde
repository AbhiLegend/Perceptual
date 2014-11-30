import intel.pcsdk.*;
boolean egocritter, shadows, wiggle=true;
int n = 3, l = 50, d = 50;
float zoom = 16, s = .1;
color c1 = 255, c2 = 0;
float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();
 
float w, h, mx, my, rx, ry, vv, zz;
int t, b;
 
void setup() {
  size(800, 600, P3D);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
  {
    println("Failed to initialize the PXCUPipeline!!!");
    exit();
  }
  w = width/2;
  h = height/2;
}
 
void draw() {
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
  
   
  if(egocritter) noCursor(); else cursor(ARROW);
     
  mx = lerp(mx, mHandPos[0], s);
  my = lerp(my, mHandPos[1], s);
  rx = lerp(rx, (w-mHandPos[1])/w + (egocritter ? 0 : PI), s);
  ry = lerp(ry, (mHandPos[0]-w)/w, s);
  vv = lerp(vv, wiggle?.05:-.1, s);
  zz = lerp(zz, zoom, s);
 
  noStroke();
  background(0);
 
  if(shadows) lights();
   
  translate(mx, my, 8 * zz * (sin(t*.05) -1));
  rotateY(ry);
  rotateX(rx);
  scale(zz);
   
  randomSeed(0);
  for(int i=-n; i<=n; i++)
    for(int j=-n; j<=n; j++) {
      pushMatrix();
      translate(i, j, 0);
      float d = random(vv, .1);
      float s = 1;
      for(float k=l; k>0; k--) {
        translate(0, 0, s);
        fill(noise(i, j, k+b)>.5 ? c1 : c2);
        box(1, 1, s);
        rotateY(d * sin(t*.05 + PI*k/l));
        scale(.95);
        s /= .97;
      }
      popMatrix();
  }
   
  t++;
   
}
 
void keyPressed() {
  switch(key) {
    case 'e': egocritter = !egocritter; break;
    case 'q': shadows = !shadows; break;
    case 'w': wiggle = !wiggle; break;
    case 's': zoom /= 1.1; break;
    case 'd': zoom *= 1.1; break;
    case 'a': b -= egocritter ? -1 : 1; break;
    case 'f': b += egocritter ? -1 : 1; break;
  }
  zoom = constrain(zoom, 1, 64);
}
