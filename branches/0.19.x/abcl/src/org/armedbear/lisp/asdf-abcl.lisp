;;; asdf-abcl.lisp
;;;
;;; Copyright (C) 2010 Mark Evenson
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

(in-package :asdf)
;;;; ABCL-specific extensions to ASDF, placed in a separate file from
;;;; asdf.lisp so that we can track upstream ASDF versions easier.

;;; We don't compile if the output location would be within a JAR
;;; file, which is currently always an unwritable location in ABCL.
;;; This allows us to load ASDF definitions that are packaged in JARs.
;;;
;;; XXX How does this work with ASDF-BINARY-LOCATIONS?  
(defmethod operation-done-p :around ((o compile-op) 
                                     (c cl-source-file)) 
  (let ((files (output-files o c)))
    (if (every #'sys:pathname-jar-p files) 
        t
        (call-next-method))))

(defun module-provide-asdf (name) 
  (handler-case
      (let* ((*verbose-out* (make-broadcast-stream))
             (system (asdf:find-system name nil)))
        (when system
          (asdf:operate 'asdf:load-op name)
          t))
    (missing-component (e) 
      (declare (ignore e))
      nil)
    (t (e)
      (format *error-output* "ASDF could not load ~A because ~A.~%"
              name e))))

(pushnew #'module-provide-asdf sys::*module-provider-functions*)
  
(provide 'asdf-abcl)
