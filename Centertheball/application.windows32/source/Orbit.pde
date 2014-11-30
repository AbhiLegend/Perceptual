//a class holding radii and transitions
class Orbit
{

  float easing = 0.1;

  float currentRadius, targetRadius;
  int index;

  Orbit(int index)
  {
    this.index = index;
    this.currentRadius = currentRadius;
    this.targetRadius = targetRadius;
  }

  void initialise()
  {
    currentRadius = 0;
  }

  void renew()
  {
    if (pattern == "UNIFORM")
    {
      targetRadius = minRadius + index * orbitalSpacing;
    }
    else if(pattern == "TUNNEL")
    {
      targetRadius = minRadius + index * orbitalSpacing;
    }
    else
    {
      targetRadius = random(minRadius, maxRadius);
    }
  }

  void easeTo()
  {
    currentRadius += (targetRadius - currentRadius) * easing;
    if (abs(targetRadius - currentRadius) < 2) currentRadius = targetRadius;
    if (currentRadius > width * 0.75) 
    {
      rings[index].visible = false;
    }
  }
}  

