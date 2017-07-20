;; ---------------------------------------------------------------------
;; Allow automated package installation
;; ---------------------------------------------------------------------
(require 'package)
(package-initialize)
(add-to-list 'package-archives
             '("melpa-stable" . "http://stable.melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("marmalade" . "http://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)

(unless (package-installed-p 'use-package)
    (progn
      (package-refresh-contents)
      (package-install 'use-package)))
(require 'use-package)

(unless package-archive-contents
  (package-refresh-contents))

;; ---------------------------------------------------------------------
;; Packages
;; ---------------------------------------------------------------------
;; Allow solarized theme as safe
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("4aee8551b53a43a883cb0b7f3255d6859d766b6c5e14bcb01bed572fcbef4328" default)))
 '(package-selected-packages
   (quote
    (idle-highlight-mode better-defaults yaml-mode markdown-mode color-theme-sanityinc-solarized use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package color-theme-sanityinc-solarized
  :ensure color-theme-sanityinc-solarized)
;; Load dark solarized theme
(load-theme 'sanityinc-solarized-dark)

(use-package markdown-mode
  :ensure t
  :mode
  ("\\.text\\'" . markdown-mode)
  ("\\.markdown\\'" . markdown-mode)
  ("\\.md\\'" . markdown-mode)
  )

(use-package yaml-mode
  :ensure t
  :mode
  ("\\.yml\\'" . yaml-mode)
  )

(use-package better-defaults
  :ensure t
  )

(use-package idle-highlight-mode
  :ensure t
  )

; list the packages you want
;ido-ubiquitous
;find-file-in-project magit smex scpaste

;; ---------------------------------------------------------------------
;; Configuration
;; ---------------------------------------------------------------------
;; Inhibit splash screen
(setq inhibit-splash-screen t)

;; Modules
(add-to-list 'load-path "~/.emacs.d/elpa")

;; Backup files go into a common directory
(setq backup-directory-alist `(("." . "~/.emacs.d/.saves")))

;; Change save interval from 300 to 1000
;; keystrokes so it isn't so annoying
(setq auto-save-interval 1000)

;; Remove the toolbar
(tool-bar-mode -1)

;;Disable ctrl-z behaviour
(global-set-key "\C-z" nil)

;; Enable syntax highlighting for appropriate modes
(global-font-lock-mode t)
;; Enable visual feedback upon selection
(setq transient-mark-mode t)
;; Enable column number mode
(setq column-number-mode t)

;; Set-up some keys globally
(global-set-key "\C-xl" 'goto-line)
(global-set-key "\C-cu" 'uncomment-region)
(global-set-key "\C-ci" 'indent-region)
(global-set-key [f3] 'grep-find)
;; Tell grep-find to ignore svn directories
(setq grep-find-command
  "find . -path '*/.svn' -prune -o -type f -print | xargs -e grep -I -n -e ")

(require 'cl) ;;gives unless command
;; Needed to get bash ctrl-left/ctrl-right working
(unless window-system
  (global-set-key "\e[;5D" 'backward-word)
  (global-set-key "\e[5C" 'forward-word)
  (global-set-key "\e[1;5F" 'end-of-buffer)
  (global-set-key "\e[1;5H" 'beginning-of-buffer))

;;turn on mouse wheel
(if (load "mwheel" t)
	(mwheel-install))

;;ask about newline at end of text files
(setq require-final-newline 'query)

;; Remove trailing whitespace upon saving
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;reload files if they change on disk
(global-auto-revert-mode t)

;; File associations
;; C++
(setq auto-mode-alist (cons '("\\.C$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cc$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.c$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.h$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cpp$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cxx$" . c++-mode) auto-mode-alist))

;; Set BSD style indent with a default of 2 spaces per tab for global things
(setq c-default-style "bsd"
      c-basic-offset 2)

;; Turn off use of tabs for indentation in many modes
(setq indent-tabs-mode nil)

;; If indent-tabs-mode is off, untabify before saving
;; (add-hook 'write-file-hooks
;;           (lambda ()
;; 	    (if (not indent-tabs-mode)
;; 		(untabify (point-min) (point-max)))))

;; LaTeX mode
(add-hook 'latex-mode-hook
	  '(lambda()
	     (setq indent-tabs-mode nil)
	     ))
;; C mode
(add-hook 'c-mode-hook
	  '(lambda()
	     (setq indent-tabs-mode nil)
	     ))
;; C++ mode
(add-hook 'c++-mode-hook
	  '(lambda()
	     (setq indent-tabs-mode nil)
	     ))
;; CMake mode
(add-hook 'cmake-mode-hook
	  '(lambda()
	     (setq indent-tabs-mode nil)
	     ))
;; Python mode
(add-hook 'python-mode-hook
	  '(lambda()
	     (setq indent-tabs-mode nil)
	     ))
;; Fortran mode
(add-hook 'fortran-mode-hook
	  '(lambda()
	     (setq indent-tabs-mode nil)
	     ))
;; perl mode
(add-hook 'perl-mode-hook
	  '(lambda()
	     (setq indent-tabs-mode nil)
	     ))
;; Lisp mode
(add-hook 'lisp-mode-hook
	  '(lambda()
	     (setq indent-tabs-mode nil)
	     ))
