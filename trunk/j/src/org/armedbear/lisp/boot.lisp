;;; boot.lisp
;;;
;;; Copyright (C) 2003-2004 Peter Graves
;;; $Id: boot.lisp,v 1.197 2004-10-05 17:25:45 piso Exp $
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

(export '(decode-stream-arg))

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



;;; Reading circular data: the #= and ## reader macros (from SBCL)

;;; Objects already seen by CIRCLE-SUBST.
(defvar *sharp-equal-circle-table*)

;; This function is kind of like NSUBLIS, but checks for circularities and
;; substitutes in arrays and structures as well as lists. The first arg is an
;; alist of the things to be replaced assoc'd with the things to replace them.
(defun circle-subst (old-new-alist tree)
  (cond ((not (typep tree
                     '(or cons (array t) structure-object standard-object)))
         (let ((entry (find tree old-new-alist :key #'second)))
           (if entry (third entry) tree)))
        ((null (gethash tree *sharp-equal-circle-table*))
         (setf (gethash tree *sharp-equal-circle-table*) t)
         (cond
          ((typep tree 'structure-object)
           (do ((i 0 (1+ i))
                (end (structure-length tree)))
               ((= i end))
             (let* ((old (%structure-ref tree i))
                    (new (circle-subst old-new-alist old)))
               (unless (eq old new)
                 (%structure-set tree i new)))))
;;           ((typep tree 'standard-object)
;;            (do ((i 1 (1+ i))
;;                 (end (%instance-length tree)))
;;                ((= i end))
;;              (let* ((old (%instance-ref tree i))
;;                     (new (circle-subst old-new-alist old)))
;;                (unless (eq old new)
;;                  (setf (%instance-ref tree i) new)))))
          ((arrayp tree)
           (do ((i 0 (1+ i))
                (end (array-total-size tree)))
               ((>= i end))
             (let* ((old (row-major-aref tree i))
                    (new (circle-subst old-new-alist old)))
               (unless (eq old new)
                 (setf (row-major-aref tree i) new)))))
         (t
          (let ((a (circle-subst old-new-alist (car tree)))
                (d (circle-subst old-new-alist (cdr tree))))
            (unless (eq a (car tree))
              (rplaca tree a))
            (unless (eq d (cdr tree))
              (rplacd tree d)))))
        tree)
  (t tree)))

;;; Sharp-equal works as follows. When a label is assigned (i.e. when
;;; #= is called) we GENSYM a symbol is which is used as an
;;; unforgeable tag. *SHARP-SHARP-ALIST* maps the integer tag to this
;;; gensym.
;;;
;;; When SHARP-SHARP encounters a reference to a label, it returns the
;;; symbol assoc'd with the label. Resolution of the reference is
;;; deferred until the read done by #= finishes. Any already resolved
;;; tags (in *SHARP-EQUAL-ALIST*) are simply returned.
;;;
;;; After reading of the #= form is completed, we add an entry to
;;; *SHARP-EQUAL-ALIST* that maps the gensym tag to the resolved
;;; object. Then for each entry in the *SHARP-SHARP-ALIST, the current
;;; object is searched and any uses of the gensysm token are replaced
;;; with the actual value.

(defvar *sharp-sharp-alist* ())

(defun sharp-equal (stream ignore label)
  (declare (ignore ignore))
  (when *read-suppress* (return-from sharp-equal (values)))
  (unless label
    (error 'reader-error
           :stream stream
           :format-control "Missing label for #="))
  (when (or (assoc label *sharp-sharp-alist*)
            (assoc label *sharp-equal-alist*))
    (error 'reader-error
           :stream stream
           :format-control "Multiply defined label: #~D="
           :format-arguments (list label)))
  (let* ((tag (gensym))
         (*sharp-sharp-alist* (acons label tag *sharp-sharp-alist*))
         (obj (read stream t nil t)))
    (when (eq obj tag)
      (error 'reader-error
             :stream stream
             :format-control "Must tag something more than just #~D#"
             :format-arguments (list label)))
    (push (list label tag obj) *sharp-equal-alist*)
    (let ((*sharp-equal-circle-table* (make-hash-table :test 'eq :size 20)))
      (circle-subst *sharp-equal-alist* obj))))

(defun sharp-sharp (stream ignore label)
  (declare (ignore ignore))
  (when *read-suppress* (return-from sharp-sharp nil))
  (unless label
    (error 'reader-error :stream stream :format-control "Missing label for ##"))
  (let ((entry (assoc label *sharp-equal-alist*)))
    (if entry
        (third entry)
        (let ((pair (assoc label *sharp-sharp-alist*)))
          (unless pair
            (error 'reader-error
                   :stream stream
                   :format-control "Object is not labelled #~S#"
                   :format-arguments (list label)))
          (cdr pair)))))

(set-dispatch-macro-character #\# #\= #'sharp-equal *standard-readtable*)
(set-dispatch-macro-character #\# #\# #'sharp-sharp *standard-readtable*)


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

(defpackage "XP"
  (:use "CL")
  (:export
   #:output-pretty-object))

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

(defun decode-stream-arg (stream)
  (cond ((eq stream t)
         *terminal-io*)
	((null stream)
         *standard-output*)
	(t stream)))

(declaim (notinline decode-stream-arg))

(defun read-from-string (string &optional (eof-error-p t) eof-value
                                &key (start 0) end preserve-whitespace)
  (sys::%read-from-string string eof-error-p eof-value start end preserve-whitespace))

(defconstant lambda-list-keywords
  '(&optional &rest &key &aux &body &whole &allow-other-keys &environment))

(defconstant call-arguments-limit 50)

(defconstant lambda-parameters-limit 50)

(defconstant multiple-values-limit 20)

(defconstant internal-time-units-per-second 1000)

(load-system-file "restart")
(load-system-file "late-setf")
(load-system-file "debug")
(load-system-file "print")
(load-system-file "pprint-dispatch")
(load-system-file "pprint")

(unless (sys::featurep :j)
  (sys::load-system-file "top-level")
  (sys::%format t "Startup completed in ~A seconds.~%" (float (/ (ext:uptime) 1000))))
