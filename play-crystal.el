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
;; ### Features:
;;
;; * [x] Allows to paste code into Emacs buffers
;; * [ ] Allows to submit code to [play.crystal-lang.org](https://play.crystal-lang.org)
;;
;; ### Usage
;;
;; Run one of the predefined interactive functions to fetch or submit
;; code from [play.crystal-lang.org](https://play.crystal-lang.org).
;;

;;; Code:

(eval-when-compile
  (require 'cl))

(require 'json)
(require 'request)
(require 'subr-x)

(defgroup play-crystal nil
  "https://play.crystal-lang.org/ integration."
  :prefix "play-crystal-"
  :group 'applications)

(defconst play-crystal-version "0.1.0")
(defconst play-crystal-baseurl "https://play.crystal-lang.org")
(defconst play-crystal-runs-path "/runs")

(defvar play-crystal-buffer-name "*Play-Crystal*"
  "Buffer name for code insertions.")

(defvar play-crystal-debug-buffer-name "*Play-Crystal-Debug*"
  "Buffer name for responses from play.crystal-lang.org.")

(defconst play-crystal-default-headers
  '(("Accept" . "application/json")
    ("User-Agent" . ,(format "play-crystal.el/%s" play-crystal-version))))

(cl-defun play-crystal--request
    (endpoint
     &key
     (type "GET")
     (params nil)
     (data nil)
     (parser 'json-read)
     (error nil)
     (success nil)
     (complete 'play-crystal--default-callback)
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
           :complete complete
           :error error
           :timeout timeout
           :status-code status-code
           :sync sync))

(cl-defun play-crystal--default-callback (&key data response error-thrown &allow-other-keys)
  (with-current-buffer (get-buffer-create play-crystal-debug-buffer-name)
    (let ((error-message (assoc-default 'message (assoc-default 'error data))))
      (if (not (s-blank-str? error-message))
          (message error-message)
        (and error-thrown (message (error-message-string error-thrown)))))
    (let ((inhibit-read-only t))
      (erase-buffer)
      (and (stringp data) (insert data))
      (let ((raw-header (request-response--raw-header response)))
        (unless (or (null raw-header) (string-empty-p raw-header))
          (insert "\n" raw-header))))))

(cl-defun play-crystal--chunk (data)
  "Pre-formatted play crystal code chunk."
  (let* ((run (assoc-default 'run data))
         (html-url (assoc-default 'html_url run))
         (created-at (assoc-default 'created_at run))
         (language (assoc-default 'language run))
         (version (assoc-default 'version run))
         (exit-code (assoc-default 'exit_code run))
         (code (assoc-default 'code run))
         (id (assoc-default 'id run)))
    (when (not (s-blank-str? code))
      (concat
       (format "\n# Html url: %s" html-url)
       (format "\n# Created at: %s" created-at)
       (format "\n# Language: %s" language)
       (format "\n# Version: %s" version)
       (format "\n# Exit code: %d" exit-code)
       (format "\n%s" code)
       (format "\n# End of chunk #%s" id)))))

(cl-defun play-crystal--read-run-id ()
  "Read run id."
  (list (read-string "Enter run id: ")))

(cl-defun play-crystal--run-path (run-id)
  "Returns a path to the run."
  (format "%s/%s" play-crystal-runs-path run-id))

(defun play-crystal-insert (run-id)
  "Insert code defined by RUN-ID into the current buffer."
  (interactive (play-crystal-read-run-id))
  (play-crystal--request
   (play-crystal--run-path run-id)
   :success (cl-function
             (lambda (&key data &allow-other-keys)
               (insert (play-crystal-chunk data))))))

(defun play-crystal-insert-another-buffer (run-id)
  "Insert code defined by RUN-ID into another buffer."
  (interactive (play-crystal-read-run-id))
  (play-crystal--request
   (play-crystal--run-path run-id)
   :success (cl-function
             (lambda (&key data &allow-other-keys)
               (progn
                 (switch-to-buffer play-crystal-buffer-name)
                 (erase-buffer)
                 (when (fboundp 'crystal-mode) (crystal-mode))
                 (insert (play-crystal-chunk data)))))))

(provide 'play-crystal)
;;; play-crystal.el ends here
