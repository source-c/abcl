(defpackage #:abcl.test.ansi
  (:use :cl :cl-user)
  (:nicknames #:ansi-tests #:abcl-ansi-tests #:gcl-ansi)
  (:export #:run 
	   #:verify-ansi-tests
	   #:load-tests
	   #:clean-tests
	   #:report #:parse))

(in-package :abcl.test.ansi)

(defparameter *ansi-tests-master-source-location*
  "<svn://common-lisp.net/project/ansi-test/svn/trunk/ansi-tests>")  

(defparameter *ansi-tests-directory*
  (if (find :asdf2 *features*)
      (asdf:system-relative-pathname :ansi-compiled "../ansi-tests/")
      (merge-pathnames #p"../ansi-tests/"
		       (asdf:component-pathname 
			(asdf:find-system :ansi-compiled)))))

(defun run (&key (compile-tests nil)) 
  "Run the ANSI-TESTS suite, to be found in *ANSI-TESTS-DIRECTORY*.
Possibly running the compiled version of the tests if COMPILE-TESTS is non-NIL."
  (verify-ansi-tests)
  (let* ((ansi-tests-directory 
	  *ansi-tests-directory*)
	 (boot-file 
	  (if compile-tests "compileit.lsp" "doit.lsp"))
	 (message 
	  (format nil "Invocation of '~A' in ~A" 
		  boot-file ansi-tests-directory)))
    (progv 
	'(*default-pathname-defaults*) 
	`(,(merge-pathnames *ansi-tests-directory* 
			    *default-pathname-defaults*))
	  (format t "--->  ~A begins.~%" message)
	  (format t "Invoking ABCL hosted on ~A ~A.~%" 
		  (software-type) (software-version))
	  (time (load boot-file))
	  (format t "<--- ~A ends.~%" message))))

(defun verify-ansi-tests () 
  (unless 
      (probe-file *ansi-tests-directory*)
    (error 'file-error
	   "Failed to find the GCL ANSI tests in '~A'. Please
locally obtain ~A, and set the value of *ANSI-TESTS-DIRECTORY* to that
location."  
	     *ansi-tests-directory*
	     *ansi-tests-master-source-location*)))

(defvar *ansi-tests-loaded-p* nil)
(defun load-tests ()
  "Load the ANSI tests but do not execute them."
  (verify-ansi-tests)
  (let ((*default-pathname-defaults* *ansi-tests-directory*)
	(package *package*))
    (setf *package* (find-package :cl-user))
    (load "gclload1.lsp")
    (load "gclload2.lsp")
    (setf *package* package))
  (setf *ansi-tests-loaded-p* t))
  
(defun clean-tests ()
  "Do what 'make clean' would do from the GCL ANSI tests,"
  ;; so we don't have to hunt for 'make' in the PATH on win32.
  (verify-ansi-tests)

  (mapcar #'delete-file
	  (append (directory (format nil "~A/*.cls" *ansi-tests-directory*))
		  (directory (format nil "~A/*.abcl" *ansi-tests-directory*))
		  (directory (format nil "~A/scratch/*" *ansi-tests-directory*))
		  (mapcar (lambda(x) 
			    (format nil "~A/~A" *ansi-tests-directory* x))
			  '("scratch/"
			    "scratch.txt" "foo.txt" "foo.lsp"
			    "foo.dat" 
			    "tmp.txt" "tmp.dat" "tmp2.dat"
			    "temp.dat" "out.class" 
			    "file-that-was-renamed.txt"
			    "compile-file-test-lp.lsp"
			    "compile-file-test-lp.out" 
			    "ldtest.lsp")))))

		   
	     

