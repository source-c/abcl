;;; customizations.lisp

;;; User customizations for the build.

;;; This file is LOADed by INITIALIZE-BUILD (in build-abcl.lisp).

;;; The variable *PLATFORM-IS-WINDOWS* should be true on Windows platforms. You
;;; can, of course, substitute your own test for this in the code below, or add
;;; a section for OS X, or Solaris, or whatever...

;;; You MUST set *JDK* to the location of the JDK you want to use. Remove or
;;; comment out settings that don't apply to your situation.

;;; You don't really need to specify anything but *JDK*. *JAVA-COMPILER* and
;;; *JAR* default to javac and jar, respectively, from the configured JDK.

;;; Directories should be specified with a trailing slash (or, on Windows, a
;;; trailing backslash).

(in-package #:build-abcl)

;; Standard compiler options.
(setf *javac-options* "-g")
(setf *jikes-options* "+D -g")

;; *PLATFORM* will be either :WINDOWS, :DARWIN, :LINUX, or :UNKNOWN.
(case *platform*
  (:windows
   (setf *jdk*           "C:\\Program Files\\Java\\jdk1.5.0_05\\")
   #+(or) (setf *java-compiler* "jikes")
   )
  (:darwin
   (setf *jdk*           "/usr/")
   (setf *java-compiler* "jikes")
   #+(or) (setf *jar*    "jar"))
  ((:linux :unknown)
   (setf *jdk*           "/home/peter/blackdown/j2sdk1.4.2/")
   (setf *java-compiler* "jikes")
   (setf *jar*           "fastjar")))
