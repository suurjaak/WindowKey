/**
 * AutoHotkey script for changing active window position and size with
 * global Windows hotkeys. 
 *
 * Hotkeys:
 * Win+Ctrl+Left/Right/Up/Down  move window left/right/up/down
 * Win+Alt+Left/Right/Up/Down   snap window to left/right/top/bottom edge
 * Win+Ctrl+Shift+Left          reduce width, or expand left if at screen
 *                              right edge
 * Win+Ctrl+Shift+Right         expand width, or reduce from left if at screen
 *                              right edge
 * Win+Ctrl+Shift+Up            reduce height, or expand up if at screen
 *                              bottom edge
 * Win+Ctrl+Shift+Down          expand height, or reduce from top if at screen
 *                              bottom edge
 * Win+number                   move and size window to numbered grid position
 * Win+Ctrl+A                   toggle window always on top
 * Win+F10                      exit program
 * 
 * Grid hotkeys:
 * Win+1                        left edge, third of screen width, full height
 * Win+2                        left edge, 2/5 of screen width, full height
 * Win+3                        left edge, half of screen width, full height
 * Win+4                        left edge, 3/5 of screen width, full height
 * Win+5                        left edge, 2/3 of screen width, full height
 * Win+6                        left edge, 4/5 of screen width, full height
 * Win+7                        right edge, 2/5 of screen width, full height
 * Win+8                        right edge, third of screen width, full height
 * Win+9                        top right, third of screen width,
 *                              half of screen height
 * Win+0                        restore window previous position and size
 * 
 * 
 * Released under the MIT License.
 * 
 * @author    Erki Suurjaak
 * @created   03.01.2014
 * @modified  08.01.2014
 */

; Rate of hotkey activations beyond which a warning dialog will be displayed.
#HotkeyInterval 1 ; Default is 2000 milliseconds
#NoTrayIcon ; Hide initial default icon

global AUTHOR := "Erki Suurjaak"
global TITLE := "WindowKey"
global VERSION := "1.0"
global VERSION_DATE := "08.01.2014"
global HOMEPAGE := "https://github.com/suurjaak/WindowKey"
global STEP_SIZE := 10
global STEP_MOVE := 20
global PADDING_X := -4 ; Window looks best when slightly over screen bounds
global PADDING_Y := -4
global ICON_FILE := A_IsCompiled ? A_ScriptFullPath : (A_ScriptDir . "\Icon.ico")

global windowRects := {} ; Cache of {window handle: (x, y, w, h)} before last change

Menu, Tray, NoStandard
Menu, Tray, Add, &About %TITLE%, WK_Menu_About
Menu, Tray, Add, Go to &homepage, WK_Menu_Homepage
Menu, Tray, Add ; separator
Menu, Tray, Add, &Start with Windows, WK_Menu_Toggle_Startup
Menu, Tray, Add, &Disable hotkeys, WK_Menu_Toggle_Hotkeys
Menu, Tray, Add ; separator
Menu, Tray, Add, E&xit, WK_Exit

Menu, Tray, Default, &About %TITLE%
IfExist, %A_Startup%\%TITLE%.lnk 
    Menu, Tray, Check, &Start with Windows
Menu, Tray, Icon, %ICON_FILE%
Menu, Tray, Icon,,, 1 ; Freeze icon: no autochange on suspending hotkeys
Menu, Tray, Tip, %TITLE% %VERSION%
Return


; Windows+number: Position window to grid area X
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
    GoSub, WK_WindowGrid
    Return


; Alt+Windows+Arrow: Snap window to screen edge in arrow direction
#!Up::
#!Down::
#!Left::
#!Right::
#!NumpadUp::
#!NumpadDown::
#!NumpadLeft::
#!NumpadRight::
    GoSub, WK_WindowEdge
    Return


; Ctrl+Windows+Arrow: Move window one step, straight or diagonally
#^Up::
#^Down::
#^Left::
#^Right::
#^NumpadUp::
#^NumpadDown::
#^NumpadLeft::
#^NumpadRight::
    GoSub, WK_WindowMove
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
    GoSub, WK_WindowResize
    Return


; Ctrl+Windows+A: Toggle window always on top
#^A::
    WinSet, AlwaysOnTop, Toggle, A
    Return


; Windows+F10: Exit program
#F10::
    GoSub, WK_Exit
    Return


;;; Arrange the foreground window to a pre-defined grid.
WK_WindowGrid:
    WinGet, is_maximized, MinMax, A
    WinGet, hwnd, ID, A
    WinGetPos, x, y, w, h, A
    SysGet, workarea, MonitorWorkArea
    hotkey := A_ThisHotkey
    hwndKey := hwnd + 0 ; Convert window handle type to hashable

    if hotkey in #0,#Numpad0
    {
        rect := windowRects[hwndKey]
        ; @todo restore/set maximized
        if rect
            WinMove A,, rect[1], rect[2], rect[3], rect[4]
    } else {
        if is_maximized
            WinRestore, A
        MIN_X := workareaLeft + PADDING_X
        MIN_Y := workareaTop + PADDING_Y
        MAX_W := workareaRight - workareaLeft - 2 * PADDING_X
        MAX_H := workareaBottom - workareaTop - 2 * PADDING_Y
        MAX_R := workareaRight - PADDING_X
        if hotkey contains 1
            rect := [MIN_X, MIN_Y, MAX_W * 1/3, MAX_H]
        else if hotkey contains 2
            rect := [MIN_X, MIN_Y, MAX_W * 2/5, MAX_H]
        else if hotkey contains 3
            rect := [MIN_X, MIN_Y, MAX_W * 1/2, MAX_H]
        else if hotkey contains 4
            rect := [MIN_X, MIN_Y, MAX_W * 3/5, MAX_H]
        else if hotkey contains 5
            rect := [MIN_X, MIN_Y, MAX_W * 2/3, MAX_H]
        else if hotkey contains 6
            rect := [MIN_X, MIN_Y, MAX_W * 4/5, MAX_H]
        else if hotkey contains 7
            rect := [MAX_R - MAX_W * 2/5, MIN_Y, MAX_W * 2/5, MAX_H]
        else if hotkey contains 8
            rect := [MAX_R - MAX_W * 1/3, MIN_Y, MAX_W * 1/3, MAX_H]
        else if hotkey contains 9
            rect := [MAX_R - MAX_W * 1/3, MIN_Y, MAX_W * 1/3, MAX_H * 1/2]
        WinMove A,, rect[1], rect[2], rect[3], rect[4]
    }
    windowRects[hwndKey] := [x, y, w, h]
    Return



;;; Snap foreground window to one screen edge.
WK_WindowEdge:
    SysGet, workarea, MonitorWorkArea
    WinGet, hwnd, ID, A
    WinGetPos, x, y, w, h, A
    MIN_X := workareaLeft + PADDING_X
    MIN_Y := workareaTop + PADDING_Y
    MAX_X := workareaRight - PADDING_X
    MAX_Y := workareaBottom - PADDING_Y
    keystate := WK_Keystate()
    isChanged := false

    if keystate["Up"] { ; Snap to top
        if (y > MIN_Y) {
            y := MIN_Y
            isChanged := true
        }
    } else if keystate["Down"] { ; Snap to bottom
        if (y + h < workareaBottom - PADDING_Y) {
            y := workareaBottom - PADDING_Y - h
            isChanged := true
        } else if (y + h => workareaBottom) { ; Taskbar edge: go to screen edge
            y := A_ScreenHeight - h - MIN_Y
            isChanged := true
        }
    } else if keystate["Left"] { ; Snap to left
        if (x > MIN_X) {
            x := MIN_X
            isChanged := true
        }
    } else if keystate["Right"] { ; Snap to right
        if (x + w < MAX_X) {
            x := MAX_X - w
            isChanged := true
        }
    }
    if isChanged {
        SetWinDelay, 10 ; Default delay is 100, makes continuous action slow
        WinMove A,, x, y, w, h
        windowRects[hwnd + 0] := [x, y, w, h]
    }
    Return


;;; Move the foreground window one step, straight or diagonally.
WK_WindowMove:
    SysGet, workarea, MonitorWorkArea
    WinGet, hwnd, ID, A
    WinGetPos, x, y, w, h, A
    MIN_X := workareaLeft + PADDING_X
    MIN_Y := workareaTop + PADDING_Y
    MAX_X := workareaRight - PADDING_X
    MAX_Y := workareaBottom - PADDING_Y
    keystate := WK_Keystate()
    isChanged := false

    if keystate["Up"] { ; Move up
        if (y > MIN_Y) {
            y := Max(y - STEP_MOVE, MIN_Y)
            isChanged := true
        }
    } else if keystate["Down"] { ; Move down
        if (y + h < MAX_Y) {
            y := Min(y + STEP_MOVE, MAX_Y)
            isChanged := true
        }
    }
    ; Move diagonally if two arrow keys are down
    if keystate["Left"] { ; Move left
        if (x > MIN_X) {
            x := Max(x - STEP_MOVE, MIN_X)
            isChanged := true
        }
    } else if keystate["Right"] { ; Move right
        if (x + w < MAX_X) {
            x := Min(x + STEP_MOVE, MAX_X - w)
            isChanged := true
        }
    }
    if isChanged {
        SetWinDelay, 10 ; Default delay is 100, makes continuous action slow
        WinMove A,, x, y, w, h
        windowRects[hwnd + 0] := [x, y, w, h]
    }
    Return


;;; Resize foreground window one step, straight or diagonally.
WK_WindowResize:
    SysGet, workarea, MonitorWorkArea
    WinGet, hwnd, ID, A
    WinGetPos, x, y, w, h, A
    MIN_W := 100
    MIN_H := 100
    MIN_X := workareaLeft + PADDING_X
    MIN_Y := workareaTop + PADDING_Y
    MAX_W := workareaRight - workareaLeft - 2 * PADDING_X
    MAX_X := workareaRight - PADDING_X
    MAX_Y := workareaBottom - PADDING_Y
    keystate := WK_Keystate()
    isChanged := false

    if keystate["Up"] {
        if (y + h >= MAX_Y and y > MIN_Y) {
            ; At screen bottom: increase window height above
            new_y := Max(y - STEP_SIZE, MIN_Y)
            h := h + y - new_y
            y := new_y
            isChanged := true
        } else if (h > MIN_H) { ; Decrease window height below
            h := h - STEP_SIZE
            isChanged := true
        }
    } else if keystate["Down"] {
        if (y + h < MAX_Y) { ; Increase window height below
            h := Min(h + STEP_SIZE, MAX_Y - y)
            isChanged := true
        } else if (h > MIN_H) { ; Decrease window height above
            y := y + STEP_SIZE
            h := h - STEP_SIZE
            isChanged := true
        }
    }
    ; Size diagonally if two arrow keys are down
    if keystate["Left"] {
        if (w == MAX_W) { ; Decrease window width from right
            w := w - STEP_SIZE
            isChanged := true
        } else if (x + w >= MAX_X) { ; Increase window width to the left
            new_x := Max(x - STEP_SIZE, MIN_X)
            w := w + x - new_x
            x := new_x
            isChanged := true
        } else if (w > MIN_W) { ; Decrease window width from right
            w := w - STEP_SIZE
            isChanged := true
        }
    } else if keystate["Right"] {
        if (x + w < MAX_X) { ; Increase window width to the right
            w := Min(w + STEP_SIZE, MAX_X - x)
            isChanged := true
        } else if (w > MIN_W) { ; Decrease window width from left
            new_w := Max(w - STEP_SIZE, MIN_W)
            x := x + w - new_w
            w := new_w
            isChanged := true
        }
    }
    if isChanged {
        SetWinDelay, 10 ; Default delay is 100, makes continuous action slow
        WinMove A,, x, y, w, h
        windowRects[hwnd + 0] := [x, y, w, h]
    }
    Return


;;; Returns arrow keystates as {Up: True, Down: False, ..Left ..Right}
WK_Keystate() {
    keystate := {}
    hotkey := A_ThisHotkey
    if hotkey contains Down
        keystate["Down"] := true
    if GetKeyState("Down") or GetKeyState("NumpadDown")
        keystate["Down"] := true
    if hotkey contains Up
        keystate["Up"] := true
    if GetKeyState("Up") or GetKeyState("NumpadUp")
        keystate["Up"] := true
    if hotkey contains Left
        keystate["Left"] := true
    if GetKeyState("Left") or GetKeyState("NumpadLeft")
        keystate["Left"] := true
    if hotkey contains Right
        keystate["Right"] := true
    if GetKeyState("Right") or GetKeyState("NumpadRight")
        keystate["Right"] := true

    Return keystate
}


WK_Menu_About:
    Msgbox,, %TITLE%,
    (LTrim
    Small tray program for changing active window position and size with global Windows hotkeys.

    Hotkeys:

    Win+Ctrl+arrow `t`t move window left/right/up/down
    Win+Alt+arrow `t`t snap window to left/right/top/bottom edge
    Win+Ctrl+Shift+arrow `t resize window to/from arrow direction
    Win+Ctrl+A `t`t toggle window always on top
    Win+F10 `t`t`t exit program
    Win 1 `t`t`t left edge, third of screen width, full height
    Win 2 `t`t`t left edge, 2/5 of screen width, full height
    Win 3 `t`t`t left edge, half of screen width, full height
    Win 4 `t`t`t left edge, 3/5 of screen width, full height
    Win 5 `t`t`t left edge, 2/3 of screen width, full height
    Win 6 `t`t`t left edge, 4/5 of screen width, full height
    Win 7 `t`t`t right edge, 2/5 of screen width, full height
    Win 8 `t`t`t right edge, third of screen width, full height
    Win 9 `t`t`t top right, third of screen width, half of screen height
    Win 0 `t`t`t restore window previous position and size

    © %AUTHOR%. Version %VERSION%, %VERSION_DATE%. Written with AutoHotkey.
    )
    Return


WK_Menu_Homepage:
    Run, %HOMEPAGE%
    Return


WK_Menu_Toggle_Startup:
    LinkFile = %A_Startup%\%TITLE%.lnk 
    IfExist, %LinkFile%
    {
        FileDelete, %LinkFile%
        Menu, Tray, Uncheck, &Start with Windows
    } else {
        FileCreateShortcut, %A_ScriptFullPath%, %LinkFile%, %A_ScriptDir%,,,%ICON_FILE%
        Menu, Tray, Check, &Start with Windows
    }
    Return


WK_Menu_Toggle_Hotkeys:
    Suspend, Toggle
    Menu, Tray, ToggleCheck, &Disable hotkeys
    Return


WK_Exit:
    Menu, Tray, NoIcon
    ExitApp
    Return


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
