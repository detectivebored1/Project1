
ArrayList<Integer>[] neighbors = new ArrayList[maxNumNodes];  //A list of neighbors can can be reached from a given node
ArrayList<Integer>[] pathcosts = new ArrayList[maxNumNodes];  //A list of pathcosts to neighbours from a given node

//We also want some help arrays to keep track of some information about nodes we've visited
Boolean[] visited = new Boolean[maxNumNodes]; //A list which store if a given node has been visited
int[] parent = new int[maxNumNodes]; //A list which stores the best previous node on the optimal path to reach this node

//Set which nodes are connected to which neighbors (graph edges) based on PRM rules
void connectNeighbors(PVector[] centers, float[] radii, int numObstacles, PVector[] nodePos, int numNodes){
  for (int i = 0; i < numNodes; i++){
    neighbors[i] = new ArrayList<Integer>();  //Clear neighbors list
    pathcosts[i] = new ArrayList<Integer>(); //Clear pathcost list
    for (int j = 0; j < numNodes; j++){
      if (i == j) continue; //don't connect to myself 
      PVector dir = PVector.sub(nodePos[j],nodePos[i]).normalize();
      float distBetween = PVector.dist(nodePos[i],nodePos[j]);
      hitInfo circleListCheck = rayCircleListIntersect(centers, radii, numObstacles, nodePos[i], dir, distBetween);
      if (!circleListCheck.hit){
        neighbors[i].add(j);
        pathcosts[i].add(int(distBetween));
      }
    }
  }
}

//This is probably a bad idea and you shouldn't use it...
int closestNode(PVector point, PVector[] nodePos, int numNodes){
  int closestID = -1;
  float minDist = 999999;
  for (int i = 1; i < numNodes; i++){
    float dist = PVector.dist(point, nodePos[i]) ;
    if (dist < minDist){
      closestID = i;
      minDist = dist;
    }
  }
  return closestID;
}

ArrayList<Integer> planPath(PVector startPos, PVector goalPos, PVector[] centers, float[] radii, int numObstacles, PVector[] nodePos, int numNodes){
  ArrayList<Integer> path = new ArrayList();
  
  int startID = closestNode(startPos, nodePos, numNodes);
  int goalID = closestNode(goalPos, nodePos, numNodes);
  
  path = runUCS(nodePos, numNodes, startID, goalID);
  
  return path;
}

public static int indexmin(ArrayList<Integer> array){
    int index = 0;
    int min = array.get(index);

    for (int i = 1; i < array.size(); i++){
        if (array.get(i) <= min){
        min = array.get(i);
        index = i;
        }
    }
        return index;
}
//UCS (Uniform Cost Search)
ArrayList<Integer> runUCS(PVector[] nodePos, int numNodes, int startID, int goalID){
  ArrayList<Integer> fringe = new ArrayList();    //New empty fringe
  ArrayList<Integer> fringecosts = new ArrayList();    //New empty fringe
  ArrayList<Integer> path = new ArrayList();
  for (int i = 0; i < numNodes; i++) { //Clear visit tags and parent pointers
    visited[i] = false;
    parent[i] = -1; //No parent yet
  }
  visited[startID] = true;
  fringe.add(startID);
  fringecosts.add(0);
  while (fringe.size() > 0){
    int minPosition = indexmin(fringecosts);
    int currentNode = fringe.get(minPosition);
    int cost = fringecosts.get(minPosition);
    fringe.remove(minPosition);
    fringecosts.remove(minPosition);
    if (currentNode == goalID){
      //println("Goal found!");
      break;
    }
    for (int i = 0; i < neighbors[currentNode].size(); i++){
      int neighborNode = neighbors[currentNode].get(i);
      int nodeCost = cost + pathcosts[currentNode].get(i);
      if(!visited[neighborNode]){
        visited[neighborNode] = true;
        parent[neighborNode] = currentNode;
        fringe.add(neighborNode);
        fringecosts.add(nodeCost);
      }
    }
  }
  
  if (fringe.size() == 0){
    //println("No Path");
    path.add(0,-1);
    return path;
  }
  //print("\nReverse path: ");
  int prevNode = parent[goalID];
  path.add(0,goalID);
  print(goalID, " ");
  while (prevNode >= 0){
    print(prevNode," ");
    path.add(0,prevNode);
    prevNode = parent[prevNode];
  }
  print("\n");
  
  return path;
}
