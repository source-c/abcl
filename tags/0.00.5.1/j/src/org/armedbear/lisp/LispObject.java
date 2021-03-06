/*
 * LispObject.java
 *
 * Copyright (C) 2002-2005 Peter Graves
 * $Id: LispObject.java,v 1.130 2005-05-16 15:58:12 piso Exp $
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

public class LispObject extends Lisp
{
    public LispObject typeOf()
    {
        return T;
    }

    public LispObject classOf()
    {
        return BuiltInClass.CLASS_T;
    }

    public LispObject getDescription() throws ConditionThrowable
    {
        StringBuffer sb = new StringBuffer("An object of type ");
        sb.append(typeOf().writeToString());
        sb.append(" at #x");
        sb.append(Integer.toHexString(System.identityHashCode(this)).toUpperCase());
        return new SimpleString(sb);
    }

    public LispObject getParts() throws ConditionThrowable
    {
        return NIL;
    }

    public boolean getBooleanValue()
    {
        return true;
    }

    public LispObject typep(LispObject typeSpecifier) throws ConditionThrowable
    {
        if (typeSpecifier == T)
            return T;
        if (typeSpecifier == BuiltInClass.CLASS_T)
            return T;
        if (typeSpecifier == Symbol.ATOM)
            return T;
        return NIL;
    }

    public boolean constantp()
    {
        return true;
    }

    public LispObject CONSTANTP()
    {
        return constantp() ? T : NIL;
    }

    public LispObject ATOM()
    {
        return T;
    }

    public boolean atom()
    {
        return true;
    }

    public Object javaInstance() throws ConditionThrowable
    {
        return signal(new TypeError("The value " + writeToString() +
                                    " is not of primitive type."));
    }

    public Object javaInstance(Class c) throws ConditionThrowable
    {
        if (c == LispObject.class)
            return this;
        return signal(new TypeError("The value " + writeToString() +
                                    " is not of primitive type."));
    }

    public LispObject car() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.LIST));
    }

    public void setCar(LispObject obj) throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.CONS));
    }

    public LispObject RPLACA(LispObject obj) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.CONS));
    }

    public LispObject cdr() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.LIST));
    }

    public void setCdr(LispObject obj) throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.CONS));
    }

    public LispObject RPLACD(LispObject obj) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.CONS));
    }

    public LispObject cadr() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.LIST));
    }

    public LispObject cddr() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.LIST));
    }

    public LispObject push(LispObject obj) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.LIST));
    }

    public LispObject EQ(LispObject obj)
    {
        return this == obj ? T : NIL;
    }

    public boolean eql(int n)
    {
        return false;
    }

    public boolean eql(LispObject obj)
    {
        return this == obj;
    }

    public final LispObject EQL(LispObject obj)
    {
        return eql(obj) ? T : NIL;
    }

    public final LispObject EQUAL(LispObject obj) throws ConditionThrowable
    {
        return equal(obj) ? T : NIL;
    }

    public boolean equal(int n)
    {
        return false;
    }

    public boolean equal(LispObject obj) throws ConditionThrowable
    {
        return this == obj;
    }

    public boolean equalp(int n)
    {
        return false;
    }

    public boolean equalp(LispObject obj) throws ConditionThrowable
    {
        return this == obj;
    }

    public LispObject ABS() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.NUMBER));
    }

    public LispObject NUMERATOR() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.RATIONAL));
    }

    public LispObject DENOMINATOR() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.RATIONAL));
    }

    public LispObject EVENP() throws ConditionThrowable
    {
        return evenp() ? T : NIL;
    }

    public boolean evenp() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.INTEGER));
        // Not reached.
        return false;
    }

    public LispObject ODDP() throws ConditionThrowable
    {
        return oddp() ? T : NIL;
    }

    public boolean oddp() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.INTEGER));
        // Not reached.
        return false;
    }

    public LispObject PLUSP() throws ConditionThrowable
    {
        return plusp() ? T : NIL;
    }

    public boolean plusp() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.REAL));
        // Not reached.
        return false;
    }

    public LispObject MINUSP() throws ConditionThrowable
    {
        return minusp() ? T : NIL;
    }

    public boolean minusp() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.REAL));
        // Not reached.
        return false;
    }

    public LispObject NUMBERP()
    {
        return NIL;
    }

    public boolean numberp()
    {
        return false;
    }

    public LispObject ZEROP() throws ConditionThrowable
    {
        return zerop() ? T : NIL;
    }

    public boolean zerop() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.NUMBER));
        // Not reached.
        return false;
    }

    public LispObject BIT_VECTOR_P()
    {
        return NIL;
    }

    public LispObject COMPLEXP()
    {
        return NIL;
    }

    public LispObject FLOATP()
    {
        return NIL;
    }

    public boolean floatp()
    {
        return false;
    }

    public LispObject INTEGERP()
    {
        return NIL;
    }

    public boolean integerp()
    {
        return false;
    }

    public LispObject RATIONALP()
    {
        return rationalp() ? T : NIL;
    }

    public boolean rationalp()
    {
        return false;
    }

    public LispObject REALP()
    {
        return realp() ? T : NIL;
    }

    public boolean realp()
    {
        return false;
    }

    public LispObject STRINGP()
    {
        return NIL;
    }

    public boolean stringp()
    {
        return false;
    }

    public LispObject SIMPLE_STRING_P()
    {
        return NIL;
    }

    public LispObject VECTORP()
    {
        return NIL;
    }

    public boolean vectorp()
    {
        return false;
    }

    public LispObject CHARACTERP()
    {
        return NIL;
    }

    public boolean characterp()
    {
        return false;
    }

    public int length() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.SEQUENCE));
        // Not reached.
        return 0;
    }

    public final LispObject LENGTH() throws ConditionThrowable
    {
        return new Fixnum(length());
    }

    public LispObject SCHAR(int index) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.SIMPLE_STRING));
    }

    public LispObject NTH(int index) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.LIST));
    }

    public LispObject NTH(LispObject arg) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.LIST));
    }

    public LispObject elt(int index) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.SEQUENCE));
    }

    public LispObject nreverse() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.SEQUENCE));
    }

    public int aref(int index) throws ConditionThrowable
    {
        return Fixnum.getValue(AREF(new Fixnum(index)));
    }

    public LispObject AREF(int index) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.ARRAY));
    }

    public LispObject AREF(LispObject index) throws ConditionThrowable
    {
        try {
            return AREF(((Fixnum)index).value);
        }
        catch (ClassCastException e) {
            return signal(new TypeError(index, Symbol.FIXNUM));
        }
    }

    public void aset(int index, int n)
        throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.ARRAY));
    }

    public void aset(int index, LispObject newValue)
        throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.ARRAY));
    }

    public void aset(LispObject index, LispObject newValue)
        throws ConditionThrowable
    {
        try {
            aset(((Fixnum)index).value, newValue);
        }
        catch (ClassCastException e) {
            signal(new TypeError(index, Symbol.FIXNUM));
        }
    }

    public LispObject[] copyToArray() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.LIST));
        // Not reached.
        return null;
    }

    public LispObject SYMBOLP()
    {
        return NIL;
    }

    public boolean listp()
    {
        return false;
    }

    public LispObject LISTP()
    {
        return NIL;
    }

    public boolean endp() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.LIST));
        // Not reached.
        return false;
    }

    public LispObject ENDP() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.LIST));
    }

    public LispObject NOT()
    {
        return NIL;
    }

    public boolean isSpecialVariable()
    {
        return false;
    }

    public LispObject getDocumentation(LispObject docType)
        throws ConditionThrowable
    {
        LispObject propertyList = getPropertyList();
        if (propertyList != null) {
            LispObject alist = getf(propertyList, Symbol._DOCUMENTATION, NIL);
            if (alist != null) {
                LispObject entry = assq(docType, alist);
                if (entry instanceof Cons)
                    return ((Cons)entry).cdr;
            }
        }
        return NIL;
    }

    public void setDocumentation(LispObject docType, LispObject documentation)
        throws ConditionThrowable
    {
        LispObject propertyList = getPropertyList();
        if (propertyList != null) {
            LispObject alist = getf(propertyList, Symbol._DOCUMENTATION, NIL);
            if (alist == null)
                alist = NIL;
            LispObject entry = assq(docType, alist);
            if (entry instanceof Cons) {
                ((Cons)entry).cdr = documentation;
            } else {
                alist = alist.push(new Cons(docType, documentation));
                setPropertyList(putf(propertyList, Symbol._DOCUMENTATION, alist));
            }
        }
    }

    public LispObject getPropertyList()
    {
        return null;
    }

    public void setPropertyList(LispObject obj)
    {
    }

    public LispObject getSymbolValue() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.SYMBOL));
    }

    public LispObject getSymbolFunction() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.SYMBOL));
    }

    public LispObject getSymbolFunctionOrDie() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.SYMBOL));
    }

    public String writeToString() throws ConditionThrowable
    {
        return toString();
    }

    public String unreadableString(String s)
    {
        StringBuffer sb = new StringBuffer("#<");
        sb.append(s);
        sb.append(" {");
        sb.append(Integer.toHexString(System.identityHashCode(this)).toUpperCase());
        sb.append("}>");
        return sb.toString();
    }

    public String unreadableString(Symbol symbol) throws ConditionThrowable
    {
        StringBuffer sb = new StringBuffer("#<");
        sb.append(symbol.writeToString());
        sb.append(" {");
        sb.append(Integer.toHexString(System.identityHashCode(this)).toUpperCase());
        sb.append("}>");
        return sb.toString();
    }

    // Special operator
    public LispObject execute(LispObject args, Environment env)
        throws ConditionThrowable
    {
        return signal(new LispError());
    }

    public LispObject execute() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.FUNCTION));
    }

    public LispObject execute(LispObject arg) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.FUNCTION));
    }

    public LispObject execute(LispObject first, LispObject second)
        throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.FUNCTION));
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third)
        throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.FUNCTION));
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third, LispObject fourth)
        throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.FUNCTION));
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third, LispObject fourth,
                              LispObject fifth)
        throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.FUNCTION));
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third, LispObject fourth,
                              LispObject fifth, LispObject sixth)
        throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.FUNCTION));
    }

    public LispObject execute(LispObject[] args) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.FUNCTION));
    }

    // Used by COMPILE-MULTIPLE-VALUE-CALL.
    public LispObject dispatch(LispObject[] args) throws ConditionThrowable
    {
        switch (args.length) {
            case 0:
                return execute();
            case 1:
                return execute(args[0]);
            case 2:
                return execute(args[0], args[1]);
            case 3:
                return execute(args[0], args[1], args[2]);
            case 4:
                return execute(args[0], args[1], args[2], args[3]);
            case 5:
                return execute(args[0], args[1], args[2], args[3], args[4]);
            case 6:
                return execute(args[0], args[1], args[2], args[3], args[4],
                               args[5]);
            default:
                return signal(new TypeError(this, Symbol.FUNCTION));
        }
    }

    public LispObject incr() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.NUMBER));
    }

    public LispObject decr() throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.NUMBER));
    }

    public LispObject add(int n) throws ConditionThrowable
    {
        return add(new Fixnum(n));
    }

    public LispObject add(LispObject obj) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.NUMBER));
    }

    public LispObject subtract(int n) throws ConditionThrowable
    {
        return subtract(new Fixnum(n));
    }

    public LispObject subtract(LispObject obj) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.NUMBER));
    }

    public LispObject multiplyBy(int n) throws ConditionThrowable
    {
        return multiplyBy(new Fixnum(n));
    }

    public LispObject multiplyBy(LispObject obj) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.NUMBER));
    }

    public LispObject divideBy(LispObject obj) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.NUMBER));
    }

    public boolean isEqualTo(int n) throws ConditionThrowable
    {
        return isEqualTo(new Fixnum(n));
    }

    public boolean isEqualTo(LispObject obj) throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.NUMBER));
        // Not reached.
        return false;
    }

    public LispObject IS_E(LispObject obj) throws ConditionThrowable
    {
        return isEqualTo(obj) ? T : NIL;
    }

    public boolean isNotEqualTo(int n) throws ConditionThrowable
    {
        return isNotEqualTo(new Fixnum(n));
    }

    public boolean isNotEqualTo(LispObject obj) throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.NUMBER));
        // Not reached.
        return false;
    }

    public LispObject IS_NE(LispObject obj) throws ConditionThrowable
    {
        return isNotEqualTo(obj) ? T : NIL;
    }

    public boolean isLessThan(int n) throws ConditionThrowable
    {
        return isLessThan(new Fixnum(n));
    }

    public boolean isLessThan(LispObject obj) throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.REAL));
        // Not reached.
        return false;
    }

    public LispObject IS_LT(LispObject obj) throws ConditionThrowable
    {
        return isLessThan(obj) ? T : NIL;
    }

    public boolean isGreaterThan(int n) throws ConditionThrowable
    {
        return isGreaterThan(new Fixnum(n));
    }

    public boolean isGreaterThan(LispObject obj) throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.REAL));
        // Not reached.
        return false;
    }

    public LispObject IS_GT(LispObject obj) throws ConditionThrowable
    {
        return isGreaterThan(obj) ? T : NIL;
    }

    public boolean isLessThanOrEqualTo(int n) throws ConditionThrowable
    {
        return isLessThanOrEqualTo(new Fixnum(n));
    }

    public boolean isLessThanOrEqualTo(LispObject obj) throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.REAL));
        // Not reached.
        return false;
    }

    public LispObject IS_LE(LispObject obj) throws ConditionThrowable
    {
        return isLessThanOrEqualTo(obj) ? T : NIL;
    }

    public boolean isGreaterThanOrEqualTo(int n) throws ConditionThrowable
    {
        return isGreaterThanOrEqualTo(new Fixnum(n));
    }

    public boolean isGreaterThanOrEqualTo(LispObject obj) throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.REAL));
        // Not reached.
        return false;
    }

    public LispObject IS_GE(LispObject obj) throws ConditionThrowable
    {
        return isGreaterThanOrEqualTo(obj) ? T : NIL;
    }

    public LispObject truncate(LispObject obj) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.REAL));
    }

    public LispObject MOD(LispObject divisor) throws ConditionThrowable
    {
        truncate(divisor);
        final LispThread thread = LispThread.currentThread();
        LispObject remainder = thread._values[1];
        thread.clearValues();
        if (!remainder.zerop()) {
            if (divisor.minusp()) {
                if (plusp())
                    return remainder.add(divisor);
            } else {
                if (minusp())
                    return remainder.add(divisor);
            }
        }
        return remainder;
    }

    public LispObject MOD(int divisor) throws ConditionThrowable
    {
        return MOD(new Fixnum(divisor));
    }

    public LispObject ash(int shift) throws ConditionThrowable
    {
        return ash(new Fixnum(shift));
    }

    public LispObject ash(LispObject obj) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.INTEGER));
    }

    public LispObject logand(int n) throws ConditionThrowable
    {
        return logand(new Fixnum(n));
    }

    public LispObject logand(LispObject obj) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.INTEGER));
    }

    public int sxhash()
    {
        return hashCode() & 0x7fffffff;
    }

    // For EQUALP hash tables.
    public int psxhash()
    {
        return sxhash();
    }

    public LispObject STRING() throws ConditionThrowable
    {
        return signal(new TypeError(writeToString() + " cannot be coerced to a string."));
    }

    public char[] chars() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.STRING));
        // Not reached.
        return null;
    }

    public char[] getStringChars() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.STRING));
        // Not reached.
        return null;
    }

    public String getStringValue() throws ConditionThrowable
    {
        signal(new TypeError(this, Symbol.STRING));
        // Not reached.
        return null;
    }

    public LispObject getSlotValue(int index) throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.STRUCTURE_OBJECT));
    }

    public LispObject setSlotValue(int index, LispObject value)
        throws ConditionThrowable
    {
        return signal(new TypeError(this, Symbol.STRUCTURE_OBJECT));
    }

    // Profiling.
    public int getCallCount()
    {
        return 0;
    }

    public void setCallCount(int n)
    {
    }

    public void incrementCallCount()
    {
    }
}
