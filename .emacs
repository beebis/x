;;(add-to-list 'load-path "~/.emacs.d/lisp")
;;(add-to-list 'load-path "~/.emacs.d/lisp/bookmark-plus")
(setq home (getenv "HOME"))
;;(server-start)


;;(desktop-change-dir "dirname")
;;(desktop-read)

(defun fix-path ()
  (interactive)
  (save-excursion
    (previous-line)
    (beginning-of-line)
    (kill-line))
  (yank))

(defun emacs-lisp-expand-clever ()
  "Cleverly expand symbols with normal dabbrev-expand, but also
if the symbol is -foo, then expand to module-name-foo."
  (interactive)
  (if (save-excursion
        (backward-sexp)
        (when (looking-at "#?'") (search-forward "'"))
        (looking-at "-"))
      (if (eq last-command this-command)
          (call-interactively 'dabbrev-expand)
        (let ((module-name (emacs-lisp-module-name)))
          (progn
            (save-excursion
              (backward-sexp)
              (when (looking-at "#?'") (search-forward "'"))
              (unless (string= (buffer-substring-no-properties
                                (point)
                                (min (point-max) (+ (point) (length module-name))))
                               module-name)
                (insert module-name)))
            (call-interactively 'dabbrev-expand))))
    (call-interactively 'dabbrev-expand)))

(defun emacs-lisp-module-name ()
  "Search the buffer for `provide' declaration."
  (save-excursion
    (goto-char (point-min))
    (when (search-forward-regexp "^(provide '" nil t 1)
      (symbol-name (symbol-at-point)))))

(defun my-indent-region (beg end)
  (interactive "r")
  (let ((marker (make-marker)))
    (set-marker marker (region-end))
    (goto-char (region-beginning))
    (while (< (point) marker)
      (funcall indent-line-function)
      (forward-line 1))))

(define-key function-key-map (kbd "<f5>") 'event-apply-alt-modifier)
(define-key function-key-map (kbd "<f6>") 'event-apply-super-modifier)
(define-key function-key-map (kbd "<f7>") 'event-apply-hyper-modifier)
(define-key function-key-map (kbd "<f8>") 'event-apply-meta-modifier)
(define-key function-key-map (kbd "<f9>") 'execute-extended-command)

(setq tramp-default-method "ssh")
(setq display-time-default-load-average 5)
(display-time)
(defun set-exec-path-from-shell-PATH ()
  (let ((path-from-shell (replace-regexp-in-string
                          "[ \t\n]*$"
                          ""
                          (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq eshell-path-env path-from-shell) ; for eshell users
    (setq exec-path (split-string path-from-shell path-separator))))
(when window-system (set-exec-path-from-shell-PATH))

;;(setenv "GOPATH" (getenv "HOME"))

;;(setenv "GOPATH" "/home/bob/bob")
;;(setenv "GOROOT" "/home/bob/bob/go")
;(setenv "GOROOT" "/Users/bob/homebrew/Cellar/go/1.10.3/libexec")
;;(setenv "GOPATH" "/Users/bob")
;;(setenv "GOPATH" "/home/bob/")
;;(setenv "GOROOT" "/home/bob/go")
;(add-to-list 'exec-path "/Users/bob/go/bin")
;(add-to-list 'exec-path "/Users/bob/bin")
;;(add-hook 'before-save-hook 'gofmt-before-save)
(which-function-mode 1)

;;(setq company-tooltip-limit 20)
;;(setq company-idle-delay .3)   
;;(setq company-echo-delay 0)    
;;(setq company-begin-commands '(self-insert-command))

(add-hook 'go-mode-hook
          #'(lambda()
	      (setq gofmt-command "goimports")
	      (add-hook 'before-save-hook 'gofmt-before-save)
	      (if (not (string-match "go" compile-command))
		  (set (make-local-variable 'compile-command)
		       "go build -v && go vet"))
	      ;; (lambda ()
              ;;   (set (make-local-variable 'company-backends) '(company-go))
              ;;   (company-mode))
	      (local-set-key (kbd "C-c .") 'godef-jump)
	      (local-set-key (kbd "C-c *") 'pop-tag-mark)
	      (local-set-key (kbd "C-c C-n") 'forward-list)
	      (local-set-key (kbd "C-c C-p") 'backward-list)))
	      ;;;(require 'go-guru)
              ;;;(require 'go-imports)))
;;;	      (define-key go-mode-map "\C-c\C-c" 'compile)

;;;;	      (define-key go-mode-map "\C-cI" 'go-imports-insert-import)
;;;;	      (define-key go-mode-map "\C-cR" go-imports-reload-packages-list)))

(defun auto-complete-for-go ()
  (auto-complete-mode 1))

;;(add-hook 'go-mode-hook 'auto-complete-for-go)
;;(with-eval-after-load 'go-mode (require 'go-autocomplete))

(defun select-previous-window ()
  "Switch to the previous window"
  (interactive)
  (select-window (previous-window)))

(defun select-next-window ()
  "Switch to the previous window"
  (interactive)
  (select-window (next-window)))

(setq comint-input-ring-size 100000)

(defun keymap-unset-key (key keymap)
    "Remove binding of KEY in a keymap
    KEY is a string or vector representing a sequence of keystrokes."
    (interactive
     (list (call-interactively #'get-key-combo)
           (completing-read "Which map: " minor-mode-map-alist nil t)))
    (let ((map (rest (assoc (intern keymap) minor-mode-map-alist))))
      (when map
        (define-key map key nil)
        (message  "%s unbound for %s" key keymap))))

(package-initialize)

(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))
;;(add-to-list 'package-archives '("milkbox" . "http://melpa.milkbox.net/packags/"))
(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))


;;(require 's)

;;(require 'bookmark+)
;;(require 'package)
;;(require 'desktop)
;;(require 'tramp)
;;(require 'shell)
;;(require 'ansi-color)
;;(require 'xt-mouse)
;;(require 'mouse)

;;(require 'company)
;;(require 'company-go)
;;(require 'auto-complete)
;;(require 'go-autocomplete)
;;(require 'auto-complete-config)
;;(require 'telephone-line)

;;(ac-config-default)

;;(add-hook 'shell-mode-hook 'my-shell-mode-hook)
;;(keymap-unset-key  (kbd "C-c >")   "shell-script-mode")
;;(keymap-unset-key  (kbd "C-c >")   "shell-script-mode")

(defun my-shell-mode-hook ()
  (setq comint-input-ring-file-name "~/.zsh_history")  ;; or bash_history
  (setq comint-input-ring-separator "\n: \\([0-9]+\\):\\([0-9]+\\);")
  ;;(setq shell-pushd-regexp "z")
  ;(define-key shell-mode-map (kbd "<up>") 'comint-previous-input)
  ;(define-key shell-mode-map (kbd "<down>") 'comint-next-input)
  (define-key shell-mode-map (kbd "C-c p") 'comint-previous-input)
  (define-key shell-mode-map (kbd "C-c n") 'comint-next-input)
  (define-key shell-mode-map (kbd "C-c r") 'comint-history-isearch-backward-regexp)
  (comint-read-input-ring t))

(defun colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region (point-min) (point-max))
  (toggle-read-only))

;;(add-hook 'after-init-hook 'global-company-mode)

;;(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)
;;(add-hook 'shell-mode-hook (lambda () (highlight-regexp "\\[OK\\]" "hi-green-b")))
;;(add-hook 'shell-mode-hook (lambda () (goto-address-mode )))
;;(add-hook 'shell-mode-hook 'compilation-shell-minor-mode)
;;(add-hook 'shell-mode-hook #'company-mode)
;;(define-key shell-mode-map (kbd "TAB") #'company-manual-begin)

;;(load "~/.emacs.d/lisp/virtual-desktops")
;;(virtual-desktops-mode 1)

;;(xterm-mouse-mode)
;;(xterm-mouse-mode t)
;;(defun track-mouse (e))
;;(setq mouse-wheel-follow-mouse 't)
;;(defvar alternating-scroll-down-next t)
;;(defvar alternating-scroll-up-next t)
(defun alternating-scroll-down-line ()
  (interactive "@")
  (when alternating-scroll-down-next
    (scroll-down-line))
  (setq alternating-scroll-down-next (not alternating-scroll-down-next)))
(defun alternating-scroll-up-line ()
  (interactive "@")
  (when alternating-scroll-up-next
    (scroll-up-line))
  (setq alternating-scroll-up-next (not alternating-scroll-up-next)))


(set-display-table-slot standard-display-table 'vertical-border ?│)
;;(toggle-scroll-bar -1)
;;(smartparens-global-mode 1)
(menu-bar-mode 1)
(show-paren-mode 1)
;;(telephone-line-mode 1)
(display-time-mode 1)
;;(tool-bar-mode 0)

(setq show-paren-style 'expression)

(global-set-key (kbd "<mouse-4>") 'alternating-scroll-down-line)
(global-set-key (kbd "<mouse-5>") 'alternating-scroll-up-line)

(global-set-key (kbd "C-x x") 'execute-extended-command)
(global-set-key (kbd "C-x <up>") 'scroll-down-command)
(global-set-key (kbd "C-x <down>") 'scroll-upl-command)
(global-set-key (kbd "H-!") 'shell-command)
(global-set-key (kbd "C-c !") 'shell-command)
(global-set-key (kbd "C-c &") 'async-shell-command)
(global-set-key (kbd "C-c :") 'eval-expression)
(global-set-key (kbd "C-c /") 'dabbrev-expand)
(global-set-key (kbd "C-c `") 'next-error)
(global-set-key (kbd "C-c <") 'beginning-of-buffer)
(global-set-key (kbd "C-c >") 'end-of-buffer)
(global-set-key (kbd "C-c %") 'query-replace)
(global-set-key (kbd "H-%") 'query-replace)
(global-set-key (kbd "C-c DEL") 'backward-kill-word)
(global-set-key (kbd "C-c a") 'beginning-of-defun)
(global-set-key (kbd "H-a") 'beginning-of-defun)
(global-set-key (kbd "H-e") 'end-of-defun)
(global-set-key (kbd "C-c e") 'end-of-defun)
(global-set-key (kbd "C-c b") 'backward-word)
(global-set-key (kbd "H-c") 'compile)
(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "C-c d") 'kill-word)
(global-set-key (kbd "C-c i") 'completion-at-point)
(global-set-key (kbd "C-c f") 'forward-word)
(global-set-key (kbd "H-g") 'goto-line)
(global-set-key (kbd "C-c g") 'goto-line)
(global-set-key (kbd "C-x n") 'select-next-window)
(global-set-key (kbd "C-x p") 'select-previous-window) ;; like gosling unipress emacs
(global-set-key (kbd "H-r") 'replace-string)
(global-set-key (kbd "C-c r") 'replace-string)
(global-set-key (kbd "H-s") 'shell)
(global-set-key (kbd "H-n") 'next-buffer)
(global-set-key (kbd "H-p") 'previous-buffer)
(global-set-key (kbd "H-z") 'fix-path)
(global-set-key (kbd "C-c s") 'shell)
(global-set-key (kbd "C-c v") 'scroll-down-command)
(global-set-key (kbd "C-c w") 'kill-ring-save)
(global-set-key (kbd "C-c x") 'execute-extended-command)
(global-set-key (kbd "C-c y") 'yank-pop)
(global-set-key (kbd "C-c C-c") 'exit-recursive-edit)
(global-set-key (kbd "C-c C-v") 'scroll-down-command)
(global-set-key (kbd "C-c C-w") 'append-next-kill)

(define-key minibuffer-local-map (kbd "C-c p") 'previous-history-element)
(define-key minibuffer-local-map (kbd "C-c n") 'next-history-element)

;;(add-hook 'prog-mode-hook 'highlight-todos)
;;(global-hl-todo-mode 1)

;;(bookmark-load "~/.emacs.d/bookmarks")

;;(add-to-list 'default-frame-alist '(height . 35))
;;(add-to-list 'default-frame-alist '(width . 90))

;;(require 'color-theme-modern)
;;(require 'kaolin-themes)

;;(color-theme-initialize)
;;(autoload 'color-theme-approximate-on "color-theme-approximate")
;;(color-theme-charcoal-black)
;(color-theme-approximate-on)
;;(load-theme 'atom-dark' t)
;;(load-theme 'atom-one-dark' t)
;;(when (display-graphic-p)
;;  (load-theme 'kaolin-dark t))
;;(load-theme 'kaolin-ocean t)
;;(load-theme 'kaolin-bubblegum t)
;;(load-theme 'kaolin-eclipse t)
;;(load-theme 'kaolin-galaxy t)
;;(load-theme 'bubbleberry t)
;;(color-theme-charcoal-black)
;;(add-to-list 'custom-theme-load-path "~/.emacs.d/private/bubblegum-theme")
;;(load-theme 'bubblegum-dark)
;;(color-theme-solarized-dark)
;;(color-theme-sanityinc-solarized)
;;(setf shell-cd-regexp "\\(?:cd\\|z\\)")
;;(set-face-foreground 'vertical-border (face-background 'default))

;; (custom-set-variables
;;  ;; custom-set-variables was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(custom-safe-themes
;;    (quote
;;     ("2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" default)))
;;  '(display-time-mode t)
;;  '(package-selected-packages
;;    (quote
;;     (bubbleberry-theme solarized-theme atom-dark-theme atom-one-dark-theme color-theme-modern kaolin-themes color-theme telephone-line smartparens s go-autocomplete)))
;;  '(show-paren-mode t))
;; (custom-set-faces
;;  ;; custom-set-faces was added by Custom.
;;  ;; If you edit it by hand, you could mess it up, so be careful.
;;  ;; Your init file should contain only one such instance.
;;  ;; If there is more than one, they won't work right.
;;  '(default ((t (:family "Ubuntu Mono" :foundry "DAMA" :slant normal :weight normal :height 161 :width normal)))))
;;(custom-set-faces
;; '(default ((t (:family "Delugia Nerd Font"  :slant normal :weight normal :height 161 :width normal)))))
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(display-time-mode t)
 '(show-paren-mode t))
