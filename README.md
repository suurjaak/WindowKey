WindowKey
=========

Small tray program for changing active window position and size with global
Windows hotkeys.


Hotkeys:

Key                                 | Action
----------------------------------- | -----------------------------------------
Win Alt        + Left/Right/Up/Down | snap window to left/right/top/bottom edge
Win Ctrl       + Left/Right/Up/Down | move window left/right/up/down
Win Ctrl Shift + Left               | reduce width, or expand to the left if at screen right edge
Win Ctrl Shift + Right              | expand width, or reduce from left if at screen right edge
Win Ctrl Shift + Up                 | reduce height, or expand upward if at screen bottom edge
Win Ctrl Shift + Down               | expand height, or reduce from top if at screen bottom edge
Win            + number             | move and size window to numbered grid position
Win Ctrl       + A                  | toggle window always on top
Win            + F10                | exit program
 | 
***Win         + number***          | ***move and size window to grid position X***
Win            + 1                  | on the left, third of screen width, full height
Win            + 2                  | on the left, 2/5 of screen width, full height
Win            + 3                  | on the left, half of screen width, full height
Win            + 4                  | on the left, 3/5 of screen width, full height
Win            + 5                  | on the left, 2/3 of screen width, full height
Win            + 6                  | on the left, 4/5 of screen width, full height
Win            + 7                  | on the right, 2/5 of screen width, full height
Win            + 8                  | on the right, third of screen width, full height
Win            + 9                  | top right, third of screen width, half of screen height
Win            + 0                  | restore window previous position and size


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
