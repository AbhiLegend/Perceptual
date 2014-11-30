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
  //image(irImage, 0,0);

  float rad = 10;
  pushStyle();
  noStroke();
  //ellipseMode(RADIUS);  
  switch(gState)
  {
    case 0:
    {
      if (numVisible < numShapes)
    {
      orbits[numVisible].initialise();
      orbits[numVisible].renew();
      colours[numVisible].initialise();
      colours[numVisible].renew();
      rings[numVisible].initialise();
      rings[numVisible].visible = true;
      numVisible = min(numVisible+=1, numShapes);
      if (pattern == "UNIFORM" || pattern == "TUNNEL")
      {
        setOrbitalSpacing();
        displayInfo.renew();
      }
    }
      break;
    }
    case 1:
    {if (numVisible >= 5)
    {
      numVisible = max(numVisible -= 1, 5);
      orbits[numVisible].targetRadius = 0.8 * width;
      colours[numVisible].target = color(255, 255, 255);
      if (pattern == "UNIFORM" || pattern == "TUNNEL")
      {
        setOrbitalSpacing();
        displayInfo.renew();
      }
    }
    break;
    }    
    case 2:
    {
      pattern = "UNIFORM";
    for (int s = 0; s < numShapes; s++)
    { 
      setOrbitalSpacing();
      orbits[s].renew();
      colours[s].renew();
      displayInfo.renew();
      bgcolour.target = dark;
    }
      break;
    }    
    case 3:
    {
      pattern = "TUNNEL";
    for (int s = 0; s < numShapes; s++)
    { 
      setOrbitalSpacing();
      orbits[s].renew();
      colours[s].renew();
      displayInfo.renew();
      bgcolour.target = medium;
    }
      break;
    }    
    case 4:
    {
      pattern = "RANDOM";
    for (int s = 0; s < numShapes; s++) 
    {
      orbits[s].renew();
      colours[s].renew();
      displayInfo.renew();
      bgcolour.target = light;
    }
      break;
    }    
  }
  //fill(255);
  //rect(0,0,125,30);
  fill(0);
  text("Gesture Based Maze Game",10,20);
  popStyle();
  popMatrix();  
}
