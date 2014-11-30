//a class for holding the strokeWeight and blobSize and their transitions
class Display
{
  float currentStroke, targetStroke;
  float currentBlob, targetBlob;
  float defaultStroke;
  float defaultBlob;
  
  float easing = 0.1;

  Display()
  {
    this.currentStroke = currentStroke;
    this.targetStroke = targetStroke;
    this.currentBlob = currentBlob;
    this.targetBlob = targetBlob;
    
    this.defaultStroke = defaultStroke;
    this.defaultBlob = defaultBlob;
  }

  void renew()
  {
    if(pattern == "UNIFORM")
    {
      targetStroke = 0.5 * (maxRadius - minRadius) / numVisible;
      targetBlob = 0.5 * (maxRadius - minRadius) / numVisible;
    }
    else if(pattern == "TUNNEL")
    {
      targetStroke = 0.9 * (maxRadius - minRadius) / numVisible;
      targetBlob = 0.9 * (maxRadius - minRadius) / numVisible;
    }
    else
    {
      targetStroke = random(2) * (maxRadius - minRadius) / numVisible;
      targetBlob = random(1, 2) * (maxRadius - minRadius) / numVisible;
    }
  }

  void easeToStroke()
  {
    currentStroke += (targetStroke - currentStroke) * easing;
    if (abs(targetStroke - currentStroke) < 0.2) currentStroke = targetStroke;
  }
  void easeToBlob()
  {
    currentBlob += (targetBlob - currentBlob) * easing;
    if (abs(targetBlob - currentBlob) < 0.2) currentBlob = targetBlob;
  }
}

