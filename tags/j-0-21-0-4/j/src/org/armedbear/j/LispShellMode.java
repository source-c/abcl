/*
 * LispShellMode.java
 *
 * Copyright (C) 2002-2003 Peter Graves
 * $Id: LispShellMode.java,v 1.16 2004-10-25 01:44:19 piso Exp $
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

package org.armedbear.j;

import java.awt.event.KeyEvent;

public final class LispShellMode extends LispMode implements Constants, Mode
{
    private static final LispShellMode mode = new LispShellMode();

    protected LispShellMode()
    {
        super(LISP_SHELL_MODE, LISP_SHELL_MODE_NAME);
        setProperty(Property.VERTICAL_RULE, 0);
        setProperty(Property.SHOW_LINE_NUMBERS, false);
        setProperty(Property.SHOW_CHANGE_MARKS, false);
        setProperty(Property.HIGHLIGHT_BRACKETS, true);
        setProperty(Property.INDENT_SIZE, 2);
    }

    public static final Mode getMode()
    {
        return mode;
    }

    public Formatter getFormatter(Buffer buffer)
    {
        return new LispShellFormatter(buffer);
    }

    protected void setKeyMapDefaults(KeyMap km)
    {
        km.mapKey(KeyEvent.VK_HOME, 0, "shellHome");
        km.mapKey(KeyEvent.VK_BACK_SPACE, 0, "shellBackspace");
        km.mapKey(KeyEvent.VK_ESCAPE, 0, "shellEscape");
        km.mapKey(KeyEvent.VK_P, CTRL_MASK, "shellPreviousInput");
        km.mapKey(KeyEvent.VK_N, CTRL_MASK, "shellNextInput");
        km.mapKey(KeyEvent.VK_P, CTRL_MASK | ALT_MASK, "shellPreviousPrompt");
        km.mapKey(KeyEvent.VK_N, CTRL_MASK | ALT_MASK, "shellNextPrompt");
        km.mapKey(KeyEvent.VK_ENTER, 0, "LispShellMode.enter");
        km.mapKey(KeyEvent.VK_ENTER, ALT_MASK, "newlineAndIndent");
        km.mapKey(KeyEvent.VK_R, CTRL_MASK, "resetLisp");
        km.mapKey(KeyEvent.VK_TAB, 0, "indentLineOrRegion");
        km.mapKey(KeyEvent.VK_C, CTRL_MASK | ALT_MASK, "shellInterrupt");
        km.mapKey(KeyEvent.VK_T, CTRL_MASK, "findTag");
        km.mapKey(KeyEvent.VK_F9, CTRL_MASK, "recompile");
        km.mapKey(KeyEvent.VK_F1, ALT_MASK, "hyperspec");
        km.mapKey(KeyEvent.VK_M, CTRL_MASK, "lispFindMatchingChar");
        km.mapKey(KeyEvent.VK_M, CTRL_MASK | SHIFT_MASK, "lispSelectSyntax");
    }

    public void populateModeMenu(Editor editor, Menu menu)
    {
        menu.add(editor, "Reset Lisp", 'L', "resetLisp", true);
        menu.addSeparator();
        menu.add(editor, "Previous Input", 'P', "shellPreviousInput", true);
        menu.add(editor, "Next Input", 'N', "shellNextInput", true);
        menu.add(editor, "Goto Previous Prompt", 'R', "shellPreviousPrompt", true);
        menu.add(editor, "Goto Next Prompt", 'T', "shellNextPrompt", true);
    }

    public boolean isTaggable()
    {
        return false;
    }

    public Tagger getTagger(SystemBuffer buffer)
    {
        return null;
    }

    public boolean acceptsLinePaste(Editor editor)
    {
        if (editor.getBuffer() instanceof LispShell) {
            Position pos = ((LispShell)editor.getBuffer()).getEndOfOutput();
            if (pos != null)
                pos.getLine().setFlags(STATE_INPUT);
        }
        return false;
    }

    public static void enter()
    {
        final Editor editor = Editor.currentEditor();
        final Buffer buffer = editor.getBuffer();
        if (buffer.getMode() != mode) {
            Debug.bug();
            return;
        }
        if (buffer instanceof LispShell)
            ((LispShell)buffer).enter();
        else
            Debug.bug();
    }

    public static void electricCloseParen()
    {
        final Editor editor = Editor.currentEditor();
        final Buffer buffer = editor.getBuffer();
        if (buffer.getMode() != mode) {
            Debug.bug();
            return;
        }
        if (buffer instanceof LispShell)
            ((LispShell)buffer).electricCloseParen();
        else
            Debug.bug();
    }

    public static void resetLisp()
    {
        final Editor editor = Editor.currentEditor();
        final Buffer buffer = editor.getBuffer();
        if (buffer.getMode() != mode) {
            Debug.bug();
            return;
        }
        if (buffer instanceof LispShell)
            ((LispShell)buffer).resetLisp();
        else if (buffer instanceof JLisp)
            ;
        else
            Debug.bug();
    }
}
