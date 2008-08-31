;;; package.lisp
;;;
;;; Copyright (C) 2008 Erik Huelsmann
;;; $Id: parse-integer.lisp,v 1.4 2003-09-08 13:35:25 piso Exp $
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

;; Redefines make-package from boot.lisp

(defun make-package (name &key nicknames use)
  (restart-case
      (progn
        (when (find-package name)
          (error 'simple-error "Package ~A already exists." name))
        (dolist (nick nicknames)
          (when (find-package nick)
            (error 'package-error :package nick)))
        (%make-package name nicknames use))
    (use-existing-package ()
      :report "Use existing package"
      (return-from make-package (find-package name)))))

(defun import (symbols &optional (package *package* package-supplied-p))
  (dolist (symbol (if (listp symbols) symbols (list symbols)))
    (let* ((sym-name (string symbol))
           (local-sym (find-symbol sym-name package)))
      (restart-case
          (progn
            (when (and local-sym (not (eql symbol local-sym)))
              (error 'package-error
                     "Different symbol (~A) with the same name already accessible in package ~A."
                     local-sym (package-name package)))
            (if package-supplied-p
                (%import symbol package)
                (%import symbol)))
        (unintern-existing ()
          :report (lambda (s) (format s "Unintern ~S and continue" local-sym))
          (unintern local-sym)
          (%import symbol))
        (skip ()
          :report "Skip symbol"))))
  T)
