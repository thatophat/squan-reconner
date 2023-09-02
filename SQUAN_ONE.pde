import peasy.*;
PeasyCam cam;

//CUBE VARIABLES
float len = 150; //defines length of whole cube

float[] upLayer = {1, -1, 0.02, 2, -2, 0.03, 3, -3, 0.04, 4, -4, 0.01}; //array represnting up layer
float[] doLayer = {0.05, 5, -5, 0.06, 6, -6, 0.07, 7, -7, 0.08, 8, -8}; //array representing down layer

boolean bar = false;
boolean sliceable = false;

//RESET STATES:
//{1, -1, 0.02, 2, -2, 0.03, 3, -3, 0.04, 4, -4, 0.01}
//{0.05, 5, -5, 0.06, 6, -6, 0.07, 7, -7, 0.08, 8, -8}

//RECON VARIABLES
String setupmoves = "(1,0)/ (-3,0)/ (5,-4)/ (0,-3)/ (-2,-2)/ (5,-1)/ (-5,0)/ (6,-3)/ (3,0)/ (3,-2)/ (6,-2)/ (2,0)/ (-1,0)"; //PASTE YOUR SETUP MOVES OR SCRAMBLE HERE
String moves = "(-5,0)/(3,-2)/(-1,-2)/(0,-3)/(1,0)/(-3,-3)/(0,0)/(3,0)/(-1,-1)/(-3,0)/(6,-2)/(-3,0)/(3,3)/(0,-3)/";  //TYPE YOUR MOVES YOU WANT TO ANIMATE AND SEE HERE
int hun = 0;
int ten = 10; 
int one = 10;
int[] setupmovesArr = {};
int[] movesArr = {};
boolean setupfirst;
boolean setuplast;

//COLOUR VARIABLES

color BL = #60D937; 
color RE = #FF2600;
color GR = #0433FF;
color OR = #FF9300;

color[] polescol = {#1E1E1E, #FFFFFF}; //colours on {top,bottom} for a reset squan (aka colour scheme, default B/W)

color[] ercArray = {OR, BL, RE, GR, RE, BL, OR, GR}; //colour array for edges and right side of corners {OBRGRBOG}
color[] lcArray = {BL, RE, GR, OR, BL, OR, GR, RE}; //colour array for left side of corners {BRGOBOGR}

//ANIMATION VARIABLES
boolean animating = false;
int updir;
int dodir;
float speed = 0.85; //anim speed multiplier
int step = 0;
int turnState = 0;
boolean start = false;
boolean first = false;
boolean lastmove;
boolean firstmove = false; 

float up_ang = 0;
float do_ang = 0;
float slice_ang = 0;
float a = 0;
float equ_rotZ = 0;
float equ_rotY = 0;

void encodeMoves(){
  hun = 0;
  ten = 10; 
  one = 10;
  
  if (moves != ""){
    for (int i = 0; i < moves.length(); i++){
      char ch = moves.charAt(i);
      if (int(ch) == 40){ //is this an open bracket
        if (int(moves.charAt(i+1)) == 45){ //is the next value a negative?
          hun = 2;
        } else {
          hun = 1;
        }
      }
      if (int(ch) >= 48 && int(ch) <= 54){ //is this a number?
        if (ten == 10){    //is this the first or second part of the bracket?
          ten = int(ch) - 48; 
        } else {
          one = int(ch) - 48;
        }
      }
      if (int(ch) == 45){ //is this a negative sign
        if (int(moves.charAt(i-1)) != 40){
          hun += 2;
        }
      }
      if(int(ch) == 41){
        movesArr = append(movesArr, (one+10*ten+100*hun));
        hun = 0;
        ten = 10; 
        one = 10;  
      }
    }
    if (moves.charAt(0) == '/'){
      turnState = -1; //START WITH SLICE
      first = true;
    } else {
      turnState = 1; //START WITH TURN
      first = false;
    }
    
    if (moves.charAt(moves.length() - 1) == '/'){
      lastmove = true;
    } else {
      lastmove = false;
    }
  }
}

void encodeSetupMoves(){
  hun = 0;
  ten = 10; 
  one = 10;
  for (int i = 0; i < setupmoves.length(); i++){
    char ch = setupmoves.charAt(i);
    if (int(ch) == 40){ //is this an open bracket
      if (int(setupmoves.charAt(i+1)) == 45){ //is the next value a negative?
        hun = 2;
      } else {
        hun = 1;
      }
    }
    if (int(ch) >= 48 && int(ch) <= 54){ //is this a number?
      if (ten == 10){    //is this the first or second part of the bracket?
        ten = int(ch) - 48; 
      } else {
        one = int(ch) - 48;
      }
    }
    if (int(ch) == 45){ //is this a negative sign
      if (int(setupmoves.charAt(i-1)) != 40){
        hun += 2;
      }
    }
    if(int(ch) == 41){
      setupmovesArr = append(setupmovesArr, (one+10*ten+100*hun));
      hun = 0;
      ten = 10; 
      one = 10;  
    }
  }
  if (setupmoves.charAt(0) == '/'){
    setupfirst = true;
  } else {
    //START WITH TURN
    first = false;
  }
  
  if (setupmoves.charAt(setupmoves.length() - 1) == '/'){
    setuplast = true;
  } else {
    setuplast = false;
  }
}

void doSetup(){
  if (setupfirst == true){
    slice();
    print("hello");
  }
  for (int i = 0; i < setupmovesArr.length; i++){
    upturn(setupmovesArr[i]);
    doturn(setupmovesArr[i]);
    slice();
  }
  if (setuplast == false){
    slice();
  }
}

//DRAWING PIECES

void edge(int col){ //edge
  fill(col);
  beginShape();
  strokeWeight(5);
  vertex(0, 0, 0);
  vertex((len/2) * tan(PI/12) , -len/2,  0);
  vertex(-((len/2) * tan(PI/12)) , -len/2,  0);
  endShape(CLOSE);
}

void corn(int col){ //corner
  pushMatrix();
  rotateZ(PI/6);
  fill(col);
  beginShape();
  strokeWeight(5);
  vertex(0,0,0);
  vertex(-(len/2) * tan(PI/12),-(len/2),0);
  vertex(-(len/2),-(len/2),0);
  vertex(-(len/2),-(len/2) * tan(PI/12),0);
  endShape(CLOSE);
  popMatrix();

}

int edgefill(boolean isTop, boolean isInternal, int j){
  if (isInternal == true){
    return 15;
  } else {
    if (isTop == true){
      return polescol[round(((100 / 8 * upLayer[j]) - 0.01)%(1))];
    } else {
      return polescol[round(((100 / 8 * doLayer[j]) - 0.01)%(1))];
    }
  }
}

int cornfill(boolean isTop, boolean isInternal, int j){
  if (isInternal == true){
    return 15;
  } else {
    if (isTop == true){
      return polescol[round((abs(upLayer[j])/8.5)%1)];
    } else {
      return polescol[round((abs(doLayer[j])/8.5)%1)];
    }
  }
}

void cshape(int isLeft_po,int top, boolean isInternal){ // top=1 refers to up layer, top=-1 refers to down layer
  pushMatrix();
  translate(0,0,top * (len/2));
  
  int start_po = 0;
  if (isLeft_po == 0){
    start_po= 0;
  } else {
    start_po = 6;
  }
  
  if (top == 1){ //TOP LAYER
    for (int i=start_po; i<(start_po + 6); i++){ 
      if (abs(upLayer[i]) < 1){ //edge
        pushMatrix();
        rotateZ((i+1)*PI/6);
        edge(edgefill(true, isInternal, i));
        popMatrix();
      } else {
        pushMatrix();
        rotateZ((i+2)*PI/6);
        corn(cornfill(true, isInternal, i));
        popMatrix();
        i++;
      }      
    }
  } else { //BOTTOM LAYER
    pushMatrix();
    rotateZ(PI);
    for (int i=start_po; i<(start_po + 6); i++){
      if (abs(doLayer[i]) < 1){ //edge
        pushMatrix();
        rotateZ(-(i)*PI/6);
        edge(edgefill(false, isInternal, i));
        popMatrix();
      } else {
        pushMatrix();
        rotateZ(-(i)*PI/6);
        corn(cornfill(false, isInternal, i));
        popMatrix();
        i++;
      }      
    }
    popMatrix();
  }
  popMatrix();
}

void equ(float x, float y, float z, color fill){ //draws the equator on left of cube
  pushMatrix();
  translate(x,y,z);
  fill(fill);
  beginShape(QUADS);
  vertex(-len/2, -len/2, -(len/6));
  vertex(-len/2, -len/2, +(len/6));
  vertex(-len/2, len/2, +(len/6));
  vertex(-len/2, len/2, -(len/6));
  endShape();
  popMatrix();
}

void cadj(float x, float y, float z, color fill){ //draws the adjacent corner bit on the corners left
  pushMatrix();
  translate(x,y,z);
  fill(fill);
  beginShape(QUADS);
  vertex(-len/2, -len/2, len/6); //this rectangle is originaly from the ULB corner 
  vertex(-len/2, -len/2, len/2);
  vertex(-(len/2) * tan(PI/12), -len/2, len/2);
  vertex(-(len/2) * tan(PI/12), -len/2, len/6);
  endShape();
  popMatrix();
}

void eadj(float x,float y, float z, color fill){
  pushMatrix();
  translate(x,y,z);
  fill(fill);
  beginShape(QUADS);
  vertex(-((len/2) * tan(PI/12)), -len/2, len/6);
  vertex(-((len/2) * tan(PI/12)), -len/2, len/2);
  vertex(((len/2) * tan(PI/12)), -len/2, len/2);
  vertex(((len/2) * tan(PI/12)), -len/2, len/6);
  endShape();
  popMatrix();
}

void oppequ(float x, float y, float z, color fill){ //draws the larger part of the bar
  pushMatrix();
  translate(x,y,z);
  fill(fill);
  beginShape(QUADS);
  vertex(-len/2, -len/2, len/6); //this rectangle is originaly from the ULB corner 
  vertex(-len/2, -len/2, len/2);
  vertex((len/2) * tan(PI/12), -len/2, len/2);
  vertex((len/2) * tan(PI/12), -len/2, len/6);
  endShape();
  popMatrix();
}

void facesides(int isLeft_sides, int top){
  if (isLeft_sides == 0){
    isLeft_sides = 0;
  } else {
    isLeft_sides = 6;
  }
  pushMatrix(); 
  if (top == 1){
    for (int i=isLeft_sides; i<(isLeft_sides+6); i++){ 
      if ( abs(upLayer[i]) < 1){ //edge
        pushMatrix();
        rotateZ((i+1)*PI/6);
        eadj(0,0,0, ercArray[int(100 * upLayer[i])-1]);
        popMatrix();
      } else if(upLayer[i] >= 1) { //right side of corner
        pushMatrix();
        rotateZ((i)*PI/6);
        cadj(len/2+ (len/2) * tan(PI/12),0,0,ercArray[int(upLayer[i])-1]);
        popMatrix();
      } else {
        pushMatrix();
        rotateZ((i+2)*PI/6);
        cadj(0,0,0,lcArray[int(abs(upLayer[i]))-1]);
        popMatrix();
      }
        
    }
  } else {
    translate(0,0,-2 * len/3);
    for (int i=isLeft_sides; i<(isLeft_sides+6); i++){ 
      if ( abs(doLayer[i]) < 1){ //edge
        pushMatrix();
        rotateZ(-(i)*PI/6);
        eadj(0,len,0,ercArray[int(100 * doLayer[i])-1]);
        popMatrix();
      } else if(doLayer[i] >= 1) { //right side of corner
        pushMatrix();
        rotateZ(-(i-1)*PI/6);
        cadj(len/2+ (len/2) * tan(PI/12),len,0, ercArray[int(doLayer[i])-1]);
        popMatrix();
      } else {
        pushMatrix();
        rotateZ(-(i+1)*PI/6);
        cadj(0,len,0,lcArray[int(abs(doLayer[i]))-1]);
        popMatrix();
      }
        
    }
  }
  popMatrix();
}

void barflip(boolean isRight, boolean flipped){
  //draws the equator
  if (isRight == false) {
  equ(0,0,0,ercArray[3]); //green
  cadj(0, len, -len/3, ercArray[2]); //small [red ]front 
  oppequ(0,0,-len/3,ercArray[0]);// big [orange] back
  } else{  
    if (flipped == false) {
      equ(len,0,0, ercArray[1]); //blue
      cadj(len/2 + ((len/2) * tan(PI/12)), 0, -len/3, ercArray[0]); //small back
      oppequ(len/2-((len/2) * tan(PI/12)),len,-len/3,ercArray[2]);// big front
      
      fill(15);
      beginShape(QUADS);
      vertex(len/2, -len/2, len/6);
      vertex(len/2, len/2, len/6);
      vertex(-(len/2) * tan(PI/12), len/2, len/6);
      vertex((len/2) * tan(PI/12), -len/2, len/6);
      
      vertex(len/2, -len/2, -len/6);
      vertex(len/2, len/2, -len/6);
      vertex(-(len/2) * tan(PI/12), len/2, -len/6);
      vertex((len/2) * tan(PI/12), -len/2, -len/6);
      endShape();
      
    } else {
      pushMatrix();
      rotateX(PI);
      rotateZ(-PI/6);
      equ(len,0,0, ercArray[1]); //blue
      cadj(len/2 + ((len/2) * tan(PI/12)), 0, -len/3, ercArray[0]); //small back
      oppequ(len/2-((len/2) * tan(PI/12)),len,-len/3,ercArray[2]);// big front
      
      fill(15);
      beginShape(QUADS);
      vertex(len/2, -len/2, len/6);
      vertex(len/2, len/2, len/6);
      vertex(-(len/2) * tan(PI/12), len/2, len/6);
      vertex((len/2) * tan(PI/12), -len/2, len/6);
      
      vertex(len/2, -len/2, -len/6);
      vertex(len/2, len/2, -len/6);
      vertex(-(len/2) * tan(PI/12), len/2, -len/6);
      vertex((len/2) * tan(PI/12), -len/2, -len/6);
      endShape();
      
      popMatrix();
    }
  }
}

//ARRAY/SQUAN OPERATIONS

void slice(){
  float[] upSection = subset(upLayer, 0, 6); //section refers to the pieces on the right of the squan
  float[] doSection = subset(doLayer, 0, 6); //section refers to the pieces on the right of the squan
  
  upLayer = subset(upLayer, 6, 6); //removes the first 6 pieces by only taking the last 6 data slots
  doLayer = subset(doLayer, 6, 6); //removes the first 6 pieces by only taking the last 6 data slots
  
  upLayer = splice(upLayer, doSection, 0); //combine the two together to form the layer
  doLayer = splice(doLayer, upSection, 0);
  
  bar = !bar;

}

boolean isSliceable(int input){
  float tempvar;
  float tempArr[];
  
  tempArr = upLayer;
  for (int i=0; i<floor((input%100)/10); i++){ 
    if (floor(input/100)%2 != 0){
      tempvar = tempArr[11];
      tempArr = subset(tempArr, 0, 11);
      tempArr = splice(tempArr, tempvar , 0);
    } else {
      tempvar = upLayer[0];
      tempArr = subset(tempArr, 1, 11);
      tempArr = append(tempArr, tempvar);
    }
    
  } 
  float[] upSection = subset(tempArr, 0, 6); //section refers to the pieces on the right of the squan
  float upTotal = 0;
  for (float n : upSection)
  {
  upTotal += n;
  }  
  
  tempArr = doLayer;
  for (int i=0; i<(input%10); i++){
    if (floor(input/100) <= 2){  //IF IT IS A CLOCKWISE TURN
      tempvar = tempArr[11];
      tempArr = subset(tempArr, 0, 11);
      tempArr = splice(tempArr, tempvar , 0);
    } else {
      tempvar = tempArr[0];
      tempArr = subset(tempArr, 1, 11);
      tempArr = append(tempArr, tempvar);
    }       
  }
  
  float[] doSection = subset(doLayer, 0, 6); //section refers to the pieces on the right of the squan
  float doTotal = 0;
  for (float n : doSection)
  {
  doTotal += n;
  }      
  if ((round(doTotal) == 0)&&(round(upTotal) == 0)){
    return true;
  } else {
    return false;
  }  
}

void upturn(int input){    
  float tempvar;
  
  for (int i=0; i<floor((input%100)/10); i++){ //floor((input%10)/100)
    if (floor(input/100)%2 != 0){
      tempvar = upLayer[11];
      upLayer = subset(upLayer, 0, 11);
      upLayer = splice(upLayer, tempvar , 0);
    } else {
      tempvar = upLayer[0];
      upLayer = subset(upLayer, 1, 11);
      upLayer = append(upLayer, tempvar);
    }
    
  }
}
    
void doturn(int input){
  float tempvar;
  for (int i=0; i<(input%10); i++){
    if (floor(input/100) <= 2){  //IF IT IS A CLOCKWISE TURN
      tempvar = doLayer[11];
      doLayer = subset(doLayer, 0, 11);
      doLayer = splice(doLayer, tempvar , 0);
    } else {
      tempvar = doLayer[0];
      doLayer = subset(doLayer, 1, 11);
      doLayer = append(doLayer, tempvar);
    }       
  }
}

//ANIMATION FUNCTIONS

void UDturnanim(int input){
  pushMatrix();
  rotateZ(up_ang);
  cshape(0,1, false); //UP LAYER RIGHT SIDE
  cshape(1,1, false); //UP LAYER LEFT SIDE
  facesides(0,1); //UP LAYER RIGHT SIDE
  facesides(1,1); //UP LAYER LEFT SIDE    
  
  pushMatrix();
  translate(0,0,-len/3);
  cshape(0,1, true); //UP LAYER RIGHT SIDE (INTERNAL)
  cshape(1,1, true); //UP LAYER LEFT SIDE (INTERNAL)
  popMatrix();
  popMatrix();
  
  a += 0.03*speed;

  if (floor(input/100)%2 == 1){
    up_ang = lerp(0, (floor(0.1*(input%100)) * PI/6), a);
  } else {
    up_ang = lerp(0, -(floor(0.1*(input%100)) * PI/6), a);
  }

  pushMatrix();
  rotateZ(do_ang);
  cshape(0,-1, false); //DOWN LAYER RIGHT SIDE
  cshape(1,-1, false); //DOWN LAYER LEFT SIDE
  facesides(0,-1); //DOWN LAYER RIGHT SIDE
  facesides(1,-1); //DOWN LAYER LEFT SIDE    
  
  pushMatrix();
  translate(0,0,len/3);
  cshape(0,-1, true); //DOWN LAYER RIGHT SIDE (INTERNAL)
  cshape(1,-1, true); //DOWN LAYER LEFT SIDE (INTERNAL)
  popMatrix();
  popMatrix();
  
  if (floor(input/100) <= 2){ //IF CLOCKWISE
    do_ang = lerp(0,-(input%10 * PI/6),a);
  } else {
    do_ang = lerp(0,(input%10 * PI/6),a);
  } 
  
  barflip(true, bar);
  barflip(false, bar);
  
  if (a >= 1){
    animating = false;   
    up_ang = 0;
    do_ang = 0;
    a = 0;
    upturn(input); //CHANGE ARRAY HERE
    doturn(input);
  }
}

void slice_anim(){
  pushMatrix();
  rotateX(slice_ang);
  rotateY(equ_rotY);
  rotateZ(equ_rotZ);
  barflip(true,bar);

  cshape(0,1, false); //UP LAYER RIGHT SIDE
  cshape(0,-1, false); //DOWN LAYER RIGHT SIDE
  facesides(0,1); //UP LAYER RIGHT SIDE
  facesides(0,-1); //DOWN LAYER RIGHT SIDE   
  
  fill(15);
  beginShape(QUADS);
  vertex((len/2) * tan(PI/12),-len/2, len/2); //slice plane 
  vertex((len/2) * tan(PI/12),-len/2, -len/2);
  vertex(-(len/2) * tan(PI/12),len/2, -len/2);
  vertex(-(len/2) * tan(PI/12),len/2, len/2); 
  endShape();

  pushMatrix();
  translate(0,0,-len/3);
  cshape(0,1, true); //UP LAYER RIGHT SIDE (INTERNAL)
  popMatrix();
  
  pushMatrix();
  translate(0,0,len/3);
  cshape(0,-1, true); //DOWN LAYER RIGHT SIDE (INTERNAL)
  popMatrix();
  
  popMatrix();
  slice_ang = PI * a;
  a += 0.03*speed;
  equ_rotY =  -PI/3 * sq(a - 0.5) + PI/12;  
  equ_rotZ =  -PI/6 * a;
  
  cshape(1,1, false); //UP LAYER LEFT SIDE
  cshape(1,-1,false); // DOWN LAYER LEFT SIDE
  facesides(1,1); //UP LAYER LEFT SIDE
  facesides(1,-1); //DOWN LAYER LEFT SIDE 
  barflip(false,bar);
  
  fill(15);
  beginShape(QUADS);
  vertex((len/2) * tan(PI/12),-len/2, len/2); //slice plane 
  vertex((len/2) * tan(PI/12),-len/2, -len/2);
  vertex(-(len/2) * tan(PI/12),len/2, -len/2);
  vertex(-(len/2) * tan(PI/12),len/2, len/2); 
  endShape();
  
  pushMatrix();
  translate(0,0,-len/3);
  cshape(1,1, true); //UP LAYER LEFT SIDE (INTERNAL)
  popMatrix();

  pushMatrix();
  translate(0,0,len/3);
  cshape(1,-1, true); //DOWN LAYER LEFT SIDE (INTERNAL)
  popMatrix();
  
  if (abs(slice_ang) >= PI){
    animating = false;
    slice_ang = 0;
    a = 0;
    equ_rotZ = 0;
    equ_rotY = 0;
    slice();
  }   
}

void setup(){
  size(600,600,P3D);
  cam = new PeasyCam(this, 400);
  translate(width/2,height/2); //sets origin in center 
  encodeSetupMoves();
  doSetup(); 
  encodeMoves();
}

//INPUT AND SCENE
void keyPressed() {
  if (key == ' ' && start == false){
    animating = true;
    start = true;
  }
}

void draw(){ //draws the scene
  strokeWeight(5);
  background(200);
  
  //draw internals
  fill(15);
  beginShape(QUADS); //core internals
  vertex(-len/2, -len/2, len/6); //top left part of core
  vertex(-len/2, len/2, len/6);
  vertex(-(len/2) * tan(PI/12),len/2 , len/6);
  vertex((len/2) * tan(PI/12),-len/2, len/6);
  
  vertex(-len/2, -len/2, -len/6); //bottom left part of core
  vertex(-len/2, len/2, -len/6);
  vertex(-(len/2) * tan(PI/12),len/2 , -len/6);
  vertex((len/2) * tan(PI/12),-len/2, -len/6);
  endShape();  
  
  //ANIMATES CURRENT MOVE
  if (animating == true){
    if (turnState == 1){
      UDturnanim(movesArr[step]);
    } else {
      slice_anim();
    }   
  } else {
    //draws the U/D layers 
    cshape(0,1, false); //UP LAYER RIGHT SIDE
    cshape(1,1, false); //UP LAYER LEFT SIDE
    cshape(0,-1, false); //DOWN LAYER RIGHT SIDE
    cshape(1,-1,false); // DOWN LAYER LEFT SIDE
    
    //draws the adjacent part of the u and d layers 
    facesides(0,1); //UP LAYER RIGHT SIDE
    facesides(1,1); //UP LAYER LEFT SIDE
    facesides(0,-1); //DOWN LAYER RIGHT SIDE
    facesides(1,-1); //DOWN LAYER LEFT SIDE 
    
    //draws bar
    barflip(true, bar);
    barflip(false, bar); 
    
    pushMatrix();
    translate(0,0,-len/3);
    cshape(0,1, true); //UP LAYER RIGHT SIDE (INTERNAL)
    cshape(1,1, true); //UP LAYER LEFT SIDE (INTERNAL)
    popMatrix();
  
    pushMatrix();
    translate(0,0,len/3);
    cshape(0,-1, true); //DOWN LAYER RIGHT SIDE (INTERNAL)
    cshape(1,-1, true); //DOWN LAYER LEFT SIDE (INTERNAL)
    popMatrix();
    //NEXT MOVE LOGIC
    if (start == true){
      if ((step < (movesArr.length - 1))&&(turnState == -1)){ //do i need to do a turn  
        if (first == true){
          if (step == 0 && firstmove == false){
            turnState = 1;
            animating = true;
            firstmove = true;
          } else {
            step++; 
            turnState = 1;
            animating = true;
          }
        } else {
          step++; 
          turnState = 1;
          animating = true;
        }
      } else if (turnState == 1) { 
        if (step != (movesArr.length - 1)){
          turnState = -1;  
          animating = true;
        } else if (step == (movesArr.length - 1) && lastmove == true){
          turnState = -1;  
          animating = true;
        } else {
          animating = false;
        }
      } else {
        animating = false;
      }
    }
  }
}
