(defpackage #:abcl.test.lisp 
  (:use #:cl #:abcl-rt)
  (:nicknames "ABCL-TEST-LISP" "ABCL-TEST")
  (:export 
   #:run #:run-matching))
(in-package #:abcl.test.lisp)

(defparameter *abcl-test-directory* 
   (make-pathname :host (pathname-host *load-truename*)
                  :device (pathname-device *load-truename*)
                  :directory (pathname-directory *load-truename*)))

(defun run ()
  "Run the Lisp test suite for ABCL."
  (let ((*default-pathname-defaults* *abcl-test-directory*))
    (do-tests)))

;;; XXX move this into test-utilities.lisp?
(defun run-matching (&optional (match "jar-file."))
  (let* ((matching (string-upcase match))
         (tests
          (remove-if-not
           (lambda (name) (search matching name))
           (mapcar (lambda (entry) 
                     (symbol-name (abcl-rt::name entry))) 
                   (rest abcl-rt::*entries*)))))
    (dolist (test tests)
      (do-test (intern test :abcl.test.lisp)))))
    


	