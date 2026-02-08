;; -*- lexical-binding: t -*-

;; DARK MODE EVERYTHING
(load-theme 'doom-one t)                ; Dark theme
(setq inhibit-startup-message t)        ; No splash screen
(tool-bar-mode -1)                      ; Remove toolbar
(scroll-bar-mode -1)                    ; Remove scrollbar
(menu-bar-mode -1)                      ; Remove menu bar

;; Dark modeline
(require 'doom-modeline)
(doom-modeline-mode 1)

;; ESSENTIAL PACKAGES
(require 'use-package)

;; Directory navigation
(use-package treemacs
  :config
  (treemacs-follow-mode t))

;; Container management
(use-package docker
  :config
  (setq docker-container-shell-file-name "/bin/bash"))

;; Load keybindings
(load-file (expand-file-name "modules/keybindings.el" (file-name-directory load-file-name)))

;; Startup Menu Function
(defun main-menu ()
  "Display a simple startup menu with common actions."
  (interactive)
  (switch-to-buffer "*Main Menu*")
  (read-only-mode -1)
  (erase-buffer)
  (insert "\n\n"
          "    * EMACS MAIN MENU *\n\n"
          "    Select an option:\n\n"
          "    [T] Open Terminal (vterm)\n"
          "    [E] Open File Explorer (treemacs)\n"
          "    [B] Open Browser (eww)\n"
          "    [F] Find File\n"
          "    [D] Docker Containers\n\n"
          "    [Q] Quit Emacs\n\n"
          "    Press corresponding key to select.\n")
  (read-only-mode 1)
  (goto-char (point-min))

  ;; Set up menu keybindings (local to this buffer)
  (local-set-key (kbd "t") (lambda () (interactive) (vterm)))
  (local-set-key (kbd "T") (lambda () (interactive) (vterm)))
  (local-set-key (kbd "e") (lambda () (interactive) (treemacs)))
  (local-set-key (kbd "E") (lambda () (interactive) (treemacs)))
  (local-set-key (kbd "b") (lambda () (interactive) (eww "https://google.com")))
  (local-set-key (kbd "B") (lambda () (interactive) (eww "https://google.com")))
  (local-set-key (kbd "f") (lambda () (interactive) (find-file "~/")))
  (local-set-key (kbd "F") (lambda () (interactive) (find-file "~/")))
  (local-set-key (kbd "d") (lambda () (interactive) (docker-containers)))
  (local-set-key (kbd "D") (lambda () (interactive) (docker-containers)))
  (local-set-key (kbd "q") 'save-buffers-kill-terminal)
  (local-set-key (kbd "Q") 'save-buffers-kill-terminal))

;; Show menu on startup
(add-hook 'emacs-startup-hook 'main-menu)
