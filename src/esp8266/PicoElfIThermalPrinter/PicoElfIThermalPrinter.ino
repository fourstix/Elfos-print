/*****************************************************
 * Pico/Elf I2C Expansion for Adafruit Thermal Printer
 * 
 *****************************************************/
#include <Wire.h> 
#include "MCP23017.h" 
#include "SoftwareSerial.h"
#include "Adafruit_Thermal.h"


//Change debug token from 0 to 1 to include debug code in compile
#define DEBUG 0

//Define Status bytes
#define P_READY 0x00
#define P_OFF   0x21

//Ascii character used for printer graphics mode
#define ASCII_DC2 18 

//Define pins used for printer
#define TX_PIN D7 // NodeMCU transmit  YELLOW WIRE  labeled RX on printer
#define RX_PIN D6 // NodeMCU receive   GREEN WIRE   labeled TX on printer

// Set up thermal printer
SoftwareSerial mySerial(RX_PIN, TX_PIN); // Declare SoftwareSerial obj first
Adafruit_Thermal printer(&mySerial);     // Pass addr to printer constructor

//Address for Address MCP23017 GPIO Expander
#define MCP_ADDR 0x20

//Define MCP23017 
MCP23017 mcp = MCP23017(MCP_ADDR);

//Define Pins used for I/O control
#define BUSY_PIN     D4
#define READY_PIN    D5

//Interrupt variable to signal data is available
volatile boolean dataAvailable = false;

// Timer values for loop
unsigned long previousMillis = 0;        // will store last t
unsigned long currentMillis = millis();  // current time
// interval to send count out to 1802
const long countDelay = 1000;

//data read from the 1802 data in lines on MCP23017 Port B
byte  data_out = 0x00;  

//Printer Mode flags
boolean isEscape = false;
boolean isPrtCmd = false;
boolean isBold = false;
boolean isInverse = false;
boolean isFontB = false;
boolean isUnderline = false;
boolean isGraphic = false;
boolean isOffline = false;

// byte count for graphics mode
int     g_count   = 0;
int     g_size    = 512; //image size in bytes

//#if DEBUG
//static const uint8_t PROGMEM spaceship_data[] = {
//    // program code (upper 25% of the screen contains display code)
//  0x90, 0xB1, 0xB2, 0xB3, 0xB4, 0xF8, 0x2D, 0xA3,
//  0xF8, 0x3F, 0xA2, 0xF8, 0x11, 0xA1, 0xD3, 0x72,
//  //0x0010
//  //Patch to keep interrupt cycles and byte count same
//  0x70, 0x22, 0x78, 0x22, 0x52, 0xC4, 0xE2, 0xE2,
//  //Patch to set R0 to page image location
//  0xE2, 0x91, 0xB0, 0xF8, 0x00, 0xA0, 0x80, 0xE2,
//  //0x0020
//  0xE2, 0x20, 0xA0, 0xE2, 0x20, 0xA0, 0xE2, 0x20,
//  0xA0, 0x3C, 0x1E, 0x30, 0x0F, 0xE2, 0x69, 0x3F,
//  //0x0030
//  //Patch - Toggle Q instead of over-writing memory (ROM)
//  0x2F, 0x37, 0x31, 0xCD, 0x7B, 0x38, 0x7A, 0x30,
//  0x2F, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
//  //0x0040
//  // bitmap  (the bottom 75% of the screen is the bitmap)
//  0x00,   0x00,   0x00,   0x00,   0x00,   0x00,   0x00,   0x00, 
//  0x00,   0x00,   0x00,   0x00,   0x00,   0x00,   0x00,   0x00, 
//  0x7B,   0xDE,   0xDB,   0xDE,   0x00,   0x00,   0x00,   0x00, 
//  0x4A,   0x50,   0xDA,   0x52,   0x00,   0x00,   0x00,   0x00, 
//  0x42,   0x5E,   0xAB,   0xD0,   0x00,   0x00,   0x00,   0x00, 
//  0x4A,   0x42,   0x8A,   0x52,   0x00,   0x00,   0x00,   0x00, 
//  0x7B,   0xDE,   0x8A,   0x5E,   0x00,   0x00,   0x00,   0x00, 
//  0x00,   0x00,   0x00,   0x00,   0x00,   0x00,   0x00,   0x00, 
//  0x00,   0x00,   0x00,   0x00,   0x00,   0x00,   0x07,   0xE0, 
//  0x00,   0x00,   0x00,   0x00,   0xFF,   0xFF,   0xFF,   0xFF, 
//  0x00,   0x06,   0x00,   0x01,   0x00,   0x00,   0x00,   0x01, 
//  0x00,   0x7F,   0xE0,   0x01,   0x00,   0x00,   0x00,   0x02, 
//  0x7F,   0xC0,   0x3F,   0xE0,   0xFC,   0xFF,   0xFF,   0xFE, 
//  0x40,   0x0F,   0x00,   0x10,   0x04,   0x80,   0x00,   0x00, 
//  0x7F,   0xC0,   0x3F,   0xE0,   0x04,   0x80,   0x00,   0x00, 
//  0x00,   0x3F,   0xD0,   0x40,   0x04,   0x80,   0x00,   0x00, 
//  0x00,   0x0F,   0x08,   0x20,   0x04,   0x80,   0x7A,   0x1E, 
//  0x00,   0x00,   0x07,   0x90,   0x04,   0x80,   0x42,   0x10, 
//  0x00,   0x00,   0x18,   0x7F,   0xFC,   0xF0,   0x72,   0x1C, 
//  0x00,   0x00,   0x30,   0x00,   0x00,   0x10,   0x42,   0x10, 
//  0x00,   0x00,   0x73,   0xFC,   0x00,   0x10,   0x7B,   0xD0, 
//  0x00,   0x00,   0x30,   0x00,   0x3F,   0xF0,   0x00,   0x00, 
//  0x00,   0x00,   0x18,   0x0F,   0xC0,   0x00,   0x00,   0x00, 
//  0x00,   0x00,   0x07,   0xF0,   0x00,   0x00,   0x00,   0x00 
//};
//#endif

//lookup table to expand graphics data into two row bytes
static const uint8_t expand_2[16] = {
//   0     1     2     3     4     5     6     7
  0x00, 0x03, 0x0C, 0x0F, 0x30, 0x33, 0x3C, 0x3F,
//   8     9     A     B     C     D     E     F
  0xC0, 0xC3, 0xCC, 0xCF, 0xF0, 0xF3, 0xFC, 0xFF
};

// Temporary Data for expanding width of line of graphic data
// A 64x64 image is expanded into 1 line of 16 bytes,
// but a 32x64 image is expnded into 2 lines of 16 bytes.
byte t_line[32];


// Data for expanded chunk of an image
// A 64x64 image expands into 2 lines of 32 bytes each,
// but a 32x64 image expands into 4 lines of 32 bytes. 
byte g_chunk[128];


//Set up routine for MCP23017
void setupMcpCommunication() {
  //Set up MCP23017 for data lines
  mcp.init();
  mcp.portMode(MCP23017Port::A, 0);         //Port A as ouput
  mcp.portMode(MCP23017Port::B, 0b11111111);//Port B as input

  //Initialize GPIO ports
  mcp.writeRegister(MCP23017Register::GPIO_A, 0x00);
  mcp.writeRegister(MCP23017Register::GPIO_B, 0x00);    
} //setupMcpCommunication

//ISR for READY_PIN pin
//ESP2866 ISR's must have be cached in RAM!
ICACHE_RAM_ATTR void readPortData() {
  dataAvailable = true;
  //Set Busy flag to true
  digitalWrite(BUSY_PIN, true);

  //#if DEBUG
  //Serial.println("!!!!!!");
  //#endif
}

/*****************************
 *   Function    NodeMCU    
 *                 Pin  
 *   SCL (I2C)      D1  
 *   SDA (I2C)      D2 
 *   
 *   Note: D3 is used for Flash and should be avoided
 *   
 *   READY (Input)  D5      
 *   FLAG (Output)  D4
 */
 
void setup() {    
  //Initialize serial for debugging
  #if DEBUG
  Serial.begin(9600);
  #endif
  
  // Initialize SoftwareSerial for printing
  mySerial.begin(19200);  
  
  //Set up MCP23017
  Wire.begin();
  setupMcpCommunication();

  // Set up busy pins
  pinMode(BUSY_PIN, OUTPUT);
  digitalWrite(BUSY_PIN, false);

  // Set up data ready interrupt
  pinMode(READY_PIN, INPUT);
  attachInterrupt(digitalPinToInterrupt(READY_PIN), readPortData, FALLING); 

  
  //Initialize Printer
  printer.begin();      // Init printer (same regardless of serial type)
  printer.wake();       // MUST wake() before printing again, even if reset
  printer.setDefault(); // Restore printer to defaults
  
  // let the dust settle a bit
  delay(500);
  
  // reset all flags for normal printing
  normalPrint();
  //Show that we are ready
  #if DEBUG
  Serial.println("Ready");
  #endif
  printer.feed(2); 
} // Setup

#if DEBUG
// Pretty print two hex digits for display
void print2Hex(uint8_t v) {  
  //If single Hex digit
  if (v < 0x10) {
   Serial.print(F("0"));
  } // if v < 0x10
  Serial.print(v, HEX);
}
#endif

void loop() {
  unsigned long currentMillis = millis();

  //Check if data was sent by the 1802
  if (dataAvailable) {
    char c_data = mcp.readPort(MCP23017Port::B);
  
    if (isGraphic) {
      byte idx = g_count % 8;
      byte g_value = c_data;
      
      if (g_size == 256) {
        // process 32x64 image (256 bytes)
        fill32x64DataChunk(g_value, idx);
        g_count++;
        // Every 8 bytes print a line as expanded graphics data
        if ((g_count % 8) == 0) {
          print32x64DataChunk();
        } // if g_count
      } else {
        // process 64x64 image (512 bytes)
        fill64x64DataChunk(g_value, idx);
        g_count++;
        // Every 8 bytes print a line as expanded graphics data
        if ((g_count % 8) == 0) {
          print64x64DataChunk();
        } // if g_count
      } //if-else g_size == 256
      
      //After entire image is printed reset to normal printing
      if (g_count >= g_size) {
       normalPrint();
      } // g_count
    } else if (isPrtCmd) {
      handlePrtCmd(c_data);
    } else if (isEscape) {
      handleEscape(c_data);
    } else {
      handleChar(c_data);
    } // if-else

//    #if DEBUG
//    print2Hex(data_out);
//    Serial.println();
//    #endif

    //Clear interrupt variable
    dataAvailable = false;    
    //Set busy flag to false when done
    digitalWrite(BUSY_PIN, false);
  //if not printing, update the the printer status every second  
  } else if (currentMillis - previousMillis >= countDelay) {
    // save the last time you sent count to 1802
    previousMillis = currentMillis;
    //Update the printer status
    updatePrtStatus();
  } //if - else if time difference >= delay
} // loop

// Process a printable character
void handleChar(char c_prt) { 
  if (c_prt == 0x1B) {
     isPrtCmd = true;
  } else if (c_prt == '\\') {
      isEscape = true;
  } else {
    printer.print(c_prt);
    if (c_prt == 0x0B || c_prt == 0x0C) {
      //Eject paper for tear off after formfeed or vertical tab
      printer.feed(4);
    } // if c_ptr was FF or VT
  } // if-else
} //handleChar

// Process an Character Escape sequence
void handleEscape(char c_esc) {
  switch(c_esc) {
    //backslash
    case '\\':
      handleChar('\\');
      break;

    //escape
    case 'e':
    case 'E':
      handleChar(0x1B);
      break;
        
    //formfeed
    case 'f':
    case 'F':
      handleChar(0x0C);
      break;
                 
    //newline
    case 'n':
    case 'N':
      handleChar(0x0A);
      break;

    //carrriage return
    case 'r':
    case 'R':
      handleChar(0x0D);
      break;
      
    //tab
    case 't':
    case 'T':
      handleChar(0x09);
      break;

    //vertical tab
    case 'v':
    case 'V':
      handleChar(0x0B);
      break;
           
    //print out unknown string as literal
    default:
      printer.print('\\');
      handleChar(c_esc);
      break;
  } // switch
  isEscape = false;
} // handleChrEscape

//Handle escape sequences for printer command
void handlePrtCmd(char c_cmd) {
  switch(c_cmd) {
    //toggle bold on and off
    case 'e':
    case 'E': 
      if (isBold) {
        printer.boldOff();
        isBold = false;
      } else {
        printer.boldOn();
        isBold = true;
      } // if-else isBold
      break;
      
    //toggle inverse
    case 'i':
    case 'I':
      if (isInverse) {
        printer.inverseOff();
        isInverse = false;
      } else {
        printer.inverseOn();
        isInverse = true;
      } // if-else isInverse
      break;
      
    // switch font
    case 's':
    case 'S':
      if (isFontB) {
        printer.setFont('A');
        isFontB = false;
      } else {
        printer.setFont('B');
        isFontB = true;
      } // if-else isStrike
      break;

    // toggle underline
    case 'u':
    case 'U':
      if (isUnderline) {
        printer.underlineOff();
        isUnderline = false;
      } else {
        printer.underlineOn();
        isUnderline = true;            
      } // if-else isUnderline
      break;

    // center text
    case 'c':
    case 'C':  
      printer.justify('C');
      break;
        
    // left justify
    case 'l':
    case 'L':
      printer.justify('L');
      break;
   
    // right justify
    case 'r':
    case 'R':
      printer.justify('R');
      break;
        
    // single space        
    case '1':
      printer.setLineHeight(30);
      break;
        
    // double space
    case '2':
      printer.setLineHeight(60);
      break;
        
    // normal size (small) text
    case 'n':
    case 'N':    
      printer.setSize('S');
        break;

    // tall (medium) text
    case 't':
    case 'T':
      printer.setSize('M');
      break;

    // wide (large) text
    case 'w':
    case 'W':
      printer.setSize('L');
      break; 
             
    //wake up and reset printer  
    case '@':
      printer.wake();
      if (isOffline) {
        printer.online();
        isOffline = false;
      } // isOffline
      normalPrint();
      //Update status immediately after waking
      updatePrtStatus();
      break;
      
    //set text to normal defaults
    case '!':
      normalPrint();
      break;
      
    //start graphics mode for 64x64 bit image (512 bytes)  
    case '*':
      printer.wake();
      normalPrint();
      isGraphic = true;
      g_size = 512;
      break;

    //start graphics mode for 32x64 bit image (256 bytes)  
    case '#':
      printer.wake();
      normalPrint();
      isGraphic = true;
      g_size = 256;
      break;

//  #if DEBUG          
//    // print test graphic
//    case '%':
//      printer.wake();
//      normalPrint();
//      //isGraphic = true;
//      testPrtGraphics();
//      break;
//  #endif   
  
    //go offline and sleep
    case '=':
      printer.offline();
      printer.sleep();
      isOffline = true;            
      //Update status immediately after sleeping
      updatePrtStatus();
      break;

    // print help text on printer
    case '?':
      printHelpText();
      break;
      
    //send unknown command as literal byte sequence
    default:
      printer.write(0x1B);
      printer.write(c_cmd);
      break;
   } //switch
   isPrtCmd = false;
} //handlePrtCmd

//Handle graphics bytes
void handleGraphics(char c_cmd, byte idx) {
  byte g_value = c_cmd;
  if (g_size == 256) {
    fill32x64DataChunk(g_value, idx);
  } else {
    fill64x64DataChunk(g_value, idx);
  } //if g_size
} //handleGraphics 

// Expand data for a 512 bit image (2x4)
void fill64x64DataChunk(byte value, byte idx) {
  byte lo_nibble = value & 0x0F;
  byte hi_nibble = (value >> 4) & 0x0F;
  
  //convert each nibble into a byte
  byte gdata1 = expand_2[hi_nibble];
  byte gdata2 = expand_2[lo_nibble]; 

  //Calculate row offset value for double width line data
  byte row_idx = 2*idx;

  
  //Double width of line to 16 bytes
  t_line[row_idx]   = gdata1;
  t_line[row_idx+1] = gdata2;

  //expand line data into graphics block (2 x 32)
  for(int j = 0; j < 16; j++) {
    //get temporary value and expand again
    byte val = t_line[j];      
    byte lo_temp = val & 0x0F;
    byte hi_temp = (val >> 4) & 0x0F;
    // fill graphics chunk
    byte offset = 2*j;
    byte tdata1 = expand_2[hi_temp];
    byte tdata2 = expand_2[lo_temp];

    // fill 2 lines with graphics data doubled again
    for (int k = 0; k < 2; k++) {
      g_chunk[k*32 + offset] = tdata1;
      g_chunk[k*32 + offset + 1] = tdata2;
    } //for k      
  } // for j
} // fillDataChunk

//Print a 2x4 expanded line of a 512 byte image
void print64x64DataChunk() {
  printer.printBitmap(32*8, 2, g_chunk, false);
} //print64x64DataChunk

//Expand data for 256 byte image (4x4 expansion)
void fill32x64DataChunk(byte value, byte idx) {
  byte lo_nibble = value & 0x0F;
  byte hi_nibble = (value >> 4) & 0x0F;
  
  //convert each nibble into a byte
  byte gdata1 = expand_2[hi_nibble];
  byte gdata2 = expand_2[lo_nibble]; 

  //Calculate offset values for doubled lines of data
  byte line1 = 2*idx;
  byte line2 = line1 + 16;
  
  //Double size of graphics data by repeating lines
  t_line[line1]   = gdata1;
  t_line[line2]   = gdata1;
  t_line[line1+1] = gdata2;
  t_line[line2+1] = gdata2;

  for(int i = 0; i < 2; i++) {
    for(int j = 0; j < 16; j++) {
      //get temporary value and expand again
      byte val = t_line[i*16+j];      
      byte lo_temp = val & 0x0F;
      byte hi_temp = (val >> 4) & 0x0F;
      // fill graphics chunk
      byte offset = 2*j;
      byte tdata1 = expand_2[hi_temp];
      byte tdata2 = expand_2[lo_temp];

      // fill 4 lines in graphics data doubled again
      for (int k = 0; k < 4; k++) {
        g_chunk[k*32 + offset] = tdata1;
        g_chunk[k*32 + offset + 1] = tdata2;
      } //for k      
    } // for j
  } // for i
} // fill32x64DataChunk

//Print an 4x4 expanded line from a 256 byte image
void print32x64DataChunk() {
  printer.printBitmap(32*8, 4, g_chunk, false);
} //print32x64DataChunk

// Get the acutal printer status byte instead of using hasPaper()
// and output the status byte to PORT A of the MCP23017 
void updatePrtStatus() {
  byte prtStatus = 0xFF;
  
  //if printer is asleep, don't wake up, just assign status
  if (isOffline) {
    prtStatus = P_OFF;
  } else { 
    int  value  = -1;
    //send status cmd bytes <ESC> v 0 to printer
    printer.write(0x1B);
    printer.write('v');
    printer.write(0x00);
        
    for (byte i = 0; i < 10; i++) {
      if (mySerial.available()) {
        value = mySerial.read();
        break;
      } // if available
      delay(100);
    } // for
    
    // mask return value to byte result
    prtStatus = (value & 0x00FF);
    
    // make result 0x00 when ready 
    if (prtStatus == 0x20) {
      prtStatus = P_READY;  
    } // if prtStatus okay
  } //if-else isOffline
  
  #if DEBUG
  print2Hex(prtStatus);
  Serial.println();
  #endif
    
  //Send the data to the 1802
  mcp.writePort(MCP23017Port::A, prtStatus);
} // updatePrtStatus

//Set text back to defaults
void normalPrint() {
  printer.setDefault();
  //Set back to default font
  printer.setFont('A');
  // Set the flags to false
  isBold = false;
  isInverse = false;
  isUnderline = false;
  isFontB = false;
  isGraphic = false;
  // reset graphics byte counter
  g_count = 0;
} //normalPrint
 
//Print list of escape codes and printer commamds
void printHelpText() {
  printer.boldOn();
  printer.println(F("ASCII Escape Characters: "));
  printer.boldOff();
  printer.println(F("\\f - FF  \\n - LF \\r - CR"));
  printer.println(F("\\t - TAB \\v - VT \\e - ESC"));
  printer.println(F("\\\\ - Backslash"));
  printer.boldOn();
  printer.println(F("Printer Commands:"));
  printer.boldOff();
  printer.println(F("ESC @ - wake and go online"));
  printer.println(F("ESC ! - default to normal text"));
  printer.boldOn();
  printer.println(F("ESC e - toggle bold"));
  printer.boldOff(); 
  printer.inverseOn();
  printer.println(F("ESC i - toggle inverse"));
  printer.inverseOff();
  printer.underlineOn();
  printer.println(F("ESC u - toggle underline"));
  printer.underlineOff();
  printer.println(F("ESC 1 - single space lines"));
  printer.setLineHeight(60);
  printer.println(F("ESC 2 - double space lines"));
  printer.setLineHeight(30);
  printer.setFont('B');  
  printer.println(F("ESC s - switch font style "));
  printer.setFont('A');
  printer.justify('L');
  printer.println(F("ESC l (ESC L) - left justify"));
  printer.justify('C');
  printer.println(F("ESC c - center text"));
  printer.justify('R');
  printer.println(F("ESC r - right justify"));
  printer.setDefault();
  printer.println(F("ESC n - normal (small) text"));
  printer.setSize('M');
  printer.println(F("Esc t - tall (medium) text"));
  printer.setSize('L');
  printer.println(F("ESC w - wide (large) text"));
  printer.setDefault();
  printer.println(F("ESC # graphic[256] - 32x64 image"));
  printer.println(F("ESC * graphic[512] - 64x64 image"));
//  #if DEBUG
//    printer.println(F("ESC % - 32x64 graphic test image."));
//  #endif
  printer.println(F("ESC = - go offline and sleep"));
  printer.println(F("ESC ? - print this help text."));
  printer.feed(4);
} //printHelpText

//#if DEBUG
////Test graphics printing
//void testPrtGraphics() {
//  for (int rowStart = 0; rowStart < 32; rowStart ++) {
//    //Each row is 8 bytes
//    for (int i = 0; i < 8; i++) {
//      //get the data and expand it
//      byte g_value = pgm_read_byte(spaceship_data + 8 * rowStart + i);
//        
//    fill32x64DataChunk(g_value, i);
//    } // for
//    print32x64DataChunk();
//  } // for rowStart
//} // testPrtGraphics
//#endif
