;;; boot.lisp
;;;
;;; Copyright (C) 2003-2004 Peter Graves
;;; $Id: boot.lisp,v 1.187 2004-09-07 20:22:06 piso Exp $
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

(sys::%in-package "SYSTEM")

(setq ext:*autoload-verbose* nil)
(setq *load-verbose* nil)

(defmacro in-package (name)
  (list 'sys::%in-package (string name)))

(defmacro lambda (lambda-list &rest body)
  (list 'function (list* 'lambda lambda-list body)))

(defmacro when (pred &rest body)
  (list 'if pred (if (> (length body) 1)
                     (append '(progn) body)
                     (car body))))

(defmacro unless (pred &rest body)
  (list 'if (list 'not pred) (if (> (length body) 1)
                                 (append '(progn) body)
                                 (car body))))

(defmacro return (&optional result)
  (list 'return-from nil result))

(defmacro defun (name lambda-list &rest body)
  (list 'sys::%defun (list 'QUOTE name) (list 'QUOTE lambda-list) (list 'QUOTE body)))

(defmacro defconstant (name initial-value &optional docstring)
  (list 'sys::%defconstant (list 'QUOTE name) initial-value docstring))

(defmacro defparameter (name initial-value &optional docstring)
  (list 'sys::%defparameter (list 'QUOTE name) initial-value docstring))

;; EVAL is redefined in precompiler.lisp.
(defun eval (form)
  (sys::%eval form))

(defun terpri (&optional output-stream)
  (sys::%terpri output-stream))

(defun fresh-line (&optional output-stream)
  (sys::%fresh-line output-stream))

(defun write-char (character &optional output-stream)
  (sys::%write-char character output-stream))

;; SYS::OUTPUT-OBJECT is redefined in print.lisp.
(defun sys::output-object (object stream)
  (sys::%output-object object stream))

(defun print (object &optional stream)
  (terpri stream)
  (let ((*print-escape* t))
    (output-object object stream))
  (write-char #\space stream)
  object)

(defun prin1 (object &optional (stream *standard-output*))
  (let ((*print-escape* t))
    (output-object object stream))
  object)

(defun princ (object &optional (stream *standard-output*))
  (let ((*print-escape* nil)
        (*print-readably* nil))
    (output-object object stream))
  object)

(defun finish-output (&optional output-stream)
  (%finish-output output-stream))

(defun force-output (&optional output-stream)
  (%force-output output-stream))

(defun clear-output (&optional output-stream)
  (%clear-output output-stream))

(defun simple-format (destination control-string &rest args)
  (apply *simple-format-function* destination control-string args))

(export 'simple-format '#:system)

;; INVOKE-DEBUGGER is redefined in debug.lisp.
(defun invoke-debugger (condition)
  (sys::%format t "~A~%" condition)
  (ext:quit))

;; CLASS-NAME is redefined as a generic function when CLOS is loaded.
(defun class-name (class)
  (sys::%class-name class))

(sys:load-system-file "autoloads")
(sys:load-system-file "early-defuns")
(sys:load-system-file "backquote")
(sys:load-system-file "setf")
(sys:load-system-file "documentation")

(defmacro defvar (var &optional (val nil valp) (doc nil docp))
  `(progn
     (sys::%defvar ',var)
     ,@(when valp
	 `((unless (boundp ',var)
	     (setq ,var ,val))))
     ,@(when docp
         `((sys::%set-documentation ',var 'variable ',doc)))
     ',var))

(defun make-package (package-name &key nicknames use)
  (sys::%make-package package-name nicknames use))

(defun make-keyword (symbol)
  (intern (symbol-name symbol) *keyword-package*))

(defun featurep (form)
  (cond ((atom form)
         (ext:memq form *features*))
        ((eq (car form) :not)
         (not (featurep (cadr form))))
        ((eq (car form) :and)
         (dolist (subform (cdr form) t)
           (unless (featurep subform) (return))))
        ((eq (car form) :or)
         (dolist (subform (cdr form) nil)
           (when (featurep subform) (return t))))
        (t
         (error "READ-FEATURE"))))

(export 'featurep '#:system)

;;; READ-CONDITIONAL (from OpenMCL)
(defun read-feature (stream)
  (let* ((f (let* ((*package* sys::*keyword-package*))
              (read stream t nil t))))
    (if (featurep f) #\+ #\-)))

(defun read-conditional (stream subchar int)
  (cond (*read-suppress*
         (read stream t nil t)
         (values))
        ((eql subchar (read-feature stream))
         (read stream t nil t))
        (t
         (let ((*read-suppress* t))
           (read stream t nil t)
           (values)))))

(set-dispatch-macro-character #\# #\+ #'read-conditional *standard-readtable*)
(set-dispatch-macro-character #\# #\- #'read-conditional *standard-readtable*)

(copy-readtable *standard-readtable* *readtable*)

;; SYS::%COMPILE is redefined in precompiler.lisp.
(defun sys::%compile (name definition)
  (values (if name name definition) nil nil))

(load-system-file "macros")
(load-system-file "fixme")
(load-system-file "destructuring-bind")
(load-system-file "arrays")
(load-system-file "compiler-macro")
(load-system-file "subtypep")
(load-system-file "typep")
(load-system-file "precompiler")

(precompile-package "PRECOMPILER")
(precompile-package "EXTENSIONS")
(precompile-package "SYSTEM")
(precompile-package "COMMON-LISP")

(load-system-file "signal")
(load-system-file "list")
(load-system-file "sequences")
(load-system-file "error")
(load-system-file "defpackage")
(load-system-file "define-modify-macro")

;;; Package definitions.
(defpackage "FORMAT" (:use "CL" "EXT"))
(defpackage "XP" (:use "CL"))

;;; PROVIDE, REQUIRE (from SBCL)
(defun provide (module-name)
  (pushnew (string module-name) *modules* :test #'string=)
  t)

(defun require (module-name &optional pathnames)
  (unless (member (string module-name) *modules* :test #'string=)
    (let ((saved-modules (copy-list *modules*)))
      (cond (pathnames
             (unless (listp pathnames) (setf pathnames (list pathnames)))
             (dolist (x pathnames)
               (load x)))
            (t
             (let ((*readtable* (copy-readtable nil)))
               (sys::load-system-file (string-downcase (string module-name))))))
      (set-difference *modules* saved-modules))))

(defun read-from-string (string &optional eof-error-p eof-value
				&key (start 0) end preserve-whitespace)
  (sys::%read-from-string string eof-error-p eof-value start end preserve-whitespace))

(defconstant lambda-list-keywords
  '(&optional &rest &key &aux &body &whole &allow-other-keys &environment))

(defconstant call-arguments-limit 50)

(defconstant lambda-parameters-limit 50)

(defconstant multiple-values-limit 20)

(defconstant internal-time-units-per-second 1000)

(sys::load-system-file "restart")
(sys::load-system-file "late-setf")
(sys::load-system-file "debug")
(sys::load-system-file "print")

(unless (sys::featurep :j)
  (sys::load-system-file "top-level")
  (sys::%format t "Startup completed in ~A seconds.~%" (float (/ (ext:uptime) 1000))))
