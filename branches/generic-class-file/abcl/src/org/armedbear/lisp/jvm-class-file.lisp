;;; jvm-class-file.lisp
;;;
;;; Copyright (C) 2010 Erik Huelsmann
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
;;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
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

(in-package "JVM")

#|

The general design of the class-file writer is to have generic
- human readable - representations of the class being generated
during the construction and manipulation phases.

After completing the creation/manipulation of the class, all its
components will be finalized. This process translates readable
(e.g. string) representations to indices to be stored on disc.

The only thing to be done after finalization is sending the
output to a stream ("writing").


Finalization happens highest-level first. As an example, take a
method with exception handlers. The exception handlers are stored
as attributes in the class file structure. They are children of the
method's Code attribute. In this example, the body of the Code
attribute (the higher level) gets finalized before the attributes.
The reason to do so is that the exceptions need to refer to labels
(offsets) in the Code segment.


|#


(defun map-primitive-type (type)
  (case type
    (:int        "I")
    (:long       "J")
    (:float      "F")
    (:double     "D")
    (:boolean    "Z")
    (:char       "C")
    (:byte       "B")
    (:short      "S")
    ((nil :void) "V")))


#|

The `class-name' facility helps to abstract from "this instruction takes
a reference" and "this instruction takes a class name". We simply pass
the class name around and the instructions themselves know which
representation to use.

|#

(defstruct (class-name (:conc-name class-)
                       (:constructor %make-class-name))
  name-internal
  ref
  array-ref)

(defun make-class-name (name)
  (setf name (substitute #\/ #\. name))
  (%make-class-name :name-internal name
                    :ref (concatenate 'string "L" name ";")
                    :array-ref (concatenate 'string "[L" name ";")))

(defmacro define-class-name (symbol java-dotted-name &optional documentation)
  `(defconstant ,symbol (make-class-name ,java-dotted-name)
     ,documentation))

(define-class-name +!java-object+ "java.lang.Object")
(define-class-name +!java-string+ "java.lang.String")
(define-class-name +!lisp-object+ "org.armedbear.lisp.LispObject")
(define-class-name +!lisp-simple-string+ "org.armedbear.lisp.SimpleString")
(define-class-name +!lisp+ "org.armedbear.lisp.Lisp")
(define-class-name +!lisp-nil+ "org.armedbear.lisp.Nil")
(define-class-name +!lisp-class+ "org.armedbear.lisp.LispClass")
(define-class-name +!lisp-symbol+ "org.armedbear.lisp.Symbol")
(define-class-name +!lisp-thread+ "org.armedbear.lisp.LispThread")
(define-class-name +!lisp-closure-binding+ "org.armedbear.lisp.ClosureBinding")
(define-class-name +!lisp-integer+ "org.armedbear.lisp.Integer")
(define-class-name +!lisp-fixnum+ "org.armedbear.lisp.Fixnum")
(define-class-name +!lisp-bignum+ "org.armedbear.lisp.Bignum")
(define-class-name +!lisp-single-float+ "org.armedbear.lisp.SingleFloat")
(define-class-name +!lisp-double-float+ "org.armedbear.lisp.DoubleFloat")
(define-class-name +!lisp-cons+ "org.armedbear.lisp.Cons")
(define-class-name +!lisp-load+ "org.armedbear.lisp.Load")
(define-class-name +!lisp-character+ "org.armedbear.lisp.Character")
(define-class-name +!lisp-simple-vector+ "org.armedbear.lisp.SimpleVector")
(define-class-name +!lisp-abstract-string+ "org.armedbear.lisp.AbstractString")
(define-class-name +!lisp-abstract-vector+ "org.armedbear.lisp.AbstractVector")
(define-class-name +!lisp-abstract-bit-vector+
    "org.armedbear.lisp.AbstractBitVector")
(define-class-name +!lisp-environment+ "org.armedbear.lisp.Environment")
(define-class-name +!lisp-special-binding+ "org.armedbear.lisp.SpecialBinding")
(define-class-name +!lisp-special-binding-mark+
    "org.armedbear.lisp.SpecialBindingMark")
(define-class-name +!lisp-throw+ "org.armedbear.lisp.Throw")
(define-class-name +!lisp-return+ "org.armedbear.lisp.Return")
(define-class-name +!lisp-go+ "org.armedbear.lisp.Go")
(define-class-name +!lisp-primitive+ "org.armedbear.lisp.Primitive")
(define-class-name +!lisp-compiled-closure+
    "org.armedbear.lisp.CompiledClosure")
(define-class-name +!lisp-eql-hash-table+ "org.armedbear.lisp.EqlHashTable")
(define-class-name +!lisp-package+ "org.armedbear.lisp.Package")
(define-class-name +!lisp-readtable+ "org.armedbear.lisp.Readtable")
(define-class-name +!lisp-stream+ "org.armedbear.lisp.Stream")
(define-class-name +!lisp-closure+ "org.armedbear.lisp.Closure")
(define-class-name +!lisp-closure-parameter+
    "org.armedbear.lisp.Closure$Parameter")
(define-class-name +!fasl-loader+ "org.armedbear.lisp.FaslClassLoader")

#|

Lisp-side descriptor representation:

 - list: a list starting with a method return value, followed by
     the argument types
 - keyword: the primitive type associated with that keyword
 - class-name structure instance: the class-ref value

The latter two can be converted to a Java representation using
the `internal-field-ref' function, the former is to be fed to
`descriptor'.

|#

(defun internal-field-type (field-type)
  (if (keywordp field-type)
      (map-primitive-type field-type)
      (class-name-internal field-type)))

(defun internal-field-ref (field-type)
  (if (keywordp field-type)
      (map-primitive-type field-type)
      (class-ref field-type)))

(defun descriptor (return-type &rest argument-types)
  (format nil "(~{~A~}~A)" (mapcar #'internal-field-ref argument-types)
          (internal-field-type return-type)))


(defstruct pool
  ;; `count' contains a reference to the last-used slot (0 being empty)
  ;; "A constant pool entry is considered valid if it has
  ;; an index greater than 0 (zero) and less than pool-count"
  (count 0)
  entries-list
  ;; the entries hash stores raw values, except in case of string and
  ;; utf8, because both are string values
  (entries (make-hash-table :test #'equal :size 2048 :rehash-size 2.0)))

(defstruct constant
  tag
  index)

(defparameter +constant-type-map+
  '((:class          7 1)
    (:field-ref      9 1)
    (:method-ref    10 1)
    ;; (:interface-method-ref 11)
    (:string         8 1)
    (:integer        3 1)
    (:float          4 1)
    (:long           5 2)
    (:double         6 2)
    (:name-and-type 12 1)
    (:utf8           1 1)))

(defstruct (constant-class (:constructor make-constant-class (index name-index))
                           (:include constant
                                     (tag 7)))
  name-index)

(defstruct (constant-member-ref (:constructor
                                 %make-constant-member-ref
                                     (tag index class-index name/type-index))
                                (:include constant))
  class-index
  name/type-index)

(declaim (inline make-constant-field-ref make-constant-method-ref
                 make-constant-interface-method-ref))
(defun make-constant-field-ref (index class-index name/type-index)
  (%make-constant-member-ref 9 index class-index name/type-index))

(defun make-constant-method-ref (index class-index name/type-index)
  (%make-constant-member-ref 10 index class-index name/type-index))

(defun make-constant-interface-method-ref (index class-index name/type-index)
  (%make-constant-member-ref 11 index class-index name/type-index))

(defstruct (constant-string (:constructor
                             make-constant-string (index value-index))
                            (:include constant
                                      (tag 8)))
  value-index) ;;; #### is this the value or the value index???

(defstruct (constant-float/int (:constructor
                                %make-constant-float/int (tag index value))
                               (:include constant))
  value)

(declaim (inline make-constant-float make-constant-int))
(defun make-constant-float (index value)
  (%make-constant-float/int 4 index value))

(defun make-constant-int (index value)
  (%make-constant-float/int 3 index value))

(defstruct (constant-double/long (:constructor
                                  %make-constant-double/long (tag index value))
                                 (:include constant))
  value)

(declaim (inline make-constant-double make-constant-float))
(defun make-constant-double (index value)
  (%make-constant-double/long 6 index value))

(defun make-constant-long (index value)
  (%make-constant-double/long 5 index value))

(defstruct (constant-name/type (:include constant
                                         (tag 12)))
  name-index
  descriptor-index)

(defstruct (constant-utf8 (:constructor make-constant-utf8 (index value))
                          (:include constant
                                    (tag 11)))
  value)


(defun pool-add-class (pool class)
  ;; ### do we make class a string or class-name structure?
  (let ((entry (gethash class (pool-entries pool))))
    (unless entry
      (setf entry
            (make-constant-class (incf (pool-count pool))
                                 (pool-add-utf8 pool
                                                (class-name-internal class)))
            (gethash class (pool-entries pool)) entry)
      (push entry (pool-entries-list pool)))
    (constant-index entry)))

(defun pool-add-field-ref (pool class name type)
  (let ((entry (gethash (acons name type class) (pool-entries pool))))
    (unless entry
      (setf entry (make-constant-field-ref (incf (pool-count pool))
                                           (pool-add-class pool class)
                                           (pool-add-name/type pool name type))
            (gethash (acons name type class) (pool-entries pool)) entry)
      (push entry (pool-entries-list pool)))
    (constant-index entry)))

(defun pool-add-method-ref (pool class name type)
  (let ((entry (gethash (acons name type class) (pool-entries pool))))
    (unless entry
      (setf entry (make-constant-method-ref (incf (pool-count pool))
                                            (pool-add-class pool class)
                                            (pool-add-name/type pool name type))
            (gethash (acons name type class) (pool-entries pool)) entry)
      (push entry (pool-entries-list pool)))
    (constant-index entry)))

(defun pool-add-interface-method-ref (pool class name type)
  (let ((entry (gethash (acons name type class) (pool-entries pool))))
    (unless entry
      (setf entry
            (make-constant-interface-method-ref (incf (pool-count pool))
                                                (pool-add-class pool class)
                                                (pool-add-name/type pool
                                                                    name type))
            (gethash (acons name type class) (pool-entries pool)) entry)
      (push entry (pool-entries-list pool)))
    (constant-index entry)))

(defun pool-add-string (pool string)
  (let ((entry (gethash (cons 8 string) ;; 8 == string-tag
                        (pool-entries pool))))
    (unless entry
      (setf entry (make-constant-string (incf (pool-count pool))
                                        (pool-add-utf8 pool string))
            (gethash (cons 8 string) (pool-entries pool)) entry)
      (push entry (pool-entries-list pool)))
    (constant-index entry)))

(defun pool-add-int (pool int)
  (let ((entry (gethash (cons 3 int) (pool-entries pool))))
    (unless entry
      (setf entry (make-constant-int (incf (pool-count pool)) int)
            (gethash (cons 3 int) (pool-entries pool)) entry)
      (push entry (pool-entries-list pool)))
    (constant-index entry)))

(defun pool-add-float (pool float)
  (let ((entry (gethash (cons 4 float) (pool-entries pool))))
    (unless entry
      (setf entry (make-constant-float (incf (pool-count pool)) float)
            (gethash (cons 4 float) (pool-entries pool)) entry)
      (push entry (pool-entries-list pool)))
    (constant-index entry)))

(defun pool-add-long (pool long)
  (let ((entry (gethash (cons 5 long) (pool-entries pool))))
    (unless entry
      (setf entry (make-constant-long (incf (pool-count pool)) long)
            (gethash (cons 5 long) (pool-entries pool)) entry)
      (push entry (pool-entries-list pool))
      (incf (pool-count pool))) ;; double index increase; long takes 2 slots
    (constant-index entry)))

(defun pool-add-double (pool double)
  (let ((entry (gethash (cons 6 double) (pool-entries pool))))
    (unless entry
      (setf entry (make-constant-double (incf (pool-count pool)) double)
            (gethash (cons 6 double) (pool-entries pool)) entry)
      (push entry (pool-entries-list pool))
      (incf (pool-count pool))) ;; double index increase; 'double' takes 2 slots
    (constant-index entry)))

(defun pool-add-name/type (pool name type)
  (let ((entry (gethash (cons name type) (pool-entries pool)))
        (internal-type (if (listp type)
                           (apply #'descriptor type)
                           (internal-field-ref type))))
    (unless entry
      (setf entry (make-constant-name/type (incf (pool-count pool))
                                           (pool-add-utf8 pool name)
                                           (pool-add-utf8 pool internal-type))
            (gethash (cons name type) (pool-entries pool)) entry)
      (push entry (pool-entries-list pool)))
    (constant-index entry)))

(defun pool-add-utf8 (pool utf8-as-string)
  (let ((entry (gethash (cons 11 utf8-as-string) ;; 11 == utf8
                        (pool-entries pool))))
    (unless entry
      (setf entry (make-constant-utf8 (incf (pool-count pool)) utf8-as-string)
            (gethash (cons 11 utf8-as-string) (pool-entries pool)) entry)
      (push entry (pool-entries-list pool)))
    (constant-index entry)))

(defstruct (class-file (:constructor %make-class-file))
  constants
  access-flags
  class
  superclass
  ;; interfaces
  fields
  methods
  attributes
  )

(defun class-add-field (class field)
  (push field (class-file-fields class)))

(defun class-field (class name)
  (find name (class-file-fields class)
        :test #'string= :key #'field-name))

(defun class-add-method (class method)
  (push method (class-file-methods class)))

(defun class-methods-by-name (class name)
  (remove name (class-file-methods class)
          :test-not #'string= :key #'method-name))

(defun class-method (class name return &rest args)
  (let ((return-and-args (cons return args)))
    (find-if #'(lambda (c)
                 (and (string= (method-name c) name)
                      (equal (method-descriptor c) return-and-args)))
             (class-file-methods class))))

(defun class-add-attribute (class attribute)
  (push atttribute (class-file-attributes class)))

(defun class-attribute (class name)
  (find name (class-file-attributes class)
        :test #'string= :key #'attribute-name))


(defun finalize-class-file (class)

  ;; constant pool contains constants finalized on addition;
  ;; no need for additional finalization

  (setf (class-file-access-flags class)
        (map-flags (class-file-access-flags class)))
  (setf (class-file-class-name class)
        (pool-add-class (class-name-internal (class-file-class-name class))))
  ;;  (finalize-interfaces)
  (dolist (field (class-file-fields class))
    (finalize-field field class))
  (dolist (method (class-file-methods class))
    (finalize-method method class))
  ;; top-level attributes (no parent attributes to refer to)
  (finalize-attributes (class-file-attributes class) nil class)

)

(defun !write-class-file (class stream)
  ;; all components need to finalize themselves:
  ;;  the constant pool needs to be complete before we start
  ;;  writing our output.

  ;; header
  (write-u4 #xCAFEBABE stream)
  (write-u2 3 stream)
  (write-u2 45 stream)

   ;; constants pool
  (write-constants (class-file-constants class) stream)
  ;; flags
  (write-u2  (class-file-access-flags class) stream)
  ;; class name
  (write-u2 (class-file-class class) stream)
  ;; superclass
  (write-u2 (class-file-superclass class) stream)

  ;; interfaces
  (write-u2 0 stream)

  ;; fields
  (write-u2 (length (class-file-fields class)) stream)
  (dolist (field (class-file-fields class))
    (!write-field field stream))

  ;; methods
  (write-u2 (length (class-file-methods class)) stream)
  (dolist (method (class-file-methods class))
    (!write-method method stream))

  ;; attributes
  (write-attributes (class-file-attributes class) stream))

(defun write-constants (constants stream)
  (write-u2 (pool-count constants) stream)
  (dolist (entry (reverse (pool-entries-list constants)))
    (let ((tag (constant-tag entry)))
    (write-u1 tag stream)
    (case tag
      (1 ; UTF8
       (write-utf8 (constant-utf8-value entry) stream))
      ((3 4) ; int
       (write-u4 (constant-float/int-value entry) stream))
      ((5 6) ; long double
       (write-u4 (logand (ash (constant-double/long-value entry) -32)
                         #xFFFFffff) stream)
       (write-u4 (logand (constant-double/long-value entry) #xFFFFffff) stream))
      ((9 10 11) ; fieldref methodref InterfaceMethodref
       (write-u2 (constant-member-ref-class-index entry) stream)
       (write-u2 (constant-member-ref-name/type-index entry) stream))
      (12 ; nameAndType
       (write-u2 (constant-name/type-name-index entry) stream)
       (write-u2 (constant-name/type-descriptor-index entry) stream))
      (7  ; class
       (write-u2 (constant-class-name-index entry) stream))
      (8  ; string
       (write-u2 (constant-string-value-index entry) stream))
      (t
       (error "write-constant-pool-entry unhandled tag ~D~%" tag))))))

#|

ABCL doesn't use interfaces, so don't implement it here at this time

(defstruct interface)

|#


(defparameter +access-flags-map+
  '((:public       #x0001)
    (:private      #x0002)
    (:protected    #x0004)
    (:static       #x0008)
    (:final        #x0010)
    (:volatile     #x0040)
    (:synchronized #x0020)
    (:transient    #x0080)
    (:native       #x0100)
    (:abstract     #x0400)
    (:strict       #x0800)))

(defun map-flags (flags)
  (reduce #'(lambda (x y)
              (logior (or (when (member (car x) flags)
                            (second x))
                          0) y)
              (logior (or )))
          :initial-value 0))

(defstruct (field (:constructor %make-field))
  access-flags
  name
  descriptor
  attributes
  )

(defun make-field (name type &key (flags '(:public)))
  (%make-field :access-flags flags
               :name name
               :descriptor type))

(defun field-add-attribute (field attribute)
  (push attribute (field-attributes field)))

(defun field-attribute (field name)
  (find name (field-attributes field)
        :test #'string= :key #'attribute-name))

(defun finalize-field (field class)
  (let ((pool (class-file-constants class)))
    (setf (field-access-flags field)
          (map-flags (field-access-flags field))
          (field-descriptor field)
          (pool-add-utf8 pool (internal-field-type (field-descriptor field)))
          (field-name field)
          (pool-add-utf8 pool (field-name field))))
  (finalize-attributes (field-attributes field) nil class))

(defun !write-field (field stream)
  (write-u2 (field-access-flags field) stream)
  (write-u2 (field-name field) stream)
  (write-u2 (field-descriptor field) stream)
  (write-attributes (field-attributes field) stream))


(defstruct (method (:constructor %!make-method))
  access-flags
  name
  descriptor
  attributes
  arg-count ;; not in the class file,
            ;; but required for setting up CODE attribute
  )


(defun map-method-name (name)
  (cond
    ((eq name :class-constructor)
     "<clinit>")
    ((eq name :constructor)
     "<init>")
    (t name)))

(defun !make-method (name return args &key (flags '(:public)))
  (%make-method :descriptor (cons return args)
                :access-flags flags
                :name name
                :arg-count (if (member :static flags)
                               (length args)
                               (1+ (length args))))) ;; implicit 'this'

(defun method-add-attribute (method attribute)
  (push attribute (method-attributes method)))

(defun method-attribute (method name)
  (find name (method-attributes method)
        :test #'string= :key #'attribute-name))


(defun finalize-method (method class)
  (let ((pool (class-file-constants class)))
    (setf (method-access-flags method)
          (map-flags (method-access-flags method))
          (method-descriptor method)
          (pool-add-utf8 pool (apply #'descriptor (method-descriptor method)))
          (method-name method)
          (pool-add-utf8 pool (map-method-name (method-name method)))))
  (finalize-attributes (method-attributes method) nil class))


(defun !write-method (method stream)
  (write-u2 (method-access-flags method) stream)
  (write-u2 (method-name method) stream)
  (write-u2 (method-descriptor method) stream)
  (write-attributes (method-attributes method) stream))

(defstruct attribute
  name

  ;; not in the class file:
  finalizer  ;; function of 3 arguments: the attribute, parent and class-file
  writer     ;; function of 2 arguments: the attribute and the output stream
  )

(defun finalize-attributes (attributes att class)
  (dolist (attribute attributes)
    ;; assure header: make sure 'name' is in the pool
    (setf (attribute-name attribute)
          (pool-add-string (class-file-constants class)
                           (attribute-name attribute)))
    ;; we're saving "root" attributes: attributes which have no parent
    (funcall (attribute-finalizer attribute) attribute att class)))

(defun write-attributes (attributes stream)
  (write-u2 (length attributes) stream)
  (dolist (attribute attributes)
    (write-u2 (attribute-name attribute) stream)
    ;; set up a bulk catcher for (UNSIGNED-BYTE 8)
    ;; since we need to know the attribute length (excluding the header)
    (let ((local-stream (sys::%make-byte-array-output-stream)))
      (funcall (attribute-writer attribute) attribute local-stream)
      (let ((array (sys::%get-output-stream-array local-stream)))
        (write-u2 (length array) stream)
        (write-sequence array stream)))))



(defstruct (code-attribute (:conc-name code-)
                           (:include attribute
                                     (name "Code")
                                     (finalizer #'!finalize-code)
                                     (writer #'!write-code))
                           (:constructor %make-code-attribute))
  max-stack
  max-locals
  code
  attributes
  ;; labels contains offsets into the code array after it's finalized
  (labels (make-hash-table :test #'eq))

  ;; fields not in the class file start here
  current-local ;; used for handling nested WITH-CODE-TO-METHOD blocks
  )


(defun code-label-offset (code label)
  (gethash label (code-labels code)))

(defun (setf code-label-offset) (offset code label)
  (setf (gethash label (code-labels code)) offset))

(defun !finalize-code (code class)
  (let ((c (coerce (resolve-instructions (code-code code)) 'vector)))
    (setf (code-max-stack code) (analyze-stack c)
          (code-code code) (code-bytes c)))
  (finalize-attributes (code-attributes code) code class))

(defun !write-code (code stream)
  (write-u2 (code-max-stack code) stream)
  (write-u2 (code-max-locals code) stream)
  (let ((code-array (code-code code)))
    (write-u4 (length code-array) stream)
    (dotimes (i (length code-array))
      (write-u1 (svref code-array i) stream)))
  (write-attributes (code-attributes code) stream))

(defun make-code-attribute (method)
  (%make-code-attribute :max-locals (method-arg-count method)))

(defun code-add-attribute (code attribute)
  (push attribute (code-attributes code)))

(defun code-attribute (code name)
  (find name (code-attributes code)
        :test #'string= :key #'attribute-name))



(defvar *current-code-attribute*)

(defun save-code-specials (code)
  (setf (code-code code) *code*
        (code-max-locals code) *registers-allocated*
        (code-exception-handlers code) *handlers*
        (code-current-local code) *register*))

(defun restore-code-specials (code)
  (setf *code* (code-code code)
        *registers-allocated* (code-max-locals code)
        *register* (code-current-local code)))

(defmacro with-code-to-method ((method &key safe-nesting) &body body)
  (let ((m (gensym))
        (c (gensym)))
    `(progn
       ,@(when safe-nesting
           `((when *current-code-attribute*
               (save-code-specials *current-code-attribute*))))
       (let* ((,m ,method)
              (,c (method-attribute ,m "Code"))
              (*code* (code-code ,c))
              (*registers-allocated* (code-max-locals ,c))
              (*register* (code-current-local ,c))
              (*current-code-attribute* ,c))
         ,@body
         (setf (code-code ,c) *code*
               (code-exception-handlers ,c) *handlers*
               (code-max-locals ,c) *registers-allocated*))
       ,@(when safe-nesting
           `((when *current-code-attribute*
               (restore-code-specials *current-code-attribute*)))))))

(defstruct (exceptions-attribute (:constructor make-exceptions)
                                 (:conc-name exceptions-)
                                 (:include attribute
                                           (name "Exceptions")
                                           (finalizer #'finalize-exceptions)
                                           (writer #'write-exceptions)))
  exceptions)

(defun finalize-exceptions (exceptions code class)
  (dolist (exception (exceptions-exceptions exceptions))
    ;; no need to finalize `catch-type': it's already the index required
    (setf (exception-start-pc exception)
          (code-label-offset code (exception-start-pc exception))
          (exception-end-pc exception)
          (code-label-offset code (exception-end-pc exception))
          (exception-handler-pc exception)
          (code-label-offset code (exception-handler-pc exception))
          (exception-catch-type exception)
          (pool-add-string (class-file-constants class)
                           (exception-catch-type exception))))
  ;;(finalize-attributes (exceptions-attributes exception) exceptions class)
  )


(defun write-exceptions (exceptions stream)
  ; number of entries
  (write-u2 (length (exceptions-exceptions exceptions)) stream)
  (dolist (exception (exceptions-exceptions exceptions))
    (write-u2 (exception-start-pc exception) stream)
    (write-u2 (exception-end-pc exception) stream)
    (write-u2 (exception-handler-pc exception) stream)
    (write-u2 (exception-catch-type exception) stream)))

(defun code-add-exception (code start end handler type)
  (when (null (code-attribute code "Exceptions"))
    (code-add-attribute code (make-exceptions)))
  (push (make-exception :start-pc start
                        :end-pc end
                        :handler-pc handler
                        :catch-type type)
        (exceptions-exceptions (code-attribute code "Exceptions"))))

(defstruct exception
  start-pc    ;; label target
  end-pc      ;; label target
  handler-pc  ;; label target
  catch-type  ;; a string for a specific type, or NIL for all
  )

(defstruct (source-file-attribute (:conc-name source-)
                                  (:include attribute
                                            (name "SourceFile")))
  filename)

(defstruct (line-numbers-attribute (:include attribute
                                             (name "LineNumberTable")))
  line-numbers)

(defstruct line-number
  start-pc
  line)

(defstruct (local-variables-attribute (:conc-name local-var-)
                                      (:include attribute
                                                (name "LocalVariableTable")))
  locals)

(defstruct (local-variable (:conc-name local-))
  start-pc
  length
  name
  descriptor
  index)

#|

;; this is the minimal sequence we need to support:

;;  create a class file structure
;;  add methods
;;  add code to the methods, switching from one method to the other
;;  finalize the methods, one by one
;;  write the class file

to support the sequence above, we probably need to
be able to

- find methods by signature
- find the method's code attribute
- add code to the code attribute
- finalize the code attribute contents (blocking it for further addition)
- 


|#

