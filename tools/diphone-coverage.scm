#!/usr/bin/festival --script

;;; Testing diphone set coverage of a text file

;; Copyright (C) 2004, 2005 Brailcom, o.p.s.
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


(load (path-append datadir "init.scm"))


(defvar sentence-file "tools/testing-sentences.text")
(defvar prompt-file "etc/csdiph.list")
(defvar voice voice_czech_ph)


(define (butlast list)
  (if (eq? (cdr list) nil)
      nil
      (cons (car list) (butlast (cdr list)))))

(define (set-difference list-1 list-2)
  (if list-1
      (if (member (car list-1) list-2)
          (set-difference (cdr list-1) list-2)
          (cons (car list-1) (set-difference (cdr list-1) list-2)))
      ()))

(define (read-text file)
  (let ((f (fopen file "r"))
        (buffer (format nil "%256s" " "))
        (n nil)
        (text ""))
    (while (set! n (fread buffer f))
      (set! text (string-append text (substring buffer 0 n))))
    (fclose f)
    text))

(define (text->phones text)
  (let ((utt (eval `(Utterance Text ,text))))
    (Text utt)
    (Token_POS utt)
    (Token utt)
    (POS utt)
    (Phrasify utt)
    (Word utt)
    (Pauses utt)
    (mapcar item.name (utt.relation.items utt 'Segment))))

(define (phones->diphones phones)
  (butlast
   (mapcar (lambda (x y) (format nil "%s-%s" x y)) phones (cdr phones))))

(define (file->diphones file)
  (let ((text (read-text file))
        (diphones ()))
    (while (not (string-equal text ""))
      (set! diphones
            (cons
             (phones->diphones (text->phones (string-before text "\n")))
             diphones))
      (set! text (string-after text "\n")))
    (flatten diphones)))

(define (read-diphones file)
  (let ((f (fopen file "r"))
        (diphones ())
        (sexp nil))
    (while (not (equal? (set! sexp (readfp f)) '(eof)))
      (set! diphones (cons (nth 2 sexp) diphones)))
    (fclose f)
    (flatten diphones)))

(define (missing-diphones)
  (let ((file-diphones (file->diphones sentence-file))
        (all-diphones (read-diphones prompt-file)))
    (let ((missing (set-difference all-diphones file-diphones))
          (ndiphones (length all-diphones)))
      (format t "Number of covered diphones: %s/%s\n"
              (- ndiphones (length missing)) ndiphones)
      (format t "Number of missing diphones: %s/%s\n"
              (length missing) ndiphones)
      (print missing))))


(voice)
(missing-diphones)


(provide 'diphone-coverage)
