;;; do-symbols.lisp
;;;
;;; Copyright (C) 2004 Peter Graves
;;; $Id: do-symbols.lisp,v 1.1 2004-03-31 03:02:34 piso Exp $
;;;
;;; This program is free software; you can redistribute it and/or
;;; modify it under the terms of the GNU General Public License
;;; as published by the Free Software Foundation; either version 2
;;; of the License, or (at your option) any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

(in-package "SYSTEM")

(defmacro do-symbols ((var &optional (package '*package*) (result nil)) &body body)
  `(dolist (,var
            (append (package-symbols ,package)
                    (package-inherited-symbols ,package))
            ,result)
     ,@body))
