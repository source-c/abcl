/*
 * LispString.java
 *
 * Copyright (C) 2002-2003 Peter Graves
 * $Id: LispString.java,v 1.2 2003-02-09 18:45:54 piso Exp $
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

public final class LispString extends AbstractVector implements SequenceType,
    VectorType
{
    private char[] array;
    private int fillPointer = -1; // -1 indicates no fill pointer.

    // For CONCATENATE.
    public LispString()
    {
        array = new char[0];
    }

    public LispString(LispCharacter c)
    {
        array = new char[1];
        array[0] = c.getValue();
    }

    public LispString(char c)
    {
        array = new char[1];
        array[0] = c;
    }

    public LispString(int length)
    {
        array = new char[length];
    }

    public LispString(String s)
    {
        array = s.toCharArray();
    }

    public int getFillPointer()
    {
        return fillPointer;
    }

    public void setFillPointer(LispObject obj) throws LispException
    {
        if (obj == T)
            fillPointer = 0;
        else {
            long n = Fixnum.getValue(obj);
            if (n > array.length) {
                StringBuffer sb = new StringBuffer("the new fill pointer (");
                sb.append(n);
                sb.append(") exceeds the length of the string (");
                sb.append(array.length);
                sb.append(")");
                throw new LispException(sb.toString());
            }
            if (n < 0) {
                StringBuffer sb = new StringBuffer("the new fill pointer (");
                sb.append(n);
                sb.append(") is negative");
                throw new LispException(sb.toString());
            }
            fillPointer = (int) n;
        }
    }

    public void fill(char c)
    {
        for (int i = 0; i < array.length; i++)
            array[i] = c;
    }

    public void append(LispObject obj) throws LispException
    {
        if (obj instanceof LispString) {
            LispString s = (LispString) obj;
            final int slen = s.length();
            final int newLength = array.length + slen;
            char[] newArray = new char[newLength];
            System.arraycopy(array, 0, newArray, 0, array.length);
            int j = array.length;
            for (int i = 0; i < slen; i++)
                newArray[j++] = s.array[i];
            array = newArray;
        } else if (obj instanceof Vector) {
            Vector v = (Vector) obj;
            final int vlen = v.length();
            final int newLength = array.length + vlen;
            char[] newArray = new char[newLength];
            System.arraycopy(array, 0, newArray, 0, array.length);
            int j = array.length;
            for (int i = 0; i < vlen; i++)
                newArray[j++] = LispCharacter.getValue(v.get(i));
            array = newArray;
        } else if (obj instanceof Cons) {
            final int newLength = array.length + obj.length();
            char[] newArray = new char[newLength];
            System.arraycopy(array, 0, newArray, 0, array.length);
            int j = array.length;
            while (obj != NIL) {
                newArray[j++] = LispCharacter.getValue(obj.car());
                obj = obj.cdr();
            }
            array = newArray;
        } else if (obj != NIL)
            throw new WrongTypeException(obj, "sequence");
    }

    public LispObject get(int index) throws LispException
    {
        if (index < 0 || index >= array.length)
            badIndex(index);
        return new LispCharacter(array[index]);
    }

    public void set(int index, LispObject newValue) throws LispException
    {
        char c = LispCharacter.getValue(newValue);
        array[index] = c;
    }

    public static String getValue(LispObject obj) throws LispException
    {
        try {
            return ((LispString)obj).getValue();
        }
        catch (ClassCastException e) {
            throw new WrongTypeException(obj, "string");
        }
    }

    public final String getValue()
    {
        return new String(array);
    }

    public final int length()
    {
        return array.length;
    }

    public LispObject elt(long index) throws LispException
    {
        long limit = fillPointer >= 0 ? fillPointer : array.length;
        if (index >= 0 && index < limit)
            return new LispCharacter(array[(int)index]);
        StringBuffer sb = new StringBuffer("ELT: invalid index ");
        sb.append(index);
        sb.append(" for ");
        sb.append(this);
        throw new LispException(sb.toString());
    }

    public LispObject remove(LispObject item) throws LispException
    {
        throw new LispException("not implemented");
    }

    public final String toString()
    {
        if (_PRINT_ESCAPE_.symbolValueNoThrow() != NIL) {
            StringBuffer sb = new StringBuffer();
            sb.append('"');
            sb.append(getValue());
            sb.append('"');
            return sb.toString();
        } else
            return getValue();
    }

    public static LispObject equals(LispObject first, LispObject second)
        throws LispException
    {
        char[] array1, array2;
        try {
            array1 = ((LispString)first).array;
        }
        catch (ClassCastException e) {
            throw new WrongTypeException(first, "string");
        }
        try {
            array2 = ((LispString)second).array;
        }
        catch (ClassCastException e) {
            throw new WrongTypeException(second, "string");
        }
        if (array1.length != array2.length)
            return NIL;
        for (int i = array1.length; i-- > 0;) {
            if (array1[i] != array2[i])
                return NIL;
        }
        return T;
    }

    public static LispObject equalsIgnoreCase(LispObject first,
        LispObject second) throws LispException
    {
        char[] array1, array2;
        try {
            array1 = ((LispString)first).array;
        }
        catch (ClassCastException e) {
            throw new WrongTypeException(first, "string");
        }
        try {
            array2 = ((LispString)second).array;
        }
        catch (ClassCastException e) {
            throw new WrongTypeException(second, "string");
        }
        if (array1.length != array2.length)
            return NIL;
        for (int i = array1.length; i-- > 0;) {
            char c1 = array1[i];
            char c2 = array2[i];
            if (c1 == c2)
                continue;
            if (Character.toLowerCase(c1) == Character.toLowerCase(c2))
                continue;
            if (Character.toUpperCase(c1) == Character.toUpperCase(c2))
                continue;
            return NIL;
        }
        return T;
    }
}
