;; -*- lexical-binding: t -*-

;; DIRECTORY NAVIGATION
(global-set-key (kbd "C-x t") 'treemacs)              ; Open file tree
(global-set-key (kbd "C-x d") 'dired)                 ; Open directory

;; CONTAINER MANAGEMENT
(global-set-key (kbd "C-x c") 'docker-containers)     ; List containers
(global-set-key (kbd "C-x i") 'docker-images)         ; List images

;; BASIC NAVIGATION
(global-set-key (kbd "C-x C-f") 'find-file)           ; Open file (default)
(global-set-key (kbd "C-x b") 'switch-to-buffer)      ; Switch buffer (default)

;; Return to main menu hotkey
(global-set-key (kbd "C-x m") 'main-menu)
