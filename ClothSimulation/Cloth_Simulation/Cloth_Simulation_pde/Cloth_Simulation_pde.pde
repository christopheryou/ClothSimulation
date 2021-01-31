class Vector{
  public float x;
  public float y;
  public float z;
 
  public Vector(float x, float y, float z){
    this.x = x;
    this.y = y;  
    this.z = z;
  }
  public float dot(Vector vector){
    float tempX = this.x * vector.x;
    float tempY = this.y * vector.y;
    float tempZ = this.z * vector.z;
    return tempX + tempY + tempZ;
  }
 
  public Vector cross(Vector vector){
    float x, y, z;
    x = (this.y * vector.z) - (this.z * vector.y);
    y = (this.z * vector.x) - (this.x * vector.z);
    z = (this.x * vector.y) - (this.y * vector.x);
    return new Vector(x, y, z);
  }
 
  public Vector add(Vector vector){
    return new Vector(this.x + vector.x, this.y + vector.y, this.z + vector.z);
  }
 
  public Vector sub(Vector vector){
    return new Vector(this.x - vector.x, this.y - vector.y, this.z - vector.z);
  }
 
  public Vector mult(float scalar){
    return new Vector(this.x * scalar, this.y * scalar, this.z * scalar);
  }
  public Vector div(float scalar){
    return new Vector(this.x / scalar, this.y / scalar, this.z / scalar);
  }
 
  public float mag(){
    return sqrt((this.x * this.x) + (this.y * this.y) + (this.z * this.z));
  }
}


int totalX = 30, totalY = 30;
Vector positions[][] = new Vector[totalX][totalY];
Vector newVel[][] = new Vector[totalX][totalY];
Vector oldVel[][] = new Vector[totalX][totalY];


// Parameters
// How to pick a good k and kv
// Run times
// Start value?
// Camera
// delta time.
float gravity = 20*2;
float restLen = 10;
float mass = 0.045; //TRY-IT: How does changing mass affect resting length?
//0.045
float kd = 1000*2, ks = 10000*3000;
int numNodes = totalX * totalY;

// Camera
float camX =-425.26483;
float camY = 148.0; //58
float camZ = -452.67462;
float dirX = 0.50553316;
float dirY = 0.0;
float dirZ = 0.86280715;
float angle = 0.5299998;
float pc = 0.00000005;
/*
float camX = -300, camY = 300, camZ = -1000; //Camera Position
float dirX = 0, dirY = 0, dirZ = 0; //Camera facing direction

float angle = 0.05;
*/
float damp = 0.995;


public void update(float dt){
  // Set new velocities to old  
  for (int i = 0; i < totalX; i++){
    for (int j = 0; j < totalY; j++){
      newVel[i][j] = oldVel[i][j];
    }
  }
 
  for (int i = 0 ; i < totalX; i++){
    for (int j = 0 ; j < totalY; j++){
      Vector dist = positions[i][j].sub(new Vector(-200, 100, 75));
      float distance = dist.mag();
      if (distance < 50 + 4.99){
        Vector norm = (positions[i][j].mult(-1)).add(new Vector(-200, 100, 75));
        norm = norm.mult(-1).div(norm.mag());
        //float bounce = oldVel[i][j].dot(norm);
        //bounce = norm.mult(bounce);
        Vector bounce = norm.mult(oldVel[i][j].dot(norm));
        oldVel[i][j] = oldVel[i][j].sub(bounce.mult(1.5));
        positions[i][j] = positions[i][j].add(norm.mult(5 + 50 - distance)); // .1
      }
    }
  }
 
  //Y
  for (int i = 0; i < totalX - 1; i++){
    for (int j = 0; j < totalY; j++){    
      Vector e = positions[i + 1][j].sub(positions[i][j]);
      float len = sqrt(e.dot(e));
      e = e.div(len);
      float v1 = e.dot(oldVel[i][j]);
      float v2 = e.dot(oldVel[i + 1][j]);
      float force = mass * (-ks*(restLen - len) - kd * (v1 - v2)); // potential swtich
      newVel[i][j] = (newVel[i][j].add(e.mult(force * dt)));
      newVel[i + 1][j] = newVel[i + 1][j].sub(e.mult(force * dt));
    }
  }
 
  //X
  for (int i = 0; i < totalX; i++){
    for (int j = 0; j < totalY - 1; j++){      
      Vector e = positions[i][j + 1].sub(positions[i][j]);
      float len = sqrt(e.dot(e));
      e = e.div(len);
      float v1 = e.dot(oldVel[i][j]);
      float v2 = e.dot(oldVel[i][j + 1]);
      float force = mass *(-ks*(restLen - len) - kd * (v1 - v2)); // and here
      newVel[i][j] = (newVel[i][j].add(e.mult(force * dt)));
      newVel[i][j + 1] = newVel[i][j + 1].sub(e.mult(force * dt));
    }
  }
 //force / 3 = a vector
 // add the vector to each of the points
 for (int i = 0; i < totalX-1; i++){
   for (int j = 0; j < totalY-1; j++){
     Vector c1 = positions[i][j + 1].sub(positions[i][j]);
     Vector c2 = positions[i+1][j].sub(positions[i][j]);
     Vector norm = c1.cross(c2);
     
     Vector v = newVel[i][j].add(newVel[i][j+1].add(newVel[i+1][j]));
     v = v.div(3);
     float vvn = v.dot(norm) * v.mag();
     vvn /= 2;
     vvn /= norm.mag();
     Vector van = norm.mult(vvn);
     
     // Parameters
     van = van.mult(-0.5);
     van = van.mult(pc);
     
     newVel[i][j] = newVel[i][j].add(van);
     newVel[i][j+1] = newVel[i][j+1].add(van);
     newVel[i+1][j] = newVel[i+1][j].add(van);
     
   }
 }
 
  for (int i = 0; i < totalX; i++){
    for (int j = 0; j < totalY; j++){
      newVel[i][j] = newVel[i][j].add(new Vector(0, gravity, 0)); // and here
    }
  }
  for (int i = 0; i < totalX; i++){
    newVel[0][i] = new Vector(0, 0, 0);
  }
  for (int i = 0; i < totalX; i++){
    for (int j = 0; j < totalY; j++){
      positions[i][j] = positions[i][j].add(newVel[i][j].mult(dt));
    }
  }
  //Radius = 50
  //-200, 100, 75
  for (int i = 0; i < totalX; i++){
    for (int j = 0; j < totalY; j++){
      oldVel[i][j] = newVel[i][j];
    }
  }
}
 

void updateSimpleCamera(){
  if (keyPressed){
    if (keyCode == UP){
      camX += dirX; camY += dirY; camZ += dirZ; //Move the camera in the forward direction
    }
    if (keyCode == DOWN){
      camX -= dirX; camY -= dirY; camZ -= dirZ; //Move the camera in the backward direction
    }
    if (key == 'q') camY -= 1;
    if (key == 'a') camY += 1;
    if (keyCode == RIGHT) angle -= .01;  //Turn the forward direction left/right
    if (keyCode == LEFT) angle += .01;
    if (key == 'r') {
  for (int i = 0; i < totalX; i++){
    for (int j = 0; j < totalY; j++){
       oldVel[i][j] = new Vector(0, 0, 0);
       newVel[i][j] = new Vector(0, 0, 0);
       positions[i][j] = new Vector(i*-10, 0, j * 10);
    }
  }
    }
  }
   
  dirX = sin(angle); //Compute the forward direction form the angle
  dirZ = cos(angle);
}

void setup(){
  size(1000, 1000, P3D);
  surface.setTitle("Cloth Simulation!");
  perspective(PI/4.0,(float)width/height,1,10000); //Set a near & far plan of the camera (and the FOV)
  for (int i = 0; i < totalX; i++){
    for (int j = 0; j < totalY; j++){
       oldVel[i][j] = new Vector(0, 0, 0);
       newVel[i][j] = new Vector(0, 0, 0);
       positions[i][j] = new Vector(i*-10, 0, j * 10);
    }
  }
}

int i = 0;
void draw(){
  background(25, 188, 255);
  lights();
  updateSimpleCamera();
  camera(camX,camY,camZ,camX+dirX,camY+dirY,camZ+dirZ,0,1,0);
  println("FPS " + frameRate);
  update(0.0005); //We're using a fixed, large dt -- this is a bad idea!!
  pushMatrix();
  noStroke();
  fill(50,205,50);
  translate(-200, 100, 75);
  sphere(45);// 45
  popMatrix();

   for (int i = 0; i < totalX - 1; i++){
    for (int j = 0; j < totalY - 1; j++){    
      pushMatrix();
      beginShape(TRIANGLE_STRIP);
      noStroke();
      if (i % 2 == 0){
        if (j % 2 == 0){
          fill(250, 128, 114);
        }
        else {
          fill(255, 255, 255);
        }
      }
      else {
        if (j % 2 == 0){
          fill (220, 20, 60);
        }
        else {
          fill ( 250, 128, 114);
        }
      }
       
      vertex(positions[i][j].x, positions[i][j].y, positions[i][j].z);
      vertex(positions[i][j+1].x, positions[i][j+1].y, positions[i][j+1].z);
      vertex(positions[i+1][j].x, positions[i+1][j].y, positions[i+1][j].z);
      vertex(positions[i+1][j+1].x, positions[i+1][j+1].y, positions[i+1][j+1].z);
      endShape();
      popMatrix();
    }
   }

}
