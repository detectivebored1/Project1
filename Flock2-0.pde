
Flock flock;

static int numObstacles = 20;
static int maxNumNodes = 100;
PVector circlePos[] = new PVector[numObstacles]; //Circle positions
float circleRad[] = new float[numObstacles]; 

ArrayList<Integer> path = new ArrayList();

//A list of circle obstacles
PVector startPos = new PVector(100,500);
PVector goalPos = new PVector(500,200);
PVector[] nodePos = new PVector[maxNumNodes];

BigBird bigbird;

void placeRandomObstacles(){
  for (int i = 0; i < numObstacles-1; i++){
    circlePos[i] = new PVector(random(50,950),random(50,700));
    circleRad[i] = (0+40*pow(random(1),3));
  }

}
void BigbirdObstacle(){
  circlePos[numObstacles-1] = bigbird.position;
  circleRad[numObstacles-1] = 25;
}

//Generate non-colliding PRM nodes
void generateRandomNodes(int numNodes, PVector circleCenters[], float[] circleRad){
  for (int i = 0; i < numNodes; i++){
    PVector randPos = new PVector(random(width),random(height));
    boolean insideAnyCircle = pointInCircleList(circleCenters, circleRad, numObstacles, randPos, 2);
    while (insideAnyCircle){
      randPos = new PVector(random(width),random(height));
      insideAnyCircle = pointInCircleList(circleCenters, circleRad, numObstacles, randPos, 2);
    }
    nodePos[i] = randPos;
  }
}



void setup() {
  size(1024,768);
  flock = new Flock();
  placeRandomObstacles();
  generateRandomNodes(maxNumNodes, circlePos, circleRad);
  PVector start = nodePos[closestNode(startPos, nodePos, maxNumNodes)];
  connectNeighbors(circlePos, circleRad, numObstacles, nodePos, maxNumNodes);
  path = runUCS(nodePos,maxNumNodes, closestNode(startPos, nodePos, maxNumNodes), closestNode(goalPos, nodePos, maxNumNodes));
  bigbird = new BigBird(start);
  BigbirdObstacle();
  for (int i = 0; i < 300; i++) {
    flock.addBoid(new Boid(width/2,height/2));
  }
}


void draw() {
  strokeWeight(1);
  stroke(255,255,255);
  background(135,206,235);
  for (int i = 0; i < numObstacles-1; i++){
    PVector c = circlePos[i];
    float r = circleRad[i];
    fill(255, 255, 255);
    circle(c.x,c.y,r*2);
  }
  fill(0);
  flock.run();
  PVector end = nodePos[closestNode(goalPos, nodePos, maxNumNodes)];
  PVector start = nodePos[closestNode(startPos, nodePos, maxNumNodes)];
  fill(50,30,250);
  circle(end.x,end.y,10);
  bigbird.run();
}

// Add a new boid into the System
void keyPressed(){
  if (key == 'r'){
    placeRandomObstacles();
    generateRandomNodes(maxNumNodes, circlePos, circleRad);
    connectNeighbors(circlePos, circleRad, numObstacles, nodePos, maxNumNodes);
    path = runUCS(nodePos,maxNumNodes,closestNode(startPos, nodePos, maxNumNodes), closestNode(goalPos, nodePos, maxNumNodes));  
    bigbird.position = nodePos[path.get(0)];  
    bigbird.goal = nodePos[path.get(0)];  
    BigbirdObstacle();
  }
}
void mousePressed() {
  if (mouseButton == LEFT){
    flock.addBoid(new Boid(mouseX,mouseY));
    //int nodeID = closestNode(startPos, nodePos, numNodes);
    //startPos = nodePos[nodeID];
  } else {
    goalPos = new PVector(mouseX, mouseY);
    path = runUCS(nodePos,maxNumNodes,closestNode(startPos, nodePos, maxNumNodes), closestNode(goalPos, nodePos, maxNumNodes));
      
}

  
}
