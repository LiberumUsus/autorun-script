;; AUTORUN SCRIPT
;;
;; TODO:
;; x System Args
;; x System script name
;; x Buffer Args
;; x Buffer Script name
;; x Mode Args
;; - Mode Script name
;; - Path Args
;; - Path Script Name
;; - Arg Variables

(defcustom autorun-search-depth -1
  "How many parent directories to search before giving up."
  :type 'number
  :group 'autorun-script)



(if (or (equal system-type 'windows-nt)
          (equal system-type 'msdos))
    (defcustom autorun-script-file "run-script.bat"
      "Script name to search for and run"
      :type 'string
      :group 'autorun-script)
  (defcustom autorun-script-file "run-script.sh"
    "Script name to search for and run"
    :type 'string
    :group 'autorun-script))


(defcustom autorun-script-active t
  "Activate or deactivate the autorun-script"
  :type 'boolean
  :group 'autorun-script)


(defcustom autorun-script-alist '(web-mode)
  "A list of modes that trigger autorun-script"
  :type 'list
  :group 'autorun-script)


(defcustom autorun-script-response-on t
  "If responses from calls should be shown in a buffer."
  :type 'boolean
  :group 'autorun-script)


;; ---------------------------
;; Buffer local variables
;; ---------------------------


(defcustom autorun-script-buffer-arg nil
  "The arguments to provide when calling autorun-script."
  :type 'string
  :local t
  :group 'autorun-script)
(make-variable-buffer-local 'autorun-script-buffer-arg)


(defcustom autorun-script-buffer-disabled nil
  "The local disabling of autorun-script for the buffer"
  :type 'boolean
  :local t
  :group 'autorun-script)
(make-variable-buffer-local 'autorun-script-buffer-disabled)


(defcustom autorun-script-buffer-local-file "run-script.sh"
  "Buffer override for script name to search for and run."
  :type 'string
  :group 'autorun-script)
(make-variable-buffer-local 'autorun-script-buffer-local-file)


;; ---------------------------
;; Operating Variables
;; ---------------------------

(defvar autorun-script-mode-args
  #s(hash-table
     size 30
     test equal
     data (web-mode nil v-mode nil)))


(defvar autorun-script-mode-script
  #s(hash-table
     size 30
     test equal
     data (web-mode nil v-mode nil)))



(defun autorun-script-run()
  "Call the autorun-script as it would after a save."
  "This overrides all other settings and runs anyway"
  (interactive)
  (autorun-script-after-save t))


(defun autorun-script-current-dir ()
  "Get the current directory, or return nil."
  (let ((file-name buffer-file-name))
    (if (stringp file-name)
        (file-name-directory file-name)
      nil)))


(defun autorun-script-parent-dir (cdir)
  "Get the parent directory of the provided path."
  (file-name-directory (directory-file-name cdir)))



(defun autorun-script-at-base-dir (cdir)
  "Verify if there is only one forward slash in the string provided.
The cdir should represent the 'current directory' under inspection'"
  (= (count 47 (string-to-list cdir)) 1))



(defun autorun-script-log (response)
  "Writes message to the log buffer"
  (let ((log-buffer (get-buffer-create "*autorun-script-response*")))
    (save-window-excursion
      (with-current-buffer log-buffer
        (setq buffer-read-only nil)
        (erase-buffer)
        (insert (concat (format-time-string "[%H:%M:%S]") "\n"))
        (insert response)
        (insert "\n")
        (setq buffer-read-only t)))))



(defun autorun-script-set-parent-depth ()
  "Set the depth that the script will search up to."
  (interactive)
  (let ((local_arg (read-number "Parent Search Depth: " autorun-search-depth)))
    (when (< local_arg 0)
      (setq local_arg -1))
  (setq autorun-search-depth local_arg)))



(defun autorun-script-toggle-mode ()
  "Enable or disable the current major mode with autorun-script."
  (interactive)
  "Toggle the current major-mode from the alist."
  (if (member major-mode autorun-script-alist)
      (progn
        (message "Removing mode: %s" major-mode)
        (setq autorun-script-alist (delete major-mode autorun-script-alist)))
    (progn
      (message "Adding mode: %s" major-mode)
      (setq autorun-script-alist (push major-mode autorun-script-alist)))))



(defun autorun-script-set-buffer-run-arg ()
  "Set the buffer run argument for the run-list call."
  (interactive)
  (let ((local_arg (read-string "Buffer Script Arguments: " autorun-script-buffer-arg)))
    (when (= (length local_arg) 0)
      (setq local_arg nil))
  (setq-local autorun-script-buffer-arg local_arg)))



(defun autorun-script-set-mode-run-arg ()
  "Set the run argument for the major-mode."
  (interactive)
  (let ((current_args (gethash major-mode autorun-script-mode-args)))
    (let ((new_args (read-string "MajorMode Script Arguments: " current_args)))
      (when (= (length new_args) 0)
        (setq new_args nil))
      (puthash major-mode new_args autorun-script-mode-args))))



(defun autorun-script-set-script-name ()
  "Set the run script name for the call."
  (interactive)
  (let ((new_script (read-string "Script Name: " autorun-script-file)))
    (when (= (length new_script) 0)
      (if (or (equal system-type 'windows-nt)
              (equal system-type 'msdos))
          (setq new_script "run-script.bat")
        (setq new_script "run-script.sh")))
    (setq autorun-script-mode-script new_script)))



(defun autorun-script-set-mode-script-name ()
  "Set the mode run script name for the call."
  (interactive)
  (let ((current_args (gethash major-mode autorun-script-mode-script)))
    (let ((new_script (read-string "MajorMode Script Name: " current_args)))
    (if (= (length new_script) 0)
        (remhash major-mode autorun-script-mode-script)
    (puthash major-mode  new_script autorun-script-mode-script)))))



(defun autorun-script-set-buffer-script-name ()
  "Set the buffer run script name for the call."
  (interactive)
  (let ((local_script (read-string "Script Name: " autorun-script-buffer-local-file)))
    (when (= (length local_script) 0)
      (setq local_script nil))
  (setq-local autorun-script-buffer-local-file local_script)))



(defun autorun-script-toggle-enabled ()
  "Toggle if autorun-script is active"
  (interactive)
  (setq autorun-script-active (not autorun-script-active))
  (message (concat "autorun-script is: " (if autorun-script-active "Enabled" "Disabled"))))



(defun autorun-script-toggle-response ()
  "Toggle if autorun-script script call will return the response from the script called."
  (interactive)
  (setq autorun-script-response-on (not autorun-script-response-on))
  (message (concat "autorun-script response is : " (if autorun-script-response-on "Enabled" "Disabled"))))



(defun autorun-script-toggle-buffer-active ()
  "Toggle if autorun-script is active"
  (interactive)
  (setq autorun-script-buffer-disabled (not autorun-script-buffer-disabled))
  (message (concat "autorun-script for buffer is: " (if autorun-script-buffer-disabled "disabled" "enabled"))))



(defun autorun-script-replace-vars (args)
  "Replace variables in the provided argument with appropriate values."
  "This function should be superseded by a p-list and user customizable values"
  (let ((vars #s(hash-table
     size 30
     test equal
     data ("date" (format-time-string "%d.%m.%Y")
           "datetime" (format-time-string "%d.%m.%Y:%H:%M:%S")
           "time" (format-time-string "%H:%M:%S:%6N")
           "path" (buffer-file-name)
           "file" (file-name-base (buffer-file-name))
           "ext" (file-name-extension (buffer-file-name))
           "dir"  (replace-regexp-in-string "Directory " "" (file-name-directory (pwd))))))
        (out_text args))
    (mapc (lambda (var)
            (setq out_text (replace-regexp-in-string (concat "[{]" var "[}]") (eval (gethash var vars)) out_text))) (hash-table-keys vars))
    (progn out_text)))



(defun autorun-script-after-save (&optional run-anyway)
  "Used in `after-save-hook'."

  (when (or run-anyway
            (and (member major-mode autorun-script-alist) autorun-script-active))

    (when (not run-anyway)
      (unless autorun-script-active (error "Cannot run because autorun-script disabled globally"))
      (unless (not autorun-script-buffer-disabled) (error "autorun-script disabled in this buffer")))

    (let ((curDir (autorun-script-current-dir))
          (exfile autorun-script-file)
          (args  (file-name-extension (buffer-file-name)))
          (response "")
          (executed nil)
          (parentcount 0)
          (msgprefix "SYS:"))

      ;; OVERRIDES

      ;; MODES
      (when (and (member major-mode (hash-table-keys autorun-script-mode-args))
                 (gethash major-mode autorun-script-mode-args))
        (setq args (gethash major-mode autorun-script-mode-args))
        (setq msgprefix "MODE:"))

      (when (member major-mode (hash-table-keys autorun-script-mode-script))
        (setq exfile (gethash major-mode autorun-script-mode-script)))


      ;; PATHS WIN OVER MODES


      ;; BUFFERS WIN OVER EVERYTHING
      ;; Check if buffer has it's own arguments
      (when (and (boundp 'autorun-script-buffer-arg) autorun-script-buffer-arg)
        (setq args autorun-script-buffer-arg)
        (setq msgprefix "BUFF:"))

      ;; Override of script file
      (when autorun-script-buffer-local-file
        (setq exfile autorun-script-buffer-local-file))

      ;; BAIL ON BAD DATA
      (unless curDir (error "Cannot locate current directory... eerg!"))
      (unless exfile (error "No script file to run!... eerg!"))

      (while (and (not (autorun-script-at-base-dir curDir))
                  (not executed)
                  (or (<= parentcount autorun-search-depth)
                       (= autorun-search-depth -1)))
        (if (file-exists-p (concat curDir exfile))
            (let ((default-directory curDir))
              ;; REPLACE VARS
              (setq args (autorun-script-replace-vars args))
              ;; UPDATE USER
              (message (concat msgprefix "autoscript: " (concat curDir exfile " <args: " args " > " )))
              ;; MAKE CALL
              (setq response (shell-command-to-string (concat curDir exfile " " args)))
              (when autorun-script-response-on
                (autorun-script-log response))
              (setq executed t))
          (progn
            (setq parentcount (+ parentcount 1))
            (setq curDir (autorun-script-parent-dir curDir))))))))



;; HOOKS
(add-hook 'after-save-hook 'autorun-script-after-save)
(provide 'autorun-script)
