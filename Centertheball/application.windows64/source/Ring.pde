//a class holding start and end angles of arc centred on (0, 0)
//with ring and end blob update and display
class Ring
{
  float startAngle, startAngleInc;
  float endAngle, endAngleInc;
  PVector startPos, endPos;

  float minRotInc = -0.015;
  float maxRotInc = 0.015;

  float orbit;
  color colour;
  float strokeWidth;
  float blobSize;

  boolean visible;


  Ring()
  {
    this.startAngle = startAngle;
    this.startAngleInc = startAngleInc;
    this.endAngle = endAngle;
    this.endAngleInc = endAngleInc;
    this.startPos = startPos;
    this.endPos = endPos;

    this.orbit = orbit;
    this.colour = colour;
    this.strokeWidth = strokeWidth;
    this.blobSize = blobSize;
    
    this.visible = visible;

    initialise();
  }

  void initialise()
  {
    orbit = 0;
    startAngle = random(0, TWO_PI);
    startAngleInc = random(minRotInc, maxRotInc);
    endAngle = random(0, TWO_PI);
    endAngleInc = random(minRotInc, maxRotInc);
    startPos = new PVector(0, 0);
    endPos = new PVector(0, 0);
    visible = false;
  }

  void display()
  {
    if (visible)
    {
      stroke(colour);
      strokeWeight(displayInfo.currentStroke);
      noFill();
      pushMatrix();
      rotate(startAngle);

      if (endAngle < TWO_PI) 
      {
        arc(0, 0, 2*orbit, 2*orbit, 0, endAngle);
      }
      else //TWO_PI < startAngle < FOUR_PI
      {
        arc(0, 0, 2*orbit, 2*orbit, endAngle, TWO_PI * 2);
      }

      float blobDiam = displayInfo.currentBlob;
      noStroke();
      fill(colour);
      float x1 = orbit * cos(endAngle);
      float y1 = orbit * sin(endAngle);
      ellipse(x1, y1, blobDiam, blobDiam);
      float x2 = orbit * cos(0);
      float y2 = orbit * sin(0);
      ellipse(x2, y2, blobDiam, blobDiam);
      popMatrix();
    }
  }

  void update()
  {
    endAngle += endAngleInc;
    startAngle += startAngleInc;
    endAngle %= TWO_PI*2;
    startAngle %= TWO_PI*2;
    if (endAngle < 0) endAngle += TWO_PI*2;
    if (startAngle < 0) startAngle += TWO_PI*2;

    findEndPositions();
  }

  void findEndPositions()
  {
    startPos.x = orbit * cos(endAngle);
    startPos.y = orbit * sin(endAngle);
    endPos.y = orbit * cos(startAngle);
    endPos.y = orbit * sin(startAngle);
  }
}

