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
  ellipseMode(RADIUS);  
  switch(gState)
  {
    case 0:
    {
      planet.addObject(new Building(planet, -planet.a-planet.bornA));
    auto = false;
      break;
    }
    case 1:
    {
       planet.addObject(new Cloud(planet, -planet.a-planet.bornA));
    auto = false;
      break;
    }    
    case 2:
    {
     // planet.addObject(new Tree2(planet, -planet.a-planet.bornA));
   // auto = false;
      break;
    }    
    case 3:
    {
     // planet.addObject(new Eolienne(planet, -planet.a-planet.bornA));
    //auto = false;
      break;
    }    
    case 4:
    {
     auto = true;
      //ellipse(160,120,50,50);
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
//HACKATHON....
