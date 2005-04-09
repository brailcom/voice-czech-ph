#!/usr/bin/guile -s
!#
;;; Remove useless initial and final pauses from the recording

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
;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA.


(use-modules ((fvoxedit fvoxedit-festival)))
(use-modules ((fvoxedit fvoxedit-util)))
(use-modules ((srfi srfi-1)))
(use-modules ((srfi srfi-13)))
(use-modules ((ice-9 receive)))
(use-modules ((ice-9 regex)))


(define *pause-length* 0.2)


(define (file-limits labels)
  (values (max 0.0 (- (label-time (car labels)) *pause-length*))
          (min (label-time (last labels))
               (+ (label-time (car (take-right labels 2))) *pause-length*))))

(define (adjust-diphone diphone start)
  (apply set-diphone-boundaries diphone
         (map (lambda (time) (- time start)) (diphone-boundaries diphone)))
  diphone)

(define (adjust-labels labels start end)
  (let ((result (map (lambda (l)
                       (make-label (label-name l) (- (label-time l) start)))
                     labels)))
    (list-set! result (- (length result) 1)
               (make-label (label-name (last result)) (- end start)))
    result))

(define (run)
  (let ((pattern (make-regexp "([0-9]+).*\\.lab$")))
    (for-each
     (lambda (f)
       (let ((match (regexp-exec pattern f)))
         (if match
             (let* ((diphone-name (match:substring match 1))
                    (diphone (car (get-diphone diphone-name)))
                    (wav-file (diphone-wav-file diphone))
                    (labels (diphone-labels diphone)))
               (if (not (null? labels))
                   (receive (start end) (file-limits labels)
                     (format #t "~A ~A ~A~%" wav-file start end)
                     (system (format #f "sox ~A ~A-x.wav trim ~A ~A"
                                     wav-file wav-file start (- end start)))
                     (if (not (null? (diphone-boundaries diphone)))
                         (save-diphone (adjust-diphone diphone start) #f))
                     (save-labels diphone
                                  (adjust-labels labels start end))))))))
     (sort (directory *diphone-lab-dir*) string<))))
  
(run)
