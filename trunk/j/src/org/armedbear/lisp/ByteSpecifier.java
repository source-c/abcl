/*
 * ByteSpecifier.java
 *
 * Copyright (C) 2003 Peter Graves
 * $Id: ByteSpecifier.java,v 1.1 2003-09-10 18:44:05 piso Exp $
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

package org.armedbear.lisp;

public final class ByteSpecifier extends LispObject
{
    private LispObject size;
    private LispObject position;

    public ByteSpecifier(LispObject size, LispObject position) throws TypeError
    {
        this.size = size;
        this.position = position;
        if (!size.integerp() || size.minusp())
            throw new TypeError(size, "non-negative integer");
        if (!position.integerp() || position.minusp())
            throw new TypeError(position, "non-negative integer");
    }
}
