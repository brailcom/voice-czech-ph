;;; Create group file for voice_czech_ph

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

(us_diphone_init '((name czech_ph)
                   (index_file "./dic/phdiph.est")
                   (grouped "false")
                   (coef_dir "./lpc")
                   (sig_dir "./lpc")
                   (coef_ext ".lpc")
                   (sig_ext ".res")
                   (default_diphone "#-#")))

(set! us_abs_offset 0.0)
(set! window_factor 1.0)
(set! us_rel_offset 0.0)
(set! us_gain 0.9)
(Parameter.set 'us_sigpr 'lpc)

(us_db_select 'czech_ph)

(us_make_group_file "group/ph.group")
