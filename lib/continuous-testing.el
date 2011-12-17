
(defvar ct-dev-file-name "dms.org")
(defvar ct-src-file-name "dms.py")
(defvar ct-test-file-name "test_dms.py")
(defvar ct-example-file-name "dms.org")
(defvar ct-project-dir "~/.emacs.d/martyn/martyn/DMS/")
(defvar ct-src-dir "lib/")
(defvar ct-dev-dir "dev/")
(defvar ct-test-dir "test/")
(defvar ct-example-dir "")
(defvar ct-language "python")

(defun ct-project ()
  (interactive)
  (let ((test-output-buffer
         (cond ((string= "python" ct-language)
                "*Python*")
               ((string= "emacs-lisp" ct-language)
                "*ert*")
               (t (error "ERROR! Unrecognised ct-language")))))
    
  (when (not (string= "" ct-example-file-name))
    (find-file (concat ct-project-dir ct-example-dir ct-example-file-name)))
  (delete-other-windows)
  (split-window-horizontally)
  (windmove-right)
  (find-file (concat ct-project-dir ct-dev-dir ct-dev-file-name))
  (find-file (concat ct-project-dir ct-src-dir ct-src-file-name))
  (windmove-left)
  (find-file (concat ct-project-dir ct-test-dir ct-test-file-name))
  (switch-to-buffer ct-test-file-name)
  (split-window-vertically)
  (switch-to-buffer test-output-buffer)
  (ct-add-hook)
  (windmove-down)
  (switch-to-buffer ct-test-file-name)
  (global-set-key [f4] 'ct-switch-src-control-file)
  (message (concat (file-name-sans-extension
                    " project setup complete..."))))) 

(defun ct-switch-src-control-file()
  "Fast route to project control file and back"
  (interactive)
  (let ((project-buffer ct-dev-file-name)
        (buffer))
    (unless (boundp 'ct-last-buffer)
      (setq ct-last-buffer ct-src-file-name))
    (if (equal (buffer-name) project-buffer)
        (setq buffer ct-last-buffer)
      (setq ct-last-buffer (buffer-name))
      (setq buffer project-buffer))
    (message (concat "Switching to " buffer))
    (switch-to-buffer buffer)))

(defun ct-post-save-hook ()
  (let ((original-buffer buffer-file-name)
        (original-window (selected-window)))
    (when (or (string-match 
               ct-src-file-name (file-name-nondirectory original-buffer)) 
              (string-match 
               ct-test-file-name (file-name-nondirectory original-buffer))
              (string-match 
               ct-example-file-name (file-name-nondirectory original-buffer)))
      (cond ((string= ct-language "python")
;;             (switch-to-buffer ct-test-file-name)
             (switch-to-buffer "*Python*")
             (erase-buffer)
             (call-process
              "python"     ;program
              ct-test-file-name
              "*Python*"   ;buffer
              t            ;display
              ))  ;&rest...
;;             (python-send-buffer))
            ((string= ct-language "emacs-lisp")
             (eval-buffer ct-test-file-name)
             (eval-buffer ct-src-file-name)
             (ert t)))
      (switch-to-buffer (file-name-nondirectory original-buffer)))))

(defun ct-add-hook ()
  (interactive)
  (save-excursion
    (set-buffer ct-src-file-name)
    (save-buffer)
    (set-buffer ct-test-file-name)
    (save-buffer))
  (add-hook 'after-save-hook 'ct-post-save-hook nil nil)
  (set-buffer ct-src-file-name)
  (revert-buffer nil t) 
  (set-buffer ct-test-file-name)
  (revert-buffer nil t))

(defun ct-remove-hook ()
  (interactive)
    (save-excursion
    (set-buffer ct-src-file-name)
    (save-buffer)
    (set-buffer ct-test-file-name)
    (save-buffer))
  (remove-hook 'after-save-hook 'ct-post-save-hook nil)
  (save-excursion
    (set-buffer ct-src-file-name)
    (revert-buffer nil t) 
    (set-buffer ct-test-file-name)
    (revert-buffer nil t)))

(provide 'continuous-testing)
