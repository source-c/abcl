/*
 * AtomicTypeSpecifier.java
 *
 * Copyright (C) 2003 Peter Graves
 * $Id: AtomicTypeSpecifier.java,v 1.7 2003-09-17 18:26:06 piso Exp $
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

public class AtomicTypeSpecifier extends TypeSpecifier
{
    private final Type type;

    public AtomicTypeSpecifier(Symbol symbol) throws LispError
    {
        type = Type.getInstance(symbol);
    }

    public final Type TYPE()
    {
        return type;
    }

//     public LispObject test(LispObject obj) throws LispError
//     {
//         throw new LispError(String.valueOf(getClass()) +
//                             ".test(): not implemented");
//     }
}
