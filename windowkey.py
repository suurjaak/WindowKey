# -*- coding: utf-8 -*-
"""
Background script for changing active window position and size with
global Windows hotkeys. 

Hotkeys:
- Win Alt        + Left/Right/Up/Down  move window one step left/right/up/down
- Win Ctrl       + Left/Right/Up/Down  snap window to left/right/top/bottom edge
- Win Ctrl Shift + Left/Down           increase window width/height
- Win Ctrl Shift + Right/Up            decrease window width/height
- Win            + Numpad X            move and size window to grid position X
- Win            + F10                 exit program

Grid hotkeys:
- Win + Numpad 1    left edge, third of screen width, full height
- Win + Numpad 2    left edge, 2/5 of screen width, full height
- Win + Numpad 3    left edge, half of screen width, full height
- Win + Numpad 4    left edge, 3/5 of screen width, full height
- Win + Numpad 5    maximize window
- Win + Numpad 6    right edge, half of screen width, full height
- Win + Numpad 7    right edge, 2/5 of screen width, full height
- Win + Numpad 8    right edge, third of screen width, full height
- Win + Numpad 9    top right, third of screen width, half of screen height
- Win + Numpad 0    restore window previous position and size


Released under the MIT License.

@author      Erki Suurjaak
@created     28.12.2013
@modified    30.12.2013
------------------------------------------------------------------------------
"""
import os
import ctypes
import ctypes.wintypes
import sys
import win32con

STEP = 10  # Move and size step, in pixels
MIN_X = -4 # Window top left looks best when slightly out of screen bounds
MIN_Y = -4

user32 = ctypes.windll.user32
window_rects = {} # Cache of {window handle: (x, y, w, h)} before last change


"""
user32.dll functions used:

GetSystemMetrics(SM_CXSCREEN|SM_CYSCREEN|SM_CXMIN|SM_CYMIN)
SystemParametersInfoA(SPI_GETWORKAREA, 0, rect, 0)  desktop work area
GetKeyState(VK_*)  bit mask of pressed and toggled key state
GetForegroundWindow()  foreground window handle (hwnd)
IsZoomed(hwnd)  is window maximized
ShowWindow(hwnd, SW_MAXIMIZE|SW_RESTORE)  maximize or restore window
MoveWindow(hwnd, x, y, w, h, do_repaint)  move and size window
"""

def get_state(key=None):
    """
    Returns foreground window handle, (foreground window x, y, w, h),
            (desktop area left, top, right, bottom), {arrow-key pressed states}
    """
    rect = ctypes.wintypes.RECT()
    user32.SystemParametersInfoA(win32con.SPI_GETWORKAREA, 0, ctypes.byref(rect), 0)
    workarea = [rect.left, rect.top, rect.right, rect.bottom]

    # Combine current key-press with other arrow keys being pressed
    ARROWS = (win32con.VK_UP, win32con.VK_DOWN, win32con.VK_LEFT, win32con.VK_RIGHT)
    keydown = dict((k, k == key) for k in ARROWS)
    keystates = zip(ARROWS, map(user32.GetKeyState, ARROWS))
    keydown.update((k, True) for k, s in keystates if s in [-127, -128])

    hwnd = user32.GetForegroundWindow()
    user32.GetWindowRect(hwnd, ctypes.byref(rect))
    x, y, w, h = (rect.left, rect.top, rect.right - rect.left, rect.bottom - rect.top)
    return hwnd, (x, y, w, h), workarea, keydown


def window_grid(key):
    """Arranges the foreground window by a pre-defined grid."""
    global window_rects
    hwnd, (x, y, w, h), workarea, keydown = get_state()
    window_rect = (x, y, w, h)

    MAX_W = workarea[2] - workarea[0]
    MAX_H = workarea[3] - workarea[1] - 2 * MIN_Y
    MAX_R = workarea[2] - MIN_X
    grid_areas = {
        win32con.VK_NUMPAD1: (MIN_X, MIN_Y, MAX_W / 3, MAX_H),
        win32con.VK_NUMPAD2: (MIN_X, MIN_Y, MAX_W * 2/5, MAX_H),
        win32con.VK_NUMPAD3: (MIN_X, MIN_Y, MAX_W / 2, MAX_H),
        win32con.VK_NUMPAD4: (MIN_X, MIN_Y, MAX_W * 3/5, MAX_H),
        win32con.VK_NUMPAD6: (MAX_R - MAX_W / 2, MIN_Y, MAX_W / 2, MAX_H),
        win32con.VK_NUMPAD7: (MAX_R - MAX_W * 2/5, MIN_Y, MAX_W * 2/5, MAX_H),
        win32con.VK_NUMPAD8: (MAX_R - MAX_W / 3, MIN_Y, MAX_W / 3, MAX_H),
        win32con.VK_NUMPAD9: (MAX_R - MAX_W / 3, MIN_Y, MAX_W / 3, MAX_H / 2),
    }

    if key in grid_areas:
        x, y, w, h = grid_areas[key]
        if user32.IsZoomed(hwnd): # Clear maximized flag
            user32.ShowWindow(hwnd, win32con.SW_RESTORE)
        user32.MoveWindow(hwnd, x, y, w, h, True)
    elif win32con.VK_NUMPAD5 == key: # Maximize window
        action = win32con.SW_RESTORE if user32.IsZoomed(hwnd) \
                 else win32con.SW_MAXIMIZE
        user32.ShowWindow(hwnd, action)
    elif win32con.VK_NUMPAD0 == key: # Restore last size and position
        if hwnd in window_rects:
            x, y, w, h = window_rects[hwnd]
            if user32.IsZoomed(hwnd): # Clear maximized flag
                user32.ShowWindow(hwnd, win32con.SW_RESTORE)
            user32.MoveWindow(hwnd, x, y, w, h, True)
    # @todo flag maximized state somehow
    window_rects[hwnd] = window_rect


def window_move(key):
    """Moves the foreground window one step, straight or diagonally."""
    global window_rects
    hwnd, window_rect, workarea, keydown = get_state(key)
    x, y, w, h = window_rect

    if keydown[win32con.VK_UP]: # Move up, if possible
        if y - MIN_Y > workarea[1]:
            y = max(MIN_Y, y - STEP)
    elif keydown[win32con.VK_DOWN]: # Move down
        if y + h - MIN_Y < workarea[3]:
            y = min(workarea[3] - MIN_Y, y + STEP)
    # Move diagonally if two arrow keys are down
    if keydown[win32con.VK_LEFT]: # Move left
        x = max(MIN_X, x - STEP)
    elif keydown[win32con.VK_RIGHT]: # Move right
        if x + w - MIN_X < workarea[2]:
            x = min(workarea[2] - MIN_X, x + STEP)
    if (x, y, w, h) != window_rect:
        user32.MoveWindow(hwnd, x, y, w, h, True) # Last bool argument: repaint
        window_rects[hwnd] = window_rect


def window_edge(key):
    """Snaps foreground window to one screen edge."""
    global window_rects
    hwnd, window_rect, workarea, keydown = get_state(key)
    x, y, w, h = window_rect

    if win32con.VK_UP == key: # Snap to top
        if y > MIN_Y:
            y = MIN_Y
    elif win32con.VK_DOWN == key: # Snap to bottom
        if y + h - MIN_Y < workarea[3]:
            y = workarea[3] - h - MIN_Y
        elif y + h == workarea[3]: # At taskbar bottom: snap to screen bottom
            y = user32.GetSystemMetrics(win32con.SM_CYSCREEN) - h - MIN_Y
    elif win32con.VK_LEFT == key: # Snap to left
        if x > MIN_X:
            x = MIN_X
    elif win32con.VK_RIGHT == key: # Snap to right
        if x - MIN_X < workarea[2]:
            x = workarea[2] - w - MIN_X 
    if (x, y, w, h) != window_rect:
        user32.MoveWindow(hwnd, x, y, w, h, True)
        window_rects[hwnd] = window_rect


def window_size(key):
    """Resizes foreground window one step, straight or diagonally."""
    global window_rects
    hwnd, window_rect, workarea, keydown = get_state(key)
    x, y, w, h = window_rect

    if keydown[win32con.VK_UP]: # Decrease window height from below
        if h > user32.GetSystemMetrics(win32con.SM_CYMIN):
            h = h - STEP
    elif keydown[win32con.VK_DOWN]: # Increase window height below
        if y + h - MIN_Y < workarea[3]:
            h = min(workarea[3] - MIN_Y, h + STEP)
    # Size diagonally if two arrow keys are down
    if keydown[win32con.VK_LEFT]: # Decrease window width from right
        if w > user32.GetSystemMetrics(win32con.SM_CXMIN):
            w = w - STEP
    elif keydown[win32con.VK_RIGHT]: # Increase window width to the right
        if x + w < workarea[2] - MIN_X:
            w = min(workarea[2] - x - MIN_X, w + STEP)
    if (x, y, w, h) != window_rect:
        user32.MoveWindow(hwnd, x, y, w, h, True)
        window_rects[hwnd] = window_rect


def close(key=None):
    sys.exit()


HOTKEYS = {
  # Move one step
  1: (win32con.VK_UP, win32con.MOD_WIN | win32con.MOD_ALT),
  2: (win32con.VK_DOWN, win32con.MOD_WIN | win32con.MOD_ALT),
  3: (win32con.VK_LEFT, win32con.MOD_WIN | win32con.MOD_ALT),
  4: (win32con.VK_RIGHT, win32con.MOD_WIN | win32con.MOD_ALT),

  # Move to screen edge
  5: (win32con.VK_UP, win32con.MOD_WIN | win32con.MOD_CONTROL),
  6: (win32con.VK_DOWN, win32con.MOD_WIN | win32con.MOD_CONTROL),
  7: (win32con.VK_LEFT, win32con.MOD_WIN | win32con.MOD_CONTROL),
  8: (win32con.VK_RIGHT, win32con.MOD_WIN | win32con.MOD_CONTROL),

  # Resize lower/higher/narrower/wider
  9: (win32con.VK_UP, win32con.MOD_WIN | win32con.MOD_CONTROL | win32con.MOD_SHIFT),
 10: (win32con.VK_DOWN, win32con.MOD_WIN | win32con.MOD_CONTROL | win32con.MOD_SHIFT),
 11: (win32con.VK_LEFT, win32con.MOD_WIN | win32con.MOD_CONTROL | win32con.MOD_SHIFT),
 12: (win32con.VK_RIGHT, win32con.MOD_WIN | win32con.MOD_CONTROL | win32con.MOD_SHIFT),

  # Move and size to grid
 13: (win32con.VK_NUMPAD1, win32con.MOD_WIN),
 14: (win32con.VK_NUMPAD2, win32con.MOD_WIN),
 15: (win32con.VK_NUMPAD3, win32con.MOD_WIN),
 16: (win32con.VK_NUMPAD4, win32con.MOD_WIN),
 17: (win32con.VK_NUMPAD5, win32con.MOD_WIN),
 18: (win32con.VK_NUMPAD6, win32con.MOD_WIN),
 19: (win32con.VK_NUMPAD7, win32con.MOD_WIN),
 20: (win32con.VK_NUMPAD8, win32con.MOD_WIN),
 21: (win32con.VK_NUMPAD9, win32con.MOD_WIN),
 22: (win32con.VK_NUMPAD0, win32con.MOD_WIN),

 99: (win32con.VK_F10, win32con.MOD_WIN),
}


HOTKEY_ACTIONS = {
  1: window_move, 2: window_move, 3: window_move, 4: window_move,

  5: window_edge, 6: window_edge, 7: window_edge, 8: window_edge,

  9: window_size, 10: window_size, 11: window_size, 12: window_size,

 13: window_grid, 14: window_grid, 15: window_grid, 16: window_grid,
 17: window_grid, 18: window_grid, 19: window_grid, 20: window_grid,
 21: window_grid, 22: window_grid,

 99: close,
}


def keyhandler_loop():
    for id, (vk, modifiers) in HOTKEYS.items():
        print("Registering hotkey %3d with modifier %2d for action %s." % (vk, modifiers, HOTKEY_ACTIONS.get(id)))
        if not user32.RegisterHotKey(None, id, modifiers, vk):
            print("Unable to register %3d with modifier %2d at id %s." % (vk, modifiers, id))
    print("Press Win + F10 to exit program.")

    try:
        msg = ctypes.wintypes.MSG()
        while user32.GetMessageA(ctypes.byref(msg), None, 0, 0) != 0:
            if msg.message == win32con.WM_HOTKEY:
                if msg.wParam in HOTKEY_ACTIONS:
                    HOTKEY_ACTIONS[msg.wParam](key=HOTKEYS[msg.wParam][0])
            # Post character messages to queue, create message loop.
            user32.TranslateMessage(ctypes.byref(msg))
            user32.DispatchMessageA(ctypes.byref(msg))
    finally:
        for id in HOTKEYS.keys():
            user32.UnregisterHotKey(None, id)


if "__main__" == __name__:
    keyhandler_loop()
