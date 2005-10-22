;;; describe.lisp
;;;
;;; Copyright (C) 2005 Peter Graves
;;; $Id: describe.lisp,v 1.5 2005-10-22 19:34:45 piso Exp $
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

(in-package #:system)

(require '#:clos)
(require '#:format)

(defun describe-arglist (object stream)
  (multiple-value-bind
      (arglist known-p)
      (arglist object)
    (when known-p
      (format stream "~&The function's lambda list is:~%  ~A~%" arglist))))

(defun %describe-object (object stream)
  (format stream "~S is an object of type ~S.~%" object (type-of object)))

(defun describe (object &optional stream)
  (describe-object object (out-synonym-of stream))
  (values))

(defmethod describe-object ((object t) stream)
  (let ((*print-pretty* t))
    (typecase object
      (SYMBOL
       (let ((package (symbol-package object)))
         (if package
             (multiple-value-bind
                 (sym status)
                 (find-symbol (symbol-name object) package)
               (format stream "~S is an ~A symbol in the ~A package.~%"
                       object
                       (if (eq status :internal) "internal" "external")
                       (package-name package)))
             (format stream "~S is an uninterned symbol.~%" object))
         (cond ((special-variable-p object)
                (format stream "It is a ~A; "
                        (if (constantp object) "constant" "special variable"))
                (if (boundp object)
                    (format stream "its value is ~S.~%" (symbol-value object))
                    (format stream "it is unbound.~%")))
               ((boundp object)
                (format stream "It is an undefined variable; its value is ~S.~%"
                        (symbol-value object)))))
       (when (autoloadp object)
         (resolve object))
       (let ((function (and (fboundp object) (symbol-function object))))
         (when function
           (format stream "Its function binding is ~S.~%" function)
           (describe-arglist function stream)))
       (let ((doc (documentation object 'function)))
         (when doc
           (format stream "Function documentation:~%  ~A~%" doc)))
       (let ((plist (symbol-plist object)))
         (when plist
           (format stream "The symbol's property list contains these indicator/value pairs:~%")
           (loop
             (when (null plist) (return))
             (format stream "  ~S ~S~%" (car plist) (cadr plist))
             (setf plist (cddr plist))))))
      (FUNCTION
       (%describe-object object stream)
       (describe-arglist object stream))
      (INTEGER
       (%describe-object object stream)
       (format stream "~D.~%~
                       #x~X~%~
                       #o~O~%~
                       #b~B~%"
               object object object object))
      (t
       (%describe-object object stream))))
  (values))

(defmethod describe-object ((object pathname) stream)
  (format stream "~S is an object of type ~S:~%" object (type-of object))
  (format stream " HOST         ~S~%" (pathname-host object))
  (format stream " DEVICE       ~S~%" (pathname-device object))
  (format stream " DIRECTORY    ~S~%" (pathname-directory object))
  (format stream " NAME         ~S~%" (pathname-name object))
  (format stream " TYPE         ~S~%" (pathname-type object))
  (format stream " VERSION      ~S~%" (pathname-version object)))

(defmethod describe-object ((object standard-object) stream)
  (%describe-object object stream)
  (values))
