;;; load.lisp
;;;
;;; Copyright (C) 2004 Peter Graves
;;; $Id: load.lisp,v 1.1 2004-03-25 00:54:34 piso Exp $
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

(defun load (filespec
             &key
             (verbose *load-verbose*)
             (print *load-print*)
             (if-does-not-exist t)
             (external-format :default))
  (%load filespec verbose print if-does-not-exist))
