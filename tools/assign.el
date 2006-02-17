;;; assign.el --- Assigning words to recording pieces

;; Copyright (C) 2005 Brailcom, o.p.s.
;; Author: Milan Zamazal <pdm@brailcom.org>

;; COPYRIGHT NOTICE
;;
;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

;;; Code:


;;; Configuration


(defvar word-file-name "~/brailcom/festival-hanak/prompts/words")

(defvar diphone-directory "~/brailcom/festival-hanak/recording/split")

(defvar play-program "/usr/bin/play")


;;; Functions


(defun play-sample ()
  (interactive)
  ;; The play-sound-file function doesn't work very well with all sound formats
  (setq mode-line-process (concat " "
                                  (file-name-sans-extension
                                   (file-name-nondirectory sample-file-name))))
  (call-process play-program nil nil nil sample-file-name))

(defun info-file-name (file-name)
  (concat (file-name-sans-extension file-name) ".diphone"))

(defun edit-sample-info (file-name info)
  (save-excursion
    (find-file (info-file-name file-name))
    (erase-buffer)
    (insert info)
    (save-buffer)
    (kill-buffer (current-buffer))))

(defun discard-sample ()
  (interactive)
  (edit-sample-info sample-file-name "---"))

(defun assign-diphone ()
  (interactive)
  (let ((diphone (save-excursion
                   (goto-char (line-beginning-position))
                   (and (looking-at "^\\(.*\\) +[[]\\(.+\\)[]]")
                        (concat (match-string 2) " " (match-string 1))))))
    (unless diphone
      (error "No diphone at this line"))
    (edit-sample-info sample-file-name diphone)
    (message "Diphone %s %s"
             diphone (file-name-nondirectory sample-file-name))))

(defun next-diphone ()
  (interactive)
  (while (and sample-list
              (file-exists-p (info-file-name (car sample-list))))
    (setq sample-list (cdr sample-list)))
  (if sample-list
      (progn
        (setq sample-file-name (car sample-list))
        (forward-line)
        (sit-for 0)
        (play-sample))
    (message "Done!")))

(defun assign-diphone-next ()
  (interactive)
  (assign-diphone)
  (next-diphone))

(define-derived-mode word-list-mode fundamental-mode ":-P" nil
  (setq buffer-read-only t)
  (set (make-local-variable 'sample-list)
       (directory-files diphone-directory t "\\.wav$"))
  (set (make-local-variable 'sample-file-name) nil))

(define-key word-list-mode-map "n" 'next-diphone)
(define-key word-list-mode-map "p" 'play-sample)
(define-key word-list-mode-map "s" 'isearch-forward)
(define-key word-list-mode-map "x" 'discard-sample)
(define-key word-list-mode-map " " 'assign-diphone-next)
(define-key word-list-mode-map "\r" 'assign-diphone)

(defun guess-current-line ()
  (when sample-list
    (let ((last (car
                 (last (directory-files diphone-directory t "\\.diphone$")))))
      (when last
        (let ((word nil))
          (with-temp-buffer
            (insert-file-contents last)
            (goto-char (point-min))
            (when (looking-at "^[^ ]+ +\\(.*\\) *")
              (setq word (match-string 1))))
          (when word
            (goto-char (point-min))
            (search-forward word nil t)))))))

(defun assign ()
  (interactive)
  (switch-to-buffer "*word list*")
  (let ((inhibit-read-only t))
    (erase-buffer)
    (insert-file-contents word-file-name))
  (word-list-mode)
  (guess-current-line)
  (next-diphone))


;;; Announce

(provide 'assign)


;;; assign.el ends here
