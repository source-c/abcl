/*
 * cxr.java
 *
 * Copyright (C) 2003 Peter Graves
 * $Id: cxr.java,v 1.3 2003-09-19 01:46:42 piso Exp $
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

public final class cxr extends Lisp
{
    // ### %rplaca
    private static final Primitive2 _RPLACA =
        new Primitive2("%rplaca", PACKAGE_SYS, false) {
        public LispObject execute(LispObject first, LispObject second)
            throws ConditionThrowable
        {
            first.setCar(second);
            return second;
        }
    };

    // ### %rplacd
    private static final Primitive2 _RPLACD =
        new Primitive2("%rplacd", PACKAGE_SYS, false) {
        public LispObject execute(LispObject first, LispObject second)
            throws ConditionThrowable
        {
            first.setCdr(second);
            return second;
        }
    };

    // ### car
    private static final Primitive1 CAR = new Primitive1("car") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.car();
        }
    };

    // ### cdr
    private static final Primitive1 CDR = new Primitive1("cdr") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.cdr();
        }
    };

    // ### caar
    private static final Primitive1 CAAR = new Primitive1("caar") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.car().car();
        }
    };

    // ### cadr
    private static final Primitive1 CADR = new Primitive1("cadr") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.cadr();
        }
    };

    // ### cdar
    private static final Primitive1 CDAR = new Primitive1("cdar") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.car().cdr();
        }
    };

    // ### cddr
    private static final Primitive1 CDDR = new Primitive1("cddr") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.cdr().cdr();
        }
    };

    // ### caddr
    private static final Primitive1 CADDR = new Primitive1("caddr") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.cdr().cdr().car();
        }
    };

    // ### caadr
    private static final Primitive1 CAADR = new Primitive1("caadr") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.cdr().car().car();
        }
    };

    // ### caaar
    private static final Primitive1 CAAAR = new Primitive1("caaar") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.car().car().car();
        }
    };

    // ### cdaar
    private static final Primitive1 CDAAR = new Primitive1("cdaar") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.car().car().cdr();
        }
    };

    // ### cddar
    private static final Primitive1 CDDAR = new Primitive1("cddar") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.car().cdr().cdr();
        }
    };

    // ### cdddr
    private static final Primitive1 CDDDR = new Primitive1("cdddr") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.cdr().cdr().cdr();
        }
    };

    // ### cadar
    private static final Primitive1 CADAR = new Primitive1("cadar") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.car().cdr().car();
        }
    };

    // ### cdadr
    private static final Primitive1 CDADR = new Primitive1("cdadr") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.cdr().car().cdr();
        }
    };

    // ### first
    private static final Primitive1 FIRST = new Primitive1("first") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.car();
        }
    };

    // ### rest
    private static final Primitive1 REST = new Primitive1("rest") {
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return arg.cdr();
        }
    };
}
