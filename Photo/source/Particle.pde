class Particle {
  PVector originalPos;
  PVector currentPos;
  PVector velocity;
  PVector acceleration;
  
  float mass;
  
  color particleColor;
  
  Particle(float xPos, float yPos, color c){
    originalPos = new PVector(xPos, yPos);
    currentPos = new PVector(xPos, yPos);
    velocity = new PVector(0.0, 0.0);
    acceleration = new PVector(0.0, 0.0);
    
    mass = 1;
    
    particleColor = c;
  }
  
  void place(float xPos, float yPos){
    currentPos = new PVector(xPos, yPos);
  }    
  
  void move(){
    acceleration = PVector.sub(originalPos, currentPos);
    acceleration.mult(0.001);
    
    if(mouseForce.forceOn){
      acceleration.add(mouseForce.calculateForce(currentPos, mass));
    }
    
    for(int i = forces.size()-1; i>=0; i--){
      Force f = (Force) forces.get(i);
      if(f.forceOn)
        acceleration.add(f.calculateForce(currentPos, mass));
    }   
    velocity.add(acceleration);
    velocity.mult(0.99);
    currentPos.add(velocity);
    if(currentPos.x > width-1){
      currentPos.x = width-1;
      velocity.x *= -1;
    } else if(currentPos.x < 0){
      currentPos.x = 0;
      velocity.x *= -1;
    }
    if(currentPos.y > height-1){
      currentPos.y = height-1;
      velocity.y *= -1;
    } else if(currentPos.y < 0){
      currentPos.y = 0;
      velocity.y *= -1;
    }      
  }
  
  void render(){
    int xPos = constrain(floor(currentPos.x), 0, width-1);
    int yPos = constrain(floor(currentPos.y), 0, height-1);
    buffer.pixels[(yPos*width)+xPos] = particleColor;
  }
  
  void run(){
    move();
    render();
  }
}
