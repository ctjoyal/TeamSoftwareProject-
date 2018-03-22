// To Here
import de.bezier.data.sql.*;
  
MySQL mysql;
processing.core.PApplet p;

GameScreen game;
MenuScreen menu;
Leaderboard lb;
int switcher = 0;

boolean up = false, down = false, right = false, left = false, gameOver = false;
String[] hazardTypes = {"sine", "straight", "zigzag"};
String[] hazardShapes = {"circle", "rectangle", "wall"};

void setup() {
  game = new GameScreen();
  lb = new Leaderboard();
  menu = new MenuScreen();
  
  // Grabs this sketch id? for database connection. idk just works
  p = this;
  
  ellipseMode(RADIUS);
  size(800,600);
  background(#0069b1);
 
   
}

void draw() {
  switch (switcher) {
    // Display menu here
    case 0: menu.display(); break;
    
    // While the game is happening, display game screen
    case 1: if (true) game.display(); break;
    
    // Display Leaderboards here
    case 2: lb.display(); break;
  }
}

void mousePressed() {
  if (switcher == 0 && mouseX > 100 && mouseX < 165 && mouseY > 70 && mouseY < 110) {
    switcher = 1;
  }
  if (switcher == 0 && mouseX > 100 && mouseX < 300 && mouseY > 175 && mouseY < 200) {
    switcher = 2;
    lb.connect(p);
  }
  if (switcher == 0 && mouseX > 100 && mouseX < 160 && mouseY > 270 && mouseY < 310) {
    exit();
    lb.disconnect();
  }
  if (switcher == 2 && mouseX > 300 && mouseX < 555 && mouseY > 545 && mouseY < 570) {
    switcher = 0;
  }
  // play: 100 < x < 165, 70 < y < 110
  // leaderboards: 100 < x < 300, 175 < y < 200
  // quit: 100 < x < 160, 270 < y < 310
  println(mouseX, mouseY);
}

void keyPressed() {
      switch (key) {
        case 'w':
          up = true;
          break;
        case 's':
          down = true;
          break;
        case 'a':
          left = true;
          break;
        case 'd':
          right = true;
      }
    }

     void keyReleased() {
      switch (key) {
        case 'w':
          up = false;
          break;
        case 's':
          down = false;
          break;
        case 'a':
          left = false;
          break;
        case 'd':
          right = false;
      }  
    }

/*------------------------------------------ Game Screen Class -----------------------------------------------*/

class GameScreen {
  int score;
  int time;
  float hazardSpeed;
 
  Player p1;
  ArrayList<Hazard> hazards;
 
  boolean paused;
 
  PFont f;
  
  GameScreen() {
    time = millis();
    score = 0;
    hazardSpeed = 4.0;
    
    p1 = new Player(50.0, 350.0, 20.0, 4);
    hazards = new ArrayList<Hazard>();
    
    paused = false;
    
    f = createFont("Arial", 26, true);
    textFont(f, 24);
  }
 
  /*---------------------- Inner Classes For Game Screen ---------------------------*/  
  
  /* ----------------- Game Objects --------------------*/
  
  class GameObject {
    float xpos, ypos, xradius, yradius;
    String shape;
    
    /*******************************************
    * Game Object Constructor
    *******************************************/
    GameObject(float xpos, float ypos, float xradius, float yradius, String shape) {
      this.xpos = xpos;
      this.ypos = ypos;
      this.xradius = xradius;
      this.yradius = yradius;
      this.shape = shape;
    }
    
    /*******************************************
    * Displays Game Objects
    *******************************************/
    void display() {
      switch (shape) {
        case "rectangle":
          rect(xpos, ypos, xradius, yradius);
          break;
        case "circle":
          ellipse(xpos, ypos, xradius, xradius);
          break;
        case "wall":
          rect(xpos, ypos, xradius, yradius);
      }
    }
  }
  
  /* ----------------- Player Object --------------------*/
  
  class Player extends GameObject {
    float s;
    color c = #cccccc;
    
    /*******************************************
    * Player Consctructor
    * x-positiom y-position, radius, speed
    *******************************************/
    Player(float x, float y, float r, float s) {
      super(x, y, r, r, "rectangle");
      this.s = s;
    }

   /*******************************************
   * Display Player
   *******************************************/
    void move() {
      if (!gameOver) {
        if(up)
          ypos = constrain(ypos - s, 0 + yradius, height - yradius);
        if(down)
          ypos = constrain(ypos + s, 0 + yradius, height - yradius);
        if(right)
          xpos = constrain(xpos + s, 0 + xradius, width - xradius);
        if(left)
          xpos = constrain(xpos - s, 0 + xradius, width - xradius);
      }
    }
 
    /*******************************************
    * Display Player
    * Calls: Player.move
    *******************************************/
    void display() {
      move();
      fill(c);
      super.display();
    }
  }

  /* ----------------- Hazard Objects --------------------*/
  
  class Hazard extends GameObject {
    String path;
    color c = #2e2e2e;
 
    /*******************************************
    * Hazard Constructor
    * x-position, y-position, x-radius, y-radius,
    *  path, shape
    *******************************************/
    Hazard(float x, float y, float xr, float yr, String path, String shape) {
      super(x, y, xr, yr, shape);
      this.path = path;
    }
    
    /*******************************************
    * Displays Hazard
    *******************************************/
    void display(float hazardSpeed) {
      fill(c);
      
      switch (path) {
        case "sine":
          xpos -= hazardSpeed;
          ypos += sin((xpos / 30)) * hazardSpeed * 1.5;
          break;
        case "straight":
          xpos -= hazardSpeed;
          break;
        case "zigzag":
          xpos -= hazardSpeed;
          if (xpos % 400 < 200)
            ypos += 4;
          else
            ypos -= 4;
      }
      super.display();
    }
    
    void hazardMovement(float hazardSpeed) {
       
    }
    
  }
  
  /*-------------------------- Hazard Creation --------------------------------*/ 
 
 
  /*****************************************************************
  * Checks the time since last object has been generated.
  * If delta(time) >= 1/2 second, create new hazard off screen
  * and increase the hazard speed, then reset time to current time.
  *
  * @returns true if new hazard is created
  ******************************************************************/
  boolean timeCheck() {
    int newTime = millis();
  
    if (newTime - time >= 500) {
      hazardSpeed += .1;
     // hazards.add(new Hazard(850.0, random(25, 775), 30.0, 30.0, 
      //              hazardTypes[(int)random(0,3)], hazardShapes[(int)random(0,3)]));
      hazards.add(new Hazard(850.0, random(25, 775), 30.0, 30.0, 
                    hazardTypes[(int)random(0,3)], hazardShapes[2]));
      time = newTime;
      return true;
    }
    return false;
  }
  
  /******************************************************
  * Displays players and hazards during the game screen
  *
  * Calls GameScreen.displayHazards, Player.display, GameScreen.timeCheck
  *******************************************************/
  void display() {
    while (paused) {
      if (mousePressed)
        paused = false;
    }
    background(#a5a5a5);
    
    text(score, 10, 25);
    
    timeCheck();

    displayHazards();
    p1.display();
  }
  
  /*******************************************
  * Displays all hazards currently Generated
  * Calls Hazard.display, GameScreen.circleIntersects
  * Uses ArrayList hazards 
  *******************************************/
  void displayHazards() {
    Hazard h;
    for (int i = 0; i < hazards.size(); i++) {
      h = hazards.get(i);
      if ( h.xpos < 0 - h.xradius) {
        hazards.remove(i);
        score += 100 * (int)hazardSpeed / 4;
      } else {
        h.display(hazardSpeed);
        intersectCheck(p1, h);
        //print(h.shape + "\n");
      }
    }
  }
  
  /* ------------------------- Collision Detection ----------------------- */
  
  boolean intersectCheck(Player p, Hazard h) {
    boolean intersect;

    switch (h.shape) {
      case "rectangle":
        intersect = twoRectangleCollision(p, h);
        break;
      case "circle":
        intersect = rectCircCollision(p, h);     
        break;
      case "wall":
        intersect = twoRectangleCollision(p, h);
      default:
        intersect = false;
    };
    
   if (intersect) {
     gameOver = true;
     paused = true;
     //pop.display();
   }
    
   return intersect; 
  }
  
  /************************************************
  * Checks to see if a circular hazard and
  * the player object are intersecting
  *
  * Returns true if they are and pauses the game
  *************************************************/
  boolean circleIntersects(Player p, Hazard h) {
    float difX = h.xpos - p.xpos;
    float difY = h.ypos - p.ypos;
    
    float dist = sqrt(sq(difX) + sq(difY));
    
    if (dist < h.xradius + p.xradius) {
       p.c = #ff0000;
       hazardSpeed = 0;
       paused = true;
       gameOver = true;
       return true;
    }
    else return false;
  }
  
  boolean twoRectangleCollision(GameObject player, GameObject hazard) {
    float px, py, pxrad, pyrad, hx, hy, hxrad, hyrad;
    px = player.xpos; py = player.ypos; pxrad = player.xradius; pyrad = player.yradius;
    hx = hazard.xpos; hy = hazard.ypos; hxrad = hazard.xradius; hyrad = hazard.yradius;
    
    
    if ( hx > px + pxrad || hx + hxrad < px || hy + hyrad < py || hy > py + pyrad) {
      return false;
    }
    else {
      return true;
    }
  }
  
  boolean rectCircCollision(GameObject r, GameObject c) {
    float detectPointx, detectPointy;
    float cx, cy, cr, rx, ry; 
    
    cx = c.xpos; cy = c.ypos; cr = c.xradius;
    rx = r.xpos; ry = r.ypos;
    
    if(cx < rx)
      detectPointx = rx;
    else if ( cx > rx + r.xradius)
      detectPointx = rx + r.xradius;
    else
      detectPointx = cx;
    
    if(cy < ry)
      detectPointy = ry;
    else if ( cy > ry + r.yradius)
      detectPointy = ry + r.yradius;
    else
      detectPointy = cy;

   if (sqrt(sq(detectPointx - cx) + sq(detectPointy - cy)) < c.xradius)
     return true;
   else 
     return false;
  }
  
}

  
/*----------------------------------------- Menu Screen -------------------------------------------*/

class MenuScreen {
  String play = "play";
  String lb = "leaderboards"; // Strings to be displayed in menu
  String quit = "quit";

  
  void display() {
    background(#0069b1);
    textSize(32);
    text(play, 100, 100);
    text(lb, 100, 200);
    text(quit, 100, 300);
  }
}

/*------------------------------------- Leaderboards Screen ---------------------------------------*/

class Leaderboard {
  String inits;
  int pts;
  
  /********************************************************
  * Class for connecting to an SQL database
  * 
  *********************************************************/
  void connect(processing.core.PApplet papplet) {
   
    String user = "cs3425gr";
    String pass = "cs3425gr";
    String db = "aplyons";
    mysql = new MySQL(papplet, "classdb.it.mtu.edu", db, user, pass);
 
    if (!mysql.connect()) {
      println("Connection failed, leaderboards unavailable");
    }
  }
  
  void disconnect() {
    mysql.close();
  }
  
  void display() {
    // Variable declaration
    int entry = 1;
    int yOffset = 0;
    int xOffset = 0;
    
    // Initialize screen and display text
    background(#0069b1);
    textSize(30);
    text("HIGH SCORES", 300, 30);
    text("Back to main menu", 300, 570);
    
    // Grab entries from db and display
    mysql.query("select * from Leaderboard order by points desc");
    for (int j = 0; j < 2; j++) {
      for (int i = 0; i < 10; i++) {
        if (mysql.next()) {
          
          String str = (entry + ": " + mysql.getString(1) + " " + mysql.getInt(2));
          text(str, 100 + xOffset, 100 + yOffset);
        }
        else {
          String str = entry + ": ";
          text(str, 100 + xOffset, 100 + yOffset);
        }
        entry++;
        yOffset += 30;
      }
      yOffset = 0;
      xOffset = 400;
    }
  }
}