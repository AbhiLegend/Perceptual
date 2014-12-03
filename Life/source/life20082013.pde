import intel.pcsdk.*;
float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();

class Building extends Displayable {
   
  int h = 60;
  int w = 30;
  boolean[] windows;
  int ww = 5; // windows width
 
   
  Building(Planet p, float posA) {
    super(p, posA);
     
     
    h = int(random(p.halfsize>>3, p.halfsize>>1));
    w = int(random(p.halfsize>>4, p.halfsize/6));
     
    ww = min(h,w)/5;
     
    windows = new boolean[9];
     
    for (int i = 0; i < windows.length; i++) {
      if (random(2) > 1) windows[i] = true;
    }
  }
   
  void grow() {
    
     
     
   if ( isDying ) {
      age--;
    } else {
    age++;
    }
   
    int gh = h;  // temporary heigth
    int gh2 = ww; // windows width
   
    if (age < 30) {
      if (age < 0) isDead = true;
      if (age < 10) gh = min(age, 10)*h/10;
      if (age < 30-ww) {
        gh2 = 0;
      } else {
        gh2= age-(30-ww);
      }
    } else {
      age = 30;
    }
     
    strokeWeight(1);
    noStroke();
    rect(-w/2, h/10, w, -gh);
    fill(255);
 
    int dw = w/7; int dh = -h/7;
    for (int i = 0; i < windows.length; i++) {
      int x = i%3; int y = int(i/3);
      if (windows[i]) rect(-w*0.5 + dw*(1+x*2), ww + 1.5*dh + y*2*dh, ww, -gh2);
    }
    fill(0);
     
  }
   
}
class Cloud extends Displayable {
   
  int h;
  int thick;
  PVector balls[]; // n balls
  float wind = .003; // wind
   
  Cloud(Planet p, float posA){
    super(p, posA);
    h = int(random(p.halfsize>>2, p.halfsize>>1));
    thick = h/5;
    balls = new PVector[int(random(6))+3];
    for (int i =0; i < balls.length; i++){
      balls[i] = new PVector(random(1.2), random(1.0));
    }
     
    wind = random(-.003, .003);
     
  }
   
  void grow() {
     
    if ( isDying ) {
      age--;
    }
    else {
      age++;
      posA -= wind;
    }
     
    if (age < 0) isDead = true;
    if (age > h ) age = h;
     
    int gh = min (age*3, h);
    int n = thick*gh/h;
     
     
    fill(0);
    pushMatrix();
    translate(0 , -gh);
    for (int i =0; i < balls.length; i++){
      fill(0);
      ellipse(balls[i].x*n,balls[i].y*n/2, n, n);
    }
     
    for (int i =0; i < balls.length; i++){
      noStroke();
      fill(255);
      ellipse(balls[i].x*n,balls[i].y*n/2, n-2, n-2);
    }
    fill(0);
    popMatrix();
  }
 
}
class Displayable {
   
  float posA = 0.0;
  Planet p;
  int age = 0;
  boolean isDying = false;
  boolean isDead = false;
   
  Displayable(Planet p, float posA) {
    this.p = p;
    this.posA = posA;
  }
   
  void display() {   
    pushMatrix();
      rotate(posA);
      translate(p.halfsize, 0);
      pushMatrix();
        rotate(PI/2);
        grow();
      popMatrix();
    popMatrix();
  }
   
  void grow() {}
   
}
class Eolienne extends Displayable {
   
  int h = 30;
  int w = 7;  // width of eolienne
  float a; // angle
  float aspeed = PI/20; // angular speed
   
  Eolienne(Planet p, float posA) {
    super(p, posA);
    h = p.halfsize>>2;
  }
   
  void grow() {
     
    if ( isDying ) {
      age--;
    } else {
    age++;
    }
     
    int gh = h;
    int gh2 = h/2;
 
    if (age < 40) {
      if (age < 0) isDead = true;
      if (age < 10) gh = min(age, 10)*h/10;
      gh2 = 0;
      if (age > 20) gh2 = (min(age, 30)-20)*h/20;
    } else {
      age = 40;
      a += aspeed;
      if (a > TWO_PI) a -= TWO_PI;
    }
    stroke(0);
    triangle(-w/2, 0, w/2, 0, 0, -gh);
    if (age > 10) { 
      pushMatrix();
        translate(0, -gh);
          for (int i = 0; i < 3; i++) {
          pushMatrix();
            rotate(a + TWO_PI*i/3);
            triangle(-w/2, 0, w/3, 0, 0, -gh2);
          popMatrix();
        }
      popMatrix();
    }
     
  }
   
}
class Human {
  int age;
  int h;  // taille
  int x, y;
 
  Human( int xx, int yy, int hh) {
    age  = 0;
    h = hh;
    x = xx;
    y = yy;
  }
 
  void display() {
    age++;
    drawMan(x, y, h, map((age%11), 0, 11, -.5, .5));
     
  }
 
  void drawMan(int x, int y, float s, float ang) {
    noStroke();
    fill(0);
    float m = s/8; // mesure
    pushMatrix();
    translate(x, y);
    rotate(HALF_PI);
    translate(-.9*h+abs(ang)*1.5*m, 0);
    ellipse(0, 0, m*1.2, m*1.2); // head
    translate(m*.75, 0);
    rect( 0, m/4, 2.5*m, -m/2);
    // left arm
    arm(m, ang);
    // right arm
    arm(m, -ang);
 
    translate(2.5*m, 0);
    // left leg
    leg(m, ang);
    // right leg
    leg(m, -ang);
 
    popMatrix();
  }
 
  void arm(float m, float ang) {
    pushMatrix();
    rotate(.8*ang);
    rect( 0, m/4, 2*m, -m/2);
    translate(2*m, 0);
    rotate(-abs(ang)*2);
    rect( 0, m/4, 2*m, -m/2);
    popMatrix();
  }
 
  void leg(float m, float ang) {
    pushMatrix();
    rotate(-.05-1.2*ang);
    rect( 0, m/4, 2*m, -m/2);
    translate(2*m, 0);
    if (ang > 0) rotate(1.4*ang);
    if (ang < 0) rotate(-.2*ang);
    rect( 0, m/4, 2*m, -m/2);
    popMatrix();
  }
 
}
 class Planet {
 
  int x, y;                     // center of the planet
  float a = 0.0;                // angle of the planet
  final float speed = -PI/500;  // angle speed
  int halfsize;                 // radius of the sphere
  ArrayList displayables;       // all the elements populating the planet
  float bornA = PI/5;           // angle where elements are generated
  float dieA = 4*bornA;         // angle where elements are deleted
 
  Planet(int x, int y, int h) {
    this.x = x;
    this.y = y;
    this.halfsize = h;
    displayables = new ArrayList();
  }
 
  // rotate the planet
  void turn() {
    a += speed;
    if (a > TWO_PI) a -= TWO_PI;
 
    // check for end of life elements
    for (int i=0; i < displayables.size(); i++) {
      Displayable d = (Displayable)displayables.get(i);
 
      // Checks if it's alive and passing the dying point
      if( (d.posA < -a-( dieA + d.age*speed ) ) && !(d.isDying) ){
        d.isDying = true;
      }
 
      // if dead remove it
      if (d.isDead) displayables.remove(i);
    }
 
  }
 
  // add an element
  void addObject(Displayable d) {
    displayables.add(d);  // method of the ArrayList
  }
 
  // clear the planet
  void clean() {
    displayables.clear();
  }
 
  // draw the whole planet to the window 
  void display() {
    pushMatrix();
    translate(x, y);
    rotate(a);
    stroke(0);
    fill(0);
 
    // draw elements
    for (int i=0; i < displayables.size(); i++) {
      Displayable d = (Displayable)displayables.get(i);
      d.display();
    }
 
    // draw ground
    ellipse(0, 0, halfsize<<1, halfsize<<1); // 1 left bit shifting = *2
    popMatrix();
  }
 
  void generate() {
    float n = frameCount*0.05;
    if (frameCount%(40*noise(n)) < 1 ) {
      // add an element
      switch ( int(noise(n*0.5)*4) ) {
      case 0:
        planet.addObject(new Building(planet, -planet.a-bornA));
        break;
      case 1:
        planet.addObject(new Cloud(planet, -planet.a-bornA));
        break;
      case 2:
        planet.addObject(new Tree2(planet, -planet.a-bornA));
        break;
      case 3:
        planet.addObject(new Eolienne(planet, -planet.a-bornA ));
        break;   
      }
    }
  }
 
}
class Tree2 extends Displayable {
   
  int h;
  float thick =1;
  float theta = .5;
 
  Tree2(Planet p, float posA) {
    super(p, posA);
    h = int(random(p.halfsize>>5, p.halfsize/6));
    theta = random(.1, .8);
 
  }
 
  void grow() {
 
    if ( isDying ) {
      age--;
    }
    else {
      age++;
    }
 
    if (age < 0) isDead = true;
    if (age > 60) age = 60;
 
    int gh = min(age, h);
 
 
 
    noStroke();
    fill(0);
    thick = max(gh/6, 1.0f);
    drawBranch(thick, gh);
    translate(0, -gh);
    branch(gh, theta);
 
  }
 
  void branch(float hi, float theta) {
    hi *= 0.6f;
 
    thick = max(hi/6, 1.0f);
    // All recursive functions must have an exit condition!!!!
    // Here, ours is when the length of the branch is 2 pixels or less
    if (hi > 2) {
 
      pushMatrix();    // Save the current state of transformation (i.e. where are we now)
      rotate(theta);   // Rotate by theta
      drawBranch(thick, int(hi));  // Draw the branch
      translate(0,-hi); // Move to the end of the branch
      branch(hi, theta);       // Ok, now call myself to draw two new branches!!
      popMatrix();     // Whenever we get back here, we "pop" in order to restore the previous matrix state
 
 
 
      thick = max(hi/6, 1.0f);  
      // Repeat the same thing, only branch off to the "left" this time!
      pushMatrix();
      rotate(-theta);
      drawBranch(thick, int(hi));
      translate(0,-hi);
      branch(hi, theta);
      popMatrix();
 
    }
  }
 
}
 
void drawBranch(float t, int h){
  beginShape();
  vertex(-t, 1);
  vertex( t, 1);
  vertex( t*.5, -h);
  vertex(-t*.5, -h);
  endShape(CLOSE);
};
 Planet planet;
Human hum;
 
boolean auto = true;
 
void setup() {
   
  size(820, 500);
  frameRate(20);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
{
println("Failed to initialize the PXCUPipeline!!!");
    exit();
}
  smooth();
   
  planet = new Planet(360, 500, 320);
  hum = new Human(planet.x, planet.y-planet.halfsize, planet.halfsize/8 );
  println("hum: "  + planet.x + " ," + (planet.y-planet.halfsize) );
   
  // Button setup
  int w2 = width/2;
  int h2 = height-55;
   
}
 
void draw() {
   
  planet.turn();
  
  // draw to the screen
  background(255);
  if(session.AcquireFrame(false))
  {
    getGesture();
    if(session.QueryGeoNode(PXCMGesture.GeoNode.LABEL_BODY_HAND_PRIMARY|PXCMGesture.GeoNode.LABEL_OPENNESS_ANY, hand))
    {
      mHandPos[0] = hand.positionImage.x;
      mHandPos[1] = hand.positionImage.y;
      mHandPos[2] = hand.positionWorld.y;
      mHandPos[3] = hand.openness;
    }
    session.ReleaseFrame();
   drawGesture(); //must do tracking before frame is released
  }
  planet.display();
  hum.display();
   
  if (auto) planet.generate();
   
}
 
void keyPressed() {
  if (key == 'b') {
    planet.addObject(new Building(planet, -planet.a-planet.bornA));
    auto = false;
  }
  if (key == 'c') {
    planet.addObject(new Cloud(planet, -planet.a-planet.bornA));
    auto = false;
  }
  if (key == 't') {
    planet.addObject(new Tree2(planet, -planet.a-planet.bornA));
    auto = false;
  }
  if (key == 'w') {
    planet.addObject(new Eolienne(planet, -planet.a-planet.bornA));
    auto = false;
  }
  if (key == ' ') {
    auto = true;
  }
}
