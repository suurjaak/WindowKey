WindowKey
=========

Background script for changing active window position and size with
global Windows hotkeys. 

Hotkeys:

Key                                 | Action
----------------------------------- | -----------------------------------------
Win Alt        + Left/Right/Up/Down | move window one step left/right/up/down
Win Ctrl       + Left/Right/Up/Down | snap window to left/right/top/bottom edge
Win Ctrl Shift + Left/Down          | increase window width/height
Win Ctrl Shift + Right/Up           | decrease window width/height
Win            + Numpad X           | move and size window to grid position X
Win            + F10                | exit program

Grid hotkeys:

Key            | Action
-------------- | -------------------------------------------------------
Win + Numpad 1 | left edge, third of screen width, full height
Win + Numpad 2 | left edge, 2/5 of screen width, full height
Win + Numpad 3 | left edge, half of screen width, full height
Win + Numpad 4 | left edge, 3/5 of screen width, full height
Win + Numpad 5 | maximize window
Win + Numpad 6 | right edge, half of screen width, full height
Win + Numpad 7 | right edge, 2/5 of screen width, full height
Win + Numpad 8 | right edge, third of screen width, full height
Win + Numpad 9 | top right, third of screen width, half of screen height
Win + Numpad 0 | restore window previous position and size


Dependencies
------------

Runs under Windows. Requires pywin32 (https://pypi.python.org/pypi/pywin32).


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
