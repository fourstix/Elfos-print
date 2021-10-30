# Elfos-print
Printer driver functions for the Elf/OS using an Adafruit Thermal Printer.

Platform  
--------

The printer commands were written to run on a [Pico/Elf v2 microcomputer](http://www.elf-emulation.com/picoelf.html). A lot of information and software for the Pico/Elf v2 microcomputer can be found on the [Elf-Emulation](http://www.elf-emulation.com/) website and in the [COSMAC ELF Group](https://groups.io/g/cosmacelf) at groups.io. The Elf/OS printer commands were all assembled into 1802 binary files using the [Asm/02 1802 Assembler](https://github.com/rileym65/Asm-02) by Mike Riley.

Printer Hardware
----------------

The printer used was the [Adafruit Mini Thermal Receipt Printer](https://www.adafruit.com/product/600). Adafruit has published a nice library for this printer on GitHub at [adafruit/Adafruit-Thermal-Printer-Library](https://github.com/adafruit/Adafruit-Thermal-Printer-Library). This library was written by Limor Fried/Ladyada for Adafruit Industries, with contributions from the open source community. 

 The processor used was a [NodeMCU ESP8266](https://randomnerdtutorials.com/esp8266-pinout-reference-gpios/), but the printer server code could be modified to work for almost any Arduino or Raspberry Pi microprocessor.  Random Nerd Tutorials has lot of good information on the [ESP8266 microprocessors](https://randomnerdtutorials.com/projects-esp8266/) available.

Pico/Elf I2C I/O Board
----------------------
A custom [Pico/Elf I2C I/O board](https://github.com/fourstix/Elfos-print/blob/main/brd/PicoElfI2C.pdf) is used to communicate from the Pico/Elf v2 1802 microprocessor bus and the NodeMCU microprocessor that drives the Thermal Printer via serial communication.  The Elf/OS reads and writes to Port 5 and monitors the /EF3 line to communicate data to the Pico/Elf I2C I/O board.  An MCP23017 GPIO extender reads or write data to the Pico/Elf bus.  

The printer microprocessor uses I2C to communicate with the MCP23017 and serial communication to send data to the Thermal Printer.  The Pico/Elf I2C I/O board can buffer the I/O levels to 3.3v or 5v, and the /EF line and Port number are selectable via jumper settings.  The design is based on the Pico/Elf v2 hardware by Mike Riley. Information about the Pico/Elf v2 is available at [Elf-Emulation.com](http://www.elf-emulation.com/).  [Gerber files](https://github.com/fourstix/Elfos-print/blob/main/brd/PicoElfI2C-gerbers.zip) and [Kicad project files](https://github.com/fourstix/Elfos-print/blob/main/brd/PicoElfI2C.zip) are available for this board.

I/O Connections
---------------
<table class="table table-hover table-striped table-bordered">
  <tr align="center">
    <th>ESP2866</th>
    <th>I/O Board</th>
    <th>&nbsp;</th>
  </tr>
  <tr align="center">
    <th>Pin</th>
    <th>Pin</th>
    <th>Notes</th>
  </tr>
  <tr align="center">
    <td>+5v</td>
    <td>+5v</td>
    <td>Vcc</td>
  </tr>
  <tr align="center">
    <td>GND</td>
    <td>GND</td>
    <td>Ground</td>
  </tr>
  <tr align="center">
    <td>RST</td>
    <td>/RST</td>
    <td>Reset</td>
  </tr>
  <tr align="center">
    <td>3.3v</td>
    <td>VBus</td>
    <td>Qwiic Red</td>
  </tr>
  <tr align="center">
    <td>GND</td>
    <td>GND</td>
    <td>Qwiic Black</td>
  </tr>
  <tr align="center">
    <td>D1</td>
    <td>SCL</td>
    <td>Qwiic Yellow</td>
  </tr>
  <tr align="center">
    <td>D2</td>
    <td>SDA</td>
    <td>Qwiic Blue</td>
  </tr>
  <tr align="center">
    <td>D4</td>
    <td>EF</td>
    <td>External Flag</td>
  </tr>
  <tr align="center">
    <td>D5</td>
    <td>DOUT</td>
    <td>Data Output</td>
  </tr>
  <tr align="center">
    <td>D6</td>
    <td>RX1</td>
    <td>Printer Green</td>
  </tr>
  <tr align="center">
    <td>D7</td>
    <td>TX1</td>
    <td>Printer Yellow</td>
  </tr>
  <tr align="center">
    <td>GND</td>
    <td>GND</td>
    <td>Printer Black</td>
  </tr>
  <tr align="center">
    <td>(Not Used)</td>
    <td>/DIN</td>
    <td>Data Input</td>
  </tr>
</table>

Schematic
---------
<table class="table table-hover table-striped table-bordered">
<tr align="center">
 <td ><img src="https://github.com/fourstix/Elfos-print/blob/main/pics/PicoElfI2C-schematic.jpg"></td>
</tr>
<tr align="center">
  <td >Pico/Elf I2C I/O board hardware schematic</td>
</tr>
</table>

Examples
---------
Here are some examples running printer commands on the Pico/Elf v2 Hardware
with the Pico/Elf I2C I/O board.  These examples were compiled with the [RcAsm 1802 Assmbler](https://github.com/rileym65/RcAsm).  Documentation for RcAsm can be found at [Elf-Emulation.com/RcAsm](http://www.elf-emulation.com/rcasm.html).

<table class="table table-hover table-striped table-bordered">
  <tr align="center">
   <td colspan="2"><img src="https://github.com/fourstix/Elfos-print/blob/main/pics/PicoElfprt-setup.jpg"></td>
  </tr>
  <tr align="center">
    <td colspan="2">Pico/Elf v2, Pico/Elf I2C I/O board, NodeMCU ESP2866 and Adafruit Mini Thermal Printer</td>
  </tr>
  <tr align="center">
   <td><img src="https://github.com/fourstix/Elfos-print/blob/main/pics/PicoElfI2C-board.jpg"></td>
   <td><img src="https://github.com/fourstix/Elfos-print/blob/main/pics/PicoElfPrt-vprint.jpg"></td>
  </tr>
  <tr align="center">
    <td>Close up of Pico/Elf I2C I/O Board</td>
    <td>Pixie Video GLCD display and print out of Video Buffer using vprint command.</td>
  </tr>  
  <tr align="center">
   <td><img src="https://github.com/fourstix/Elfos-print/blob/main/pics/PicoElfPrt-text.jpg"></td>
   <td><img src="https://github.com/fourstix/Elfos-print/blob/main/pics/PicoElfPrt-graphics.jpg"></td>
  </tr>
  <tr align="center">
    <td>Close up of printer showing text printed using the print command.</td>
    <td>Close up of printer showing image printed with the graphics command.</td>
  </tr>
</table>

Elf/OS Printer Commands
-------------------------------------

## lprt
**Usage:** lprt [-u]    
Load the printer driver into heap memory. The option -u will unload the printer driver and 
deallocate the memory.
 
**Note:** 
This command should be issued to load the printer driver before any other print commands.

## qprt 
**Usage:** qprt [-v|-s|-w]    
Query the printer and show its status.  The option -v will show a verbose message.  The option -s will sleep the printer offline and the option -w will wake the printer online.

## print
**Usage:** print *filename*    
Send the text file named *filename* to the printer. The file may contain ASCII escape character codes and printer command codes.

## graphics
**Usage:** graphics *filename*    
Print the data in the image file named *filename* as a graphic image. The file can be a 256 byte 32x64 image file or a 512 byte 64x64 image file.

## sprint
**Usage:** sprint *text*    
Send a text string to the printer. The string may contain ASCII escape character codes and printer command codes.

**Note:** 
The command *sprint \e?* will print help text on the printer.

## vprint
**Usage:** vprint   
Print the video buffer. Send the data in the video buffer to the printer as a graphic image.

**Note:** 
Requires the [Pixie Video functions](https://github.com/fourstix/Elfos-video) for 1861 Pixie Video Display and the 1802 Pico/Elf v2 microcomputer.

Supported ASCII Escape Character codes
--------------------------------------
<table class="table table-hover table-striped table-bordered">
  <tr align="center">
   <th >String</th>
   <th >ASCII</th>
   <th >Name</th>
  </tr>
  <tr align="center">
   <td >\f</td>
   <td >FF</td>
   <td >Form Feed</td>
  </tr>
  <tr align="center">
   <td >\n</td>
   <td >LF</td>
   <td >Line Feed</td>
  </tr>
  <tr align="center">
   <td >\r</td>
   <td >CR</td>
   <td >Carriage Return</td>
  </tr>
  <tr align="center">
   <td >\t</td>
   <td >TAB</td>
   <td >Horizontal Tab</td>
  </tr>
  <tr align="center">
   <td >\v</td>
   <td >VT</td>
   <td >Vertical Tab</td>
  </tr>
  <tr align="center">
   <td >\e</td>
   <td >ESC</td>
   <td >Escape</td>
  </tr>
  <tr align="center">
   <td >\\</td>
   <td >BS</td>
   <td >Backslash</td>
  </tr>
</table>

Printer Command codes
---------------------
<table class="table table-hover table-striped table-bordered">
  <tr align="center">
    <th >String</th>
    <th >Command</th>
  </tr>
  <tr align="center">
    <td >ESC @</td>
    <td >wake and go online</td>
  </tr>   
  <tr align="center">
    <td >ESC !</td>
    <td >default text style</td>
  </tr>   
  <tr align="center">
    <td >ESC e</td>
    <td >toggle bold text</td>
  </tr>   
  <tr align="center">
    <td >ESC i</td>
    <td >toggle inverse text</td>
  </tr>   
  <tr align="center">
    <td >ESC u</td>
    <td >toggle underline text</td>
  </tr>   
  <tr align="center">
    <td >ESC 1</td>
    <td >single space lines</td>
  </tr>   
  <tr align="center">
    <td >ESC 2</td>
    <td >double space lines</td>
  </tr>   
  <tr align="center">
    <td >ESC s</td>
    <td >switch font style</td>
  </tr>   
  <tr align="center">
    <td >ESC l (ESC L)</td>
    <td >left justify</td>
  </tr>   
  <tr align="center">
    <td >ESC c</td>
    <td >center text</td>
  </tr>   
  <tr align="center">
    <td >ESC r</td>
    <td >right justify</td>
  </tr>   
  <tr align="center">
    <td >ESC n</td>
    <td >normal (small) text</td>
  </tr>   
  <tr align="center">
    <td >Esc t</td>
    <td >tall (medium) text</td>
  </tr>   
  <tr align="center">
    <td >ESC w</td>
    <td >wide (large) text</td>
  </tr>   
  <tr align="center">
    <td >ESC # graphic[256]</td>
    <td >print 32x64 image</td>
  </tr>   
  <tr align="center">
    <td >ESC * graphic[512]</td>
    <td >print 64x64 image</td>
  </tr>   
  <tr align="center">
    <td >ESC =</td>
    <td >go offline and sleep</td>
  </tr>   
  <tr align="center">
    <td >ESC ?</td>
    <td >print help text</td>
  </tr>   
</table>
**Note:** 
ESC represents the ASCII escape code, hexadecimal value *0x1B*, decimal value *27*.

Repository Contents
-------------------
* **/src/asm/**  -- Source files for assembling Elf/OS printer commands.
  * asm.bat - Windows batch file to assemble source file with Asm/02 to create binary file. Use the command *asm xxx.asm* to assemble the xxx.asm file.
  * ops.inc - Opcode definitions for Asm/02.
  * bios.inc - Bios definitions from Elf/OS.
  * kernel.inc - Kernel definitions from Elf/OS.
  * lprt.asm -- Command to load the printer driver into heap memory.
  * qprt.asm -- Command to query the printer and show its status.
  * print.asm -- Command to send a text file to the printer.
  * graphics.asm -- Command to send data from an image file to the printer.
  * sprint.asm -- Command to send a text string to the printer.
  * vprint.asm -- Command to send the contents of the Video Buffer to the printer as image data.
* **/src/asm/esp8266/PicoElfIThermalPrinter/**  -- Source files for NodeMCU ESP8266 microcomputer to drive the printer.  
  * PicoElfIThermalPrinter.ino -- NodeMCU ESP8266 printer driver.
* **/bin/** -- Binary files for Elf/OS printer commands.
* **/lbr/**  -- Library file for Elf/OS (Unpack with Elf/OS lbr command)
  * printer.lbr - Library file for Elf/OS print commands.
* **/hlp/**  -- Help file for Elf/OS. (Used with Elf/OS help command)
  * print.lbr - Help file for Elf/OS commands. (Do not unpack with lbr, instead copy into /hlp directory.)   
* **/pics/** -- example pictures for readme
* **/brd/** -- Printed Circuit Board layout for Pico/Elf I2C I/O Board.
  * PicoElfI2C.zip -- KiCad5 project files for Pico/Elf I2C I/O Board.
  * PicoElfI2C-gerbers.zip -- Gerber files for Pico/Elf I2C I/O Board.
  * PicoElfI2C.pdf -- Schematic file for Pico/Elf I2C I/O Board.
* **/utils/asm/**  -- Asm/02 assembler used to assemble the programs.  Please check the [rileym65/Asm-02](https://github.com/rileym65/Asm-02) repository on GitHub for the latest version of Asm/02.
    * asm02.exe - Windows 10 executable version of the Asm/02 assembler.
    * asm02.doc - Asm/02 documentation.  

License Information
-------------------

This code is public domain under the MIT License, but please buy me a beverage
if you use this and we meet someday (Beerware).

References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.

Any company, product, or services names may be trademarks or services marks of others.

All libraries used in this code are copyright their respective authors.

This code is based on a Elf/OS code libraries written by Mike Riley and assembled with the RcAsm assembler also written by Mike Riley and use the Adafruit Thermal Printer library written by Limor Fried/Ladyada for Adafruit Industries, with contributions from the open source community. 

Elf/OS 
Copyright (c) 2004-2021 by Mike Riley

Asm/02 1802 Assembler
Copyright (c) 2004-2021 by Mike Riley

The Pico/Elf Microcomputer Hardware
Copyright (c) 2020-2021 by Mike Riley

The Adafruit Thermal Printer Arduino Library
Copyright (c) 2011-2021 by Adafruit Industries 
 
Many thanks to the original authors for making their designs and code available as open source.
 
This code, firmware, and software is released under the [MIT License](http://opensource.org/licenses/MIT).

The MIT License (MIT)

Copyright (c) 2021 by Gaston Williams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.**
