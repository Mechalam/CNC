import java.awt.event.KeyEvent;
import javax.swing.JOptionPane;
import processing.serial.*;


Serial port = null;
String portname = null;
boolean streaming = false;
float speed = 1;

void openSerialPort()
{
  if (portname == null) return;
  if (port != null) port.stop();
  
  port = new Serial(this, portname, 9600);
  
  port.bufferUntil('\n');
}

void selectSerialPort()
{
  String result = (String) JOptionPane.showInputDialog(frame,
    "Select the port corresponds to your Arduino board",
    "Choose Serial port",
    JOptionPane.QUESTION_MESSAGE,
    null,
    Serial.list(),
    0);
    
  if (result != null) {
    portname = result;
    openSerialPort();
  }
}

 
 // the buttons
Button button_one;  
Button button_two;
Button button_three;
Button button_four;
Button button_five;
Button button_six;
Button button_seven;
Button button_eight;
Button button_nine;
Button button_ten;
Button button_eleven;
Button button_tweleve;
Button button_thirteen;
Button button_fourteen;

int i ;       
String[] gcode;

void setup() {
  size (500,350);
 
  
  // create the button object
  button_one = new Button("+X", 60, 200, 50, 70); // X button
  button_two = new Button("-X", 210, 200, 50, 70); // Y button
  button_three = new Button("+Y", 135, 200, 50, 30); // +Y button
  button_four = new Button("-Y", 135, 240, 50, 30); // -Y button
  button_five = new Button("+Z", 285, 200, 50, 30); // +Z button
  button_six = new Button("-Z", 285, 240, 50, 30); // -Z button
  button_seven = new Button("Serial Port", 60, 140, 100, 50); // Serial Port button
  button_eight = new Button("1mm", 350, 70, 40, 40); // Speed per Click button
  button_nine = new Button("5mm", 400, 70, 40, 40); // Speed per Click button
  button_ten = new Button("10mm", 450, 70, 40, 40); // Speed per Click button
  button_eleven = new Button("Go Home", 380, 130, 100, 40);
  button_tweleve = new Button("Send G-Code", 380, 180, 100, 40);
  button_thirteen = new Button("Stop", 380, 230, 100, 40);
  button_fourteen = new Button("GRBL Setting", 280, 280, 200, 50);
}

void draw() {
  background(0);
  fill(250);
  text("Welcome to the Interface For Controlling CNC", 250, 10);
  text("Created By Alam", 250, 25);
  text("Select Movement per Click", 425, 50);
  text("Current Movement: " + speed + " mm per step", 112, 290); 
  text("Current serial port: " + portname, 73, 310);

 // draw the button in the window
  button_one.Draw();
  button_two.Draw();
  button_three.Draw();
  button_four.Draw();
  button_five.Draw();
  button_six.Draw();
  button_seven.Draw();
  button_eight.Draw();
  button_nine.Draw();
  button_ten.Draw();
  button_eleven.Draw();
  button_tweleve.Draw();
  button_thirteen.Draw();
  button_fourteen.Draw();

}

// mouse button clicked
void mousePressed()
{
  if (button_one.MouseIsOver()) 
  {
   port.write("G91\nG21\nG00 X" + speed + " Y0.000 Z0.000\n"); 
  }
  if (button_two.MouseIsOver()) 
  {
    port.write("G91\nG21\nG00 X-" + speed + " Y0.000 Z0.000\n"); 
  }
  if (button_three.MouseIsOver()) 
  {
    port.write("G91\nG21\nG00 X0.000 Y" + speed + " Z0.000\n");
  }
  if (button_four.MouseIsOver()) 
  {
    port.write("G91\nG21\nG00 X0.000 Y-" + speed + " Z0.000\n");
  }
  if (button_five.MouseIsOver()) 
  {
    port.write("G91\nG21\nG00 X0.000 Y0.000 Z" + speed + "\n");
  }
  if (button_six.MouseIsOver()) 
  {
    port.write("G91\nG21\nG00 X0.000 Y0.000 Z-" + speed + "\n");
  }
  if (button_seven.MouseIsOver()) 
  {
    selectSerialPort();
  }
  if (button_eight.MouseIsOver()) 
  {
    speed = 1;
  }
  if (button_nine.MouseIsOver()) 
  {
    speed = 5;    
  }
  if (button_ten.MouseIsOver()) 
  {
    speed = 10;
  }
  if (button_eleven.MouseIsOver()) 
  {
    port.write("G90\nG21\nG00 X0.000 Y0.000 Z0.000\n");
  }
  if (button_tweleve.MouseIsOver()) 
  {
    gcode = null; i = 0;
    File file = null; 
    println("Loading file...");
    selectInput("Select a file to process:", "fileSelected", file);
  }
  if (button_thirteen.MouseIsOver())  
  {
    streaming = false;
  }
  if (button_fourteen.MouseIsOver()) 
  {
    port.write("$$\n");
  }

}

void fileSelected(File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    println("User selected " + selection.getAbsolutePath());
    gcode = loadStrings(selection.getAbsolutePath());
    if (gcode == null) return;
    streaming = true;
    stream();
  }
}

void stream()
{
  if (!streaming) return;
  
  while (true) {
    if (i == gcode.length) {
      streaming = false;
      return;
    }
    
    if (gcode[i].trim().length() == 0) i++;
    else break;
  }
  
  println(gcode[i]);
  port.write(gcode[i] + '\n');
  i++;
}

void serialEvent(Serial p)
{
  String s = p.readStringUntil('\n');
  println(s.trim());
  
  if (s.trim().startsWith("ok")) stream();
  if (s.trim().startsWith("error")) stream(); 
}





// the Button class
class Button {
  String label; // button label
  float x;      // top left corner x position
  float y;      // top left corner y position
  float w;      // width of button
  float h;      // height of button
  
  // constructor
  Button(String labelB, float xpos, float ypos, float widthB, float heightB) {
    label = labelB;
    x = xpos;
    y = ypos;
    w = widthB;
    h = heightB;
  }
  
  void Draw() {
    fill(220);
    stroke(141);
    rect(x, y, w, h, 10);
    textAlign(CENTER, CENTER);
    fill(0);
    text(label, x + (w / 2), y + (h / 2));
  }
  
  boolean MouseIsOver() {
    if (mouseX > x && mouseX < (x + w) && mouseY > y && mouseY < (y + h)) {
      return true;
    }
    return false;
  }
}
