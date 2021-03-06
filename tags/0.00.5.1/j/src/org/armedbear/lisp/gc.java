/*
 * gc.java
 *
 * Copyright (C) 2003 Peter Graves
 * $Id: gc.java,v 1.2 2004-11-03 15:39:02 piso Exp $
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

// ### gc
public final class gc extends Primitive
{
    private gc()
    {
        super("gc", PACKAGE_EXT);
    }

    public LispObject execute()
    {
        Runtime runtime = Runtime.getRuntime();
        long free = 0;
        long maxFree = 0;
        while (true) {
            try {
                runtime.gc();
                Thread.currentThread().sleep(100);
                runtime.runFinalization();
                Thread.currentThread().sleep(100);
                runtime.gc();
                Thread.currentThread().sleep(100);
            }
            catch (InterruptedException e) {}
            free = runtime.freeMemory();
            if (free > maxFree)
                maxFree = free;
            else
                break;
        }
        return number(free);
    }

    private static final gc GC = new gc();
}
