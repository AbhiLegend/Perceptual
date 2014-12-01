int gState = -1;
boolean drawHeat = true;
boolean pushPull = false;

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
  //image(irImage, 0,0);

  float rad = 10;
  pushStyle();
  noStroke();
  //ellipseMode(RADIUS);  
  switch(gState)
  {
    case 0:
    {
      //drawHeat=!drawHeat;
      //smooth();
      break;
    }
    case 1:
    {
      reset();
      break;
    }    
    case 2:
    {
      gripHead();
      //drawHeat=!drawHeat;
      break;
    }    
    case 3:
    {
     // pushPull=true;
      break;
    }    
    case 4:
    {
      pushPull=false;
      break;
    }    
  }
  fill(255);
 // rect(0,0,125,30);
  fill(0);
  //text("Gesture Detection",10,20);
  popStyle();
  popMatrix();  
}
