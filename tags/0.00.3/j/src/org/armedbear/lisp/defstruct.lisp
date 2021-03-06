;;; defstruct.lisp
;;;
;;; Copyright (C) 2003 Peter Graves
;;; $Id: defstruct.lisp,v 1.27 2003-10-05 18:37:59 piso Exp $
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

(defvar *ds-name*)
(defvar *ds-conc-name*)
(defvar *ds-constructors*)
(defvar *ds-copier*)
(defvar *ds-named*)
(defvar *ds-predicate*)
(defvar *ds-print-function*)

(defun define-constructor (constructor slots)
  (let* ((constructor-name (intern (car constructor)))
         (slot-names (mapcar #'(lambda (x) (if (atom x) x (car x))) slots))
         (inits (mapcar #'(lambda (x) (if (atom x) nil (cadr x))) slots))
         (slot-descriptions (mapcar #'(lambda (x y) (list x y)) slot-names inits))
         (keys (cons '&key slot-descriptions)))
    `((defun ,constructor-name ,keys
        (%make-structure ',*ds-name* (list ,@slot-names))))))

(defun default-constructor-name ()
  (concatenate 'string "MAKE-" (symbol-name *ds-name*)))

(defun define-constructors (slots)
  (if *ds-constructors*
      (let ((results ()))
        (dolist (constructor *ds-constructors*)
          (when (car constructor)
            (setf results (append results (define-constructor constructor slots)))))
        results)
      (define-constructor (cons (default-constructor-name) nil) slots)))

(defun define-predicate ()
  (when *ds-predicate*
    (let ((pred (intern *ds-predicate*)))
      `((defun ,pred (object)
          (typep object ',*ds-name*))))))


(defmacro get-slot-accessor (slot)
  (case slot
    (0 #'%structure-ref-0)
    (1 #'%structure-ref-1)
    (2 #'%structure-ref-2)
    (t
     `(lambda (instance) (%structure-ref instance ,slot)))))

(defmacro get-slot-mutator (slot)
  (case slot
    (0 #'%structure-set-0)
    (1 #'%structure-set-1)
    (2 #'%structure-set-2)
    (t
     `(lambda (instance value) (%structure-set instance ,slot value)))))

(defun define-access-function (slot-name index)
  (let ((accessor
         (if *ds-conc-name*
             (intern (concatenate 'string (symbol-name *ds-conc-name*) (symbol-name slot-name)))
             slot-name)))
    `((setf (symbol-function ',accessor) (get-slot-accessor ,index))
      (%put ',accessor 'setf-inverse (get-slot-mutator ,index)))))

(defun define-access-functions (slots)
  (let ((index 0)
        (result ()))
    (dolist (slot slots)
      (let ((slot-name (if (atom slot) slot (car slot))))
        (setf result (append result (define-access-function slot-name index))))
      (incf index))
    result))

(defun define-copier ()
  (when *ds-copier*
    `((setf (fdefinition ',*ds-copier*) #'copy-structure))))

(defun parse-1-option (option)
  (case (car option)
    (:conc-name
     (setf *ds-conc-name* (if (symbolp (cadr option))
                              (cadr option)
                              (make-symbol (string (cadr option))))))
    (:constructor
     (let* ((args (cdr option))
            (numargs (length args))
            name arglist)
       (case numargs
         (0 ; Use default name.
          (setf name (default-constructor-name))
          (setf arglist nil)
          (push (list name arglist) *ds-constructors*))
         (1
          (if (null (car args))
              (setf name nil) ; No constructor.
              (setf name (symbol-name (car args))))
          (setf arglist nil)
          (push (list name arglist) *ds-constructors*))
         (2))))
    (:copier
     (let* ((args (cdr option))
            (numargs (length args)))
       (when (= numargs 1)
          (setf *ds-copier* (car args)))))
    (:predicate
     (when (= (length option) 2)
       (if (null (cadr option))
           (setf *ds-predicate* nil)
           (setf *ds-predicate* (symbol-name (cadr option))))))))

(defun parse-name-and-options (name-and-options)
  (setf *ds-name* (car name-and-options))
  (setf *ds-conc-name* (make-symbol (concatenate 'string (symbol-name *ds-name*) "-")))
  (setf *ds-copier* (intern (concatenate 'string "COPY-" (symbol-name *ds-name*))))
  (setf *ds-predicate* (concatenate 'string (symbol-name *ds-name*) "-P"))
  (let ((options (cdr name-and-options)))
    (dolist (option options)
      (cond ((consp option)
             (parse-1-option option))
            ((eq option :named)
             (setf *ds-named* t))
            ((member option '(:constructor :copier :predicate :named
                              :conc-name))
             (parse-1-option (list option)))
            (t
             (error "unrecognized DEFSTRUCT option: ~S" option))))))

(defmacro defstruct (name-and-options &rest slots)
  (let ((*ds-name* nil)
        (*ds-conc-name* nil)
        (*ds-constructors* nil)
        (*ds-copier* nil)
        (*ds-predicate* nil)
        (*ds-print-function* nil))
    (parse-name-and-options (if (atom name-and-options)
                                (list name-and-options)
                                name-and-options))
    (when (stringp (car slots))
      (setf (documentation *ds-name* 'structure) (pop slots)))
    `(progn
       (make-structure-class ',*ds-name*)
       ,@(define-constructors slots)
       ,@(define-predicate)
       ,@(define-access-functions slots)
       ,@(define-copier)
       ',*ds-name*)))

(provide 'defstruct)
