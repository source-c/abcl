/*
 * Primitive0.java
 *
 * Copyright (C) 2002-2003 Peter Graves
 * $Id: Primitive0.java,v 1.8 2003-09-19 01:46:42 piso Exp $
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

public class Primitive0 extends Function
{
    protected Primitive0()
    {
    }

    public Primitive0(String name)
    {
        super(name);
    }

    public Primitive0(String name, Package pkg)
    {
        super(name, pkg);
    }

    public Primitive0(String name, Package pkg, boolean exported)
    {
        super(name, pkg, exported);
    }

    public Primitive0(String name, Package pkg, boolean exported,
                      String arglist, String docstring)
    {
        super(name, pkg, exported, arglist, docstring);
    }

    public Primitive0(Module module, String name, int index)
    {
        super(module, name, index);
    }

    public LispObject execute(LispObject first) throws ConditionThrowable
    {
        throw new ConditionThrowable(new WrongNumberOfArgumentsException(this));
    }

    public LispObject execute(LispObject first, LispObject second)
        throws ConditionThrowable
    {
        throw new ConditionThrowable(new WrongNumberOfArgumentsException(this));
    }

    public LispObject execute(LispObject first, LispObject second,
        LispObject third) throws ConditionThrowable
    {
        throw new ConditionThrowable(new WrongNumberOfArgumentsException(this));
    }

    public LispObject execute(LispObject[] args) throws ConditionThrowable
    {
        if (args.length != 0)
            throw new ConditionThrowable(new WrongNumberOfArgumentsException(this));
        return execute();
    }
}
