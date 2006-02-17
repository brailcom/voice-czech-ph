#!/usr/bin/guile -s
!#
;;; Compute average phoneme lengths from the *.lab files

;; Copyright (C) 2005 Brailcom, o.p.s.
;; Author: Milan Zamazal <pdm@brailcom.org>

;; COPYRIGHT NOTICE

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA.


(use-modules ((fvoxedit fvoxedit-festival)))
(use-modules ((fvoxedit fvoxedit-util)))
(use-modules ((ice-9 format)))
(use-modules ((srfi srfi-1)))
(use-modules ((srfi srfi-13)))

(define *length-factor* 0.5)

(define *lengths* '())

(define (add-length phone length)
  (let ((cons% (assoc phone *lengths*)))
    (if (not cons%)
        (begin
          (set! *lengths* (alist-cons phone '() *lengths*))
          (set! cons% (car *lengths*))))
    (set-cdr! cons% (cons length (cdr cons%)))))

(define (process-labels labels)
  ;; We don't count initial and final pauses and their neighboring phones (they
  ;; may have very different lengths of phones inside).
  (if (>= (length labels) 4)
      (letrec ((process (lambda (labels start-time)
                          (if (not (null? labels))
                              (let* ((label (car labels))
                                     (ltime (label-time label)))
                                (add-length (label-name label)
                                            (- ltime start-time))
                                (process (cdr labels) ltime))))))
        (process (drop (drop-right labels 2) 2)
                 (label-time (car labels))))))

(define (process-file-labels file)
  (format #t "LAB ~A~%" file)
  (process-labels (file-labels file)))

(define (compute-lengths lengths)
  (map (lambda (item)
         (cons (car item) (* *length-factor*
                             (/ (apply + (cdr item)) (length (cdr item))))))
       lengths))

(define (print-lengths lengths)
  (for-each (lambda (item) (format #t "(~A ~,3F)~%" (car item) (cdr item)))
            lengths))

(define (map-lab-files function)
  (map function (directory *diphone-lab-dir* #:pattern "\\.lab$")))

(define (run)
  (map-lab-files process-file-labels)
  (print-lengths (compute-lengths *lengths*)))

(run)
