/*
 * MathFunctions.java
 *
 * Copyright (C) 2004-2006 Peter Graves
 * $Id$
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
 *
 * As a special exception, the copyright holders of this library give you
 * permission to link this library with independent modules to produce an
 * executable, regardless of the license terms of these independent
 * modules, and to copy and distribute the resulting executable under
 * terms of your choice, provided that you also meet, for each linked
 * independent module, the terms and conditions of the license of that
 * module.  An independent module is a module which is not derived from
 * or based on this library.  If you modify this library, you may extend
 * this exception to your version of the library, but you are not
 * obligated to do so.  If you do not wish to do so, delete this
 * exception statement from your version.
 */

package org.armedbear.lisp;

public final class MathFunctions extends Lisp
{
    // ### sin
    private static final Primitive SIN = new Primitive("sin", "radians")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return sin(arg);
        }
    };

    private static LispObject sin(LispObject arg) throws ConditionThrowable
    {
        if (arg instanceof DoubleFloat)
            return new DoubleFloat(Math.sin(((DoubleFloat)arg).value));
        if (arg.realp())
            return new SingleFloat((float)Math.sin(SingleFloat.coerceToFloat(arg).value));
        if (arg instanceof Complex) {
            LispObject n = arg.multiplyBy(Complex.getInstance(Fixnum.ZERO,
                                                              Fixnum.ONE));
            LispObject result = exp(n);
            result = result.subtract(exp(n.multiplyBy(Fixnum.MINUS_ONE)));
            return result.divideBy(Fixnum.TWO.multiplyBy(Complex.getInstance(Fixnum.ZERO,
                                                                             Fixnum.ONE)));
        }
        return type_error(arg, Symbol.NUMBER);
    }

    // ### cos
    private static final Primitive COS = new Primitive("cos", "radians")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return cos(arg);
        }
    };

    private static LispObject cos(LispObject arg) throws ConditionThrowable
    {
        if (arg instanceof DoubleFloat)
            return new DoubleFloat(Math.cos(((DoubleFloat)arg).value));
        if (arg.realp())
            return new SingleFloat((float)Math.cos(SingleFloat.coerceToFloat(arg).value));
        if (arg instanceof Complex) {
            LispObject n = arg.multiplyBy(Complex.getInstance(Fixnum.ZERO,
                                                              Fixnum.ONE));
            LispObject result = exp(n);
            result = result.add(exp(n.multiplyBy(Fixnum.MINUS_ONE)));
            return result.divideBy(Fixnum.TWO);
        }
        return type_error(arg, Symbol.NUMBER);
    }

    // ### tan
    private static final Primitive TAN = new Primitive("tan", "radians")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            if (arg instanceof DoubleFloat)
                return new DoubleFloat(Math.tan(((DoubleFloat)arg).value));
            if (arg.realp())
                return new SingleFloat((float)Math.tan(SingleFloat.coerceToFloat(arg).value));
            return sin(arg).divideBy(cos(arg));
        }
    };

    // ### asin
    private static final Primitive ASIN = new Primitive("asin", "number")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return asin(arg);
        }
    };

    private static LispObject asin(LispObject arg) throws ConditionThrowable
    {
        if (arg instanceof SingleFloat) {
            float f = ((SingleFloat)arg).value;
            if (Math.abs(f) <= 1)
                return new SingleFloat((float)Math.asin(f));
        }
        if (arg instanceof DoubleFloat) {
            double d = ((DoubleFloat)arg).value;
            if (Math.abs(d) <= 1)
                return new DoubleFloat(Math.asin(d));
        }
        LispObject result = arg.multiplyBy(arg);
        result = Fixnum.ONE.subtract(result);
        result = sqrt(result);
        LispObject n = Complex.getInstance(Fixnum.ZERO, Fixnum.ONE);
        n = n.multiplyBy(arg);
        result = n.add(result);
        result = log(result);
        result = result.multiplyBy(Complex.getInstance(Fixnum.ZERO,
                                                       Fixnum.MINUS_ONE));
        if (result instanceof Complex) {
            if (arg instanceof Complex)
                return result;
            LispObject im = ((Complex)result).getImaginaryPart();
            if (im.zerop())
                return ((Complex)result).getRealPart();
        }
        return result;
    }

    // ### acos
    private static final Primitive ACOS = new Primitive("acos", "number")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return acos(arg);
        }
    };

    private static LispObject acos(LispObject arg) throws ConditionThrowable
    {
        if (arg instanceof DoubleFloat) {
            double d = ((DoubleFloat)arg).value;
            if (Math.abs(d) <= 1)
                return new DoubleFloat(Math.acos(d));
        }
        if (arg instanceof SingleFloat) {
            float f = ((SingleFloat)arg).value;
            if (Math.abs(f) <= 1)
                return new SingleFloat((float)Math.acos(f));
        }
        LispObject result = new DoubleFloat(Math.PI/2);
        if (!(arg instanceof DoubleFloat)) {
            if (arg instanceof Complex &&
                    ((Complex)arg).getRealPart() instanceof DoubleFloat) {
                    // do nothing; we want to keep the double float value
            }
            else
                result = new SingleFloat((float)((DoubleFloat)result).value);
        }
        result = result.subtract(asin(arg));
        if (result instanceof Complex) {
            if (arg instanceof Complex)
                return result;
            LispObject im = ((Complex)result).getImaginaryPart();
            if (im.zerop())
                return ((Complex)result).getRealPart();
        }
        return result;
    }

    // ### atan
    private static final Primitive ATAN =
        new Primitive("atan", "number1 &optional number2")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            if (arg.numberp())
                return atan(arg);
            return type_error(arg, Symbol.NUMBER);
        }

        // "If both number1 and number2 are supplied for atan, the result is
        // the arc tangent of number1/number2."

        // y = +0     x = +0       +0
        // y = -0     x = +0       -0
        // y = +0     x = -0       +<PI>
        // y = -0     x = -0       -<PI>
        @Override
        public LispObject execute(LispObject y, LispObject x)
            throws ConditionThrowable
        {
            if (!y.realp())
                return type_error(y, Symbol.REAL);
            if (!x.realp())
                return type_error(x, Symbol.REAL);
            double d1, d2;
            d1 = DoubleFloat.coerceToFloat(y).value;
            d2 = DoubleFloat.coerceToFloat(x).value;
            double result = Math.atan2(d1, d2);
            if (y instanceof DoubleFloat || x instanceof DoubleFloat)
                return new DoubleFloat(result);
            else
                return new SingleFloat((float)result);
        }
    };

    private static LispObject atan(LispObject arg) throws ConditionThrowable
    {
        if (arg instanceof Complex) {
            LispObject im = ((Complex)arg).imagpart;
            if (im.zerop())
                return Complex.getInstance(atan(((Complex)arg).realpart),
                                           im);
            LispObject result = arg.multiplyBy(arg);
            result = result.add(Fixnum.ONE);
            result = Fixnum.ONE.divideBy(result);
            result = sqrt(result);
            LispObject n = Complex.getInstance(Fixnum.ZERO, Fixnum.ONE);
            n = n.multiplyBy(arg);
            n = n.add(Fixnum.ONE);
            result = n.multiplyBy(result);
            result = log(result);
            result = result.multiplyBy(Complex.getInstance(Fixnum.ZERO, Fixnum.MINUS_ONE));
            return result;
        }
        if (arg instanceof DoubleFloat)
            return new DoubleFloat(Math.atan(((DoubleFloat)arg).value));
        return new SingleFloat((float)Math.atan(SingleFloat.coerceToFloat(arg).value));
    }

    // ### sinh
    private static final Primitive SINH = new Primitive("sinh", "number")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return sinh(arg);
        }
    };

    private static LispObject sinh(LispObject arg) throws ConditionThrowable
    {
        if (arg instanceof Complex) {
            LispObject im = ((Complex)arg).getImaginaryPart();
            if (im.zerop())
                return Complex.getInstance(sinh(((Complex)arg).getRealPart()),
                                           im);
        }
        if (arg instanceof SingleFloat) {
            try {
                double d = Math.sinh(((SingleFloat)arg).value);
                return new SingleFloat((float)d);
            }
            catch (Throwable t) {
                Debug.trace(t);
                // Fall through...
            }
        } else if (arg instanceof DoubleFloat) {
            try {
                double d = Math.sinh(((DoubleFloat)arg).value);
                return new DoubleFloat(d);
            }
            catch (Throwable t) {
                Debug.trace(t);
                // Fall through...
            }
        }
        LispObject result = exp(arg);
        result = result.subtract(exp(arg.multiplyBy(Fixnum.MINUS_ONE)));
        result = result.divideBy(Fixnum.TWO);
        if (result instanceof Complex) {
            if (arg instanceof Complex)
                return result;
            LispObject im = ((Complex)result).getImaginaryPart();
            if (im.zerop())
                return ((Complex)result).getRealPart();
        }
        return result;
    }

    // ### cosh
    private static final Primitive COSH = new Primitive("cosh", "number")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return cosh(arg);
        }
    };

    private static LispObject cosh(LispObject arg) throws ConditionThrowable
    {
        if (arg instanceof Complex) {
            LispObject im = ((Complex)arg).getImaginaryPart();
            if (im.zerop())
                return Complex.getInstance(cosh(((Complex)arg).getRealPart()),
                                           im);
        }
        if (arg instanceof SingleFloat) {
            try {
                double d = Math.cosh(((SingleFloat)arg).value);
                return new SingleFloat((float)d);
            }
            catch (Throwable t) {
                Debug.trace(t);
                // Fall through...
            }
        } else if (arg instanceof DoubleFloat) {
            try {
                double d = Math.cosh(((DoubleFloat)arg).value);
                return new DoubleFloat(d);
            }
            catch (Throwable t) {
                Debug.trace(t);
                // Fall through...
            }
        }
        LispObject result = exp(arg);
        result = result.add(exp(arg.multiplyBy(Fixnum.MINUS_ONE)));
        result = result.divideBy(Fixnum.TWO);
        if (result instanceof Complex) {
            if (arg instanceof Complex)
                return result;
            LispObject im = ((Complex)result).getImaginaryPart();
            if (im.zerop())
                return ((Complex)result).getRealPart();
        }
        return result;
    }

    // ### tanh
    private static final Primitive TANH = new Primitive("tanh", "number")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            if (arg instanceof SingleFloat) {
                try {
                    double d = Math.tanh(((SingleFloat)arg).value);
                    return new SingleFloat((float)d);
                }
                catch (Throwable t) {
                    Debug.trace(t);
                    // Fall through...
                }
            } else if (arg instanceof DoubleFloat) {
                try {
                    double d = Math.tanh(((DoubleFloat)arg).value);
                    return new DoubleFloat(d);
                }
                catch (Throwable t) {
                    Debug.trace(t);
                    // Fall through...
                }
            }
            return sinh(arg).divideBy(cosh(arg));
        }
    };

    // ### asinh
    private static final Primitive ASINH = new Primitive("asinh", "number")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return asinh(arg);
        }
    };

    private static LispObject asinh(LispObject arg) throws ConditionThrowable
    {
        if (arg instanceof Complex) {
            LispObject im = ((Complex)arg).getImaginaryPart();
            if (im.zerop())
                return Complex.getInstance(asinh(((Complex)arg).getRealPart()),
                                           im);
        }
        LispObject result = arg.multiplyBy(arg);
        result = Fixnum.ONE.add(result);
        result = sqrt(result);
        result = result.add(arg);
        result = log(result);
        if (result instanceof Complex) {
            if (arg instanceof Complex)
                return result;
            LispObject im = ((Complex)result).getImaginaryPart();
            if (im.zerop())
                return ((Complex)result).getRealPart();
        }
        return result;
    }

    // ### acosh
    private static final Primitive ACOSH = new Primitive("acosh", "number")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return acosh(arg);
        }
    };

    private static LispObject acosh(LispObject arg) throws ConditionThrowable
    {
        if (arg instanceof Complex) {
            LispObject im = ((Complex)arg).getImaginaryPart();
            if (im.zerop())
                return Complex.getInstance(acosh(((Complex)arg).getRealPart()),
                                           im);
        }
        LispObject n1 = arg.add(Fixnum.ONE);
        n1 = n1.divideBy(Fixnum.TWO);
        n1 = sqrt(n1);
        LispObject n2 = arg.subtract(Fixnum.ONE);
        n2 = n2.divideBy(Fixnum.TWO);
        n2 = sqrt(n2);
        LispObject result = n1.add(n2);
        result = log(result);
        result = result.multiplyBy(Fixnum.TWO);
        if (result instanceof Complex) {
            if (arg instanceof Complex)
                return result;
            LispObject im = ((Complex)result).getImaginaryPart();
            if (im.zerop())
                return ((Complex)result).getRealPart();
        }
        return result;
    }

    // ### atanh
    private static final Primitive ATANH = new Primitive("atanh", "number")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return atanh(arg);
        }
    };

    private static LispObject atanh(LispObject arg) throws ConditionThrowable
    {
        if (arg instanceof Complex) {
            LispObject im = ((Complex)arg).getImaginaryPart();
            if (im.zerop())
                return Complex.getInstance(atanh(((Complex)arg).getRealPart()),
                                           im);
        }
        LispObject n1 = log(Fixnum.ONE.add(arg));
        LispObject n2 = log(Fixnum.ONE.subtract(arg));
        LispObject result = n1.subtract(n2);
        result = result.divideBy(Fixnum.TWO);
        if (result instanceof Complex) {
            if (arg instanceof Complex)
                return result;
            LispObject im = ((Complex)result).getImaginaryPart();
            if (im.zerop())
                return ((Complex)result).getRealPart();
        }
        return result;
    }

    // ### cis
    private static final Primitive CIS = new Primitive("cis", "radians")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return cis(arg);
        }
    };

    private static LispObject cis(LispObject arg) throws ConditionThrowable
    {
        if (arg.realp())
            return Complex.getInstance(cos(arg), sin(arg));
        return type_error(arg, Symbol.REAL);
    }

    // ### exp
    private static final Primitive EXP = new Primitive("exp", "number")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return exp(arg);
        }
    };

    private static LispObject exp(LispObject arg) throws ConditionThrowable
    {
        if (arg.realp()) {
            if (arg instanceof DoubleFloat) {
                double d = Math.pow(Math.E, ((DoubleFloat)arg).value);
                return OverUnderFlowCheck(new DoubleFloat(d));
            } else {
                float f = (float) Math.pow(Math.E, SingleFloat.coerceToFloat(arg).value);
                return OverUnderFlowCheck(new SingleFloat(f));
            }
        }
        if (arg instanceof Complex) {
            Complex c = (Complex) arg;
            return exp(c.getRealPart()).multiplyBy(cis(c.getImaginaryPart()));
        }
        return type_error(arg, Symbol.NUMBER);
    }

    // ### sqrt
    private static final Primitive SQRT = new Primitive("sqrt", "number")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return sqrt(arg);
        }
    };

    private static final LispObject sqrt(LispObject obj) throws ConditionThrowable
    {
        if (obj instanceof DoubleFloat) {
            if (obj.minusp())
                return Complex.getInstance(new DoubleFloat(0), sqrt(obj.negate()));
            return new DoubleFloat(Math.sqrt(DoubleFloat.coerceToFloat(obj).value));
        }
        if (obj.realp()) {
            if (obj.minusp())
                return Complex.getInstance(new SingleFloat(0), sqrt(obj.negate()));
            return new SingleFloat((float)Math.sqrt(SingleFloat.coerceToFloat(obj).value));
        }
        if (obj instanceof Complex) {
            LispObject imagpart = ((Complex)obj).imagpart;
            if (imagpart.zerop()) {
                LispObject realpart = ((Complex)obj).realpart;
                if (realpart.minusp())
                    return Complex.getInstance(imagpart, sqrt(realpart.negate()));
                else
                    return Complex.getInstance(sqrt(realpart), imagpart);
            }
            return exp(log(obj).divideBy(Fixnum.TWO));
        }
        return type_error(obj, Symbol.NUMBER);
    }

    // ### log
    private static final Primitive LOG =
        new Primitive("log", "number &optional base")
    {
        @Override
        public LispObject execute(LispObject arg) throws ConditionThrowable
        {
            return log(arg);
        }
        @Override
        public LispObject execute(LispObject number, LispObject base)
            throws ConditionThrowable
        {
            if (number.realp() && !number.minusp()
                && base.isEqualTo(Fixnum.getInstance(10))) {
                try {
                    double d =
                        Math.log10(DoubleFloat.coerceToFloat(number).value);
                    if (number instanceof DoubleFloat
                        || base instanceof DoubleFloat)
                        return new DoubleFloat(d);
                    else
                        return new SingleFloat((float)d);
                }
                catch (Throwable t) {
                    Debug.trace(t);
                    // Fall through...
                }
            }
            return log(number).divideBy(log(base));
        }
    };

    private static final LispObject log(LispObject obj) throws ConditionThrowable
    {
        if (obj.realp() && !obj.minusp()) {
            // Result is real.
            if (obj instanceof Fixnum)
                return new SingleFloat((float)Math.log(((Fixnum)obj).value));
            if (obj instanceof Bignum)
                return new SingleFloat((float)Math.log(((Bignum)obj).doubleValue()));
            if (obj instanceof Ratio)
                return new SingleFloat((float)Math.log(((Ratio)obj).doubleValue()));
            if (obj instanceof SingleFloat)
                return new SingleFloat((float)Math.log(((SingleFloat)obj).value));
            if (obj instanceof DoubleFloat)
                return new DoubleFloat(Math.log(((DoubleFloat)obj).value));
        } else {
            // Result is complex.
            if (obj.realp() && obj.minusp()) {
                if (obj instanceof DoubleFloat) {
                    DoubleFloat re = DoubleFloat.coerceToFloat(obj);
                    DoubleFloat abs = new DoubleFloat(Math.abs(re.value));
                    DoubleFloat phase = new DoubleFloat(Math.PI);
                    return Complex.getInstance(new DoubleFloat(Math.log(abs.getValue())), phase);
                } else {
                    SingleFloat re = SingleFloat.coerceToFloat(obj);
                    SingleFloat abs = new SingleFloat(Math.abs(re.value));
                    SingleFloat phase = new SingleFloat((float)Math.PI);
                    return Complex.getInstance(new SingleFloat((float)Math.log(abs.value)), phase);
                }
            } else if (obj instanceof Complex) {
                if (((Complex)obj).getRealPart() instanceof DoubleFloat) {
                    DoubleFloat re = DoubleFloat.coerceToFloat(((Complex)obj).getRealPart());
                    DoubleFloat im = DoubleFloat.coerceToFloat(((Complex)obj).getImaginaryPart());
                    DoubleFloat phase =
                        new DoubleFloat(Math.atan2(im.getValue(), re.getValue()));  // atan(y/x)
                    DoubleFloat abs = DoubleFloat.coerceToFloat(obj.ABS());
                    return Complex.getInstance(new DoubleFloat(Math.log(abs.getValue())), phase);
                } else {
                    SingleFloat re = SingleFloat.coerceToFloat(((Complex)obj).getRealPart());
                    SingleFloat im = SingleFloat.coerceToFloat(((Complex)obj).getImaginaryPart());
                    SingleFloat phase =
                        new SingleFloat((float)Math.atan2(im.value, re.value));  // atan(y/x)
                    SingleFloat abs = SingleFloat.coerceToFloat(obj.ABS());
                    return Complex.getInstance(new SingleFloat((float)Math.log(abs.value)), phase);
                }
            }
        }
        type_error(obj, Symbol.NUMBER);
        return NIL;
    }

    // ### expt base-number power-number => result
    public static final Primitive EXPT =
        new Primitive("expt", "base-number power-number")
    {
        @Override
        public LispObject execute(LispObject base, LispObject power)
            throws ConditionThrowable
        {
            if (power.zerop()) {
                if (power instanceof Fixnum) {
                    if (base instanceof SingleFloat)
                        return SingleFloat.ONE;
                    if (base instanceof DoubleFloat)
                        return DoubleFloat.ONE;
                    if (base instanceof Complex) {
                        if (((Complex)base).realpart instanceof SingleFloat)
                            return Complex.getInstance(SingleFloat.ONE,
                                                       SingleFloat.ZERO);
                        if (((Complex)base).realpart instanceof DoubleFloat)
                            return Complex.getInstance(DoubleFloat.ONE,
                                                       DoubleFloat.ZERO);
                    }
                    return Fixnum.ONE;
                }
                if (power instanceof DoubleFloat)
                    return DoubleFloat.ONE;
                if (base instanceof DoubleFloat)
                    return DoubleFloat.ONE;
                return SingleFloat.ONE;
            }
            if (base.zerop())
                return base;
            if (base.isEqualTo(1))
                return base;
            
            if ((power instanceof Fixnum
                 || power instanceof Bignum)
                 && (base.rationalp()
                     || (base instanceof Complex
                         && ((Complex)base).realpart.rationalp()))) {
                // exact math version
                return intexp(base, power);
            }
            // for anything not a rational or complex rational, use
            // float approximation.
            if (base instanceof Complex || power instanceof Complex)
                return exp(power.multiplyBy(log(base)));
            final double x; // base
            final double y; // power
            if (base instanceof Fixnum)
                x = ((Fixnum)base).value;
            else if (base instanceof Bignum)
                x = ((Bignum)base).doubleValue();
            else if (base instanceof Ratio)
                x = ((Ratio)base).doubleValue();
            else if (base instanceof SingleFloat)
                x = ((SingleFloat)base).value;
            else if (base instanceof DoubleFloat)
                x = ((DoubleFloat)base).value;
            else
                return error(new LispError("EXPT: unsupported case: base is of type " +
                                            base.typeOf().writeToString()));

            if (power instanceof Fixnum)
                y = ((Fixnum)power).value;
            else if (power instanceof Bignum)
                y = ((Bignum)power).doubleValue();
            else if (power instanceof Ratio)
                y = ((Ratio)power).doubleValue();
            else if (power instanceof SingleFloat)
                y = ((SingleFloat)power).value;
            else if (power instanceof DoubleFloat)
                y = ((DoubleFloat)power).value;
            else
                return error(new LispError("EXPT: unsupported case: power is of type " +
                                            power.typeOf().writeToString()));
            double r = Math.pow(x, y);
            if (Double.isNaN(r)) {
                if (x < 0) {
                    r = Math.pow(-x, y);
                    double realPart = r * Math.cos(y * Math.PI);
                    double imagPart = r * Math.sin(y * Math.PI);
                    if (base instanceof DoubleFloat || power instanceof DoubleFloat)
                        return Complex
                            .getInstance(OverUnderFlowCheck(new DoubleFloat(realPart)),
                                         OverUnderFlowCheck(new DoubleFloat(imagPart)));
                    else
                        return Complex
                            .getInstance(OverUnderFlowCheck(new SingleFloat((float)realPart)),
                                         OverUnderFlowCheck(new SingleFloat((float)imagPart)));
                }
            }
            if (base instanceof DoubleFloat || power instanceof DoubleFloat)
                return OverUnderFlowCheck(new DoubleFloat(r));
            else
                return OverUnderFlowCheck(new SingleFloat((float)r));
        }
    };

    /** Checks number for over- or underflow values.
     *
     * @param number
     * @return number or signals an appropriate error
     * @throws org.armedbear.lisp.ConditionThrowable
     */
    private final static LispObject OverUnderFlowCheck(LispObject number)
            throws ConditionThrowable
    {
        if (number instanceof Complex) {
            OverUnderFlowCheck(((Complex)number).realpart);
            OverUnderFlowCheck(((Complex)number).imagpart);
            return number;
        }

        if (TRAP_OVERFLOW) {
            if (number instanceof SingleFloat)
                if (Float.isInfinite(((SingleFloat)number).value))
                    return error(new FloatingPointOverflow(NIL));
            if (number instanceof DoubleFloat)
                if (Double.isInfinite(((DoubleFloat)number).value))
                    return error(new FloatingPointOverflow(NIL));
        }
        if (TRAP_UNDERFLOW) {
            if (number.zerop())
                return error(new FloatingPointUnderflow(NIL));
        }
        return number;
    }

    // Adapted from SBCL.
    /** Return the exponent of base taken to the integer exponent power
     *
     * @param base A value of any type
     * @param power An integer (fixnum or bignum) value
     * @throws org.armedbear.lisp.ConditionThrowable
     */
    private static final LispObject intexp(LispObject base, LispObject power)
        throws ConditionThrowable
    {
        if (power.isEqualTo(0))
            return Fixnum.ONE;
        if (base.isEqualTo(1))
            return base;
        if (base.isEqualTo(0))
            return base;

        if (power.minusp()) {
            power = Fixnum.ZERO.subtract(power);
            return Fixnum.ONE.divideBy(intexp(base, power));
        }
        if (base.eql(Fixnum.TWO))
            return Fixnum.ONE.ash(power);

        LispObject nextn = power.ash(Fixnum.MINUS_ONE);
        LispObject total;
        if (power.oddp())
            total = base;
        else
            total = Fixnum.ONE;
        while (true) {
            if (nextn.zerop())
                return total;
            base = base.multiplyBy(base);

            if (nextn.oddp())
                total = base.multiplyBy(total);
            nextn = nextn.ash(Fixnum.MINUS_ONE);
        }
    }
}
