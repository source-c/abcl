;;; socket.lisp
;;;
;;; Copyright (C) 2004 Peter Graves
;;; $Id: socket.lisp,v 1.2 2004-08-03 16:47:00 piso Exp $
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

(defun get-socket-stream (socket &key (element-type 'character))
  ":ELEMENT-TYPE must be CHARACTER or (UNSIGNED-BYTE 8); the default is CHARACTER."
  (cond ((eq element-type 'character))
        ((equal element-type '(unsigned-byte 8)))
        (t
         (error 'simple-type-error
                :format-control
                ":ELEMENT-TYPE must be CHARACTER or (UNSIGNED-BYTE 8).")))
  (%socket-stream socket element-type))

(defun make-socket (host port)
  (%make-socket host port))

(defun make-server-socket (port)
  (%make-server-socket port))

(defun socket-accept (socket)
  (%socket-accept socket))

(defun socket-close (socket)
  (%socket-close socket))

(defun server-socket-close (socket)
  (%server-socket-close socket))

(provide '#:socket)
