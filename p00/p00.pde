int NUM_ORBS = 10;
int MIN_SIZE = 10;
int MAX_SIZE = 60;
float MIN_MASS = 10;
float MAX_MASS = 100;
float G_CONSTANT = 1;
float D_COEF = 0.1;
float K_CONSTANT = 8.99e9;  // Coulomb's constant

int SPRING_LENGTH = 50;
float SPRING_K = 0.005;

int MOVING = 0;
int BOUNCE = 1;
int GRAVITY = 2;
int DRAGF = 3;
int MAGNETIC = 4;
int ELECTRIC = 5;
int TADPOLE = 6;  // New toggle for tadpole force
boolean[] toggles = new boolean[7];  // Updated array size to include tadpole toggle
String[] modes = {"Moving", "Bounce", "Gravity", "Drag", "Magnetic", "Electric", "Tadpole"};  // Updated modes array

FixedOrb earth;
OrbNode o0, o1, o2, o3;

// Magnetic field variables
PVector magneticField = new PVector(0, 0);
float magneticStrength = 0.1;  // Reduced magnetic strength

void setup() {
  size(600, 600);

  earth = new FixedOrb(width/2, height * 200, 1, 20000);
  makeOrbs();
}

void draw() {
  background(255);
  displayMode();

  o0.display();
  o1.display();
  o2.display();
  o3.display();

  PVector sf = o0.getSpring(o0.next, SPRING_LENGTH, SPRING_K);
  o0.applyForce(sf);
  sf = o1.getSpring(o1.previous, SPRING_LENGTH, SPRING_K);
  o1.applyForce(sf);
  sf = o2.getSpring(o2.next, SPRING_LENGTH, SPRING_K);
  o2.applyForce(sf);
  sf = o3.getSpring(o3.previous, SPRING_LENGTH, SPRING_K);
  o3.applyForce(sf);

  o0.bounce(toggles[BOUNCE]);
  o1.bounce(toggles[BOUNCE]);
  o2.bounce(toggles[BOUNCE]);
  o3.bounce(toggles[BOUNCE]);
  
  o0.move(toggles[MOVING]);
  o1.move(toggles[MOVING]);
  o2.move(toggles[MOVING]);
  o3.move(toggles[MOVING]);

  // Apply magnetic force to orbs if the magnetic toggle is enabled
  if (toggles[MAGNETIC]) {
    o0.applyMagneticForce(magneticField, magneticStrength);
    o1.applyMagneticForce(magneticField, magneticStrength);
    o2.applyMagneticForce(magneticField, magneticStrength);
    o3.applyMagneticForce(magneticField, magneticStrength);
  }

  // Apply electric force between orbs if the electric toggle is enabled
  if (toggles[ELECTRIC]) {
    applyElectricForces();
  }

  // Apply tadpole force to orbs if the tadpole toggle is enabled
  if (toggles[TADPOLE]) {
    o0.applyTadpoleForce();
    o1.applyTadpoleForce();
    o2.applyTadpoleForce();
    o3.applyTadpoleForce();
  }
}

void makeOrbs() {
  o0 = new OrbNode();
  o1 = new OrbNode();
  o2 = new OrbNode();
  o3 = new OrbNode();

  o0.next = o1;
  o1.previous = o0;
  o1.next = o2;
  o2.previous = o1;
  o2.next = o3;
  o3.previous = o2;
  o3.next = o0;
}

void keyPressed() {
  if (key == ' ') { toggles[MOVING] = !toggles[MOVING]; }
  if (key == 'g') { toggles[GRAVITY] = !toggles[GRAVITY]; }
  if (key == 'b') { toggles[BOUNCE] = !toggles[BOUNCE]; }
  if (key == 'd') { toggles[DRAGF] = !toggles[DRAGF]; }
  if (key == 'm') { toggles[MAGNETIC] = !toggles[MAGNETIC]; }  // New key for magnetic toggle
  if (key == 'e') { toggles[ELECTRIC] = !toggles[ELECTRIC]; }  // New key for electric toggle
  if (key == 't') { toggles[TADPOLE] = !toggles[TADPOLE]; }  // New key for tadpole toggle
  if (key == 'r') {
    makeOrbs();
  }
  if (keyCode == UP) {
    magneticField.y -= 10;
  }
  if (keyCode == DOWN) {
    magneticField.y += 10;
  }
  if (keyCode == LEFT) {
    magneticField.x -= 10;
  }
  if (keyCode == RIGHT) {
    magneticField.x += 10;
  }
}

void displayMode() {
  textAlign(LEFT, TOP);
  textSize(20);
  noStroke();
  int x = 0;

  for (int m=0; m<toggles.length; m++) {
    //set box color
    if (toggles[m]) { fill(0, 255, 0); }
    else { fill(255, 0, 0); }

    float w = textWidth(modes[m]);
    rect(x, 0, w+5, 20);
    fill(0);
    text(modes[m], x+2, 2);
    x+= w+5;
  }
}

// Function to apply electric forces between orbs
void applyElectricForces() {
  Orb[] orbs = {o0, o1, o2, o3};
  for (int i = 0; i < orbs.length; i++) {
    for (int j = i + 1; j < orbs.length; j++) {
      PVector electricForce = orbs[i].getElectricForce(orbs[j], K_CONSTANT);
      orbs[i].applyForce(electricForce);
      electricForce.mult(-1);  // Newton's third law
      orbs[j].applyForce(electricForce);
    }
  }
}
