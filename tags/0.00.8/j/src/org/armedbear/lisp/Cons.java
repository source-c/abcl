/*
 * Cons.java
 *
 * Copyright (C) 2002-2005 Peter Graves
 * $Id: Cons.java,v 1.67 2005-08-26 00:33:49 piso Exp $
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

public final class Cons extends LispObject
{
    public LispObject car;
    public LispObject cdr;

    public Cons(LispObject car, LispObject cdr)
    {
        this.car = car;
        this.cdr = cdr;
        ++count;
    }

    public Cons(LispObject car)
    {
        this.car = car;
        this.cdr = NIL;
        ++count;
    }

    public Cons(String name, LispObject value)
    {
        this.car = new SimpleString(name);
        this.cdr = value != null ? value : NULL_VALUE;
        ++count;
    }

    public LispObject typeOf()
    {
        return Symbol.CONS;
    }

    public LispObject classOf()
    {
        return BuiltInClass.CONS;
    }

    public LispObject typep(LispObject typeSpecifier) throws ConditionThrowable
    {
        if (typeSpecifier instanceof Symbol) {
            if (typeSpecifier == Symbol.LIST)
                return T;
            if (typeSpecifier == Symbol.CONS)
                return T;
            if (typeSpecifier == Symbol.SEQUENCE)
                return T;
            if (typeSpecifier == T)
                return T;
        } else if (typeSpecifier instanceof BuiltInClass) {
            if (typeSpecifier == BuiltInClass.LIST)
                return T;
            if (typeSpecifier == BuiltInClass.CONS)
                return T;
            if (typeSpecifier == BuiltInClass.SEQUENCE)
                return T;
            if (typeSpecifier == BuiltInClass.CLASS_T)
                return T;
        }
        return NIL;
    }

    public final boolean constantp()
    {
        if (car == Symbol.QUOTE) {
            if (cdr instanceof Cons)
                if (((Cons)cdr).cdr == NIL)
                    return true;
        }
        return false;
    }

    public LispObject ATOM()
    {
        return NIL;
    }

    public boolean atom()
    {
        return false;
    }

    public final LispObject car()
    {
        return car;
    }

    public final LispObject cdr()
    {
        return cdr;
    }

    public final void setCar(LispObject obj)
    {
        car = obj;
    }

    public LispObject RPLACA(LispObject obj) throws ConditionThrowable
    {
        car = obj;
        return this;
    }

    public final void setCdr(LispObject obj)
    {
        cdr = obj;
    }

    public LispObject RPLACD(LispObject obj) throws ConditionThrowable
    {
        cdr = obj;
        return this;
    }

    public final LispObject cadr() throws ConditionThrowable
    {
        return cdr.car();
    }

    public final LispObject cddr() throws ConditionThrowable
    {
        return cdr.cdr();
    }

    public final LispObject caddr() throws ConditionThrowable
    {
        return cdr.cadr();
    }

    public final LispObject push(LispObject obj)
    {
        return new Cons(obj, this);
    }

    public final int sxhash()
    {
        return computeHash(this, 4);
    }

    private static final int computeHash(LispObject obj, int depth)
    {
        if (obj instanceof Cons) {
            if (depth > 0) {
                int n1 = computeHash(((Cons)obj).car, depth - 1);
                int n2 = computeHash(((Cons)obj).cdr, depth - 1);
                return n1 ^ n2;
            } else {
                // This number comes from SBCL, but since we're not really
                // using SBCL's SXHASH algorithm, it's probably not optimal.
                // But who knows?
                return 261835505;
            }
        } else
            return obj.sxhash();
    }

    public final int psxhash() //throws ConditionThrowable
    {
        return computeEqualpHash(this, 4);
    }

    private static final int computeEqualpHash(LispObject obj, int depth)
    {
        if (obj instanceof Cons) {
            if (depth > 0) {
                int n1 = computeEqualpHash(((Cons)obj).car, depth - 1);
                int n2 = computeEqualpHash(((Cons)obj).cdr, depth - 1);
                return n1 ^ n2;
            } else
                return 261835505; // See above.
        } else
            return obj.psxhash();
    }

    public final boolean equal(LispObject obj) throws ConditionThrowable
    {
        if (this == obj)
            return true;
        if (obj instanceof Cons) {
            if (car.equal(((Cons)obj).car) && cdr.equal(((Cons)obj).cdr))
                return true;
        }
        return false;
    }

    public final boolean equalp(LispObject obj) throws ConditionThrowable
    {
        if (this == obj)
            return true;
        if (obj instanceof Cons) {
            if (car.equalp(((Cons)obj).car) && cdr.equalp(((Cons)obj).cdr))
                return true;
        }
        return false;
    }

    public final int length() throws ConditionThrowable
    {
        int length = 0;
        LispObject obj = this;
        try {
            while (obj != NIL) {
                ++length;
                obj = ((Cons)obj).cdr;
            }
        }
        catch (ClassCastException e) {
            signalTypeError(obj, Symbol.LIST);
        }
        return length;
    }

    public LispObject NTH(int index) throws ConditionThrowable
    {
        if (index < 0)
            signalTypeError(new Fixnum(index), Symbol.UNSIGNED_BYTE);
        int i = 0;
        LispObject obj = this;
        while (true) {
            if (i == index)
                return obj.car();
            obj = obj.cdr();
            if (obj == NIL)
                return NIL;
            ++i;
        }
    }

    public LispObject NTH(LispObject arg) throws ConditionThrowable
    {
        int index;
        try {
            index = ((Fixnum)arg).value;
        }
        catch (ClassCastException e) {
            if (arg instanceof Bignum) {
                // FIXME (when machines have enough memory for it to matter)
                if (arg.minusp())
                    return signalTypeError(arg, Symbol.UNSIGNED_BYTE);
                return NIL;
            }
            return signalTypeError(arg, Symbol.UNSIGNED_BYTE);
        }
        if (index < 0)
            signalTypeError(arg, Symbol.UNSIGNED_BYTE);
        int i = 0;
        LispObject obj = this;
        while (true) {
            if (i == index)
                return obj.car();
            obj = obj.cdr();
            if (obj == NIL)
                return NIL;
            ++i;
        }
    }

    public LispObject elt(int index) throws ConditionThrowable
    {
        if (index < 0)
            signalTypeError(new Fixnum(index), Symbol.UNSIGNED_BYTE);
        int i = 0;
        Cons cons = this;
        try {
            while (true) {
                if (i == index)
                    return cons.car;
                cons = (Cons) cons.cdr;
                ++i;
            }
        }
        catch (ClassCastException e) {
            if (cons.cdr == NIL)
                signal(new TypeError("ELT: invalid index " + index + " for " +
                                     writeToString()));
            else
                signal(new TypeError(this, "proper sequence"));
            // Not reached.
            return NIL;
        }
    }

    public LispObject reverse() throws ConditionThrowable
    {
        Cons cons = this;
        LispObject result = new Cons(cons.car);
        while (cons.cdr instanceof Cons) {
            cons = (Cons) cons.cdr;
            result = new Cons(cons.car, result);
        }
        if (cons.cdr != NIL)
            return signalTypeError(cons.cdr, Symbol.LIST);
        return result;
    }

    public final LispObject nreverse() throws ConditionThrowable
    {
        if (cdr instanceof Cons) {
            Cons cons = (Cons) cdr;
            if (cons.cdr instanceof Cons) {
                Cons cons1 = cons;
                LispObject list = NIL;
                do {
                    Cons temp = (Cons) cons.cdr;
                    cons.cdr = list;
                    list = cons;
                    cons = temp;
                } while (cons.cdr instanceof Cons);
                if (cons.cdr != NIL)
                    return signalTypeError(cons.cdr, Symbol.LIST);
                cdr = list;
                cons1.cdr = cons;
            } else if (cons.cdr != NIL)
                return signalTypeError(cons.cdr, Symbol.LIST);
            LispObject temp = car;
            car = cons.car;
            cons.car = temp;
        } else if (cdr != NIL)
            return signalTypeError(cdr, Symbol.LIST);
        return this;
    }

    public final boolean listp()
    {
        return true;
    }

    public final LispObject LISTP()
    {
        return T;
    }

    public final boolean endp()
    {
        return false;
    }

    public final LispObject ENDP()
    {
        return NIL;
    }

    public final LispObject[] copyToArray() throws ConditionThrowable
    {
        final int length = length();
        LispObject[] array = new LispObject[length];
        LispObject rest = this;
        for (int i = 0; i < length; i++) {
            array[i] = rest.car();
            rest = rest.cdr();
        }
        return array;
    }

    public LispObject execute() throws ConditionThrowable
    {
        if (car == Symbol.LAMBDA) {
            Closure closure = new Closure(this, new Environment());
            return closure.execute();
        }
        return signalExecutionError();
    }

    public LispObject execute(LispObject arg) throws ConditionThrowable
    {
        if (car == Symbol.LAMBDA) {
            Closure closure = new Closure(this, new Environment());
            return closure.execute(arg);
        }
        return signalExecutionError();
    }

    public LispObject execute(LispObject first, LispObject second)
        throws ConditionThrowable
    {
        if (car == Symbol.LAMBDA) {
            Closure closure = new Closure(this, new Environment());
            return closure.execute(first, second);
        }
        return signalExecutionError();
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third)
        throws ConditionThrowable
    {
        if (car == Symbol.LAMBDA) {
            Closure closure = new Closure(this, new Environment());
            return closure.execute(first, second, third);
        }
        return signalExecutionError();
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third, LispObject fourth)
        throws ConditionThrowable
    {
        if (car == Symbol.LAMBDA) {
            Closure closure = new Closure(this, new Environment());
            return closure.execute(first, second, third, fourth);
        }
        return signalExecutionError();
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third, LispObject fourth,
                              LispObject fifth)
        throws ConditionThrowable
    {
        if (car == Symbol.LAMBDA) {
            Closure closure = new Closure(this, new Environment());
            return closure.execute(first, second, third, fourth, fifth);
        }
        return signalExecutionError();
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third, LispObject fourth,
                              LispObject fifth, LispObject sixth)
        throws ConditionThrowable
    {
        if (car == Symbol.LAMBDA) {
            Closure closure = new Closure(this, new Environment());
            return closure.execute(first, second, third, fourth, fifth, sixth);
        }
        return signalExecutionError();
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third, LispObject fourth,
                              LispObject fifth, LispObject sixth,
                              LispObject seventh)
        throws ConditionThrowable
    {
        if (car == Symbol.LAMBDA) {
            Closure closure = new Closure(this, new Environment());
            return closure.execute(first, second, third, fourth, fifth, sixth,
                                   seventh);
        }
        return signalExecutionError();
    }

    public LispObject execute(LispObject first, LispObject second,
                              LispObject third, LispObject fourth,
                              LispObject fifth, LispObject sixth,
                              LispObject seventh, LispObject eighth)
        throws ConditionThrowable
    {
        if (car == Symbol.LAMBDA) {
            Closure closure = new Closure(this, new Environment());
            return closure.execute(first, second, third, fourth, fifth, sixth,
                                   seventh, eighth);
        }
        return signalExecutionError();
    }

    public LispObject execute(LispObject[] args) throws ConditionThrowable
    {
        if (car == Symbol.LAMBDA) {
            Closure closure = new Closure(this, new Environment());
            return closure.execute(args);
        }
        return signalExecutionError();
    }

    private final LispObject signalExecutionError() throws ConditionThrowable
    {
        return signalTypeError(this, list3(Symbol.OR, Symbol.FUNCTION,
                                           Symbol.SYMBOL));
    }

    public String writeToString() throws ConditionThrowable
    {
        final LispThread thread = LispThread.currentThread();
        final LispObject printLength = _PRINT_LENGTH_.symbolValue(thread);
        final int maxLength;
        if (printLength instanceof Fixnum)
            maxLength = ((Fixnum)printLength).value;
        else
            maxLength = Integer.MAX_VALUE;
        final LispObject printLevel = _PRINT_LEVEL_.symbolValue(thread);
        final int maxLevel;
        if (printLevel instanceof Fixnum)
            maxLevel = ((Fixnum)printLevel).value;
        else
            maxLevel = Integer.MAX_VALUE;
        StringBuffer sb = new StringBuffer();
        if (car == Symbol.QUOTE) {
            if (cdr instanceof Cons) {
                // Not a dotted list.
                if (cdr.cdr() == NIL) {
                    sb.append('\'');
                    sb.append(cdr.car().writeToString());
                    return sb.toString();
                }
            }
        }
        if (car == Symbol.FUNCTION) {
            if (cdr instanceof Cons) {
                // Not a dotted list.
                if (cdr.cdr() == NIL) {
                    sb.append("#'");
                    sb.append(cdr.car().writeToString());
                    return sb.toString();
                }
            }
        }
        LispObject currentPrintLevel =
            _CURRENT_PRINT_LEVEL_.symbolValue(thread);
        int currentLevel = Fixnum.getValue(currentPrintLevel);
        if (currentLevel < maxLevel) {
            SpecialBinding lastSpecialBinding = thread.lastSpecialBinding;
            thread.bindSpecial(_CURRENT_PRINT_LEVEL_, currentPrintLevel.incr());
            try {
                int count = 0;
                boolean truncated = false;
                sb.append('(');
                if (count < maxLength) {
                    LispObject p = this;
                    sb.append(p.car().writeToString());
                    ++count;
                    while ((p = p.cdr()) instanceof Cons) {
                        sb.append(' ');
                        if (count < maxLength) {
                            sb.append(p.car().writeToString());
                            ++count;
                        } else {
                            truncated = true;
                            break;
                        }
                    }
                    if (!truncated && p != NIL) {
                        sb.append(" . ");
                        sb.append(p.writeToString());
                    }
                } else
                    truncated = true;
                if (truncated)
                    sb.append("...");
                sb.append(')');
            }
            finally {
                thread.lastSpecialBinding = lastSpecialBinding;
            }
        } else
            sb.append('#');
        return sb.toString();
    }

    // Statistics for TIME.
    private static long count;

    /*package*/ static long getCount()
    {
        return count;
    }

    /*package*/ static void setCount(long n)
    {
        count = n;
    }
}
