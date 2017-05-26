;;; play-crystal.el --- https://play.crystal-lang.org integration.

;; Copyright © 2017 Vitalii Elenhaupt <velenhaupt@gmail.com>
;; Author: Vitalii Elenhaupt
;; URL: https://github.com/veelenga/play-crystal.el
;; Keywords: convenience
;; Version: 0.1.0
;; Package-Requires: ((emacs "24.4") (dash "2.12.0") (request "0.2.0"))

;; This file is not part of GNU Emacs.

;;; License:

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; https://play.crystal-lang.org integration.
;;
;; * [x] Allows to fetch code into Emacs buffer
;; * [ ] Allows to create crystal and execute Crystal code at [play.crystal-lang.org](https://play.crystal-lang.org)

;;; Code:

(require 'json)
(require 'request)
(require 'subr-x)

(defgroup play-crystal nil
  "https://play.crystal-lang.org/ integration."
  :prefix "play-crystal-"
  :group 'applications)

(defconst play-crystal-version "0.1.0")
(defconst play-crystal-baseurl "https://play.crystal-lang.org")

(defvar play-crystal-debug-buffer-name "*Play-Crystal*"
  "Buffer name responses from play.crystal-lang.org.")

(defconst play-crystal-default-headers
  '(("Accept" . "application/json")
    ("User-Agent" . ,(format "play-crystal.el/%s" play-crystal-version))))

(cl-defun play-crystal-request
    (endpoint
     &key
     (type "GET")
     (params nil)
     (data nil)
     (parser 'json-read)
     (error 'play-crystal-default-callback)
     (success 'play-crystal-default-callback)
     (headers play-crystal-default-headers)
     (timeout nil)
     (sync nil)
     (status-code nil)
     (authorized nil))
  "Process a request to play.crystal-lang.org endpoint."
  (request (url-expand-file-name endpoint play-crystal-baseurl)
           :type type
           :data data
           :params params
           :headers headers
           :parser parser
           :success success
           :error error
           :timeout timeout
           :status-code status-code
           :sync sync))

(cl-defun play-crystal-default-callback (&key data response error-thrown &allow-other-keys)
  (with-current-buffer (get-buffer-create play-crystal-debug-buffer-name)
    (and error-thrown (message (error-message-string error-thrown)))
    (let ((inhibit-read-only t))
      (erase-buffer)
      (and (stringp data) (insert data))
      (let ((raw-header (request-response--raw-header response)))
        (unless (or (null raw-header) (string-empty-p raw-header))
          (insert "\n" raw-header))))))

(defun play-crystal-insert-run (id)
  "Insert play crystal run code into a current buffer. ID is a crystal run identity."
  (interactive
   (list
    (read-string "Enter run id: ")))
  (play-crystal-request
   (format "/runs/%s" id)
   :success (cl-function
             (lambda (&key data &allow-other-keys)
               (insert (assoc-default 'code (assoc-default 'run data)))))))

(provide 'play-crystal)
;;; play-crystal.el ends here
