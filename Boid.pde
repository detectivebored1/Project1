// The Boid class

class BigBird{
  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce; 
  float maxspeed;
  PVector goal;
  BigBird(PVector start){
    acceleration = new PVector(0, 0);
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));
    goal = start;
    r = 5;
    position = start;
    maxspeed = 2;
    maxforce = 0.03;
  }
  void run() {
    reachedgoal();
    seek(goal);
    
    //update();
    borders();
    render();
  }
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }
  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }
  void reachedgoal(){
    int endpos = path.size();
    int next = 0;
    
    //print("1: " + goal);
    //print("\n");
    //print("2: " + position);
    //print("3: " + nodePos[path.get(endpos-1)]);
    if(position == goal){
      //print("here");
      if(goal != nodePos[path.get(endpos-1)]){
        for(int i = 0; i < endpos; i ++){
          if(goal == nodePos[path.get(i)]){
            next = i+1;
          }
        }  
        goal = nodePos[path.get(next)];
        BigbirdObstacle();     
      }
    }
  }
  void update() {
    reachedgoal();
    // Update velocity
    //velocity.add(acceleration);
    //// Limit speed
    //velocity.limit(maxspeed);
    //position.add(velocity);

    //// Reset accelertion to 0 each cycle
    //acceleration.mult(0);
  }
  void seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    float distance = PVector.dist(target, position);
    // Scale to maximum speed
    if(desired.mag() > 0){
        desired.normalize();
    }
    velocity = PVector.mult(desired, maxspeed);
    if(distance < 2){
      position = target;
    }
    position.add(velocity);
  }
  
  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    
    fill(200, 100);
    stroke(255);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }
}

class Boid {

  PVector position;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  Boid(float x, float y) {
    acceleration = new PVector(0, 0);

    // This is a new PVector method not yet implemented in JS
    // velocity = PVector.random2D();

    // Leaving the code temporarily this way so that this example runs in JS
    float angle = random(TWO_PI);
    velocity = new PVector(cos(angle), sin(angle));

    position = new PVector(x, y);
    r = 2.0;
    maxspeed = 2;
    maxforce = 0.03;
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    update();
    borders();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    collisions(boids);
    // Arbitrarily weight these forces
    sep.mult(1.5);
    ali.mult(1.0);
    coh.mult(1.0);
    // Add the force vectors to acceleration
    applyForce(sep);
    applyForce(ali);
    applyForce(coh);
  }

  // Method to update position
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    position.add(velocity);

    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }
  void collisions(ArrayList<Boid> boids){
    for(Boid bird : boids){
      if(bird.position.dist(bigbird.position) < bigbird.r + 3){
         PVector normal = PVector.sub(bird.position, bigbird.position).normalize();
         bird.position = PVector.add(bigbird.position,PVector.mult(normal, bigbird.r + 3));
         PVector velNormal = PVector.mult(bird.velocity, PVector.dot(bird.velocity, normal));
         bird.velocity.limit(maxspeed/2);
      }else{
        bird.velocity.limit(maxspeed);
      }
      for(int j = 0; j < numObstacles; j++){
        if(bird.position.dist(circlePos[j]) < circleRad[j] + r){
          PVector normal = PVector.sub(bird.position, circlePos[j]).normalize();
          bird.position = PVector.add(circlePos[j],PVector.mult(normal, circleRad[j] + r));
          PVector velNormal = PVector.mult(bird.velocity, PVector.dot(bird.velocity, normal));
          //bird.velocity.sub(velNormal);
          bird.velocity.limit(maxspeed/2);
          //bird.velocity.add(PVector.mult(velNormal,1.07));
        } else {
          bird.velocity.limit(maxspeed);
          
        }
      }
    }
  }
  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, position);  // A vector pointing from the position to the target
    // Scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);

    // Above two lines of code below could be condensed with new PVector setMag() method
    // Not using this method until Processing.js catches up
    // desired.setMag(maxspeed);

    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading() + radians(90);
    // heading2D() above is now heading() but leaving old syntax until Processing.js catches up
    
    fill(200, 100);
    stroke(255);
    pushMatrix();
    translate(position.x, position.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r*2, r*2);
    vertex(r*2, r*2);
    endShape();
    popMatrix();
  }

  // Wraparound
  void borders() {
    if (position.x < -r) position.x = width+r;
    if (position.y < -r) position.y = height+r;
    if (position.x > width+r) position.x = -r;
    if (position.y > height+r) position.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(position, other.position);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    for(Boid b : boids){
      for(int i = 0; i < numObstacles; i++){
        float dist = PVector.dist( b.position, circlePos[i]);
        if(dist < circleRad[i]){
           //maxspeed = 1;
           //PVector normal = PVector.sub(b.position, circlePos[i]);
           //normal.normalize();
           //b.position = circlePos[i].add(normal.mult(circleRad[i]).mult(1.01));
           //normal.normalize();
          // normal.div(dist);        // Weight by distance
           //steer.add(normal);
        }
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // steer.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      // First two lines of code below could be condensed with new PVector setMag() method
      // Not using this method until Processing.js catches up
      // sum.setMag(maxspeed);

      // Implement Reynolds: Steering = Desired - Velocity
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  // For the average position (i.e. center) of all nearby boids, calculate steering vector towards that position
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);   // Start with empty vector to accumulate all positions
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(position, other.position);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.position); // Add position
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the position
    } 
    else {
      return new PVector(0, 0);
    }
  }
}
