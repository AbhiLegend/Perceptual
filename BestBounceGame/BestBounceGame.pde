import intel.pcsdk.*;
float[] mHandPos = new float[4];

PXCUPipeline session;
PXCMGesture.GeoNode hand = new PXCMGesture.GeoNode();

/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/6818*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */
// bounce
// a game by steven kay
// bounce and roll the ball. avoid black squares.
// bounce on multiple cyan and yellow squares to build up your scor

float BALL_R=7; // ball radius
float BOUNCE_HEIGHT=75.0; // normal bounce height
float BOUNCE_STRIDE=20.0; // should be multiple of 20 (tile size)
float TILE_SIZE=20.0;
float hite=70.0; // camera height
int[][] tiles; // types of tiles
boolean [][] gotbonus; // whether or not tile has been touched. used to ensure a tile only gets counted once!
color[] palette; // tile colours
float xp,yp; // x and y positions
int score;
int lives;
PFont font;
boolean gameover = false;

// used to build combos. certain tiles, when bounced on (but not rolled over) count towards a combo,
// which allows large scores to be built up if you hit several in a row. hitting any other type of tile
// is a combo breaker :)

float combo=1.0; 

// used to flash screen red for a few frames after losing a life
boolean showFlash=false;
int FOR_FRAMES=10;
int flashCounter;

void setup() {
  size(802,612,P3D);
  session = new PXCUPipeline(this);
  if(!session.Init(PXCUPipeline.GESTURE))
{
println("Failed to initialize the PXCUPipeline!!!");
    exit();
}
  font=loadFont("2006-48.vlw");
  textFont(font,28.0);
  reset();
  palette=new color[]{
    color(0), // black - avoid
    color(255), // white - normal tile, breaks combo
    color(255,255,0), // yellow - score, adds to combo
    color(0,255,255), // cyan - double height bounce
    color(255,0,0) // red - makes ball roll along ground
  };
}

void reset() {
  // reset game
  tiles=new int[1000][6];
  gotbonus =new boolean[1000][6];
  for (int row=0;row<1000;row++) {
    for (int col=0;col<6;col++) {
      tiles[row][col]=1;
      if (row>20 && random(0,10)>8) tiles[row][col]=0;
      if (row>30 && random(0,100)>95) tiles[row][col]=2;
      if (row>30 && random(0,100)>98) tiles[row][col]=3;
      if (row>60 && random(0,100)>99) tiles[row][col]=4;
    }
  }
  score=0;
  lives=5;
  combo=1.0;
  gameover=false;
  frameCount=0;
}

void mouseClicked() {
  if (gameover) reset();
}

void draw () {
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
 
  int ypos=(frameCount%20000);
  
  camera(0,ypos,hite,0,(ypos+400),0,0,-1,0);
  ambientLight(210,220,200);
  directionalLight(204, 204, 204, -.7, 1, 1.2);  
  lightFalloff(1.0, 0.0, 0.0) ;
  
  // background usually black, unless being 'flashed' briefly after losing a life
  if (showFlash) {
    // fade background red to black for a few frames
    float flashamt=float(flashCounter)/float(FOR_FRAMES);
    background(lerpColor(color(255,50,0),color(0),flashamt));
    flashCounter--;
    if (flashCounter==0) {
      showFlash=false;
    }
  } else {
    background(0);
  }
  
  
  // ball position
  float invertedPositionImageX = map(mHandPos[0], 0, 320, 640, 0); 
  float invertedPositionImageY = map(mHandPos[1], 0, 320, 640, 0); 
  
  float xx = 60-invertedPositionImageX/4.25; //left-right
  float yy = ypos+60+((512.0-invertedPositionImageY)/5.0); // front-back
  float zz = BALL_R/2.0+(BOUNCE_HEIGHT*(float)Math.abs(Math.sin(frameCount/BOUNCE_STRIDE))); // up-down  

  // draw tiles, but only those in a visible subset
  
  for (int col=0;col<6;col++) {
    int x=-60+(20*col);
    for (int row=0;row<1000;row++) {
      int y=20*row;
      // clip to visible region
      if (y>ypos && y<ypos+500 && tiles[row][col]>0) {
        fill(palette[tiles[row][col]],255-((y-ypos)/2));
        rect(x,y,20,20);
      }
    }
  }
  
  fill(127);
  
  // draw ball and shadow
  
  if (!gameover) {
    // ball shadow 
    ellipse(xx,yy,20,20); 
    // draw player ball 
    pushMatrix();
    translate(xx,yy,zz);
    rotateX(-frameCount/20.0); // ball roll
    sphereDetail(8);
    fill(190,56,78);
    sphere(BALL_R);
    popMatrix();
  }
  
  // draw score & combo multiplier
  
  textFont(font,28.0);
  pushMatrix();
  translate(180,ypos+400,0);
  rotateZ(PI);
  rotateX(PI*3.0/2.2);
  text("SCORE",0,-20);
  text(score+"",0,0);
  if (combo>1.0) {
    text((int)combo+"X COMBO",0,-40);
  }
  popMatrix();
  
  // draw lives
  pushMatrix();
  translate(-120,ypos+400,0);
  rotateZ(PI);
  rotateX((PI*3.0/2.2));
  text("LIVES",0,-20);
  text(lives+"",0,0);
  popMatrix();
  
  // on the ground? if so, check for 'collisions'
  if (zz <= BALL_R && !gameover) groundCheck(xx,yy);
  
  // gameover?
  if (gameover) {
    textFont(font,48.0);
    pushMatrix();
    translate(120,ypos+400,80);
    rotateZ(PI);
    rotateX((PI*3.0/2.2));
    text("GAME OVER",0,0);
    popMatrix();
  }
  
}

void groundCheck(float xx,float yy) {
  
  // called whenever ball is on ground
  
  if (BOUNCE_HEIGHT>0.0) BOUNCE_HEIGHT=70.0; //reset bounce if not rolling along ground
  
  // work out tile position underneath ball
  
  int row=(int)(yy/20.0);
  int col=(int)((xx+60)/20.0);
  
  int tiletype=0;
  if (col<0 || col>=6) {
    tiletype=0 ; // fallen off sides.. shouldn't happen!
  } else {
    tiletype=tiles[row][col]; 
    if (!(gotbonus[row][col])) {
      gotbonus[row][col]=true; // don't count a given tile more than once
      switch (tiletype) {
        case 0:
          // fell down a hole
          lives--;
          if (lives==0) gameover=true;
          combo=1.0; // combo breaker
          showFlash=true;
          flashCounter=FOR_FRAMES;          
          break;
        case 1:
          // hit normal tile
          score+=10;
          combo=1.0;
          break;
        case 2:
          // hit gold tile, turn to normal tile and rack up points
          score+=50*combo;
          tiles[row][col]=1;
          if (BOUNCE_HEIGHT>0.0) combo*=2.0;
          break;
        case 3:
          // double high bounce
          BOUNCE_HEIGHT=120.0;
          score+=50*combo;
          tiles[row][col]=1;
          if (BOUNCE_HEIGHT>0.0) combo*=2.0;
          break;
        case 4:
          // set to roll...
          BOUNCE_HEIGHT=0.0;
          combo=1.0;
          break; 
        default:
          break;
      }
    }
  }
}
