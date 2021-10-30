# Elfos-print
Printer driver functions for the Elf/OS.

Platform  
--------

The printer commands were written to run on a [Pico/Elf](http://www.elf-emulation.com/picoelf.html).
A lot of information and software for the Pico/Elf can be found on the [Elf-Emulation](http://www.elf-emulation.com/) website and in the [COSMAC ELF Group](https://groups.io/g/cosmacelf) at groups.io. The Elf/OS printer commands were all assembled into 1802 binary files using the [Asm/02 1802 Assembler](https://github.com/rileym65/Asm-02) by Mike Riley.

Printer  
--------

The printer used was the [Adafruit Mini Thermal Receipt Printer](https://www.adafruit.com/product/600). Adafruit has published a nice library for this printer available on GitHub at [adafruit/Adafruit-Thermal-Printer-Library](https://github.com/adafruit/Adafruit-Thermal-Printer-Library). The processor used was a [NodeMCU ESP8266](https://randomnerdtutorials.com/esp8266-pinout-reference-gpios/), but the printer server code could be modified to work for almost any Arduino or Raspberry Pi microprocessor.  Random Nerd Tutorials has lot of good information on the [ESP8266 microprocessors](https://randomnerdtutorials.com/projects-esp8266/) available.

Pico/Elf I2C I/O Board
----------------------
A custom [Pico/Elf I2C](https://github.com/fourstix/Elfos-print/blob/main/brd/PicoElfI2C.pdf) board was used to communicate from the Pico/Elf v2 1802 microprocessor bus and the NodeMCU microprocessor that drives the Thermal Printer via serial communication.  The Elf/OS reads and writes to Port 5 and monitors the /EF3 line to communicate data to the Pico/Elf I2C I/O board.  An MCP23017 GPIO extender reads or write data to the Pico/Elf bus.  The printer microprocessor uses I2C to communicate with the MCP23017 and serial communication to send data to the Thermal Printer.  The Pico/Elf I2C board can buffer the I/O levels to 3.3v or 5v, and the /EF line and Port are selectable via jumper settings.  The design is based on the Pico/Elf v2 hardware by Mike Riley. Information about the Pico/Elf v2 is available at [Elf-Emulation.com](http://www.elf-emulation.com/).  [Gerber files]() and [Kicad files]() are available for the board.

Examples
---------------------
Here are some examples running printer commands on the Pico/Elf v2 Hardware
with the Pico/Elf I2C I/O board.  These examples were compiled with the [RcAsm 1802 Assmbler](https://github.com/rileym65/RcAsm).  Documentation for RcAsm can be found at [Elf-Emulation.com/RcAsm](http://www.elf-emulation.com/rcasm.html).

<table class="table table-hover table-striped table-bordered">
  <tr align="center">
   <td colspan="2"><img src="https://github.com/fourstix/Elfos-print/blob/main/pics/PicoElfI2C-schematic.jpg"></td>
  </tr>
  <tr align="center">
    <td colspan="2">Schematic for Pico/Elf I2C I/O board</td>
  </tr>
  <tr align="center">
   <td><img src="https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/pics/tvclock.jpg"></td>
   <td><img src="https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/pics/port4out.jpg"></td>
  </tr>
  <tr align="center">
    <td>Close up of 128x64 ST7920 GLCD display with 1802 Pico/Elf v2 running Tom Pittman's TV Clock program.</td>
    <td>Close up of 128x64 ST7920 GLCD display displaying the hex value '0E' output to Port 4 by the 1802 Pico/Elf v2. Note that the LED is on indicating the Q-bit is true.</td>
  </tr>  
  <tr align="center">
     <td colspan="2"><img src="https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/pics/schematic.jpg"></td>
  </tr>
  <tr align="center">
     <td colspan="2">Pico/Elf Pixie Video GLCD version 2 Hardware Schematic</td>
  </tr>
  <tr align="center">
     <td colspan="2"><img src="https://github.com/fourstix/PicoElfPixieVideoGLCDV2/blob/main/pics/all_three.jpg"></td>
  </tr>
  <tr align="center">
     <td colspan="2">Pico/Elf v2 running with an STG RTC/NVR card and a Pixie Video GLCD Card connected by an IDE cable.</td>
  </tr>
</table>


License Information
-------------------

This code is public domain under the MIT License, but please buy me a beverage
if you use this and we meet someday (Beerware).

References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.

Any company, product, or services names may be trademarks or services marks of others.

All libraries used in this code are copyright their respective authors.

This code is based on a Elf/OS code libraries written by Mike Riley and assembled with the RcAsm assembler also written by Mike Riley.

Elf/OS 
Copyright (c) 2004-2021 by Mike Riley

Asm/02 1802 Assembler
Copyright (c) 2004-2021 by Mike Riley

The Pico/Elf Microcomputer Hardware
Copyright (c) 2020-2021 by Mike Riley
 
 
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
