/*
 * LispMode.java
 *
 * Copyright (C) 1998-2002 Peter Graves
 * $Id: LispMode.java,v 1.14 2002-11-09 19:19:56 piso Exp $
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

public class LispMode extends AbstractMode implements Constants, Mode
{
    private static final LispMode mode = new LispMode();

    private LispMode()
    {
        super(LISP_MODE, LISP_MODE_NAME);
        keywords = new Keywords(this);
        setProperty(Property.INDENT_SIZE, 2);
    }

    protected LispMode(int id, String displayName)
    {
        super(id, displayName);
    }

    public static Mode getMode()
    {
        return mode;
    }

    public String getCommentStart()
    {
        return ";; ";
    }

    public final SyntaxIterator getSyntaxIterator(Position pos)
    {
        return new LispSyntaxIterator(pos);
    }

    public Formatter getFormatter(Buffer buffer)
    {
        return new LispFormatter(buffer);
    }

    protected void setKeyMapDefaults(KeyMap km)
    {
        km.mapKey(KeyEvent.VK_TAB, 0, "tab");
        km.mapKey(KeyEvent.VK_ENTER, 0, "newlineAndIndent");
        km.mapKey(KeyEvent.VK_T, CTRL_MASK, "findTag");
        km.mapKey(KeyEvent.VK_PERIOD, ALT_MASK, "findTagAtDot");
        km.mapKey(KeyEvent.VK_L, CTRL_MASK | SHIFT_MASK, "listTags");
        km.mapKey(')', "closeParen");
    }

    public boolean isTaggable()
    {
        return true;
    }

    public Tagger getTagger(SystemBuffer buffer)
    {
        return new LispTagger(buffer);
    }

    private static final String validChars =
        "!$%&*+-./0123456789:<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_abcdefghijklmnopqrstuvwxyz{}~";

    public final boolean isIdentifierStart(char c)
    {
        return validChars.indexOf(c) >= 0;
    }

    public final boolean isIdentifierPart(char c)
    {
        return validChars.indexOf(c) >= 0;
    }

    public boolean isInQuote(Buffer buffer, Position pos)
    {
        // This implementation only considers the current line.
        final Line line = pos.getLine();
        final int offset = pos.getOffset();
        boolean inQuote = false;
        for (int i = 0; i < offset; i++) {
            char c = line.charAt(i);
            if (c == '\\') {
                // Escape.
                ++i;
            } else if (inQuote) {
                if (c == '"')
                    inQuote = false;
            } else if (c == '"') {
                inQuote = true;
            }
        }
        return inQuote;
    }

    public boolean canIndent()
    {
        return true;
    }

    private final String[] specials = new String[] {
        "case", "ecase", "do", "do*", "dolist", "dotimes", "flet", "lambda",
        "let", "let*", "loop", "progn", "typecase", "unless", "when"
    };

    private final String[] elispSpecials = new String[] {
        "while"
    };

    private final String[] hemlockSpecials = new String[] {
        "frob", "with-mark"
    };

    public int getCorrectIndentation(Line line, Buffer buffer)
    {
        final Line model = findModel(line);
        if (model == null)
            return 0;
        final int modelIndent = buffer.getIndentation(model);
        final String modelTrim = model.trim();
        if (line.flags() == STATE_QUOTE) {
            if (modelTrim.length() > 0 && modelTrim.charAt(0) == '"')
                return modelIndent + 1;
            else
                return modelIndent;
        }
        if (modelTrim.length() == 0)
            return 0;
        if (modelTrim.charAt(0) == ';')
            return modelIndent;
        final int indentSize = buffer.getIndentSize();
        Position pos = findContainingSexp(new Position(line, 0));
        if (pos != null) {
            SyntaxIterator it = getSyntaxIterator(pos);
            while (true) {
                char c = it.nextChar();
                if (Character.isWhitespace(c))
                    continue;
                if (c == '(') {
                    // First element of containing sexp is a list. Indent
                    // under that list.
                    return buffer.getCol(it.getPosition());
                }
                // Otherwise...
                String token = gatherToken(it.getPosition());
                if (token.startsWith("def"))
                    return buffer.getCol(pos) + indentSize;
                if (Utilities.isOneOf(token, specials))
                    return buffer.getCol(pos) + indentSize;
                if (Utilities.isOneOf(token, elispSpecials))
                    return buffer.getCol(pos) + indentSize;
                if (Utilities.isOneOf(token, hemlockSpecials))
                    return buffer.getCol(pos) + indentSize;
                Position next = forwardSexp(pos);
                if (next != null && next.getLine() == pos.getLine())
                    return buffer.getCol(next);
                return buffer.getCol(pos) + 1;
            }
        }
        return 0;
    }

    private static Line findModel(Line line)
    {
        Line model = line.previous();
        if (line.flags() == STATE_COMMENT) {
            // Any non-blank line is an acceptable model.
            while (model != null && model.isBlank())
                model = model.previous();
        } else {
            while (model != null) {
                if (isAcceptableModel(model))
                    break; // Found an acceptable model.
                else
                    model = model.previous();
            }
        }
        return model;
    }

    private static boolean isAcceptableModel(Line model)
    {
        String trim = model.trim();
        if (trim.length() == 0)
            return false;
        if (trim.charAt(0) == ';')
            return false;
        return true;
    }

    private String gatherToken(Position pos)
    {
        FastStringBuffer sb = new FastStringBuffer();
        while (true) {
            char c = pos.getChar();
            if (Character.isWhitespace(c))
                break;
            sb.append(c);
            if (!pos.next())
                break;
        }
        return sb.toString();
    }

    private int depth(Line line, Buffer buffer)
    {
        if (buffer.needsRenumbering())
            buffer.renumber();
        Position pos = new Position(line, 0);
        Position start = findStartOfDefun(pos);
        if (pos.equals(start))
            return 0;
        SyntaxIterator it = getSyntaxIterator(start);
        int depth = 1;
        while (true) {
            char c = it.nextChar();
            if (!it.getPosition().isBefore(pos))
                break;
            if (c == '(')
                ++depth;
            else if (c == ')')
                --depth;
        }
        return depth;
    }

    private static Position findStartOfDefun(Position pos)
    {
        Line line = pos.getLine();
        while (true) {
            if (line.getText().startsWith("(def"))
                return new Position(line, 0);
            Line prev = line.previous();
            if (prev == null)
                return new Position(line, 0);
            line = prev;
        }
    }

    protected Position findContainingSexp(Position start)
    {
        SyntaxIterator it = getSyntaxIterator(start);
        int parenCount = 0;
        while (true) {
            switch (it.prevChar()) {
                case ')':
                    ++parenCount;
                    break;
                case '(':
                    if (parenCount == 0)
                        return it.getPosition(); // Found unmatched '('.
                    if (it.getPosition().getOffset() == 0)
                        return null;
                    --parenCount;
                    break;
                case SyntaxIterator.DONE:
                    return null;
                default:
                    break;
            }
        }
    }

    protected Position forwardSexp(Position start)
    {
        // Skip to whitespace.
        Position pos = start.copy();
        while (pos.next()) {
            char c = pos.getChar();
            if (Character.isWhitespace(c))
                break;
        }
        // Skip whitespace.
        while (pos.next()) {
            char c = pos.getChar();
            if (!Character.isWhitespace(c))
                break;
        }
        return pos;
    }
}
