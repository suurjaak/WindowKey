WindowKey 1.3
=============

A tray tool for changing active window position and size with global
Windows hotkeys.


Hotkeys:

Win            + Left/Right/Up/Down   move window one step (20 px) in arrow direction
Win Ctrl       + Left/Right/Up/Down   snap window to screen edge in arrow direction
Win Shift      + Left/Right/Up/Down   resize window one step (20 px) in arrow direction
Win Ctrl Shift + Left/Right/Up/Down   expand window to screen edge in arrow direction
Win Alt        + Left/Right/Up/Down   move window one step in arrow direction, ignoring screen bounds
Win Ctrl       + A                    toggle window always on top
Win            + F10                  exit program


Grid hotkeys:

Win + 1                               top left,  40% of screen width, full height   
Win + 2                               top left,  50% of screen width, full height   
Win + 3                               top left,  60% of screen width, full height   
Win + 4                               top left,  66% of screen width, full height   
Win + 5                               top left,  80% of screen width, full height   
Win + 6                               top right, 40% of screen width, full height   
Win + 7                               top right, 33% of screen width, full height   
Win + 8                               top right, 50% of screen width, 66% of height
Win + 9                               top right, 33% of screen width, 50% of height
Win + 0                               restore window previous position and size


Windows stay within screen bounds and snap against the edge.

Resize works in reverse at screen edge. For example, Win+Shift+Down normally
expands height below, but reduces height above when window is at screen bottom.
Similarly, Win+Shift+Left usually reduces width from the right, but starts
expanding width to the left when window is against screen right edge.


Dependencies
------------

Runs under Microsoft Windows. Tested under Windows 7 and Windows XP.


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
