WindowKey
=========

Small tray program for changing active window position and size with global
Windows hotkeys.


Hotkeys:

Key                                 | Action
----------------------------------- | -----------------------------------------
Win            + Left/Right/Up/Down | move window one step (20px) in arrow direction
Win Alt        + Left/Right/Up/Down | snap window to left/right/top/bottom edge
Win Shift      + Left/Right/Up/Down | resize window one step (20px) to/from arrow direction
Win Ctrl       + Left/Right/Up/Down | move window one pixel in arrow direction
Win Ctrl Shift + Left/Right/Up/Down | resize window one pixel to/from arrow direction
Win Ctrl Alt   + Left/Right/Up/Down | move window one step in arrow direction, ignoring screen bounds
Win Ctrl       + A                  | toggle window always on top
Win            + F10                | exit program
 | 
***Win         + number***          | ***move and size window to grid position X***
Win            + 1                  | 2/5 of screen from left, full height
Win            + 2                  | 1/2 of screen from left, full height
Win            + 3                  | 3/5 of screen from left, full height
Win            + 4                  | 2/3 of screen from left, full height
Win            + 5                  | 4/5 of screen from left, full height
Win            + 6                  | 2/5 of screen from right, full height
Win            + 7                  | 1/3 of screen from right, full height
Win            + 8                  | 1/2 of screen in top right, 2/3 of height
Win            + 9                  | 1/3 of screen in top right, 1/2 of height
Win            + 0                  | restore window previous position and size

Windows stay within screen bounds and snap against the edge.

Resize goes into reverse at screen edge. For example, Down usually expands
height below, but starts reducing height above when window is at the bottom.
Similarly, Left usually reduces width from the right, but starts expanding
width to the left when window is against screen right edge.


Dependencies
------------

Runs under Windows.

In source code form, needs AutoHotkey.


Attribution
-----------

Application icon from Fugue Icons, (c) 2010 Yusuke Kamiyamane
(http://p.yusukekamiyamane.com/).

Executable compiled with AutoHotkey 1.1.13.01 (http://www.autohotkey.com/).

Installer created with Nullsoft Scriptable Install System 2.46
(http://nsis.sourceforge.net/).



License
-------

The MIT License

Copyright (C) 2013-2014 by Erki Suurjaak

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

The software is provided "as is", without warranty of any kind, express or
implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose and noninfringement. In no event shall the
authors or copyright holders be liable for any claim, damages or other
liability, whether in an action of contract, tort or otherwise, arising from,
out of or in connection with the software or the use or other dealings in
the software.
