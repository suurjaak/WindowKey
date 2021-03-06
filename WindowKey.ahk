/**
 * AutoHotkey script for changing active window position and size with
 * global Windows hotkeys. 
 *
 * Actions:
 * - move window left/right/up/down by one step or one pixel
 * - snap window to left/right/top/bottom edge
 * - resize window left/right/up/down by one step or one pixel
 * - toggle window always on top
 * - set window to grid position <number>
 * 
 * 
 * Released under the MIT License.
 * 
 * @author    Erki Suurjaak
 * @created   03.01.2014
 * @modified  21.01.2014
 */
AUTHOR        := "Erki Suurjaak"
TITLE         := "WindowKey"
VERSION       := "1.4"
VERSION_DATE  := "21.01.2014"
HOMEPAGE      := "https://github.com/suurjaak/WindowKey"
ICON_FILE     := A_IsCompiled ? A_ScriptFullPath : (A_ScriptDir . "\Icon.ico")
STEP_SIZE     := 20
STEP_MOVE     := 20
PADDING_X     := -4 ; Window looks best when slightly over screen bounds
PADDING_Y     := -4
INTERVAL_EDGE := 500
ABOUT_INTRO    =
(
A tray tool for changing active window position and size with global Windows hotkeys.
)
ABOUT_TEXT   =
(
Hotkeys:

Win   ←↑→↓ `t`t  move window one step (%STEP_MOVE% px) in arrow direction
Win Ctrl   ←↑→↓ `t  snap window to screen edge in arrow direction
Win Shift   ←↑→↓ `t  resize window one step (%STEP_SIZE% px) in arrow direction
Win Ctrl Shift   ←↑→↓   expand window to screen edge in arrow direction`t
Win Alt ←↑→↓ `t  move window one step in arrow direction, ignoring screen bounds
Win Ctrl A `t`t  toggle window always on top
Win F10 `t`t  exit %TITLE% program

Grid hotkeys:

Win  1 `t`t`t  top left,   40`% of screen width, full height
Win  2 `t`t`t  top left,   50`% of screen width, full height
Win  3 `t`t`t  top left,   60`% of screen width, full height
Win  4 `t`t`t  top left,   66`% of screen width, full height
Win  5 `t`t`t  top left,   80`% of screen width, full height
Win  6 `t`t`t  top right, 40`% of screen width, full height
Win  7 `t`t`t  top right, 33`% of screen width, full height
Win  8 `t`t`t  top right, 50`% of screen width, 66`% of height
Win  9 `t`t`t  top right, 33`% of screen width, 50`% of height
Win  0 `t`t`t  restore window previous position and size

Resize works in reverse at screen edge. For example, Win+Shift+Down normally expands
height below, but reduces height above when window is at screen bottom.


Version %VERSION%, %VERSION_DATE%. Created with AutoHotkey.

Copyright 2013-2014 by %AUTHOR%.
)


thisHotkey    := "" ; Local A_ThisHotkey override
stepMove      := STEP_MOVE ; Hotkey-specific move step
stepSize      := STEP_SIZE ; Hotkey-specific size step
outOfBounds   := 0  ; Local moving out of bounds flag (0|1)
windowRects   := {} ; {hwnd: (x, y, w, h, isMaximized), } before last change
resizedRects  := {} ; {arrow: (x, y, w, h, isMaximized), } before sized to edge
resizedToEdge := {} ; {"Top""Bottom"Left""Right": if sizing just reached edge }
lastResizeTickCount  := 0 ; A_TickCount at last resize


#HotkeyInterval 1 ; Avoid AutoHotkey warnings on rapid keypress (default 2000)
#NoTrayIcon ; Hide initial default icon
#SingleInstance force ; Replace previous running instance automatically
#IfWinNotActive ahk_class DV2ControlHost ; Ignore start menu window for hotkeys

Menu, GridMenu, Add, &1 - top left`,   40`% width`, full height, WK_Menu_Grid
Menu, GridMenu, Add, &2 - top left`,   50`% width`, full height, WK_Menu_Grid
Menu, GridMenu, Add, &3 - top left`,   60`% width`, full height, WK_Menu_Grid
Menu, GridMenu, Add, &4 - top left`,   66`% width`, full height, WK_Menu_Grid
Menu, GridMenu, Add, &5 - top left`,   80`% width`, full height, WK_Menu_Grid
Menu, GridMenu, Add, &6 - top right`, 40`% width`, full height, WK_Menu_Grid
Menu, GridMenu, Add, &7 - top right`, 33`% width`, full height, WK_Menu_Grid
Menu, GridMenu, Add, &8 - top right`, 50`% width`, 66`% height, WK_Menu_Grid
Menu, GridMenu, Add, &9 - top right`, 33`% width`, 50`% height, WK_Menu_Grid
Menu, GridMenu, Add, &0 - restore last position, WK_Menu_Grid
Menu, SnapMenu, Add, &Left edge, WK_Menu_Edge
Menu, SnapMenu, Add, &Top edge, WK_Menu_Edge
Menu, SnapMenu, Add, &Right edge, WK_Menu_Edge
Menu, SnapMenu, Add, &Bottom edge, WK_Menu_Edge
Menu, Tray, NoStandard
Menu, Tray, Add, &About %TITLE%, WK_Menu_About
Menu, Tray, Add, Go to &homepage, WK_OpenHomepage
Menu, Tray, Add ; separator
Menu, Tray, Add, Set window to &grid, :GridMenu
Menu, Tray, Add, Snap window to &edge, :SnapMenu
Menu, Tray, Add ; separator
Menu, Tray, Add, &Start with Windows, WK_Menu_Toggle_Startup
Menu, Tray, Add, &Disable hotkeys, WK_Menu_Toggle_Hotkeys
Menu, Tray, Add ; separator
Menu, Tray, Add, E&xit, WK_Menu_Exit

Menu, Tray, Default, &About %TITLE%
IfExist, %A_Startup%\%TITLE%.lnk 
    Menu, Tray, Check, &Start with Windows
Menu, Tray, Icon, %ICON_FILE%
Menu, Tray, Icon,,, 1 ; Freeze icon: no icon change when suspending hotkeys
Menu, Tray, Tip, %TITLE%
Sleep, 500
traytip := "Global hotkeys " . (A_IsSuspended ? "disabled." : "enabled.")
TrayTip, %TITLE%, %traytip%, 5, 1 ; 5: seconds, 1: info icon
Return


; Windows+Arrow: Move window one step.
#Up::
#Down::
#Left::
#Right::
#NumpadUp::
#NumpadDown::
#NumpadLeft::
#NumpadRight::
    thisHotkey := A_ThisHotkey
    stepMove := STEP_MOVE
    outOfBounds := 0
    GoSub, WK_WindowMove
    Return


; Alt+Windows+Arrow: Move window one step, ignoring screen bounds.
#!Up::
#!Down::
#!Left::
#!Right::
#!NumpadUp::
#!NumpadDown::
#!NumpadLeft::
#!NumpadRight::
    thisHotkey := A_ThisHotkey
    stepMove := STEP_MOVE
    outOfBounds := 1
    GoSub, WK_WindowMove
    Return


; Alt+Windows+Arrow: Snap window to screen edge in arrow direction.
#^Up::
#^Down::
#^Left::
#^Right::
#^NumpadUp::
#^NumpadDown::
#^NumpadLeft::
#^NumpadRight::
    thisHotkey := A_ThisHotkey
    GoSub, WK_WindowEdge
    Return


; Shift+Windows+Arrow: Resize window one step, straight or diagonally.
#+Up::
#+Down::
#+Left::
#+Right::
#+NumpadUp::
#+NumpadDown::
#+NumpadLeft::
#+NumpadRight::
    thisHotkey := A_ThisHotkey
    timeSincePriorResize := A_TimeSincePriorHotkey
    stepSize := STEP_SIZE
    GoSub, WK_WindowResize
    Return


; Ctrl+Shift+Windows+Arrow: Resize window one step, straight or diagonally.
#^+Up::
#^+Down::
#^+Left::
#^+Right::
#^+NumpadUp::
#^+NumpadDown::
#^+NumpadLeft::
#^+NumpadRight::
    thisHotkey := A_ThisHotkey
    stepSize := STEP_SIZE
    GoSub, WK_WindowResizeToEdge
    Return


; Windows+number: Position window to grid area X.
#1::
#2::
#3::
#4::
#5::
#6::
#7::
#8::
#9::
#0::
#Numpad1::
#Numpad2::
#Numpad3::
#Numpad4::
#Numpad5::
#Numpad6::
#Numpad7::
#Numpad8::
#Numpad9::
#Numpad0::
    thisHotkey := A_ThisHotkey
    GoSub, WK_WindowGrid
    Return


; Ctrl+Windows+A: Toggle window always on top.
#^A::
    WinSet, AlwaysOnTop, Toggle, A
    Return


; Windows+F10: Exit program.
#IfWinNotActive ; Discard previously set ahk_class DV2ControlHost 
#F10::
    GoSub, WK_Exit
    Return


; Arrange the foreground window to a pre-defined grid.
WK_WindowGrid:
    SysGet, workarea, MonitorWorkArea ; Creates workareaLeft, workAreaTop etc
    WinGet, hwnd, ID, A
    WinGet, isMaximized, MinMax, A
    WinGetPos, x, y, w, h, A

    SetWinDelay, 10 ; Default delay is 100, makes continuous action slow
    If thisHotkey contains 0
    {
        rect := windowRects[hwnd + 0] ; Convert window handle type to hashable
        If isMaximized ; Window is currently maximized: simply restore
            WinRestore, A
        Else If rect and rect[5] ; Restore maximized state
            WinMaximize, A
        Else If rect
            WinMove A,, rect[1], rect[2], rect[3], rect[4]
    } Else {
        MIN_X := workareaLeft + PADDING_X
        MIN_Y := workareaTop + PADDING_Y
        MAX_X := workareaRight - PADDING_X
        MAX_W := workareaRight - workareaLeft - 2 * PADDING_X
        MAX_H := workareaBottom - workareaTop - 2 * PADDING_Y
        If thisHotkey contains 1
            rect := [MIN_X, MIN_Y, MAX_W * 2/5, MAX_H]
        Else If thisHotkey contains 2
            rect := [MIN_X, MIN_Y, MAX_W * 1/2, MAX_H]
        Else If thisHotkey contains 3
            rect := [MIN_X, MIN_Y, MAX_W * 3/5, MAX_H]
        Else If thisHotkey contains 4
            rect := [MIN_X, MIN_Y, MAX_W * 2/3, MAX_H]
        Else If thisHotkey contains 5
            rect := [MIN_X, MIN_Y, MAX_W * 4/5, MAX_H]
        Else If thisHotkey contains 6
            rect := [MAX_X - Floor(MAX_W * 2/5), MIN_Y, MAX_W * 2/5, MAX_H]
        Else If thisHotkey contains 7
            rect := [MAX_X - Floor(MAX_W * 1/3), MIN_Y, MAX_W * 1/3, MAX_H]
        Else If thisHotkey contains 8
            rect := [MAX_X - Floor(MAX_W * 1/2), MIN_Y, MAX_W * 1/2, MAX_H * 2/3]
        Else If thisHotkey contains 9
            rect := [MAX_X - Floor(MAX_W * 1/3), MIN_Y, MAX_W * 1/3, MAX_H * 1/2]
        If isMaximized
            WinRestore, A
        WinMove A,, rect[1], rect[2], rect[3], rect[4]
    }
    windowRects[hwnd + 0] := [x, y, w, h, isMaximized]
    Return


; Snap foreground window to one screen edge.
WK_WindowEdge:
    SysGet, workarea, MonitorWorkArea ; Creates workareaLeft, workAreaTop etc
    WinGet, hwnd, ID, A
    WinGetPos, x, y, w, h, A
    keystate := WK_Keystate()
    MIN_X := workareaLeft + PADDING_X
    MIN_Y := workareaTop + PADDING_Y
    MAX_X := workareaRight - PADDING_X
    MAX_Y := workareaBottom - PADDING_Y
    x2 := x, y2 = y

    If keystate["Up"] { ; Snap to top
        If (y > MIN_Y)
            y2 := MIN_Y
    } Else If keystate["Down"] { ; Snap to bottom
        If (y + h < workareaBottom - PADDING_Y)
            y2 := workareaBottom - PADDING_Y - h
        Else  ; Taskbar edge: go to screen edge
            y2 := A_ScreenHeight - h - MIN_Y
    } Else If keystate["Left"] { ; Snap to left
        If (x > MIN_X)
            x2 := MIN_X
    } Else If keystate["Right"] { ; Snap to right
        If (x + w < MAX_X)
            x2 := MAX_X - w
    }

    If (x != x2 or y != y2) {
        windowRects[hwnd + 0] := [x, y, w, h, false]
        SetWinDelay, 10 ; Default delay is 100, makes continuous movement slow
        WinMove A,, x2, y2, w, h
    }
    Return


; Move the foreground window one step, straight or diagonally.
WK_WindowMove:
    SysGet, workarea, MonitorWorkArea ; Creates workareaLeft, workAreaTop etc
    WinGet, hwnd, ID, A
    WinGetPos, x, y, w, h, A
    keystate := WK_Keystate()
    MIN_X := workareaLeft + PADDING_X - outOfBounds * (w + 3 * PADDING_X)
    MIN_Y := workareaTop + PADDING_Y - outOfBounds * (h + 3 * PADDING_Y)
    MAX_X := workareaRight - PADDING_X + outOfBounds * (w + 3 * PADDING_X)
    MAX_Y := workareaBottom - PADDING_Y + outOfBounds * (h + 3 * PADDING_Y)
    x2 := x, y2 = y

    If keystate["Up"] { ; Move up
        If (y > MIN_Y)
            y2 := Max(y - stepMove, MIN_Y)
    } Else If keystate["Down"] { ; Move down
        If (y + h < MAX_Y)
            y2 := Min(y + stepMove, MAX_Y - h)
    }
    ; Move diagonally if two arrow keys are down
    If keystate["Left"] { ; Move left
        If (x > MIN_X)
            x2 := Max(x - stepMove, MIN_X)
    } Else If keystate["Right"] { ; Move right
        If (x + w < MAX_X)
            x2 := Min(x + stepMove, MAX_X - w)
    }

    If (x != x2 or y != y2) {
        If ((x2 - PADDING_X) * (x - PADDING_X) < 0) ; Crossing PADDING_X
            x2 := PADDING_X ; Snap to edge if crossing over
        windowRects[hwnd + 0] := [x, y, w, h, false]
        SetWinDelay, 10 ; Default delay is 100, makes continuous movement slow
        WinMove A,, x2, y2, w, h
    }
    Return


; Resize foreground window one step, straight or diagonally.
WK_WindowResize:
    SysGet, workarea, MonitorWorkArea ; Creates workareaLeft, workAreaTop etc
    WinGet, hwnd, ID, A
    WinGet, isMaximized, MinMax, A
    WinGetPos, x, y, w, h, A
    keystate := WK_Keystate()
    MIN_W := 100
    MIN_H := 100
    MIN_X := workareaLeft + PADDING_X
    MIN_Y := workareaTop + PADDING_Y
    MAX_W := workareaRight - workareaLeft - 2 * PADDING_X
    MAX_H := workareaBottom - workareaTop - 2 * PADDING_Y
    MAX_X := workareaRight - PADDING_X
    MAX_Y := workareaBottom - PADDING_Y
    x2 := x, y2 = y, w2 = w, h2 = h
    inInterval := (A_TickCount - lastResizeTickCount < INTERVAL_EDGE)
    EDGESTRINGS := "Top,Bottom,Left,Right"
    Loop, parse, EDGESTRINGS, `,
        resizedToEdge[A_LoopField] := inInterval and resizedToEdge[A_LoopField]

    If keystate["Up"] {
        If (y + h >= MAX_Y and y > MIN_Y) {
            ; At screen bottom: expand height upwards
            y2 := Max(y - stepSize, MIN_Y)
            h2 := h + y - y2
            resizedToEdge["Top"] := (y2 < y) and (y2 == MIN_Y)
        } Else If (h > MIN_H and not resizedToEdge["Top"])
            h2 := Max(h - stepSize, MIN_H) ; Reduce height below
    } Else If keystate["Down"] {
        If (y + h < MAX_Y) { ; Expand height downwards
            h2 := Min(h + stepSize, MAX_Y - y)
            resizedToEdge["Bottom"] := (h2 > h) and (y2 + h2 == MAX_Y)
        } Else If (h > MIN_H and not resizedToEdge["Bottom"]) {
            h2 := Max(h - stepSize, MIN_H) ; Reduce height above
            y2 := y + h - h2
        }
    }
    ; Size diagonally if two arrow keys are down
    If keystate["Left"] {
        If (w >= MAX_W and not resizedToEdge["Left"])
            w2 := w - stepSize ; Reduce width from the right
        Else If (x + w >= MAX_X) {
            x2 := Max(x - stepSize, MIN_X) ; Expand width to the left
            w2 := w + x - x2
            resizedToEdge["Left"] := (x2 < x) and (x2 == MIN_X)
        } Else If (w > MIN_W) and not resizedToEdge["Left"]
            w2 := Max(w - stepSize, MIN_W) ; Reduce width from the right
    } Else If keystate["Right"] {
        If (x + w < MAX_X) { ; Expand width to the right
            w2 := Min(w + stepSize, MAX_X - x)
            resizedToEdge["Right"] := (w2 > w) and (x2 + w2 == MAX_X)
        } Else If (w > MIN_W and not resizedToEdge["Right"]) {
            w2 := Max(w - stepSize, MIN_W) ; Reduce width from the left
            x2 := Min(x + w - w2, MAX_X - MIN_W + 3 * PADDING_X)
        }
    }

    If (x != x2 or y != y2 or w != w2 or h != h2) {
        windowRects[hwnd + 0] := [x, y, w, h, isMaximized]
        SetWinDelay, 10 ; Default delay is 100, makes continuous action slow
        If isMaximized
            WinRestore, A
        If (w2 >= MAX_W and h2 >= MAX_H and x2 == MIN_X and y2 == MIN_Y)
            WinMaximize, A
        Else
            WinMove A,, x2, y2, w2, h2
    }
    lastResizeTickCount := A_TickCount
    Return


; Resize foreground window to screen edge in arrow direction.
WK_WindowResizeToEdge:
    SysGet, workarea, MonitorWorkArea ; Creates workareaLeft, workAreaTop etc
    WinGet, hwnd, ID, A
    WinGet, isMaximized, MinMax, A
    WinGetPos, x, y, w, h, A
    keystate := WK_Keystate()
    MIN_X := workareaLeft + PADDING_X
    MIN_Y := workareaTop + PADDING_Y
    MAX_X := workareaRight - PADDING_X
    MAX_Y := workareaBottom - PADDING_Y
    x2 := x, y2 = y, w2 = w, h2 = h

    If keystate["Up"] {
        If (y > MIN_Y) { ; Expand to top
            y2 := MIN_Y, h2 = y + h - MIN_Y
            resizedRects["Up"] := [x, y, w, h, isMaximized]
        } Else If resizedRects["Up"] { ; Toggle back down
            rect := resizedRects["Up"]
            y2 := resizedRects["Up"][2], h2 = resizedRects["Up"][4]
        }
    } Else If keystate["Down"] {
        If (y + h < MAX_Y) { ; Expand to bottom
            h2 := MAX_Y - y
            resizedRects["Down"] := [x, y, w, h, isMaximized]
        } Else If resizedRects["Down"] { ; Toggle back up
            rect := resizedRects["Down"]
            y2 := resizedRects["Down"][2], h2 = resizedRects["Down"][4]
        }
    } Else If keystate["Left"] {
        If (x > MIN_X) { ; Expand to left
            x2 := MIN_X, w2 = x + w - MIN_X
            resizedRects["Left"] := [x, y, w, h, isMaximized]
        } Else If resizedRects["Left"] { ; Toggle back right
            rect := resizedRects["Left"]
            x2 := resizedRects["Left"][1], w2 = resizedRects["Left"][3]
        }
    } Else If keystate["Right"] {
        If (x + w < MAX_X) { ; Expand to right
            w2 := MAX_X - x
            resizedRects["Right"] := [x, y, w, h, isMaximized]
        } Else If resizedRects["Right"] { ; Toggle back left
            rect := resizedRects["Right"]
            x2 := resizedRects["Right"][1], w2 = resizedRects["Right"][3]
        }
    }

    If (x != x2 or y != y2 or w != w2 or h != h2) {
        windowRects[hwnd + 0] := [x, y, w, h, isMaximized]
        SetWinDelay, 10 ; Default delay is 100, makes continuous action slow
        If isMaximized
            WinRestore, A
        If (w2 >= MAX_W and h2 >= MAX_H and x2 == MIN_X and y2 == MIN_Y)
            WinMaximize, A
        Else
            WinMove A,, x2, y2, w2, h2
    }
    Return


WK_Menu_About:
    Gui, Destroy
    Gui, Add, Picture, x10 y10 w32 h32, %ICON_FILE%
    Gui, Add, Text, x50 y21, %ABOUT_INTRO%
    Gui, Add, Text, x12 y+20, %ABOUT_TEXT%
    StringReplace, linkLabel, HOMEPAGE, https://
    Gui, Add, Text, x290 y+-13 cBlue gWK_OpenHomepage +Right, %linkLabel%
    Gui, Add, Button, x200 y+20 w70 gGuiEscape, OK
    Gui -0x10000 -0x20000 ; Remove maximize and minimize button
    Gui, Color, white
    Gui, Show,, %TITLE%
    Return


WK_Menu_Grid:
    SendInput !{TAB} ; Alt-Tab to previous active window
    thisHotkey := "#" . A_ThisMenuItemPos
    GoSub, WK_WindowGrid
    Return


WK_Menu_Edge:
    SendInput !{TAB} ; Alt-Tab to previous active window
    thisHotkey := ["Left", "Up", "Right", "Down"][A_ThisMenuItemPos]
    GoSub, WK_WindowEdge
    Return


WK_Menu_Toggle_Startup:
    SendInput !{TAB} ; Alt-Tab to previous active window
    link = %A_Startup%\%TITLE%.lnk 
    action := FileExist(link) ? "Removed " TITLE " from" : "Added " TITLE " to"
    IfExist, %link%
        FileDelete, %link%
    Else
        FileCreateShortcut, %A_ScriptFullPath%, %link%, %A_ScriptDir%,,
                          , %ICON_FILE%
    Menu, Tray, ToggleCheck, &Start with Windows
    Sleep, 500
    TrayTip, %TITLE%, %action% Windows startup.
    Return


WK_Menu_Toggle_Hotkeys:
    SendInput !{TAB} ; Alt-Tab to previous active window
    GoSub, WK_Toggle_Hotkeys
    Return


WK_Toggle_Hotkeys:
    Suspend, Toggle
    Menu, Tray, ToggleCheck, &Disable hotkeys
    hovertip := TITLE . (A_IsSuspended ? " (disabled)" : "")
    traytip := "Global hotkeys " . (A_IsSuspended ? "disabled." : "enabled.")
    Menu, Tray, Tip, %hovertip%
    Sleep, 500
    TrayTip, %TITLE%, %traytip%
    Return


WK_OpenHomepage:
    Run, %HOMEPAGE%
    Return


WK_Menu_Exit:
    SendInput !{TAB} ; Alt-Tab to previous active window
    GoSub, WK_Exit
    Return


WK_Exit:
    Menu, Tray, NoIcon
    ExitApp
    Return


GuiEscape:
    Gui, Destroy
    Return


; Return current state for arrow keys, like {"Up": True, }.
WK_Keystate() {
    global thisHotkey
    keystate := {}
    If thisHotkey contains Down
        keystate["Down"] := true
    If GetKeyState("Down") or GetKeyState("NumpadDown")
        keystate["Down"] := true
    If thisHotkey contains Up
        keystate["Up"] := true
    If GetKeyState("Up") or GetKeyState("NumpadUp")
        keystate["Up"] := true
    If thisHotkey contains Left
        keystate["Left"] := true
    If GetKeyState("Left") or GetKeyState("NumpadLeft")
        keystate["Left"] := true
    If thisHotkey contains Right
        keystate["Right"] := true
    If GetKeyState("Right") or GetKeyState("NumpadRight")
        keystate["Right"] := true

    Return keystate
}


Min(x, x1="", x2="", x3="", x4="", x5="", x6="", x7="", x8="", x9="") {
   Loop
      IfEqual x%A_Index%,, Return x
      Else x := x < x%A_Index% ? x : x%A_Index%
}


Max(x, x1="", x2="", x3="", x4="", x5="", x6="", x7="", x8="", x9="") {
   Loop
      IfEqual x%A_Index%,, Return x
      Else x := x > x%A_Index% ? x : x%A_Index%
}
