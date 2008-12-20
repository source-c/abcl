;;; subtypep.lisp
;;;
;;; Copyright (C) 2003-2005 Peter Graves
;;; $Id$
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
;;;
;;; As a special exception, the copyright holders of this library give you
;;; permission to link this library with independent modules to produce an
;;; executable, regardless of the license terms of these independent
;;; modules, and to copy and distribute the resulting executable under
;;; terms of your choice, provided that you also meet, for each linked
;;; independent module, the terms and conditions of the license of that
;;; module.  An independent module is a module which is not derived from
;;; or based on this library.  If you modify this library, you may extend
;;; this exception to your version of the library, but you are not
;;; obligated to do so.  If you do not wish to do so, delete this
;;; exception statement from your version.

(in-package #:system)

(defparameter *known-types* (make-hash-table :test 'eq))

(defun initialize-known-types ()
  (let ((ht (make-hash-table :test 'eq)))
    (dolist (i '((ARITHMETIC-ERROR ERROR)
                 (ARRAY)
                 (BASE-STRING STRING)
                 (BIGNUM INTEGER)
                 (BIT FIXNUM)
                 (BIT-VECTOR VECTOR)
                 (BOOLEAN SYMBOL)
                 (BUILT-IN-CLASS CLASS)
                 (CELL-ERROR ERROR)
                 (CHARACTER)
                 (CLASS STANDARD-OBJECT)
                 (COMPILED-FUNCTION FUNCTION)
                 (COMPLEX NUMBER)
                 (CONDITION)
                 (CONS LIST)
                 (CONTROL-ERROR ERROR)
                 (DIVISION-BY-ZERO ARITHMETIC-ERROR)
                 (DOUBLE-FLOAT FLOAT)
                 (END-OF-FILE STREAM-ERROR)
                 (ERROR SERIOUS-CONDITION)
                 (EXTENDED-CHAR CHARACTER NIL)
                 (FILE-ERROR ERROR)
                 (FIXNUM INTEGER)
                 (FLOAT REAL)
                 (FLOATING-POINT-INEXACT ARITHMETIC-ERROR)
                 (FLOATING-POINT-INVALID-OPERATION ARITHMETIC-ERROR)
                 (FLOATING-POINT-OVERFLOW ARITHMETIC-ERROR)
                 (FLOATING-POINT-UNDERFLOW ARITHMETIC-ERROR)
                 (FUNCTION)
                 (GENERIC-FUNCTION FUNCTION)
                 (HASH-TABLE)
                 (INTEGER RATIONAL)
                 (KEYWORD SYMBOL)
                 (LIST SEQUENCE)
                 (LONG-FLOAT FLOAT)
                 (NIL-VECTOR SIMPLE-STRING)
                 (NULL BOOLEAN LIST)
                 (NUMBER)
                 (PACKAGE)
                 (PACKAGE-ERROR ERROR)
                 (PARSE-ERROR ERROR)
                 (PATHNAME)
                 (PRINT-NOT-READABLE ERROR)
                 (PROGRAM-ERROR ERROR)
                 (RANDOM-STATE)
                 (RATIO RATIONAL)
                 (RATIONAL REAL)
                 (READER-ERROR PARSE-ERROR STREAM-ERROR)
                 (READTABLE)
                 (REAL NUMBER)
                 (RESTART)
                 (SERIOUS-CONDITION CONDITION)
                 (SHORT-FLOAT FLOAT)
                 (SIMPLE-ARRAY ARRAY)
                 (SIMPLE-BASE-STRING SIMPLE-STRING BASE-STRING)
                 (SIMPLE-BIT-VECTOR BIT-VECTOR SIMPLE-ARRAY)
                 (SIMPLE-CONDITION CONDITION)
                 (SIMPLE-ERROR SIMPLE-CONDITION ERROR)
                 (SIMPLE-STRING STRING SIMPLE-ARRAY)
                 (SIMPLE-TYPE-ERROR SIMPLE-CONDITION TYPE-ERROR)
                 (SIMPLE-VECTOR VECTOR SIMPLE-ARRAY)
                 (SIMPLE-WARNING SIMPLE-CONDITION WARNING)
                 (SINGLE-FLOAT FLOAT)
                 (STANDARD-CHAR CHARACTER)
                 (STANDARD-CLASS CLASS)
                 (STANDARD-GENERIC-FUNCTION GENERIC-FUNCTION)
                 (STANDARD-OBJECT)
                 (STORAGE-CONDITION SERIOUS-CONDITION)
                 (STREAM)
                 (STREAM-ERROR ERROR)
                 (STRING VECTOR)
                 (STRUCTURE-CLASS CLASS STANDARD-OBJECT)
                 (STYLE-WARNING WARNING)
                 (SYMBOL)
                 (TWO-WAY-STREAM STREAM)
                 (TYPE-ERROR ERROR)
                 (UNBOUND-SLOT CELL-ERROR)
                 (UNBOUND-VARIABLE CELL-ERROR)
                 (UNDEFINED-FUNCTION CELL-ERROR)
                 (VECTOR ARRAY SEQUENCE)
                 (WARNING CONDITION)))
    (setf (gethash (%car i) ht) (%cdr i)))
    (setf *known-types* ht)))

(initialize-known-types)

(defun known-type-p (type)
  (multiple-value-bind (value present-p) (gethash type *known-types*)
    present-p))

(defun sub-interval-p (i1 i2)
  (let (low1 high1 low2 high2)
    (if (null i1)
        (setq low1 '* high1 '*)
        (if (null (cdr i1))
            (setq low1 (car i1) high1 '*)
            (setq low1 (car i1) high1 (cadr i1))))
    (if (null i2)
        (setq low2 '* high2 '*)
        (if (null (cdr i2))
            (setq low2 (car i2) high2 '*)
            (setq low2 (car i2) high2 (cadr i2))))
    (when (and (consp low1) (integerp (%car low1)))
      (setq low1 (1+ (car low1))))
    (when (and (consp low2) (integerp (%car low2)))
      (setq low2 (1+ (car low2))))
    (when (and (consp high1) (integerp (%car high1)))
      (setq high1 (1- (car high1))))
    (when (and (consp high2) (integerp (%car high2)))
      (setq high2 (1- (car high2))))
    (cond ((eq low1 '*)
	   (unless (eq low2 '*)
	           (return-from sub-interval-p nil)))
          ((eq low2 '*))
	  ((consp low1)
	   (if (consp low2)
	       (when (< (%car low1) (%car low2))
		     (return-from sub-interval-p nil))
	       (when (< (%car low1) low2)
		     (return-from sub-interval-p nil))))
	  ((if (consp low2)
	       (when (<= low1 (%car low2))
		     (return-from sub-interval-p nil))
	       (when (< low1 low2)
		     (return-from sub-interval-p nil)))))
    (cond ((eq high1 '*)
	   (unless (eq high2 '*)
	           (return-from sub-interval-p nil)))
          ((eq high2 '*))
	  ((consp high1)
	   (if (consp high2)
	       (when (> (%car high1) (%car high2))
		     (return-from sub-interval-p nil))
	       (when (> (%car high1) high2)
		     (return-from sub-interval-p nil))))
	  ((if (consp high2)
	       (when (>= high1 (%car high2))
		     (return-from sub-interval-p nil))
	       (when (> high1 high2)
		     (return-from sub-interval-p nil)))))
    (return-from sub-interval-p t)))

(defun dimension-subtypep (dim1 dim2)
  (cond ((eq dim2 '*)
         t)
        ((equal dim1 dim2)
         t)
        ((integerp dim2)
         (and (listp dim1) (= (length dim1) dim2)))
        ((eql dim1 0)
         (null dim2))
        ((integerp dim1)
         (and (consp dim2)
              (= (length dim2) dim1)
              (equal dim2 (make-list dim1 :initial-element '*))))
        ((and (consp dim1) (consp dim2) (= (length dim1) (length dim2)))
         (do* ((list1 dim1 (cdr list1))
               (list2 dim2 (cdr list2))
               (e1 (car list1) (car list1))
               (e2 (car list2) (car list2)))
              ((null list1) t)
           (unless (or (eq e2 '*) (eql e1 e2))
              (return nil))))
        (t
         nil)))

(defun simple-subtypep (type1 type2)
  (if (eq type1 type2)
      t
      (multiple-value-bind (type1-supertypes type1-known-p)
          (gethash type1 *known-types*)
        (if type1-known-p
            (if (memq type2 type1-supertypes)
                t
                (dolist (supertype type1-supertypes)
                  (when (simple-subtypep supertype type2)
                    (return t))))
            nil))))

;; (defstruct ctype
;;   ((:constructor make-ctype (super type)))
;;   super
;;   type)

(defun make-ctype (super type)
  (cons super type))

(defun ctype-super (ctype)
  (car ctype))

(defun ctype-type (ctype)
  (cdr ctype))

(defun ctype (type)
  (cond ((classp type)
         nil)
        (t
         (let ((tp (if (atom type) type (car type))))
           (case tp
             ((ARRAY VECTOR STRING SIMPLE-ARRAY SIMPLE-STRING BASE-STRING
               SIMPLE-BASE-STRING BIT-VECTOR SIMPLE-BIT-VECTOR NIL-VECTOR)
              (make-ctype 'ARRAY type))
             ((REAL INTEGER BIT FIXNUM SIGNED-BYTE UNSIGNED-BYTE BIGNUM RATIO
               FLOAT SINGLE-FLOAT DOUBLE-FLOAT SHORT-FLOAT LONG-FLOAT)
              (make-ctype 'REAL type))
             (COMPLEX
              (make-ctype 'COMPLEX
                          (if (atom type) '* (cadr type))))
             (FUNCTION
              (make-ctype 'FUNCTION type)))))))

(defun csubtypep-array (ct1 ct2)
  (let ((type1 (normalize-type (ctype-type ct1)))
        (type2 (normalize-type (ctype-type ct2))))
  (when (eq type1 type2)
    (return-from csubtypep-array (values t t)))
  (let (t1 t2 i1 i2)
    (if (atom type1)
        (setf t1 type1 i1 nil)
        (setf t1 (car type1) i1 (cdr type1)))
    (if (atom type2)
        (setf t2 type2 i2 nil)
        (setf t2 (car type2) i2 (cdr type2)))
    (cond ((and (classp t1) (eq (%class-name t1) 'array) (eq t2 'array))
           (values (equal i2 '(* *)) t))
          ((and (memq t1 '(array simple-array)) (eq t2 'array))
           (let ((e1 (car i1))
                 (e2 (car i2))
                 (d1 (cadr i1))
                 (d2 (cadr i2)))
             (cond ((and (eq e2 '*) (eq d2 '*))
                    (values t t))
                   ((or (eq e2 '*)
                        (equal e1 e2)
                        (equal (upgraded-array-element-type e1)
                               (upgraded-array-element-type e2)))
                    (values (dimension-subtypep d1 d2) t))
                   (t
                    (values nil t)))))
          ((and (memq t1 '(simple-base-string base-string simple-string string nil-vector))
                (memq t2 '(simple-base-string base-string simple-string string nil-vector)))
           (if (and (simple-subtypep t1 t2)
                    (or (eql (car i1) (car i2))
                        (eq (car i2) '*)))
               (return-from csubtypep-array (values t t))
               (return-from csubtypep-array (values nil t))))
          ((and (memq t1 '(array simple-array)) (eq t2 'string))
           (let ((element-type (car i1))
                 (dim (cadr i1))
                 (size (car i2)))
             (unless (%subtypep element-type 'character)
               (return-from csubtypep-array (values nil t)))
             (when (integerp size)
               (if (and (consp dim) (= (length dim) 1) (eql (%car dim) size))
                   (return-from csubtypep-array (values t t))
                   (return-from csubtypep-array (values nil t))))
             (when (or (null size) (eql size '*))
               (if (or (eql dim 1)
                       (and (consp dim) (= (length dim) 1)))
                   (return-from csubtypep-array (values t t))
                   (return-from csubtypep-array (values nil t))))))
          ((and (eq t1 'simple-array) (eq t2 'simple-string))
           (let ((element-type (car i1))
                 (dim (cadr i1))
                 (size (car i2)))
             (unless (%subtypep element-type 'character)
               (return-from csubtypep-array (values nil t)))
             (when (integerp size)
               (if (and (consp dim) (= (length dim) 1) (eql (%car dim) size))
                   (return-from csubtypep-array (values t t))
                   (return-from csubtypep-array (values nil t))))
             (when (or (null size) (eql size '*))
               (if (or (eql dim 1)
                       (and (consp dim) (= (length dim) 1)))
                   (return-from csubtypep-array (values t t))
                   (return-from csubtypep-array (values nil t))))))
          ((and (memq t1 '(string simple-string nil-vector)) (eq t2 'array))
           (let ((element-type (car i2))
                 (dim (cadr i2))
                 (size (car i1)))
             (unless (eq element-type '*)
               (return-from csubtypep-array (values nil t)))
             (when (integerp size)
               (if (or (eq dim '*)
                       (eql dim 1)
                       (and (consp dim)
                            (= (length dim) 1)
                            (or (eq (%car dim) '*)
                                (eql (%car dim) size))))
                   (return-from csubtypep-array (values t t))
                   (return-from csubtypep-array (values nil t))))
             (when (or (null size) (eql size '*))
               (if (or (eq dim '*)
                       (eql dim 1)
                       (and (consp dim) (= (length dim) 1)))
                   (return-from csubtypep-array (values t t))
                   (return-from csubtypep-array (values nil t))))))
          ((and (memq t1 '(bit-vector simple-bit-vector)) (eq t2 'array))
           (let ((element-type (car i2))
                 (dim (cadr i2))
                 (size (car i1)))
             (unless (or (memq element-type '(bit *))
                         (equal element-type '(integer 0 1)))
               (return-from csubtypep-array (values nil t)))
             (when (integerp size)
               (if (or (eq dim '*)
                       (eql dim 1)
                       (and (consp dim)
                            (= (length dim) 1)
                            (or (eq (%car dim) '*)
                                (eql (%car dim) size))))
                   (return-from csubtypep-array (values t t))
                   (return-from csubtypep-array (values nil t))))
             (when (or (null size) (eql size '*))
               (if (or (eq dim '*)
                       (eql dim 1)
                       (and (consp dim) (= (length dim) 1)))
                   (return-from csubtypep-array (values t t))
                   (return-from csubtypep-array (values nil t))))))
          ((eq t2 'simple-array)
           (case t1
             (simple-array
              (let ((e1 (car i1))
                    (e2 (car i2))
                    (d1 (cadr i1))
                    (d2 (cadr i2)))
                (cond ((and (eq e2 '*) (eq d2 '*))
                       (values t t))
                      ((or (eq e2 '*)
                           (equal e1 e2)
                           (equal (upgraded-array-element-type e1)
                                  (upgraded-array-element-type e2)))
                       (values (dimension-subtypep d1 d2) t))
                      (t
                       (values nil t)))))
             ((simple-string simple-bit-vector nil-vector)
              (let ((element-type (car i2))
                    (dim (cadr i2))
                    (size (car i1)))
                (unless (eq element-type '*)
                  (return-from csubtypep-array (values nil t)))
                (when (integerp size)
                  (if (or (eq dim '*)
                          (and (consp dim) (= (length dim) 1) (eql (%car dim) size)))
                      (return-from csubtypep-array (values t t))
                      (return-from csubtypep-array (values nil t))))
                (when (or (null size) (eql size '*))
                  (if (or (eq dim '*)
                          (eql dim 1)
                          (and (consp dim) (= (length dim) 1)))
                      (return-from csubtypep-array (values t t))
                      (return-from csubtypep-array (values nil t))))))
             (t
              (values nil t))))
          ((eq t2 'bit-vector)
           (let ((size1 (car i1))
                 (size2 (car i2)))
             (case t1
               ((bit-vector simple-bit-vector)
                (values (if (or (eq size2 '*) (eql size1 size2))
                            t
                            nil) t))
               (t
                (values nil t)))))
          ((eq t2 'simple-bit-vector)
           (let ((size1 (car i1))
                 (size2 (car i2)))
             (if (and (eq t1 'simple-bit-vector)
                      (or (eq size2 '*)
                          (eql size1 size2)))
                 (values t t)
                 (values nil t))))
          ((classp t2)
           (let ((class-name (%class-name t2)))
             (cond ((eq class-name t1)
                    (values t t))
                   ((and (eq class-name 'array)
                         (memq t1 '(array simple-array vector simple-vector string
                                    simple-string simple-base-string bit-vector
                                    simple-bit-vector)))
                    (values t t))
                   ((eq class-name 'vector)
                    (cond ((memq t1 '(string simple-string))
                           (values t t))
                          ((eq t1 'array)
                           (let ((dim (cadr i1)))
                             (if (or (eql dim 1)
                                     (and (consp dim) (= (length dim) 1)))
                                 (values t t)
                                 (values nil t))))
                          (t
                           (values nil t))))
                   ((and (eq class-name 'simple-vector)
                         (eq t1 'simple-array))
                    (let ((dim (cadr i1)))
                      (if (or (eql dim 1)
                              (and (consp dim) (= (length dim) 1)))
                          (values t t)
                          (values nil t))))
                   ((and (eq class-name 'bit-vector)
                         (eq t1 'simple-bit-vector))
                    (values t t))
                   ((and (eq class-name 'string)
                         (memq t1 '(string simple-string)))
                    (values t t))
                   (t
                    (values nil nil)))))
          (t
           (values nil nil))))))

(defun csubtypep-function (ct1 ct2)
  (let ((type1 (ctype-type ct1))
        (type2 (ctype-type ct2)))
    (cond ((and (listp type1) (atom type2))
           (values t t))
          (t
           (values nil nil)))))

(defun csubtypep-complex (ct1 ct2)
  (let ((type1 (cdr ct1))
        (type2 (cdr ct2)))
    (cond ((or (null type2) (eq type2 '*))
           (values t t))
          ((eq type1 '*)
           (values nil t))
          (t
           (subtypep type1 type2)))))

(defun csubtypep (ctype1 ctype2)
  (cond ((null (and ctype1 ctype2))
         (values nil nil))
        ((neq (ctype-super ctype1) (ctype-super ctype2))
         (values nil t))
        ((eq (ctype-super ctype1) 'array)
         (csubtypep-array ctype1 ctype2))
        ((eq (ctype-super ctype1) 'function)
         (csubtypep-function ctype1 ctype2))
        ((eq (ctype-super ctype1) 'complex)
         (csubtypep-complex ctype1 ctype2))
        (t
         (values nil nil))))

(defun %subtypep (type1 type2)
  (when (or (eq type1 type2)
            (null type1)
            (eq type2 t)
            (and (classp type2) (eq (%class-name type2) t)))
    (return-from %subtypep (values t t)))
  (let ((ct1 (ctype type1))
        (ct2 (ctype type2)))
    (multiple-value-bind (subtype-p valid-p)
        (csubtypep ct1 ct2)
      (when valid-p
        (return-from %subtypep (values subtype-p valid-p)))))
  (when (and (atom type1) (atom type2))
    (let* ((classp-1 (classp type1))
           (classp-2 (classp type2))
           class1 class2)
      (when (and (setf class1 (if classp-1
                                  type1
                                  (and (symbolp type1) (find-class type1 nil))))
                 (setf class2 (if classp-2
                                  type2
                                  (and (symbolp type2) (find-class type2 nil)))))
        (return-from %subtypep (values (subclassp class1 class2) t)))
      (when (or classp-1 classp-2)
        (let ((t1 (if classp-1 (%class-name type1) type1))
              (t2 (if classp-2 (%class-name type2) type2)))
          (return-from %subtypep (values (simple-subtypep t1 t2) t))))))
  (setf type1 (normalize-type type1)
        type2 (normalize-type type2))
  (when (eq type1 type2)
    (return-from %subtypep (values t t)))
  (let (t1 t2 i1 i2)
    (if (atom type1)
        (setf t1 type1 i1 nil)
        (setf t1 (%car type1) i1 (%cdr type1)))
    (if (atom type2)
        (setf t2 type2 i2 nil)
        (setf t2 (%car type2) i2 (%cdr type2)))
    (cond ((null t1)
           (return-from %subtypep (values t t)))
          ((eq t1 'atom)
           (return-from %subtypep (values (eq t2 t) t)))
          ((eq t2 'atom)
           (return-from %subtypep (cond ((memq t1 '(cons list sequence))
                                        (values nil t))
                                       (t
                                        (values t t)))))
          ((eq t1 'member)
           (dolist (e i1)
             (unless (typep e type2) (return-from %subtypep (values nil t))))
           (return-from %subtypep (values t t)))
          ((eq t1 'eql)
           (case t2
             (EQL
              (return-from %subtypep (values (eql (car i1) (car i2)) t)))
             (SATISFIES
              (return-from %subtypep (values (funcall (car i2) (car i1)) t)))
             (t
              (return-from %subtypep (values (typep (car i1) type2) t)))))
          ((eq t1 'or)
           (dolist (tt i1)
             (multiple-value-bind (tv flag) (%subtypep tt type2)
               (unless tv (return-from %subtypep (values tv flag)))))
           (return-from %subtypep (values t t)))
          ((eq t1 'and)
           (dolist (tt i1)
             (let ((tv (%subtypep tt type2)))
               (when tv (return-from %subtypep (values t t)))))
           (return-from %subtypep (values nil nil)))
          ((eq t1 'cons)
           (case t2
             ((LIST SEQUENCE)
              (return-from %subtypep (values t t)))
             (CONS
              (when (and (%subtypep (car i1) (car i2))
                         (%subtypep (cadr i1) (cadr i2)))
                (return-from %subtypep (values t t)))))
           (return-from %subtypep (values nil (known-type-p t2))))
          ((eq t2 'or)
           (dolist (tt i2)
             (let ((tv (%subtypep type1 tt)))
               (when tv (return-from %subtypep (values t t)))))
           (return-from %subtypep (values nil nil)))
          ((eq t2 'and)
           (dolist (tt i2)
             (multiple-value-bind (tv flag) (%subtypep type1 tt)
               (unless tv (return-from %subtypep (values tv flag)))))
           (return-from %subtypep (values t t)))
          ((null (or i1 i2))
           (return-from %subtypep (values (simple-subtypep t1 t2) t)))
          ((eq t2 'SEQUENCE)
           (cond ((memq t1 '(null cons list))
                  (values t t))
                 ((memq t1 '(simple-base-string base-string simple-string string nil-vector))
                  (values t t))
                 ((memq t1 '(bit-vector simple-bit-vector))
                  (values t t))
                 ((memq t1 '(array simple-array))
                  (cond ((and (cdr i1) (consp (cadr i1)) (null (cdadr i1)))
                         (values t t))
                        ((and (cdr i1) (eql (cadr i1) 1))
                         (values t t))
                        (t
                         (values nil t))))
                 (t (values nil (known-type-p t1)))))
          ((eq t1 'integer)
           (cond ((memq t2 '(integer rational real number))
                  (values (sub-interval-p i1 i2) t))
                 ((or (eq t2 'bignum)
                      (and (classp t2) (eq (%class-name t2) 'bignum)))
                  (values
                   (or (sub-interval-p i1 (list '* (list most-negative-fixnum)))
                       (sub-interval-p i1 (list (list most-positive-fixnum) '*)))
                   t))
                 (t
                  (values nil (known-type-p t2)))))
          ((eq t1 'rational)
           (if (memq t2 '(rational real number))
               (values (sub-interval-p i1 i2) t)
               (values nil (known-type-p t2))))
          ((eq t1 'float)
           (if (memq t2 '(float real number))
               (values (sub-interval-p i1 i2) t)
               (values nil (known-type-p t2))))
          ((memq t1 '(single-float short-float))
           (if (memq t2 '(single-float short-float float real number))
               (values (sub-interval-p i1 i2) t)
               (values nil (known-type-p t2))))
          ((memq t1 '(double-float long-float))
           (if (memq t2 '(double-float long-float float real number))
               (values (sub-interval-p i1 i2) t)
               (values nil (known-type-p t2))))
          ((eq t1 'real)
           (if (memq t2 '(real number))
               (values (sub-interval-p i1 i2) t)
               (values nil (known-type-p t2))))
          ((eq t1 'complex)
           (cond ((eq t2 'number)
                  (values t t))
                 ((eq t2 'complex)
                  (cond ((equal i2 '(*))
                         (values t t))
                        ((equal i1 '(*))
                         (values nil t))
                        (t
                         (values (subtypep (car i1) (car i2)) t))))))
          ((and (classp t1)
                (eq (%class-name t1) 'array)
                (eq t2 'array))
           (values (equal i2 '(* *)) t))
          ((and (memq t1 '(array simple-array)) (eq t2 'array))
           (let ((e1 (car i1))
                 (e2 (car i2))
                 (d1 (cadr i1))
                 (d2 (cadr i2)))
             (cond ((and (eq e2 '*) (eq d2 '*))
                    (values t t))
                   ((or (eq e2 '*)
                        (equal e1 e2)
                        (equal (upgraded-array-element-type e1)
                               (upgraded-array-element-type e2)))
                    (values (dimension-subtypep d1 d2) t))
                   (t
                    (values nil t)))))
          ((and (memq t1 '(array simple-array)) (eq t2 'string))
           (let ((element-type (car i1))
                 (dim (cadr i1))
                 (size (car i2)))
             (unless (%subtypep element-type 'character)
               (return-from %subtypep (values nil t)))
             (when (integerp size)
               (if (and (consp dim) (= (length dim) 1) (eql (%car dim) size))
                   (return-from %subtypep (values t t))
                   (return-from %subtypep (values nil t))))
             (when (or (null size) (eql size '*))
               (if (or (eql dim 1)
                       (and (consp dim) (= (length dim) 1)))
                   (return-from %subtypep (values t t))
                   (return-from %subtypep (values nil t))))))
          ((and (eq t1 'simple-array) (eq t2 'simple-string))
           (let ((element-type (car i1))
                 (dim (cadr i1))
                 (size (car i2)))
             (unless (%subtypep element-type 'character)
               (return-from %subtypep (values nil t)))
             (when (integerp size)
               (if (and (consp dim) (= (length dim) 1) (eql (%car dim) size))
                   (return-from %subtypep (values t t))
                   (return-from %subtypep (values nil t))))
             (when (or (null size) (eql size '*))
               (if (or (eql dim 1)
                       (and (consp dim) (= (length dim) 1)))
                   (return-from %subtypep (values t t))
                   (return-from %subtypep (values nil t))))))
          ((and (memq t1 '(string simple-string)) (eq t2 'array))
           (let ((element-type (car i2))
                 (dim (cadr i2))
                 (size (car i1)))
             (unless (eq element-type '*)
               (return-from %subtypep (values nil t)))
             (when (integerp size)
               (if (or (eq dim '*)
                       (and (consp dim) (= (length dim) 1) (eql (%car dim) size)))
                   (return-from %subtypep (values t t))
                   (return-from %subtypep (values nil t))))
             (when (or (null size) (eql size '*))
               (if (or (eq dim '*)
                       (eql dim 1)
                       (and (consp dim) (= (length dim) 1)))
                   (return-from %subtypep (values t t))
                   (return-from %subtypep (values nil t))))))
          ((eq t2 'simple-array)
           (case t1
             (simple-array
              (let ((e1 (car i1))
                    (e2 (car i2))
                    (d1 (cadr i1))
                    (d2 (cadr i2)))
                (cond ((and (eq e2 '*) (eq d2 '*))
                       (values t t))
                      ((or (eq e2 '*)
                           (equal e1 e2)
                           (equal (upgraded-array-element-type e1)
                                  (upgraded-array-element-type e2)))
                       (values (dimension-subtypep d1 d2) t))
                      (t
                       (values nil t)))))
             ((simple-string simple-bit-vector)
              (let ((element-type (car i2))
                    (dim (cadr i2))
                    (size (car i1)))
                (unless (eq element-type '*)
                  (return-from %subtypep (values nil t)))
                (when (integerp size)
                  (if (or (eq dim '*)
                          (and (consp dim) (= (length dim) 1) (eql (%car dim) size)))
                      (return-from %subtypep (values t t))
                      (return-from %subtypep (values nil t))))
                (when (or (null size) (eql size '*))
                  (if (or (eq dim '*)
                          (eql dim 1)
                          (and (consp dim) (= (length dim) 1)))
                      (return-from %subtypep (values t t))
                      (return-from %subtypep (values nil t))))))
             (t
              (values nil t))))
          ((eq t2 'bit-vector)
           (let ((size1 (car i1))
                 (size2 (car i2)))
             (case t1
               ((bit-vector simple-bit-vector)
                (values (if (or (eq size2 '*) (eql size1 size2))
                            t
                            nil) t))
               (t
                (values nil t)))))
          ((classp t2)
           (let ((class-name (%class-name t2)))
             (cond ((eq class-name t1)
                    (values t t))
                   ((and (eq class-name 'array)
                         (memq t1 '(array simple-array vector simple-vector string
                                    simple-string simple-base-string bit-vector
                                    simple-bit-vector)))
                    (values t t))
                   ((eq class-name 'vector)
                    (cond ((memq t1 '(string simple-string))
                           (values t t))
                          ((memq t1 '(array simple-array))
                           (let ((dim (cadr i1)))
                             (if (or (eql dim 1)
                                     (and (consp dim) (= (length dim) 1)))
                                 (values t t)
                                 (values nil t))))
                          (t
                           (values nil t))))
                   ((and (eq class-name 'simple-vector)
                         (eq t1 'simple-array))
                    (let ((dim (cadr i1)))
                      (if (or (eql dim 1)
                              (and (consp dim) (= (length dim) 1)))
                          (values t t)
                          (values nil t))))
                   ((and (eq class-name 'bit-vector)
                         (eq t1 'simple-bit-vector))
                    (values t t))
                   ((and (eq class-name 'string)
                         (memq t1 '(string simple-string)))
                    (values t t))
                   (t
                    (values nil nil)))))
          (t
           (values nil nil)))))

(defun subtypep (type1 type2 &optional environment)
  (declare (ignore environment))
  (%subtypep type1 type2))
