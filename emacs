;; ---------------------------------------------------------------------
;; This is written against emacs-major-version=30
;; ---------------------------------------------------------------------
;; Allow automated package installation
;;
;; To clean out the package cache:
;; M-x package-refresh-contents
;; ---------------------------------------------------------------------
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(package-initialize)

(require 'cl-lib) ;;gives unless command
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
 '(package-selected-packages nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(use-package solarized-theme
  :ensure solarized-theme)
;; Load dark solarized theme
(load-theme 'solarized-dark t)

(use-package markdown-mode
  :ensure t
  :mode
  ("\\.text\\'" . markdown-mode)
  ("\\.markdown\\'" . markdown-mode)
  ("\\.md\\'" . markdown-mode)
  )

(use-package lua-mode
  :ensure t
  :mode
  ("\\.lua\\'" . lua-mode)
  )

(use-package yaml-mode
  :ensure t
  :mode
  ("\\.yml\\'" . yaml-mode)
  )

; list the packages you want
;ido-ubiquitous
;find-file-in-project magit smex scpaste

;; ---------------------------------------------------------------------
;; https://github.com/redguardtoo/find-file-in-project to use
;; fd https://github.com/sharkdp/fd?tab=readme-ov-file#using-fd-with-emacs
;;
;; M-x find-file-in-project
;; ---------------------------------------------------------------------
(package-install 'find-file-in-project)
(require 'find-file-in-project)
(setq ffip-use-rust-fd t)

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
;; turn on line numbers
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Set-up some keys globally
(global-set-key "\C-xl" 'goto-line)
(global-set-key "\C-cu" 'uncomment-region)
(global-set-key "\C-ci" 'indent-region)

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

;; Turn off use of tabs for indentation in many modes
(setq indent-tabs-mode nil)

;; ---------------------------------------------------------------------
;; on-the-fly syntax checking
;; ---------------------------------------------------------------------
(use-package flycheck
  :ensure t
  :config
  (add-hook 'after-init-hook #'global-flycheck-mode))

;; ---------------------------------------------------------------------
;; ripgrep for finding
;; ---------------------------------------------------------------------
(use-package rg
  :ensure t
)
(rg-enable-default-bindings)

;; -------------------------------------------------------------------
;; tree-sitter does more accurate tokenization for better highlighting
(use-package tree-sitter
    :ensure t
      :custom
  ;; Some stuff taken from here: https://robbmann.io/posts/emacs-treesit-auto/
  (treesit-extra-load-path '("/usr/lib64/"))
  (treesit-language-source-alist
   '((bash .       ("https://github.com/tree-sitter/tree-sitter-bash"))
     (c .          ("https://github.com/tree-sitter/tree-sitter-c"))
     (c++ .        ("https://github.com/tree-sitter/tree-sitter-cpp"))
     (css .        ("https://github.com/tree-sitter/tree-sitter-css"))
     (html .       ("https://github.com/tree-sitter/tree-sitter-html"))
     (java .       ("https://github.com/tree-sitter/tree-sitter-java"))
     (javascript . ("https://github.com/tree-sitter/tree-sitter-javascript"))
     (json .       ("https://github.com/tree-sitter/tree-sitter-json"))
     (lua .        ("https://github.com/Azganoth/tree-sitter-lua"))
     (makefile .   ("https://github.com/alemuller/tree-sitter-make"))
     (python .     ("https://github.com/tree-sitter/tree-sitter-python"))
     (typescript . ("https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src"))
     (ruby .       ("https://github.com/tree-sitter/tree-sitter-ruby"))
     (rust .       ("https://github.com/tree-sitter/tree-sitter-rust"))
     (sql .        ("https://github.com/m-novikov/tree-sitter-sql"))
     (toml .       ("https://github.com/tree-sitter/tree-sitter-toml"))
     (yaml .       ("https://github.com/ikatyang/tree-sitter-yaml"))))
  (major-mode-remap-alist
   '((c-mode . c-ts-mode)
     (c++-mode . c++-ts-mode)
     (css-mode . css-ts-mode)
     (html-mode . html-ts-mode)
     (java-mode . java-ts-mode)
     (js-mode . js-ts-mode)
     (json-mode . json-ts-mode)
     (makefile-mode . makefile-ts-mode)
     (python-mode . python-ts-mode)
     (typescript-mode . typescript-ts-mode)
     (ruby-mode . ruby-ts-mode)
     (rust-mode . rust-ts-mode)
     (toml-mode . toml-ts-mode)
     (yaml-mode . yaml-ts-mode)))
  (treesit-auto-fallback-alist
   '((toml-ts-mode . conf-toml-mode)
     (typescript-ts-mode . nil)
     (tsx-ts-mode . nil)))
  (treesit-font-lock-settings t)
  (treesit-simple-indent t)
  (treesit-defun-type-regexp t)
    )
(use-package tree-sitter-langs
    :ensure t)
(global-tree-sitter-mode)
(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)

;; -------------------------------------------------------------------
(package-install 'lsp-mode)
(use-package lsp-mode
  :custom
  (lsp-completion-provider :none) ;; we use Corfu!
)

;; add hooks for lsp - requires the lsp-server setup
;;(add-hook 'python-mode-hook #'lsp)
;;(add-hook 'c++-mode-hook #'lsp)

;; -------------------------------------------------------------------
(if (> emacs-major-version 29) ;; does not exist in emacs 29
  (package-install 'orderless)
  (use-package orderless
    :ensure t
    :init
    (completion-styles '(orderless literal-only))
    (completion-category-overrides '((file (styles partial-completion))))
    ;;(completion-category-defaults nil) ;; Disable defaults, use our settings
    ;;(completion-pcm-leading-wildcard t)
  )

  (orderless-define-completion-style orderless-literal-only
				     (orderless-style-dispatchers nil)
				     (orderless-matching-styles '(orderless-literal)))

  (add-hook 'corfu-mode-hook
            (lambda ()
              (setq-local completion-styles '(orderless-literal-only basic)
                          completion-category-overrides nil
                          completion-category-defaults nil)))

  (setq orderless-matching-styles '(orderless-literal orderless-regexp orderless-flex))
)

;; -------------------------------------------------------------------
;; set up corfu https://github.com/minad/corfu
;; much taken from https://andrewfavia.dev/posts/emacs-as-python-ide-again/
(package-install 'corfu)
(use-package corfu
  ;; :after orderless
  ;; Optional customizations
  :custom
  (corfu-auto t) ;; turn on corfu
;;  (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
;;  (corfu-preselect-first t)
;;  (corfu-separator ?\s)          ;; Orderless field separator
;;  (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
;;  (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
;;  (corfu-preview-current nil)    ;; Disable current candidate preview
;;  ;; (corfu-preselect-first nil)    ;; Disable candidate preselection
;;  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
;;  ;; (corfu-echo-documentation nil) ;; Disable documentation in the echo area
;;  (corfu-scroll-margin 5)        ;; Use scroll margin
  ;; Enable Corfu only for certain modes.
;;  :hook ((python-mode . corfu-mode)
;;         (c++-mode-hook . corfu-mode)
;;         (cmake-mode-hook . corfu-mode)
;;         (lisp-mode-hook . corfu-mode)
;;        )

 :init
 (global-corfu-mode)
 :config
 (corfu-popupinfo-mode t)
 )

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  ;;(tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p)
)
