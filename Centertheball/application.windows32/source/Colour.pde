//a class for holding colours and transitions
class Colour
{
  color current, target;
  float easing = 0.1;

  int index;
  
  float tunnelAngle = 0;
  float tunnelInc = 0.05;

  Colour(int index)
  {
    this.index = index;
    this.current = current;
    this.target = target;
  }
  Colour() {}

  void initialise()
  {
    current = color(0, 0, 0);
  }

  void renew()
  {
    if (pattern == "UNIFORM")
    {
      target = color(index*96/numShapes, (numShapes - 1.25*index)*255/numShapes, 2*index*255/numShapes);
    }
    else if(pattern == "TUNNEL")
    {
      float mappedIndex = map(index, 0, numVisible, 0, TWO_PI);
      float grey = (sin(mappedIndex + tunnelAngle) * 128) + 128; 
      tunnelAngle -= tunnelInc;
      target = color(2*(255-grey)/3, 255-grey, (255-grey)/2);
    }
    else
    {
      target = color(random(128, 240), random(64, 192), random(32, 128));
    }
  }

  void easeTo(color target)
  {
    float redbit = red(current);
    float greenbit = green(current);
    float bluebit = blue(current);
    redbit += (red(target) - red(current)) * easing;
    greenbit += (green(target) - green(current)) * easing;
    bluebit += (blue(target) - blue(current)) * easing;

    if (abs(red(target) - red(current)) < 1) redbit = red(target);
    if (abs(green(target) - green(current)) < 1) greenbit = green(target);
    if (abs(blue(target) - blue(current)) < 1) bluebit = blue(target);
    current = color (redbit, greenbit, bluebit);
  }
}

