;; Package management configurations.
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
		(goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(setq straight-use-package-by-default t)

(straight-use-package 'use-package)

;; (eval-when-compile
  ;; (require 'use-package)
  ;; )
(straight-use-package 'diminish)
;; TODO: Use Diminish for RYO
													 ;(require 'diminish)
;; (require 'bind-key)
;; (require 'use-package-ensure)
;; (setq use-package-always-ensure t)

;; Persient Soft
(straight-use-package 'pcache)
(straight-use-package 'persistent-soft)
;; (require 'persistent-soft)
;(persistent-soft-store 'hundred 100 "mydatastore")
(persistent-soft-fetch 'hundred "mydatastore")
;(persistent-soft-fetch 'thousand "mydatastore")

;; (add-hook 'after-init-hook (lambda (
;; 												(recentf-mode)
;; 												;; (recentf-load-list)
;; 												)))
(recentf-mode t)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(run-at-time nil (* 5 60) 'recentf-save-list)
;; (add-hook 'kill-emacs-hook 'recentf-save-list)
;; (add-hook 'after-save-hook 'recentf-save-list)

(straight-use-package 'smartparens)
(smartparens-mode t)
(add-hook 'prog-mode-hook 'smartparens-mode)
(add-hook 'text-mode-hook 'smartparens-mode)

;; Vertical completion.
(straight-use-package 'selectrum)
(selectrum-mode t)
(straight-use-package 'prescient)
;; (prescient-filter-method fuzzy)


;; (straight-use-package 'company-prescient)
;; (company-prescient-mode t)
(straight-use-package 'selectrum-prescient)
(selectrum-prescient-mode t)
(prescient-persist-mode t)

;; Enable richer annotations using the Marginalia package
(native-compile-async "~/.emacs.d/marginalia/" 'recursively)
(add-to-list 'load-path "~/.emacs.d/marginalia/")
(load "marginalia")
(marginalia-mode)
(setq marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light))

;; Folding
(straight-use-package
							 '(origami :type git :host github :repo "jcs-elpa/origami.el"))
(global-origami-mode t)

;; Tree
(straight-use-package 'treemacs)

;; Projectile
(straight-use-package 'projectile)
(projectile-mode t)

;; Syntax highlighting
(straight-use-package 'tree-sitter)
(straight-use-package 'tree-sitter-langs)

(require 'tree-sitter)
(require 'tree-sitter-langs)
;; (global-tree-sitter-mode)
(add-hook 'tree-sitter-mode-hook 'tree-sitter-hl-mode)

;; Indentation
(straight-use-package 'smart-tabs-mode)
(setq-default indent-tabs-mode t)

(setq-default tab-width 3)
(setq c-basic-offset 3)
(setq cua-auto-tabify-rectangles nil)
;; (setq-default tab-always-indent t)
(setq-default indent-tabs-mode t)

(defadvice align (around smart-tabs activate)
  (let ((indent-tabs-mode nil)) ad-do-it))
(defadvice align-regexp (around smart-tabs activate)
  (let ((indent-tabs-mode nil)) ad-do-it))
(defadvice indent-relative (around smart-tabs activate)
  (let ((indent-tabs-mode nil)) ad-do-it))
(defadvice indent-according-to-mode (around smart-tabs activate)
  (let ((indent-tabs-mode indent-tabs-mode))
    (if (memq indent-line-function
              '(indent-relative
                indent-relative-maybe))
        (setq indent-tabs-mode nil))
    ad-do-it))
(defmacro smart-tabs-advice (function offset)
  `(progn
     (defvaralias ',offset 'tab-width)
     (defadvice ,function (around smart-tabs activate)
       (cond
        (indent-tabs-mode
         (save-excursion
           (beginning-of-line)
           (while (looking-at "\t*\\( +\\)\t+")
             (replace-match "" nil nil nil 1)))
         (setq tab-width tab-width)
         (let ((tab-width fill-column)
               (,offset fill-column)
               (wstart (window-start)))
           (unwind-protect
               (progn ad-do-it)
             (set-window-start (selected-window) wstart))))
        (t
         ad-do-it)))))

(use-package aggressive-indent
  :config
  (add-to-list
   'aggressive-indent-dont-indent-if
   '(and (derived-mode-p 'c++-mode)
         (null (string-match "\\([;{}]\\|\\b\\(if\\|for\\|while\\)\\b\\)"
                             (thing-at-point 'line)))))
  :init
  ;; (add-hook 'emacs-lisp-mode-hook (lambda () (aggressive-indent-mode t)))
  ;; (add-hook 'c-mode-common-hook #'aggressive-indent-mode)
  ;; (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)
  )

;; (add-hook 'emacs-lisp-mode-hook (lambda () (aggressive-indent-mode t)))
;; (add-hook 'c-mode-common-hook (lambda () (aggressive-indent-mode t)))
;; (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)
;; (add-hook 'c-mode-common-hook   #'aggressive-indent-mode)

(use-package highlight-indent-guides
  ;; :hook
  ;; (prog-mode-hook . highlight-indent-guides)
  ;; :init
  )
;; (add-hook 'c++-mode-hook #'highlight-indent-guides-mode)

;; (add-hook 'prog-mode-hook #'highlight-indent-guides-mode)
;; (add-hook 'prog-mode-hook (lambda () (highlight-indent-guides-mode t)))
(setq highlight-indent-guides-method 'character)
(setq highlight-indent-guides-responsive 'top)
(setq highlight-indent-guides-delay 0)

;; Completion
(straight-use-package 'flycheck)
(add-hook 'prog-mode-hook 'flycheck-mode)
;; (global-flycheck-mode)

(use-package company
  :straight t
  :diminish
  ;; :hook (company-mode . (lambda() (setq company-backend (company-capf :with company-dabbrev))))
  :config
  (add-to-list 'company-backends '(company-files ))
  (add-to-list 'company-backends '(company-capf ))
  :custom
  (company-begin-commands '(self-insert-command))
  (company-require-match nil)
  (company-idle-delay .6)
  (company-minimum-prefix-length 1)
  (company-show-numbers t)
  (company-tooltip-align-annotations t))

;; (setq company-dabbrev-downcase nil)
(setq-local completion-ignore-case nil)
;; (setq company-dabbrev-code-ignore-case nil)
;; (setq company-dabbrev-ignore-case nil)

;; (push (apply-partially #'cl-remove-if
                       ;; (lambda (c) (string-match-p "\\`[0-9]+\\'" c)))
      ;; company-transformers)

;; (add-hook 'org-mode-hook 'company-org-roam)
;; (add-hook 'prog-mode-hook 'company-mode)

(straight-use-package 'company-posframe)
(straight-use-package 'company-box)
(add-hook 'company-mode-hook 'company-box-mode)

;; Formatting
;; (straight-use-package 'format-all)
;; (add-hook 'prog-mode-hook 'format-all-mode)

(use-package lsp-mode
  :straight t
  :hook
  (lisp-mode . lsp-deferred)
  (c-mode-hook . lsp-deferred)
  (c++-mode-hook . lsp-deferred)
  :config
  :custom
  (company-lsp-cache-candidates 'auto)
  (company-lsp-async t)
  (company-lsp-enable-snippet t)
  (company-lsp-enable-recompletion t)
  :commands (lsp lsp-deferred))
(use-package lsp-ui
  :straight t
  :commands lsp-ui-mode)
(add-to-list 'load-path "~/.emacs.d/cask/core/")
(add-to-list 'load-path "~/.emacs.d/cask/lisp/")
(add-to-list 'load-path "~/.emacs.d/cask/langs/")
(use-package lsp-treemacs
  :straight t
  :commands lsp-treemacs-errors-list
  :config
  (add-to-list 'company-backends '(company-lsp)))

;; Doesn't seem to work rn.
;; (use-package company-tabnine
;; :straight t
;; :ensure t
;; )
;; (require 'company-tabnine)
;; (add-to-list 'company-backends 'company-tabnine)

;; (straight-use-package 'flx)
;; (use-package company-fuzzy
;;   :straight t
;;   :config
;;   ;; (add-to-list 'company-fuzzy-history-backends 'company-yasnippet)
;;   :custom
;;   (company-fuzzy-sorting-backend 'flx)
;;   (company-fuzzy-prefix-on-top t)
;;   (company-fuzzy-show-annotation t))

(straight-use-package 'company-prescient)
(add-hook 'company-mode-hook 'company-prescient-mode)

;; Company keybindings
(add-hook 'company-mode-hook 'company-tng-mode)
(define-key company-active-map (kbd "TAB") 'company-select-next)
(define-key company-active-map (kbd "<backtab>") 'company-select-previous)
(define-key company-active-map (kbd "RET") nil)

(global-company-mode t)

;; Debugging
;; TODO: Configure debugger.
(straight-use-package 'dap-mode)
(add-hook 'dap-stopped-hook
          (lambda (arg) (call-interactively #'dap-hydra)))


;; Languages
;; V
(straight-use-package
 '(vlang-mode :type git :host github :repo "Naheel-Azawy/vlang-mode"))

;; (smart-tabs-add-language-support vlang vlang-mode-hook
  ;; ((c-indent-line . c-basic-offset)
   ;; (c-indent-region . c-basic-offset)))

;; C++
(add-hook 'c++-mode-hook 'tree-sitter-mode)
;; (lambda () (setq indent-tabs-mode t)))

(smart-tabs-advice c-indent-line c-basic-offset)
(smart-tabs-advice c-indent-region c-basic-offset)

(straight-use-package 'cmake-project)
(defun maybe-cmake-project-mode ()
  (if (or (file-exists-p "CMakeLists.txt")
          (file-exists-p (expand-file-name "CMakeLists.txt" (car (project-roots (project-current))))))
      (cmake-project-mode)))

(straight-use-package 'disaster)

(add-hook 'c-mode-hook 'maybe-cmake-project-mode)
(add-hook 'c++-mode-hook 'maybe-cmake-project-mode)

(straight-use-package 'cmake-mode)
(straight-use-package 'cmake-font-lock)
(add-hook 'cmake-mode-hook 'cmake-font-lock-activate)

(setq gc-cons-threshold (* 100 1024 1024)
      read-process-output-max (* 1024 1024)
      treemacs-space-between-root-nodes nil
      ;; company-idle-delay 0.0
      ;; company-minimum-prefix-length 1
      lsp-idle-delay 0.1 ;; clangd is fast
      ;; be more ide-ish
      lsp-headerline-breadcrumb-enable t)

(straight-use-package 'cpp-auto-include)

													 ;(sp-local-pair 'c++-mode "/*" "*/" :post-handlers '((" | " "SPC")
													 ;                                                    ("* ||\n[i]" "RET"))
													 ;					)
;; (straight-use-package 'cmake-ide)

;; SQL
(straight-use-package 'exec-path-from-shell)
(straight-use-package 'emacsql)
(straight-use-package 'emacsql-mysql)

;; ;; HLSL
;; ;;(straight-use-package 'hlsl-mode)
;; (use-package hlsl-mode
;;   ;; :straight t
;;   :load-path "~/.emacs.d/hlsl/hlsl-mode.el"
;;   )

;; Elisp
;; https://github.com/Fuco1/.emacs.d/blob/master/files/smartparens.el
(sp-with-modes sp--lisp-modes
  (sp-local-pair "(" nil
                 :wrap "C-("
                 :pre-handlers '(my-add-space-before-sexp-insertion)
                 :post-handlers '(my-add-space-after-sexp-insertion))
  (sp-local-pair "'" nil :actions nil))

(defun my-add-space-after-sexp-insertion (id action _context)
  (when (eq action 'insert)
    (save-excursion
      (forward-char (sp-get-pair id :cl-l))
      (when (or (eq (char-syntax (following-char)) ?w)
                (looking-at (sp--get-opening-regexp)))
		  (insert " ")))))

(defun my-add-space-before-sexp-insertion (id action _context)
  (when (eq action 'insert)
    (save-excursion
      (backward-char (length id))
      (when (or (eq (char-syntax (preceding-char)) ?w)
                (and (looking-back (sp--get-closing-regexp))
                     (not (eq (char-syntax (preceding-char)) ?'))))
        (insert " ")))))


(with-eval-after-load 'lsp-mode
  (add-hook 'lsp-mode-hook 'lsp-enable-which-key-integration))


;; https://www.emacswiki.org/emacs/SmartTabs
;; (smart-tabs-insinuate 'c ;; 'vlang
                      ;; 'c++)

;; Debugging
(use-package dap-mode
  :straight t
  )


;; Searching
;; TODO: Configure this
(straight-use-package 'ctrlf)
(ctrlf-mode t)

(straight-use-package 'restart-emacs)


;; EDITOR SETTINGS
;; (when (display-graphic-p) ; Start full screen
;; (add-to-list 'default-frame-alist '(fullscreen . t))
;; (x-focus-frame nil)
;; )

(setq inhibit-splash-screen t)
(add-hook 'emacs-startup-hook 'dired-jump)

;; Make frame borderless.
;; (setq default-frame-alist '((undecorated . t)))
;; (add-to-list 'default-frame-alist '(drag-internal-border . 1))
;; (add-to-list 'default-frame-alist '(internal-border-width . 5))

(setq-default frame-title-format "Emacs %b (%f)")

(use-package hungry-delete
  :straight t
  :config
  (global-hungry-delete-mode)
  )
;; (straight-use-package 'duplicate-thing)

(straight-use-package 'syntax-subword)
(global-syntax-subword-mode t)

;; Ripgrep
													 ;(grep-apply-setting
													 ;   'grep-find-command
													 ;   '("rg -n -H --no-heading -e '' $(git rev-parse --show-toplevel || pwd)" . 27)
													 ;	)

;; Crux
(straight-use-package 'crux)

;; Comments
(straight-use-package 'banner-comment)
;; (straight-use-package 'smart-comment)
(straight-use-package 'nocomments-mode)

;; (add-hook 'before-save-hook #'delete-trailing-whitespace)
(setq-default require-final-newline t)
(add-hook 'org-mode-hook (lambda () (require-final-newline nil)))

;; This is disabled because it causes Avy to be slow.
;; This is a known Avy issue. I very much wish I'll be able to
;; enable it in all modes one day.
;; (global-visual-line-mode)
(add-hook 'text-mode 'visual-line-mode)

;; (use-package super-save
;;   :straight t
;;   :config
;;   (super-save-mode t)
;;   )

(use-package embark
  :straight (:host github :repo "oantolin/embark"
						 :branch "master"))

;; MODELINE
(straight-use-package 'all-the-icons)
(display-time-mode t)

(straight-use-package 'telephone-line)

(setq
 telephone-line-primary-right-separator 'telephone-line-abs-right
 telephone-line-secondary-right-separator 'telephone-line-abs-hollow-right
 telephone-line-primary-left-separator 'telephone-line-tan-right
 telephone-line-secondary-left-separator 'telephone-line-tan-hollow-right)

(defface my-red '((t (:foreground "white" :background "red"))) "")
(defface my-orangered '((t (:foreground "white" :background "orange red"))) "")
(defface my-orange '((t (:foreground "dim grey" :background "orange"))) "")
(defface my-gold '((t (:foreground "dim grey" :background "gold"))) "")
(defface my-yellow '((t (:foreground "dim grey" :background "yellow"))) "")
(defface my-chartreuse '((t (:foreground "dim grey" :background "chartreuse"))) "")
(defface my-green '((t (:foreground "dim grey" :background "green"))) "")
(defface my-sgreen '((t (:foreground "dim grey" :background "spring green"))) "")
(defface my-cyan '((t (:foreground "dim grey" :background "cyan"))) "")
(defface my-blue '((t (:foreground "white" :background "blue"))) "")
(defface my-dmagenta '((t (:foreground "white" :background "dark magenta"))) "")
(defface my-space-pink '((t (:foreground "floral white" :background "#cb619e"))) "")
(defface my-space-blue '((t (:foreground "floral white" :background "#6272a4"))) "")
;; (defface my-space-blue '((t (:foreground "white" :background "#282a36"))) "")
(defface my-space-gray '((t (:foreground "floral white" :background "#44475a"))) "")

(setq telephone-line-faces
      '((red . (my-red . my-red))
        (ored . (my-orangered . my-orangered))
        (orange . (my-orange . my-orange))
        (gold . (my-gold . my-gold))
        (yellow . (my-yellow . my-yellow))
        (chartreuse . (my-chartreuse . my-chartreuse))
        (green . (my-green . my-green))
        (sgreen . (my-sgreen . my-sgreen))
        (cyan . (my-cyan . my-cyan))
        (blue . (my-blue . my-blue))
        (dmagenta . (my-dmagenta . my-dmagenta))
        (space-pink . (my-space-pink . my-space-pink))
        (space-blue . (my-space-blue . my-space-blue))
        (comment . (font-lock-comment-face . my-dmagenta))
        (accent . (telephone-line-accent-active . telephone-line-accent-inactive))
        (nil . (mode-line . mode-line-inactive))))

;; (straight-use-package 'fancy-battery)
;; (fancy-battery-mode)


;; (telephone-line-defsegment* telephone-line-fancy-battery ()
  ;; (:propertize ("%s" fancy-battery-last-status)
					;; (:propertize ("%s" battery-status-function)
					
					 ;; (let* ((time (cdr (assq ?t fancy-battery-last-status)))
           ;; (face (pcase (cdr (assq ?b fancy-battery-last-status))
                   ;; ("!" 'fancy-battery-critical)
                   ;; ("+" 'fancy-battery-charging)
                   ;; (_ 'fancy-battery-discharging)))
           ;; (percentage (cdr (assq ?p fancy-battery-last-status)))
           ;; (status (if (or fancy-battery-show-percentage (string= time "N/A"))
                       ;; (and percentage (concat percentage "%%"))
                     ;; time)))
      ;; (if status
          ;; (propertize status 'face face)
        ;; Battery status is not available
        ;; (propertize "N/A" 'face 'error)))
					 ;; ))

(display-battery-mode)
;; (straight-use-package 'spinner)
;; (spinner-start 'moon)
;; (spinner-start 'minibox)

(telephone-line-defsegment* telephone-line-ryo-modal-segment-pony ()
  (let ((tag (if (bound-and-true-p ryo-modal-mode)
                 "NORMAL" "INSERT")))
    (if telephone-line-evil-use-short-tag
        (seq-take tag 1)
      tag)))

(setq telephone-line-lhs
      '((space-pink . (telephone-line-vc-segment))
        (space-blue . ())
		  (accent . (telephone-line-projectile-segment
						 telephone-line-erc-modified-channels-segment
                   telephone-line-process-segment))
		  (space-blue . (telephone-line-flycheck-segment))
		  (space-pink . (telephone-line-ryo-modal-segment-pony))
        ;; (space-gray    . (
												  ;; telephone-line-minor-mode-segment
								  ;; telephone-line-buffer-segment))
		  (nil . ())
		  ))

(setq telephone-line-rhs
      '(
		  (nil . ())
		  (space-blue . (telephone-line-misc-info-segment
							  telephone-line-filesize-segment))
		  ;; (accent . (telephone-line-fancy-battery))
		  (space-pink . ())
        (space-blue . (telephone-line-major-mode-segment))))

;; (setq telephone-line-filesize-segment nil)
(telephone-line-mode t)

(straight-use-package 'all-the-icons-dired)
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)

;; TABS
(use-package centaur-tabs
  :straight t
  :demand
  :config
  (centaur-tabs-mode t)
  :hook
  (dired-mode . centaur-tabs-local-mode)
)
(setq centaur-tabs-style "chamfer")
(setq centaur-tabs-set-icons t)
(setq centaur-tabs-plain-icons t)
(setq centaur-tabs-gray-out-icons 'buffer)
(setq centaur-tabs-set-bar 'under)
(setq x-underline-at-descent-line t)
(setq centaur-tabs-set-close-button nil)
;; (setq centaur-tabs-set-modified-marker t)
;; (setq centaur-tabs-modified-marker "*")
(setq centaur-tabs-height 9)
(setq centaur-tabs-icon-scale-factor 0.6)
(setq centaur-tabs-icon-v-adjust -0.05)
(centaur-tabs-change-fonts "Fira Code" 80)

;; AESTHETICS

;; Dracula
(add-to-list 'custom-theme-load-path (expand-file-name "./dracula-pro-theme/" user-emacs-directory))
;; (load-theme 'dracula-pro t)
(use-package dracula-pro-theme
  :straight nil
  :defer 3
  :load-path "~/wgooch/.emacs.d/dracula-pro-theme"
  ;; :init
  ;; (load-theme 'dracula-pro t)
  )

;; Pink Cat Boo
(add-to-list 'custom-theme-load-path (expand-file-name "./pink-cat-boo-buffy/" user-emacs-directory))
;; (load-theme 'pink-cat-boo-buffy t)
(use-package pink-cat-boo-buffy-theme
  :straight nil
  :defer 3
  :load-path "~/wgooch/.emacs.d/pink-cat-boo-buffy"
  :init
  (load-theme 'pink-cat-boo-buffy t)
  )

(setq custom-safe-themes t)

;; (straight-use-package 'highlight-thing)
;; (global-highlight-thing-mode)
;; (setq highlight-thing-case-sensitive-p nil)
;; (setq highlight-thing-all-visible-buffers-p t)
;; (setq highlight-thing-ignore-list '("False" "True" "t" "nil"))

(straight-use-package 'compact-docstrings)
(setq compact-docstrings-only-doc-blocks nil)
(add-hook 'after-init-hook #'global-compact-docstrings--mode)

(use-package whitespace
  :straight
  :config
  ;; Make whitespace-mode with very basic background coloring for whitespaces.
  ;; http://ergoemacs.org/emacs/whitespace-mode.html
  (setq
   whitespace-style '(face spaces space-mark
									tabs tab-mark
									newline newline-mark
									trailing
									)
   ;; Make whitespace-mode and whitespace-newline-mode use “↵" for end of line char and “⇥" for tab.
   whitespace-display-mappings
    '((space-mark 32 [183] [46]) ; SPACE 32 「 」, 183 MIDDLE DOT 「·」, 46 FULL STOP 「.」
      (newline-mark 10 [?↵ 10])
      (tab-mark ?\t [?⇥ ?\t])))
  ;; :hook
  ;; (prog-mode . whitespace-mode)
  )
(add-hook 'prog-mode-hook 'whitespace-mode)
;; (add-hook 'emacs-lisp-mode-hook 'whitespace-mode)

(use-package show-eol
  :straight t
  ;; :custom
  )
;; (global-show-eol-mode t)
(add-hook 'whitespace-mode-hook 'show-eol-mode)

;; nil does not work.
(menu-bar-mode -1)
(tool-bar-mode -1)
(toggle-scroll-bar -1)

(defun graphic-p ()
  (display-graphic-p))
(when (graphic-p)
  ;;  transparent frame
  (add-to-list 'default-frame-alist'(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist'(alpha . (95 . 89))))

;; Font
(add-hook 'prog-mode 'font-lock-mode)
(set-face-attribute 'default nil
						  :family "Fira Code"
						  :weight 'SemiBold
						  :height 90)

(set-face-attribute 'font-lock-comment-face nil
						  :family "Liga OperatorMono Nerd Font"
						  :weight 'Light
						  :height 90
						  :slant 'italic)

(set-face-attribute 'font-lock-keyword-face nil
						  :family "Fira Code"
						  :weight 'Bold)

(set-face-attribute 'variable-pitch nil
						  :family "Input Serif Compressed"
						  :weight 'Medium
						  :height 100)

(set-face-attribute 'fixed-pitch nil
						  :family "Fira Code"
						  :weight 'SemiBold
						  :height 90)

;; Change font size by monitor.
(defun fontify-frame ()
  (interactive)
  ;; (if window-system
  (progn
	 ;; (if (eq (x-display-pixel-width) 1920)
    (if (equal 'x-display-pixel-width 1920)
		  ;; (if (eq x-display-name "172.22.192.1:0.0")
		  ;; (if (eq (display-monitor-attributes-list . )
		  (progn
			 ;; Laptop
          (set-frame-parameter (selected-frame) 'font "Fira Code 10")
			 (message "On Laptop")
			 )
		(progn
		  (if (eq (x-display-pixel-width) 1050)
				(progn
				  ;; Monitor
				  (set-frame-parameter (selected-frame) 'font "Fira Code 8")
				  (message "On Monitor")
				  )
			 (progn
				(message "Failed")))))))

;; Fontify current frame
;; (fontify-frame nil)

;; Fontify any future frames
;; (push 'fontify-frame after-make-frame-functions)
;; (add-hook 'window-size-change-functions #'fontify-frame)

													 ; |-----  -|- ----|
													 ; |--------|-----|
													 ; |-|-

;; The quick brown fox jumped over the lazy dog
;; The quick brown fox jumped over the lazy dog.
;; The quick brown fox jumped over the lazy dog.

(use-package ligature
:straight (:host github :repo "mickeynp/ligature.el"
						 :branch "master")
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures 'prog-mode '(
													"|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>"
                                       ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!=="
                                       "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<"
                                       "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
                                       "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<"
                                       "..." "+++" "/==" "///" "_|_" "&&" "^=" "~~" "~@" "~=" "/*"
                                       "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|>" "{|" "|-" "-|" ;; "-|-"
                                       "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
                                       ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:"
"<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!"
                                       "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:"
                                       "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)"
                                       "\\\\" "://" "||-"
													))
  (ligature-set-ligatures 'text-mode '("|-" "-|-" "-|" "---"))
  )

(add-to-list 'ligature-composition-table '(text-mode ("=" . ,(rx (+ "=")))))
(add-to-list 'ligature-composition-table '(prog-mode ("=" . ,(rx (+ "=")))))

;; This takes too long to set up. Not needed yet.
;; (straight-use-package 'unicode-fonts)
;; (unicode-fonts-setup)

(use-package rainbow-delimiters
  :straight t
  ;; :init
   )

;; Highlight current line
;; (use-package hl-line+
;; :load-path "./random-libs"
;; :init
;; (setq hl-line-overlay-priority 100)
;; (set-face-attribute hl-line-face nil :box t)
;; (set-face-foreground 'hl-line "#9580FF")
;; (set-face-underline-p 'highlight t)
;; (toggle-hl-line-when-idle t)
;; (hl-line-when-idle-interval 10)
;; )
(add-hook 'text-mode-hook 'hl-line-mode)
(add-hook 'dired-mode-hook 'hl-line-mode)

;; Line Numbers
(use-package linum-relative
  :straight t
  :init
  ;; This backend is faster, but its faces do not work.
  (setq linum-relative-backend 'display-line-numbers-mode)
  (setq linum-relative-current-symbol "")
  (linum-relative-global-mode nil))

;; (use-package yascroll
;;   :straight t)

;; (setq yascroll:delay-to-hide 9.0)
;; (global-yascroll-bar-mode t)
;; (setq scroll-preserve-screen-position t)

;; (use-package sublimity
;;   :straight t
;;   :init
;;   (sublimity-mode t)
;;   )
;; (require 'sublimity-scroll)
;; (setq sublimity-scroll-weight 2
;; 		sublimity-scroll-drift-length 2
;; 		)

(setq x-stretch-cursor t)
(setq cursor-in-non-selected-windows nil)

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cursor ((t nil)))
 '(custom-comment ((t (:background "dim gray" :family "Operator Mono Lig Medium"))))
 '(hydra-face-red ((t (:foreground "violet")))))


;; DIRED
(add-hook 'dired-mode-hook 'all-the-icons-dired-mode)
(add-hook 'dired-mode-hook 'ryo-enable)
(straight-use-package 'posframe)

;; Load posframe locally.
(native-compile-async "~/.emacs.d/dired-posframe.el/" 'recursively)
(add-to-list 'load-path "~/.emacs.d/dired-posframe.el/")
(load "dired-posframe")

(straight-use-package 'ranger)
(add-hook 'ranger-mode-hook 'wdired-change-to-wdired-mode)

(setq ranger-modify-header nil)
(setq ranger-footer-delay 0.2)
(setq ranger-preview-delay 0.040)

(setq ranger-width-parents 0.12)
(setq ranger-max-parent-width 0.5)
(setq ranger-width-preview 0.25)
(setq ranger-dont-show-binary t)
(setq ranger-parent-depth 3)

;; I've submitted a pull request adding this. If it's accepted, I'll uncomment.
;; (use-package dired-posframe
;; :straight t
;; :config
;; (add-to-list 'dired-posframe-advice-alist
;; '(
;; (dired-next-dirline . dired-posframe--advice-show)
;; (dired-prev-dirline . dired-posframe--advice-show)
;; (dired-omit-mode . dired-posframe--advice-show)
;; )
;; )
;; )

(straight-use-package 'dired-git)
(add-hook 'dired-mode-hook 'dired-git-mode)
;; (setq initial-buffer-choice "~/.emacs.d/")
;; (add-hook 'after-init-hook 'dired-jump)

;; TODO: Replace this with RYO bindings.
(define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)

(setq-default dired-omit-files-p t)
(setq dired-omit-verbose nil)

;; Custom utility scripts.
;; There exist states, such as after kill-region, when the cursor color is incorrect.
(defun ryo-cursor-update ()
  (if ryo-modal-mode
		(progn
		  (setq cursor-type (cons 'box 2))
		  (message "NORMAL MODE")

		  (if (region-active-p)
				(keyboard-quit)))
	 (progn
		(setq cursor-type (cons 'bar 2))
		(message "INSERT MODE"))))

(defun pony-toggle-mark ()
  "Toggle whether a region is being selected."
  (interactive)
  (if (region-active-p)
		(progn
		  (setq cursor-type 'box)
		  (keyboard-quit)
		  (message "Cancel Selection")   ; This is not working.
		  )
	 (progn
		(set-mark (point))
		(setq cursor-type 'hbox)
		(message "Selecting"))))

(defun dired-posframe-toggle ()
  "Toggle the posframe."
  (interactive)
  (if (bound-and-true-p dired-posframe-mode)
		(progn
		  (setq dired-posframe-mode nil)
		  (dired-posframe-teardown)
		  (message "Posframe Disabled"))
	 (progn
		(setq dired-posframe-mode t)
		(dired-posframe-setup)
		(dired-posframe-show)
		(message "Posframe Enabled"))))

(defun dired-alternate-up ()
  "Navigate up one directory."
  (interactive)
  (find-alternate-file ".."))

(defun eval-dwim ()
  "Evaluate a selected region or current buffer."
  (interactive)
  (if (region-active-p)
		(eval-region (region-beginning) (region-end))
	 (eval-buffer)))

;; https://www.emacswiki.org/emacs/HalfScrolling
(defun zz-scroll-half-page (direction)
  "Scrolls half page up if `DIRECTION' is non-nil, otherwise will scroll half page down."
  (let ((opos (cdr (nth 6 (posn-at-point)))))
    ;; opos = original position line relative to window
    (move-to-window-line nil)  ;; Move cursor to middle line
    (if direction
        (recenter-top-bottom -1)  ;; Current line becomes last
      (recenter-top-bottom 0))  ;; Current line becomes first
    (move-to-window-line opos)))  ;; Restore cursor/point position

(defun zz-scroll-half-page-down ()
  "Scrolls exactly half page down keeping cursor/point position."
  (interactive)
  (zz-scroll-half-page nil))

(defun zz-scroll-half-page-up ()
  "Scrolls exactly half page up keeping cursor/point position."
  (interactive)
  (zz-scroll-half-page t))


;; Avy
(use-package avy
  :straight t
  :init
  (setq
   avy-keys
   '(
     ?t ?u ?n ?e ?s ?a ?r ?i  ;; 'power eight': can type them without any movement of the hand.
     ?h ?o ?k ?c ?g ?j ?p ?y ;; close to home rows; no pinkes.
     ?d ?f ?l ?q ?b ?\, ;; Bottom row.
	  )))


;; Word Rotation
(use-package grugru
  :straight t
  :init
  (grugru-default-setup)
  (setq grugru-highlight-idle-delay 0.15))
(add-hook 'prog-mode-hook #'grugru-highlight-mode)

;; Spell Checking

;; (use-package wucuo
;;   :straight t
;;   :config
;;   (setq wucuo-flyspell-start-mode "fast")
;;   (setq wucuo-spell-check-buffer-predicate
;;         (lambda ()
;; 			 (not (memq major-mode
;; 							'(dired-mode
;;                        log-edit-mode
;;                        compilation-mode
;;                        help-mode
;;                        profiler-report-mode
;;                        speedbar-mode
;;                        gud-mode
;;                        calc-mode
;;                        Info-mode))))
;; 		  )
;;   )

(use-package flyspell-correct
  :straight t
  ;; :bind (:map flyspell-mode-map ("M-c" . flyspell-correct-wrapper))
  )

(use-package flyspell-correct-popup
  :straight t
  :defer t
  ;; :after flyspell-correct
  )

(use-package flyspell-correct-avy-menu
  :straight t
  :after flyspell-correct)
;; (defun flyspell-correct-popup-inline-actions (candidates word)

;; (add-hook 'prog-mode-hook #'wucuo-start)
;; (add-hook 'text-mode-hook #'wucuo-start)
;; (setq ispell-program-name "enchant-2")
;; (setq ispell-extra-args '("-a"))
(setq ispell-program-name "aspell")
(setq ispell-extra-args '("--sug-mode=ultra" "--lang=en_US" "--run-together" "--run-together-limit=16"))
;; (setq ispell-extra-args "--run-together")
;; emacs -batch -Q -l ~/projs/wucuo/wucuo.el --eval '(let* ((ispell-program-name "aspell") (ispell-extra-args (wucuo-aspell-cli-args t))) (wucuo-spell-check-directory "."))'

(straight-use-package 'flyspell-lazy)
(add-hook 'flyspell-mode-hook 'flyspell-lazy-mode)
(add-to-list 'ispell-extra-args "--sug-mode=ultra")

;; TODO: Configure this for Org or comments or something.
;; https://laclefyoshi.hatenablog.com/entry/20150912/langtool_popup
;; (use-package langtool
;;   :straight t
;;   :config
;;   (setq langtool-default-language "en-US")
;;   )


;; ORG
(use-package org
  :straight t
  :config
  (setq-default
	org-src-fontify-natively t
	org-hide-emphasis-markers t
	org-pretty-entities t
	org-pretty-entities-include-sub-superscripts t)
  (add-to-list 'auto-mode-alist '("\\.org$" . org-mode)))

(use-package org-bullets
  :straight t
  :init
  ;; (setq org-bullets-face-name "Inconsolata-12")
  (setq org-bullets-bullet-list
        '("◎" "⚫" "○" "►" "◇"))
  :config
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode t))))

(add-hook 'org-mode-hook 'variable-pitch-mode)

;; Org Babel
;; (org-babel-do-load-languages
;; 'org-babel-load-languages
;; '((mysql . t))
;; )

;; (set-face-attribute 'org-code nil :inherit 'fixed-pitch)
;; (set-face-attribute 'org-table nil :inherit 'fixed-pitch)
(defun my-adjoin-to-list-or-symbol (element list-or-symbol)
  (let ((list (if (not (listp list-or-symbol))
                  (list list-or-symbol)
                list-or-symbol)))
    (require 'cl-lib)
    (cl-adjoin element list)))

(eval-after-load "org"
  '(mapc
    (lambda (face)
      (set-face-attribute
       face nil
       :inherit
       (my-adjoin-to-list-or-symbol
        'fixed-pitch
        (face-attribute face :inherit))))
    (list 'org-code 'org-block 'org-table)))

;; Make Bibtex export in PDF
(setq org-latex-pdf-process
		'("latexmk -pdflatex='pdflatex -interaction nonstopmode' -pdf -bibtex -f %f"))

(setq org-todo-keyword-faces
      '(
		  ("NOTE" . (:foreground "lightgreen" :weight bold))
		  ("LOW" . (:foreground "#cb4b16" :background "snow" :weight bold :box (:line-width -1)))
        ("MED" . (:foreground "goldenrod" :background "cornsilk" :weight bold :box (:line-width -1)))
        ("HIGH" . (:foreground "darkgreen" :background "honeydew" :weight bold :box (:line-width -1)))
		  ("TODO" . (:foreground "black" :background "snow" :weight bold :box (:line-width -1)))
        ("DONE" . org-done)
        ("WONTFIX" . org-done)))

(executable-find "sqlite3")
(use-package org-roam
  :straight t
  :hook
  (after-init . org-roam-mode)
  :custom
  (org-roam-directory "/path/to/org-files/")
  :bind (:map org-roam-mode-map
              (("C-c n l" . org-roam)
               ("C-c n f" . org-roam-find-file)
               ("C-c n g" . org-roam-graph))
              :map org-mode-map
              (("C-c n i" . org-roam-insert))
              (("C-c n I" . org-roam-insert-immediate))))

(use-package company-org-roam
  ;; :when (featurep! :completion company)
  :straight t
  :after org-roam
  :config
  ;; (set-company-backend! 'org-mode '(company-org-roam company-yasnippet company-dabbrev))
  )
(add-to-list 'company-backends '(company-org-roam))

;; (use-package org-journal
;;   :straight t
;;   :config
;;   (setq org-journal-enable-agenda-integration t)
;;   :custom
;;   (org-journal-dir "~/Desktop/03-resources/org-roam/")
;;   (org-journal-date-prefix "#+TITLE: ")
;;   (org-journal-file-format "%Y-%m-%d.org")
;;   (org-journal-date-format "%A, %d %B %Y")
;;   )

;; WHICH KEY
(use-package which-key
  :straight t
  :custom
  (which-key-setup-side-window-bottom)
  (which-key-enable-extended-define-key t))

(push '((nil . "ryo:.*:") . (nil . "")) which-key-replacement-alist)
(setq which-key-idle-delay 0.1)
(setq which-key-prefix-prefix "")
(setq which-key-show-prefix 'bottom)
(setq which-key-show-transient-maps t)
(which-key-mode)

;; Buffer management
;; (straight-use-package 'persp-mode)
(straight-use-package 'ace-window)
(straight-use-package 'buffer-move)

;; GIT
(straight-use-package 'magit)

(straight-use-package 'vc-msg)
(eval-after-load 'vc-msg-git
  '(progn
     ;; show code of commit
     (setq vc-msg-git-show-commit-function 'magit-show-commit)
     ;; open file of certain revision
     (push '("m"
             "[m]agit-find-file"
             (lambda ()
               (let* ((info vc-msg-previous-commit-info)
                      (git-dir (locate-dominating-file default-directory ".git")))
                 (magit-find-file (plist-get info :id )
                                  (concat git-dir (plist-get info :filename))))))
           vc-msg-git-extra))
  )
(add-hook 'after-save-hook 'magit-after-save-refresh-status)

(use-package git-gutter
  :straight t
  )
(add-hook 'prog-mode-hook 'git-gutter-mode)
(add-hook 'org-mode-hook 'git-gutter-mode)

(set-face-foreground 'git-gutter:added "orange")


;; Snippets
(use-package yasnippet
  :straight t
  :init
  ;; (define-key yas-minor-mode-map "TAB" nil)
  ;; (define-key yas-minor-mode-map "C-RET" 'yas-next-field-or-maybe-expand)
  )

(setq company-lsp-enable-snippet nil)
(advice-add 'company-tng--supress-post-completion :override #'ignore)

(define-key yas-minor-mode-map "\M-t" 'yas-expand)
(define-key yas-keymap "\M-t" 'yas-next-field-or-maybe-expand)

(dolist (keymap (list yas-minor-mode-map yas-keymap))
  (define-key keymap (kbd "TAB") nil)
  (define-key keymap [(tab)] nil)
  )

(yas-global-mode t)
(straight-use-package 'yasnippet-snippets)

(delete-selection-mode t)

;; Manage parens
(straight-use-package 'tab-jump-out)
;; (add-hook 'prog-mode-hook 'tab-jump-out-mode)
(define-globalized-minor-mode global-tab-jump-out-mode
  tab-jump-out-mode tab-jump-out-mode )
(global-tab-jump-out-mode t)
;; (add-hook 'text-mode-hook 'tab-jump-out-mode)

;; (electric-pair-mode t)
;; (show-paren-mode t)
;; (setq show-paren-style 'expression)
(add-hook 'prog-mode-hook 'turn-on-smartparens-mode)
(add-hook 'markdown-mode-hook 'turn-on-smartparens-mode)
(straight-use-package 'comment-or-uncomment-sexp)

(use-package embrace
  :straight t
  :init
  )
(add-hook 'prog-mode-hook
			 (lambda ()
			   (embrace-add-pair ?e "(" ")")
				(embrace-add-pair ?a "{" "}")
				(embrace-add-pair ?i "[" "]")
				(embrace-add-pair ?o  "\"" "\"")
				(embrace-add-pair ?c  "\'" "\'")
				(embrace-add-pair ?_  "<" ">")))
(add-hook 'org-mode-hook #'embrace-org-mode-hook)
(setq embrace-show-help-p t)

;; Pony FLY KEYS
(native-compile-async "~/.emacs.d/Pony-Fly-Keys/" 'recursively)
(add-to-list 'load-path "~/.emacs.d/Pony-Fly-Keys/")
(load "pony-fly-keys")

;; Toggle mark state.
(straight-use-package 'selected)
(selected-global-mode t)

;; This seems redundant.
(add-hook 'ryo-modal-mode-hook 'ryo-cursor-update)

;; I'm using some of Xah's utilities rn.
;; (straight-use-package 'xah-fly-keys)
(use-package xah-fly-keys
  :straight t)

;; Hydra
(straight-use-package 'hydra)

;; Case Changing
(straight-use-package 'string-inflection)

;; Multi Cursors
(straight-use-package 'multiple-cursors)
(straight-use-package 'mc-calc)

;; Bookmarks
(setq bm-restore-repository-on-load t)
(use-package bm
  :straight t
  :demand t
  :init
  (autoload 'bm-toggle   "bm" "Toggle bookmark in current buffer." t)
  (autoload 'bm-next     "bm" "Goto bookmark."                     t)
  (autoload 'bm-previous "bm" "Goto previous bookmark."            t)
  :config
  ;; Save bookmarks
  (setq bm-repository-file "~/.emacs.d/bm-repository")
  (setq bm-buffer-persistence t)
  ;; Optional labels
  (setq bm-annotate-on-create t)
  (add-hook 'find-file-hooks 'bm-buffer-restore)
  (add-hook 'kill-buffer-hook #'bm-buffer-save)
  (add-hook 'kill-emacs-hook #'(lambda nil
											(bm-buffer-save-all)
											(bm-repository-save)))
  (add-hook 'after-save-hook #'bm-buffer-save)
  (add-hook 'after-revert-hook #'bm-buffer-restore)
  (add-hook 'vc-before-checkin-hook #'bm-buffer-save)
  ;; Aesthetics
  ;; Currently, fringe-bitmap 'bm-marker is non-configable.
  (setq bm-marker 'bm-marker-left
        bm-recenter t
        bm-highlight-style 'bm-highlight-only-fringe)
  ;; These are not working.
  (add-hook 'bm-show-mode-hook 'ryo-enable)
  (add-hook 'bm-show-mode-hook 'hl-line-mode))
(add-hook 'bookmark-bmenu-mode-hook 'ryo-enable)

;; Expand Region
(use-package expand-region
  :straight t)

;; MODAL EDITING
(setq-default cursor-type (cons 'bar 2))
(defun ryo-enable ()
  (interactive)
  (unless ryo-modal-mode
	 (ryo-modal-mode))
  (ryo-cursor-update)
  (selected-off))

(add-hook 'prog-mode-hook 'ryo-enable)

;; Keybindings.
;; TODO: This does not work:
(global-unset-key "\C-n")
(global-set-key "\C-n" 'keyboard-quit)
;; (global-unset-key "<f13>")
;; (global-set-key (kbd "<f13>") 'ryo-enable)
;; (global-set-key  [f13] 'ryo-enable)

(use-package ryo-modal
  :straight t
  :commands ryo-modal-mode
  :bind
  ;; ("M-SPC" . ryo-enable)
  ;; ("C-SPC" . ryo-enable)
  ;; ("S-SPC" . ryo-enable)
  ("C-S-M-SPC" . ryo-enable)
  ;; ("<f23>"   . ryo-enable)
  ;; :init
  ;; (global-set-key [escape] 'ryo-enable)
  :config
  (setq ryo-modal-cursor-type t)
  (setq ryo-modal-cursor-color nil)

  (ryo-modal-keys
   (:exit t)
   ("t" ryo-modal-mode :name "Insert Mode"))

  (ryo-modal-keys
	("r" execute-extended-command)
	;; Basic navigation controls.
   ("e" next-logical-line)
   ("E" next-line)
	;; ("C-t" selectrum-next-candidate)
	("o" previous-logical-line)
   ("O" previous-line)
	;; ("C-c" selectrum-previous-candidate)
	("y" backward-char)
   ("i" forward-char)
   ("u" pony-move-left-word)
	("U" syntax-subword-left)
	("a" pony-move-right-word)
	("A" syntax-subword-right)
	("c" xah-beginning-of-line-or-block)
	("j" xah-end-of-line-or-block)
	("C" pony-binary-beginning-of-line)
	("J" pony-binary-end-of-line)
	("f" sp-backward-up-sexp)
	("," sp-up-sexp)
	;; TODO:
	;; https://github.com/palikar/vsexp

	;; Basic deletion commands.
	("n" hungry-delete-backward)
	("=" delete-char)
	("h" pony-delete-left-word)
	("H" subword-backward-kill)
	("k" pony-delete-right-word)
	("K" subword-kill)

	;; Commenting
	("x" comment-line)

	;; Selection
	("|" pony-mark-line)
	("(" mark-word)
	("{" xah-select-block)
	("[" rectangle-mark-mode)
	(")" mark-sexp)
	("+" mark-whole-buffer :name "Select All")
	("=" er/expand-region)
	("-" er/contract-region)
	
	;; Multi-cursor
	("M-o" mc/mark-previous-like-this)
	("M-e" mc/mark-next-like-this)

	;; Bookmarks
	;; ("p" (
	;; TODO: Configure bookmarks.
	;; ("e" bm-next :name "Bookmark Down")
	;; ("u" bm-toggle :name "Bookmark Toggle")
	;; ("h" bm-show :name "Bookmark Jump")
	;; ("N" bm-remove-all-current-buffer "Remove All")
	;; )
	;; )
	)

  (ryo-modal-keys
   ;; First argument to ryo-modal-keys may be a list of keywords.
   ;; These keywords will be applied to all keybindings.
   (:norepeat t)
   ("0" "M-0")
   ("1" "M-1")
   ("2" "M-2")
   ("3" "M-3")
   ("4" "M-4")
   ("5" "M-5")
   ("6" "M-6")
   ("7" "M-7")
   ("8" "M-8")
   ("9" "M-9"))
  
  (ryo-modal-keys
	(:norepeat t)
	;; Clipboard operations.
	("b" kill-region)
	("l" pony-copy-current-word)
	("d" yank-from-kill-ring)
	("v" pony-toggle-mark)

	;; Basic operations.
	("m" undo)
	("M" undo-redo)
	("w" ctrlf-forward-fuzzy)
	("W" ctrlf-forward-literal)
	("g" xah-shrink-whitespaces)
	("_" grugru))

  (ryo-modal-keys
	;; Buffer management hydra
	;; ("SPC" (
	;; ("SPC g" :hydra
	("q" :hydra
	 ;; ("SPC g" :hydra
	 '(hydra-buffer (:color red)
						 "Buffer Hydra"
						 ("e" split-window-below "Split Vertically")
						 ("a" split-window-right "Split Rightward")
						 ("M-e" buf-move-down "Swap Down")
						 ("M-o" buf-move-up "Swap Up")
						 ("M-a" buf-move-right "Swap Right")
						 ("M-u" buf-move-left "Swap Left")
						 ("E" windmove-down "Focus Down")
						 ("O" windmove-up "Focus Up")
						 ("U" windmove-left "Focus Left")
						 ("A" windmove-right "Focus Right")
						 ("n" delete-window "Kill")
						 ("=" ace-delete-window "Kill Other")
						 ("q" ace-delete-other-windows "Kill All Except")
						 ("k" switch-to-buffer "Switch")

						 ;; Resizing
						 ("H" enlarge-window :name "Grow Vert")
						 ("N" shrink-window :name "Shrink Vert")
						 ("T" enlarge-window-horizontally :name "Grow Hor")
						 ("S" shrink-window-horizontally :name "Shrink Hor")
						 ("g" balance-windows)
						 ;; TODO: Configure IBuffer commands.
						 ("h" ibuffer "IBuffer")
						 ("<tab>" nil "Cancel" :color blue)))

	;; Multi-cursor bindings
	;; TODO: This would be better as
	;; "2" when a selection exists.
	;; ("2" (
	;; 		("e" mc/edit-lines)
	;; 		("d" mc/edit-beginnings-of-lines)
	;; 		("s" mc/edit-ends-of-lines)
	;; 		("+" mc/mark-all-in-region)
	;; 		(")" mc/mark-all-dwim)))
	)

  (ryo-modal-keys
	;; Leader key
	("SPC" (;; ("r" format-all-buffer :name "Format")
			  ("w" exchange-point-and-mark :name "Reverse Selection")
			  ;; TODO: https://github.com/Fuco1/smartparens/wiki/Hybrid-S-expressions
			  ("h" crux-kill-line-backwards)
			  ("K" sp-kill-hybrid-sexp)
			  ("k" crux-smart-kill-line)
			  ("s" crux-duplicate-current-line-or-region :name "Duplicate")
			  ("f" sp-slurp-hybrid-sexp :name "Slurp")
			  ("," sp-dedent-adjust-sexp :name "Barf")
			  ("<" sp-push-hybrid-sexp :name "Push Sexp")
			  ("F" sp-transpose-hybrid-sexp :name "Transpose Sexp")
			  ("_" origami-toggle-node)

			  ;; Inserts
			  ("n" (
					  ;; TODO: Consider company-yasnippet
					  ("r" yas-insert-snippet :name "Snippet")
					  ("n" embrace-delete :name "Remove")
					  ("t" embrace-change :name "Change")
					  ("u" xah-insert-brace :name "{}")
					  ("e" xah-insert-paren :name "()")
					  ("a" xah-insert-square-bracket :name "[]")
					  ("o" xah-insert-ascii-double-quote :name "\"\"")
					  ("c" xah-insert-ascii-double-quote :name "\'\'")
					  ("j" pony-insert-region-pair :name "Region")
					  ("_" pony-insert-angle-pair :name "<>")
					  ("i" (
							  ("e" mc/insert-numbers)
							  ("u" mc/insert-letters)
							  ("j" mc/sort-regions)
							  ("a" mc/reverse-regions))
						:name "Multi-Cursor"))
				:name "Insert")

			  ;; File Management
			  ("o" (
                 ("i" save-buffer :name "Save Buffer")
                 ("s" write-file :name "Save As")
                 ("g" dired :name "Dired Path")
					  ("h" dired-jump :name "Dired")
					  ;; ("h" ranger :name "Dired")
                 ("r" magit-status :name "Git")
					  ("x" xah-show-in-desktop :name "Explorer")
					  ("o" recentf-open-files :name "Open Recent")
					  ("a" xah-new-empty-buffer :name "New File")
					  ("m" xah-open-last-closed :name "Open Last Closed")
					  ("v" crux-find-user-init-file :name "Init")
					  ("u" eval-dwim :name "Evaluate")
					  )
            :name "File")

			  ;; Frames
			  ("j" (
					  ("a" view-buffer-other-frame :name "New Frame")
					  ("s" make-frame :name "Duplicate Frame")
					  ("h" other-frame :name "Other Frame")))

			  ;; Large Motions
           ("e" (
                 ("a" scroll-up :name "Page Down")
                 ("A" zz-scroll-half-page-down :name "Half-Page Down")
                 ;; g can be used for scroll without moving cursor
                 ("u" scroll-down :name "Page Up")
                 ("U" zz-scroll-half-page-up :name "Half-Page Down")
                 ;; r can be used for scroll without moving cursor
                 ("n" recenter-top-bottom :name "Recenter Point")
                 ("t" move-to-window-line-top-bottom :name "Point at Center")
					  ("p" move-to-window-line-top-bottom)
					  ("f" kill-this-buffer :name "Kill This Buffer")
					  ("h" avy-goto-line :name "Line Jump")
                 ("k" avy-goto-word-1 :name "Word Jump")
					  ("y" beginning-of-buffer "Buffer Start")
					  ("i" end-of-buffer "Buffer End"))
            :name "Large Motion")

			  ;; Spellcheck
			  ("g" (
					  ("h" flyspell-correct-wrapper :name "Suggestions")
					  ("e" flyspell-correct-next :name "Next")
					  ("o" flyspell-correct-previous :name "Previous"))
				:name "Spell Checking")

			  ("u" (
					  ;; lower
					  ("n" string-inflection-underscore :name "snake_case")
					  ("t" string-inflection-lower-camelcase :name "camelCase")
					  ("r" string-inflection-kebab-case :name "kebab-case")
					  ("s" downcase-dwim :name "lowercase")
					  ("S" subword-downcase)
					  ;; UPPER
					  ("h" string-inflection-capital-underscore :name "CONSTANT_CASE")
					  ("k" string-inflection-camelcase :name "PascalCase")
					  ("z" string-inflection-kebab-case :name "kebab-case")
					  ("g" upcase-dwim :name "UPPERCASE")
					  ("G" subword-upcase)
					  )
				:name "Letter Case")

			  ;; Toggles
			  ;; ("_" (
					  ;; ("x" nocomments-mode))
				;; :name "Toggles")

			  ;; Comments
			  ("x" (
					  ("s" crux-duplicate-and-comment-current-line-or-region)
					  ("_" nocomments-mode)
					  ))
			  ) :name "LEADER"))

  (ryo-modal-keys
	;; Dired Mode
	(:norepeat t :mode 'dired-mode)
	("l" dired-do-copy)
	("h" dired-alternate-up)
	("m" dired-mark)
	("M" dired-unmark)
	("o" dired-previous-line)
	("e" dired-next-line)
	("a" dired-next-dirline)
	("u" dired-prev-dirline)
	("w" find-name-dired)
	("x" dired-omit-mode :name "Hide Details")
	("n" dired-do-delete)
	("SPC" (
			  ("p" dired-do-rename)
			  ("," dired-do-compress-to)
			  ("G" dired-do-compress)
			  ("m" dired-unmark-all-marks :name "Unmark All")
			  ("h" dired-posframe-toggle)
			  ("x" dired-mark-omitted :name "Omit")
			  ("o" (
					  ("a" find-file :name "Create File")
					  ("e" dired-create-directory :name "Create Directory"))
				)
			  ("e" (
					  ("u" dired-do-load :name "Load Elisp")
					  ("w" quit-window :name "Close Dired"))
					  ;; ("w" ranger-close :name "Close Dired"))
				)
			  ("w" (
					  ("h" dired-mark-extension)
					  ("w" dired-do-find-regexp))
				;; :name "Finding"
				))))

  (ryo-modal-keys
	;; Org Mode
	(:mode 'org-mode)
	("x" (
			("t" org-table-create))
	 :name "Table")

	("TAB" org-todo)
	("M-o" org-move-subtree-up)
	("M-e" org-move-subtree-down)

	("SPC" (("a" org-do-demote)
			  ("u" org-do-promote)
			  ("i" org-forward-heading-same-level)
			  ("y" org-backward-heading-same-level)
			  ("TAB" org-cycle)
			  ("t" (
					  ("a" org-insert-todo-subheading)
					  ("e" org-insert-todo-heading))
				:name "TODOs")
			  ;; TODO: This should be "n".
			  ("s" (
					  ("a" org-insert-subheading)
					  ("e" org-insert-heading)))
			  ("SPC" (
						 ("TAB" org-toggle-narrow-to-subtree)
						 ("t" org-next-visible-heading)
						 ("c" org-previous-visible-heading)
						 ("T" org-forward-heading-same-level)
						 ("C" org-backward-heading-same-level)
						 ("h" outline-up-heading)
						 ("n" org-goto)
						 )
				:name "Headings")))))

;; (eval-after-load "filladapt"
(diminish 'company)
(diminish 'org)
(diminish 'org-roam)
(diminish 'ryo-modal)
(diminish 'projectile)
(diminish 'yasnippet)
(diminish 'gitgutter)
;; )

;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(c++-mode-hook
;;    '((lambda nil
;;        (smart-tabs-mode-enable)
;;        (smart-tabs-advice c-indent-line c-basic-offset)
;;        (smart-tabs-advice c-indent-region c-basic-offset))
;;      maybe-cmake-project-mode highlight-indent-guides-mode))
;;  '(custom-safe-themes
;;    '("89ba918121c69681960ac1e4397296b5a756b1293325cee0cb543d70418bd556" "bcb58b7e1a372e677f44e25e3da88f283090dbd506550c137d02907446c7d11c" "7451f243a18b4b37cabfec57facc01bd1fe28b00e101e488c61e1eed913d9db9" default))
;;  '(git-gutter:added-sign "|")
;;  '(git-gutter:deleted-sign " ")
;;  '(git-gutter:modified-sign " ")
;;  '(git-gutter:update-interval 2)
;;  '(git-gutter:window-width 1)
;;  '(line-number-mode nil)
;;  '(warning-suppress-types '((comp) (comp) (comp) (comp) (comp) (comp))))
(add-hook 'prog-mode-hook 'rainbow-delimiters-mode)
;; (add-hook 'emacs-lisp-mode-hook 'rainbow-delimiters-mode)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
 
(add-hook 'prog-mode-hook 'lsp)
(add-hook 'prog-mode-hook 'hl-line-mode)
(add-hook 'prog-mode-hook 'tree-sitter-mode)

;; (add-hook 'c-mode-common-hook
          ;; 'smart-tabs-mode)
(add-hook 'c-mode-common-hook
			 (lambda () (
							 (smart-tabs-mode)
							 (tree-sitter-hl-mode)
							 (electric-indent-mode)
							 (company-capf)
							 (setq indent-tabs-mode t))))

(setq whitespace-cleanup-mode nil)
;; (add-hook 'prog-mode-hook 'ligature-mode)

(defun my-c++-mode-before-save-hook ()
  (when (eq major-mode 'c++-mode)
    (cpp-auto-include)))

(add-hook 'before-save-hook #'my-c++-mode-before-save-hook)

;; (setq tab-always-indent 'complete)
	
;; (add-hook 'c-mode-common-hook #'aggressive-indent-mode)
;; (add-hook 'prog-mode-hook 'aggressive-indent-mode)
;; (add-hook 'emacs-lisp-mode-hook #'aggressive-indent-mode)
(put 'dired-find-alternate-file 'disabled nil)
