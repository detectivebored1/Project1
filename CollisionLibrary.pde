

int strokeWidth = 2;
boolean pointInCircle(PVector center, float r, PVector pointPos, int risk){
  float dist = PVector.dist(pointPos, center);
  if (dist < r+risk){ //small safety factor
    return true;
  }
  return false;
}

//Returns true if the point is inside a list of circle
//You must consider a point as colliding if it's distance is <= eps
boolean pointInCircleList(PVector[] centers, float[] radii, int numObstacles, PVector pointPos, int risk){
  for (int i = 0; i < numObstacles-1; i++){
    PVector center =  centers[i];
    float r = radii[i];
    if (pointInCircle(center,r,pointPos, risk)){
      return true;
    }
  }
  return false;
}

class hitInfo{
  public boolean hit = false;
  public float t = 9999999;
}

hitInfo rayCircleIntersect(PVector center, float r, PVector l_start, PVector l_dir, float max_t){
  hitInfo hit = new hitInfo();
  
  //Step 2: Compute W - a displacement vector pointing from the start of the line segment to the center of the circle
    PVector toCircle = PVector.sub(center, l_start);
    
    //Step 3: Solve quadratic equation for intersection point (in terms of l_dir and toCircle)
    float a = 1;  //Length of l_dir (we normalized it)
    float b = -2*PVector.dot(l_dir,toCircle); //-2*dot(l_dir,toCircle)
    float c = toCircle.magSq() - (r+strokeWidth)*(r+strokeWidth); //different of squared distances
    
    float d = b*b - 4*a*c; //discriminant 
    
    if (d >=0 ){ 
      //If d is positive we know the line is colliding, but we need to check if the collision line within the line segment
      //  ... this means t will be between 0 and the length of the line segment
      float t1 = (-b - sqrt(d))/(2*a); //Optimization: we only need the first collision
      float t2 = (-b + sqrt(d))/(2*a); //Optimization: we only need the first collision
      //println(hit.t,t1,t2);
      if (t1 > 0 && t1 < max_t){
        hit.hit = true;
        hit.t = t1;
      }
      else if (t1 < 0 && t2 > 0){
        hit.hit = true;
        hit.t = -1;
      }
      
    }
    
  return hit;
}

hitInfo rayCircleListIntersect(PVector[] centers, float[] radii, int numObstacles, PVector l_start, PVector l_dir, float max_t){
  hitInfo hit = new hitInfo();
  hit.t = max_t;
  for (int i = 0; i < numObstacles-1; i++){
    PVector center = centers[i];
    float r = radii[i];
    
    hitInfo circleHit = rayCircleIntersect(center, r, l_start, l_dir, hit.t);
    if (circleHit.t > 0 && circleHit.t < hit.t){
      hit.hit = true;
      hit.t = circleHit.t;
    }
    else if (circleHit.hit && circleHit.t < 0){
      hit.hit = true;
      hit.t = -1;
    }
  }
  return hit;
}
