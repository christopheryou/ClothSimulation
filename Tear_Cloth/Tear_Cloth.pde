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

int tear = 0;
// Parameters
// How to pick a good k and kv
// Run times
// Start value?
// Camera
// delta time.
float gravity = .9;
float restLen = 5;
//float mass = 10; //TRY-IT: How does changing mass affect resting length?
float k = 200; //TRY-IT: How does changing k affect resting length?
float kv = 2;
float kd = kv, ks = k;
int numNodes = totalX * totalY;

// Camera
float camX = -500, camY = 150, camZ = 75; //Camera Position
float dirX = 0, dirY = 0, dirZ = 0; //Camera facing direction
float angle = 1.57;

// Time
float curTime = 0;
float prevTime = 0;

public void update(float dt){
  // Set new velocities to old  
  for (int i = 0; i < totalX; i++){
    for (int j = 0; j < totalY; j++){
      newVel[i][j] = oldVel[i][j];
    }
  }

  //y

  for (int i = 0; i < totalX - 1; i++){
    for (int j = 0; j < totalY; j++){
      if (j != 15){
        Vector e = positions[i + 1][j].sub(positions[i][j]);
        float len = sqrt(e.dot(e));
        e = e.div(len);
        float v1 = e.dot(oldVel[i][j]);
        float v2 = e.dot(oldVel[i + 1][j]);
        float force = -ks*(restLen - len) - kd * (v1 - v2); // potential swtich
        newVel[i][j] = newVel[i][j].add(e.mult(force * dt));
        newVel[i + 1][j] = newVel[i + 1][j].sub(e.mult(force * dt));
      }
      else {
        if (i > tear){
          Vector e = positions[i + 1][j].sub(positions[i][j]);
          float len = sqrt(e.dot(e));
          e = e.div(len);
          float v1 = e.dot(oldVel[i][j]);
          float v2 = e.dot(oldVel[i + 1][j]);
          float force = -ks*(restLen - len) - kd * (v1 - v2); // potential swtich
          newVel[i][j] = newVel[i][j].add(e.mult(force * dt));
          newVel[i + 1][j] = newVel[i + 1][j].sub(e.mult(force * dt));
        }  
      }
    }
  }
     
 
  //x
  for (int i = 0; i < totalX - tear; i++){
    for (int j = 0; j < totalY - 1; j++){
      Vector e = positions[i][j + 1].sub(positions[i][j]);
      float len = sqrt(e.dot(e));
      e = e.div(len);
      float v1 = e.dot(oldVel[i][j]);
      float v2 = e.dot(oldVel[i][j + 1]);
      float force = -ks*(restLen - len) - kd * (v1 - v2); // and here
      newVel[i][j] = newVel[i][j].add(e.mult(force * dt));
      newVel[i][j + 1] = newVel[i][j + 1].sub(e.mult(force * dt));
    }
  }
 
  for (int i = totalX - tear; i < totalX; i++){
    for (int j = 0; j < totalY - 1; j++){
      if (j != 14){
        Vector e = positions[i][j + 1].sub(positions[i][j]);
        float len = sqrt(e.dot(e));
        e = e.div(len);
        float v1 = e.dot(oldVel[i][j]);
        float v2 = e.dot(oldVel[i][j + 1]);
        float force = -ks*(restLen - len) - kd * (v1 - v2); // and here
        newVel[i][j] = newVel[i][j].add(e.mult(force * dt));
        newVel[i][j + 1] = newVel[i][j + 1].sub(e.mult(force * dt));
      }
     
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
    if (key == 'q') camY -= 1;
    if (key == 'a') camY += 1;

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
       positions[i][j] = new Vector(i * 1.5, i * 5, j * 5);
    }
  }
}

void keyReleased(){
    if (keyCode == RIGHT) {
      tear += 1;
      if (tear > 30)
        tear = 30;
    }//Turn the forward direction left/right
    if (keyCode == LEFT){
      tear -= 1;
      if (tear < 0){
        tear = 0;
      }
    }
}

int i = 0;
void draw(){
  curTime = millis();
  background(101, 216, 255);
  lights();
   updateSimpleCamera();
  camera(camX,camY,camZ,camX+dirX,camY+dirY,camZ+dirZ,0,1,0);

   

  float newTime = curTime - prevTime;
  newTime /= 1000;
  update(newTime); //We're using a fixed, large dt -- this is a bad idea!!
  println("tear: "  + tear);

  prevTime = curTime;
  pushMatrix();
  fill(10, 240, 10);
  translate(0, 400, 0);
  box(1000, 0.01, 1000);
  popMatrix();
  fill(205, 100, 120);
   for (int i = 0; i < totalX - 1; i++){
    for (int j = 0; j < totalY - 1; j++){
      if (j != 14){
        pushMatrix();
        beginShape(TRIANGLE_STRIP);
        noStroke();
        vertex(positions[i][j].x, positions[i][j].y, positions[i][j].z);
        vertex(positions[i][j+1].x, positions[i][j+1].y, positions[i][j+1].z);
        vertex(positions[i+1][j].x, positions[i+1][j].y, positions[i+1][j].z);
        vertex(positions[i+1][j+1].x, positions[i+1][j+1].y, positions[i+1][j+1].z);
        endShape();
        popMatrix();
      }
      else {
        if (i < totalX - tear){ //  we're not on a tear row
          pushMatrix();
          beginShape(TRIANGLE_STRIP);
          noStroke();
          vertex(positions[i][j].x, positions[i][j].y, positions[i][j].z);
          vertex(positions[i][j+1].x, positions[i][j+1].y, positions[i][j+1].z);
          vertex(positions[i+1][j].x, positions[i+1][j].y, positions[i+1][j].z);
          vertex(positions[i+1][j+1].x, positions[i+1][j+1].y, positions[i+1][j+1].z);
          endShape();
          popMatrix();
        }
      }
    }
  }
}

void keyPressed(){
  if (key == 'k'){
    k+=5;
    println("k = " + k);
  }
  if (key == 'v'){
    kv += 5;
    println("kv = " + kv);
  }
  if (key == 'g'){
    gravity += 5;
    println("g = " + gravity);
  }
  if (key == 'm'){
   // mass += 5;
    //println("m = " + mass);
  }
  if (key == 'r'){
    restLen += 5;
    println("rest = "  + restLen);
  }
}
