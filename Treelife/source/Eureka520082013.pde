import intel.pcsdk.*;
float curlx = 0;
float curly = 0;
float f = sqrt(2)/2.;
float deley = 10;
float growth = 0;
float growthTarget = 0;
float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();

  
  
void setup()
{
  size(950,450,P2D);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
  {
    println("Failed to initialize the PXCUPipeline!!!");
    exit();
  }
  //smooth();
  addMouseWheelListener(new java.awt.event.MouseWheelListener() { 
    public void mouseWheelMoved(java.awt.event.MouseWheelEvent evt) { 
      mouseWheel(evt.getWheelRotation());
  }});
}
void draw()
{
  background(250);
  stroke(0);
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
  curlx += (radians(360./height* mHandPos[0])-curlx)/deley;
  curly += (radians(360./height* mHandPos[1])-curly)/deley;
  translate(width/2,height/3*2);
  line(0,0,0,height/2);
  branch(height/4.,17);
  growth += (growthTarget/10-growth+1.)/deley;
}
  
void mouseWheel(int delta)
{
  growthTarget += delta;
}
  
void branch(float len,int num)
{
  len *= f;
  num -= 1;
  if((len > 1) && (num > 0))
  {
    pushMatrix();
    rotate(curlx);
    line(0,0,0,-len);
    translate(0,-len);
    branch(len,num);
    popMatrix();
      
//    pushMatrix();
//    line(0,0,0,-len);
//    translate(0,-len);
//    branch(len);
//    popMatrix();
    len *= growth;
    pushMatrix();
    rotate(curlx-curly);
    line(0,0,0,-len);
    translate(0,-len);
    branch(len,num);
    popMatrix();
    //len /= growth;
  }
}
