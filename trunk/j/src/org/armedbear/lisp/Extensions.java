/*
 * Extensions.java
 *
 * Copyright (C) 2002-2003 Peter Graves
 * $Id: Extensions.java,v 1.12 2003-09-24 22:53:30 piso Exp $
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

import java.net.Socket;

public final class Extensions extends Lisp
{
    // ### special-variable-p
    private static final Primitive1 SPECIAL_VARIABLE_P =
        new Primitive1("special-variable-p", PACKAGE_EXT, true) {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.isSpecialVariable() ? T : NIL;
        }
    };

    // ### charpos
    // charpos stream => position
    private static final Primitive1 CHARPOS =
        new Primitive1("charpos", PACKAGE_EXT, true) {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            if (arg instanceof CharacterOutputStream)
                return new Fixnum(((CharacterOutputStream)arg).getCharPos());
            throw new ConditionThrowable(new TypeError(arg, "character output stream"));
        }
    };

    // ### %set-charpos
    // %set-charpos stream newval => newval
    private static final Primitive2 _SET_CHARPOS =
        new Primitive2("%set-charpos", PACKAGE_SYS, false)
    {
        public LispObject execute(LispObject first, LispObject second)
            throws ConditionThrowable
        {
            if (first instanceof CharacterOutputStream) {
                ((CharacterOutputStream)first).setCharPos(Fixnum.getValue(second));
                return second;
            }
            throw new ConditionThrowable(new TypeError(first, "character output stream"));
        }
    };

    // ### make-socket
    // make-socket host port => stream
    private static final Primitive2 MAKE_SOCKET =
        new Primitive2("make-socket", PACKAGE_EXT, true) {
        public LispObject execute(LispObject first, LispObject second)
            throws ConditionThrowable
        {
            String host = LispString.getValue(first);
            int port = Fixnum.getValue(second);
            try {
                Socket socket = new Socket(host, port);
                CharacterInputStream in =
                    new CharacterInputStream(socket.getInputStream());
                CharacterOutputStream out =
                    new CharacterOutputStream(socket.getOutputStream());
                return new TwoWayStream(in, out);
            }
            catch (Exception e) {
                throw new ConditionThrowable(new LispError(e.getMessage()));
            }
        }
    };
}
