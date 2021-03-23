;;; (defun set-exec-path-from-shell-PATH ()
;;;   (let ((path-from-shell (replace-regexp-in-string
;;;                           "[ \t\n]*$"
;;;                           ""
;;;                           (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
;;;     (setenv "PATH" path-from-shell)
;;;     (setq eshell-path-env path-from-shell) ; for eshell users
;;;     (setq exec-path (split-string path-from-shell path-separator))))
;;; (when window-system (set-exec-path-from-shell-PATH))

;;; (setenv "GOPATH" (s-concat home "/go"))
;;; (setenv "GOROOT" (s-concat home "/go"))
;;; (setenv "GOROOT" "/Users/bob/homebrew/Cellar/go/1.10.3/libexec")

(setq create-lockfiles nil)

(when (eq system-type 'windows-nt)
  (add-to-list 'exec-path "c:/Users/bobba/go/bin")
  (add-to-list 'exec-path "c:/Users/bobba/bin")
  (add-to-list 'exec-path "c:/Users/bobba/Downloads/emacs-26.1-x86_64/bin")
  (add-to-list 'exec-path "c:/Users/bobba/.babun/cygwin/bin"))

;;; (when (eq system-type 'darwin)
;;;   (setq mac-option-key-is-meta nil)
;;;   (setq mac-command-key-is-meta t)
;;;   (setq mac-command-modifier 'meta)
;;;   (setq mac-option-modifier nil)
;;;   (set-face-attribute 'default nil :family "Ubuntu Mono derivative Powerline")
;;;   (set-face-attribute 'default nil :height 200)
;;;   (set-fontset-font t 'hangul (font-spec :name "NanumGothicCoding")))

(add-to-list 'load-path "~/.emacs.d/lisp")
(add-to-list 'load-path "~/.emacs.d/elisp")
(add-to-list 'load-path "~/.emacs.d/aweshell")
(add-to-list 'load-path "~/.emacs.d/lisp/bookmark-plus")

(setq home (getenv "HOME"))

(package-initialize)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/"))

;;; (add-to-list 'package-archives '("milkbox" . "http://melpa.milkbox.net/packags/"))
(when (< emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))

(define-key function-key-map (kbd "<f5>") 'event-apply-alt-modifier)
(define-key function-key-map (kbd "<f6>") 'event-apply-super-modifier)
(define-key function-key-map (kbd "<f7>") 'event-apply-hyper-modifier)
(define-key function-key-map (kbd "<f8>") 'event-apply-meta-modifier)
(define-key function-key-map (kbd "<f9>") 'execute-extended-command)

;;;string manipulation package  https://github.com/magnars/s.el
;;; see also, https://github.com/emacs-mirror/emacs/blob/master/lisp/emacs-lisp/seq.el
;;;    and https://github.com/emacs-mirror/emacs/blob/master/lisp/emacs-lisp/subr-x.el
(require 's)
(require 'aweshell)
(require 'ein)
(when (executable-find "ipython")
  (setq python-shell-interpreter "ipython"))
;;; (server-start)

;;; (desktop-change-dir "dirname")
;;; (desktop-read)

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


(setq tramp-default-method "ssh")
(setq display-time-default-load-average 5)
(display-time)

(which-function-mode 1)

(setq company-tooltip-limit 20)
(setq company-idle-delay .3)   
(setq company-echo-delay 0)    
(setq company-begin-commands '(self-insert-command))

(add-hook 'go-mode-hook
          #'(lambda()
	      (setq gofmt-command "goimports")
	      (add-hook 'before-save-hook 'gofmt-before-save)
	      (if (not (string-match "go" compile-command))
		  (set (make-local-variable 'compile-command)
		       "go build -v && go vet"))
	      (lambda ()
                (set (make-local-variable 'company-backends) '(company-go))
                (company-mode))
	      (local-set-key (kbd "C-c .") 'godef-jump)
	      (local-set-key (kbd "C-c *") 'pop-tag-mark)
	      (local-set-key (kbd "C-c C-n") 'forward-list)
	      (local-set-key (kbd "C-c C-p") 'backward-list)
	      (require 'go-guru)
              (require 'go-imports)))
;;;;	      (define-key go-mode-map "\C-c\C-c" 'compile)

;;;;	      (define-key go-mode-map "\C-cI" 'go-imports-insert-import)
;;;;	      (define-key go-mode-map "\C-cR" go-imports-reload-packages-list)))

;;; (add-hook 'before-save-hook 'gofmt-before-save)

(defun auto-complete-for-go ()
  (auto-complete-mode 1))

(add-hook 'go-mode-hook 'auto-complete-for-go)
;;; (with-eval-after-load 'go-mode (require 'go-autocomplete))

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

;;; (require 'bookmark+)
(require 'package)
(require 'desktop)
(require 'tramp)
(require 'shell)
(require 'ansi-color)
(require 'xt-mouse)
(require 'mouse)

(require 'company)
(require 'company-go)
(require 'auto-complete)
(require 'go-autocomplete)
(require 'auto-complete-config)
(ac-config-default)

(add-hook 'shell-mode-hook 'my-shell-mode-hook)
;;; (keymap-unset-key  (kbd "C-c >")   "shell-script-mode")

(defun my-shell-mode-hook ()
  (setq comint-input-ring-file-name "~/.zsh_history")  ;;; or bash_history
  (setq comint-input-ring-separator "\n: \\([0-9]+\\):\\([0-9]+\\);")
  ;;; (setq shell-pushd-regexp "z")
  ;;; (define-key shell-mode-map (kbd "<up>") 'comint-previous-input)
  ;;; (define-key shell-mode-map (kbd "<down>") 'comint-next-input)
  (define-key shell-mode-map (kbd "C-c p") 'comint-previous-input)
  (define-key shell-mode-map (kbd "C-c n") 'comint-next-input)
  (define-key shell-mode-map (kbd "C-c r") 'comint-history-isearch-backward-regexp)
  (comint-read-input-ring t))

(defun colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region (point-min) (point-max))
  (toggle-read-only))

(add-hook 'after-init-hook 'global-company-mode)

(add-hook 'compilation-filter-hook 'colorize-compilation-buffer)

;;; (add-hook 'shell-mode-hook (lambda () (highlight-regexp "\\[OK\\]" "hi-green-b")))

(add-hook 'shell-mode-hook (lambda () (goto-address-mode )))
(add-hook 'shell-mode-hook 'compilation-shell-minor-mode)
(add-hook 'shell-mode-hook #'company-mode)
(define-key shell-mode-map (kbd "TAB") #'company-manual-begin)

;;; (load "~/.emacs.d/lisp/virtual-desktops")

;;; (virtual-desktops-mode 1)

(xterm-mouse-mode 1)

(defun track-mouse (e))

(setq mouse-wheel-follow-mouse 't)

(defvar alternating-scroll-down-next t)
(defvar alternating-scroll-up-next t)

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

(autoload 'enable-paredit-mode "paredit"
     "Turn on pseudo-structural editing of Lisp code."
     t)

(add-hook 'prog-mode-hook 'paredit-everywhere-mode)

(if window-system
    (progn
      (require 'color-theme)
      (require 'kaolin-themes)
      (color-theme-initialize)
      ;; (autoload 'color-theme-approximate-on "color-theme-approximate")
      ;; (color-theme-approximate-on)
      (load-theme 'atom-one-dark t)))

(load-theme 'charcoal-black t nil)
;;(load-theme 'bubbleberry t nil)
;;(load-theme 'kaolin-dark  t nil)
;;(load-theme 'kaolin-bubblegum  t nil)
;;(load-theme 'kaolin-valley-dark  T nil)
;;(load-theme 'kaolin-ocean  T nil)

;;; (setf shell-cd-regexp "\\(?:cd\\|z\\)")

(set-face-foreground 'vertical-border (face-background 'default))
(set-display-table-slot standard-display-table 'vertical-border ?│)

;;; (toggle-scroll-bar -1)

(smartparens-global-mode 1)
(show-paren-mode 1)

(menu-bar-mode 0)

(setq show-paren-style 'expression)

;;; (require 'doom-modeline)
;;; (doom-modeline-mode 1)
;;; (require 'nyan-mode)
;;; (nyan-mode 1)

;;; (require 'spaceline)
;;; (spaceline-spacemacs-theme)
;;; (require 'smart-mode-line)
;;; (setq sml/theme 'light)
(require 'telephone-line)
(defface shackra-orange '((t (:foreground "black" :background "orange"))) "")
(defface shackra-pink '((t (:foreground "black" :background "pink"))) "")
(defface shackra-green '((t (:foreground "black" :background "green"))) "")
(add-to-list 'telephone-line-faces '(accent-orange . (shackra-orange . telephone-line-accent-inactive)))
(add-to-list 'telephone-line-faces '(accent-pink . (shackra-pink . telephone-line-accent-inactive)))
(add-to-list 'telephone-line-faces '(accent-green . (shackra-green . telephone-line-accent-inactive)))

(setq telephone-line-lhs
      '((evil   . (telephone-line-evil-tag-segment))
	(accent-orange  . (telephone-line-vc-segment
			   telephone-line-erc-modified-channels-segment
			   telephone-line-process-segment))
	(nil    . (telephone-line-minor-mode-segment
		   telephone-line-buffer-segment))))

(setq telephone-line-rhs
      '((nil    . (telephone-line-misc-info-segment))
	(accent-pink  . (telephone-line-major-mode-segment))
	(accent-green   . (telephone-line-airline-position-segment))))

(telephone-line-mode 1)

(display-time-mode 1)

;;; (tool-bar-mode 1)
(tool-bar-mode 0)

(defun fix-path ()
  (interactive)
  (save-excursion
    (previous-line)
    (beginning-of-line)
    (kill-line))
  (yank))

;;; (require 'phi-search)
;;; (global-set-key (kbd "C-s") 'phi-search)
;;; (global-set-key (kbd "C-r") 'phi-search-backward)

(require 'multiple-cursors)
;;; (global-set-key (kbd "H-l") 'mc/edit-lines)
;;; (global-set-key (kbd "H->") 'mc/mark-next-like-this)
;;; (global-set-key (kbd "H-<") 'mc/mark-previous-like-this)
;;; (global-set-key (kbd "H-.") 'mc/mark-all-like-this)
(global-set-key (kbd "H-SPC") 'set-rectangular-region-anchor)

(global-set-key (kbd "<mouse-4>") 'alternating-scroll-down-line)
(global-set-key (kbd "<mouse-5>") 'alternating-scroll-up-line)

(global-set-key (kbd "C-x x") 'execute-extended-command)
(global-set-key (kbd "C-x <up>") 'scroll-down-command)
(global-set-key (kbd "C-x <down>") 'scroll-up-command)

(global-set-key (kbd "C-c !") 'shell-command)
(global-set-key (kbd "C-c &") 'async-shell-command)
(global-set-key (kbd "C-c :") 'eval-expression)
(global-set-key (kbd "C-c /") 'dabbrev-expand)
(global-set-key (kbd "C-c `") 'next-error)
(global-set-key (kbd "C-c <") 'beginning-of-buffer)
(global-set-key (kbd "C-c >") 'end-of-buffer)
(global-set-key (kbd "C-c %") 'query-replace)
(global-set-key (kbd "C-c DEL") 'backward-kill-word)
(global-set-key (kbd "C-c a") 'beginning-of-defun)
(global-set-key (kbd "C-c e") 'end-of-defun)
(global-set-key (kbd "C-c b") 'backward-word)
(global-set-key (kbd "C-c c") 'compile)
(global-set-key (kbd "C-c d") 'kill-word)
(global-set-key (kbd "C-c i") 'completion-at-point)
(global-set-key (kbd "C-c f") 'forward-word)
(global-set-key (kbd "C-c g") 'goto-line)
(global-set-key (kbd "C-x n") 'select-next-window) ;;; like gosling unipress emacs
(global-set-key (kbd "C-x p") 'select-previous-window)
(global-set-key (kbd "C-c r") 'replace-string)
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

(global-set-key (kbd "H-%") 'query-replace) ;;; hyper <f7>
(global-set-key (kbd "H-!") 'shell-command)
(global-set-key (kbd "H-a") 'beginning-of-defun)
(global-set-key (kbd "H-e") 'end-of-defun)
(global-set-key (kbd "H-c") 'compile)
(global-set-key (kbd "H-g") 'goto-line)
(global-set-key (kbd "H-r") 'replace-string)
(global-set-key (kbd "H-s") 'shell)
(global-set-key (kbd "H-n") 'next-buffer)
(global-set-key (kbd "H-p") 'previous-buffer)
(global-set-key (kbd "H-z") 'fix-path)

;;; (add-hook 'prog-mode-hook 'highlight-todos)

(global-hl-todo-mode 1)

;;; (bookmark-load "~/.emacs.d/bookmarks")

(add-to-list 'default-frame-alist '(height . 30))
(add-to-list 'default-frame-alist '(width . 90))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Cascadia Code" :slant normal :weight normal :height 140 normal)))))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("550271a375d4095372dd1155ef51377d6cb532f221e5e87e5d7a928e8bc5e64f" "3cacf6217f589af35dc19fe0248e822f0780dfed3f499e00a7ca246b12d4ed81" "058b8c7effa451e6c4e54eb883fe528268467d29259b2c0dc2fd9e839be9c92e" "811dabdae799fd679ab73ec15c987096ca7573afb43de3474c27405f032a7b9e" "0a2cc4df6d5afbc010950f70758b404d59d23e68041f7a1bbc3a89073b9624db" "6ccf9b2b5002dccb88afed6a3be9ebbfc6e609399c8fe8d647df2a40d86ad2ea" "2433283e8d6bf25ee31b8dc1907ee55880c2b2c758c82786788abd1d029f61f9" "add84a254d0176ffc2534cd05a17d57eea4a0b764146139656b4b7d446394a54" "2d5c40e709543f156d3dee750cd9ac580a20a371f1b1e1e3ecbef2b895cf0cd2" "9f08dacc5b23d5eaec9cccb6b3d342bd4fdb05faf144bdcd9c4b5859ac173538" "b4fd44f653c69fb95d3f34f071b223ae705bb691fb9abaf2ffca3351e92aa374" "8db4b03b9ae654d4a57804286eb3e332725c84d7cdab38463cb6b97d5762ad26" "2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" "8530b2f7b281ea6f263be265dd8c75b502ecd7a30b9a0f28fa9398739e833a35" "c9b89349d269af4ac5d832759df2f142ae50b0bbbabcce9c0dd53f79008443c9" "669e02142a56f63861288cc585bee81643ded48a19e36bfdf02b66d745bcc626" default)))
 '(package-selected-packages
   (quote
    (minimap neotree ein nyan-mode multi-vterm 0x0 mc-calc mc-extras multiple-cursors phi-search phi-search-mc yaml-mode tramp-term telephone-line ssh-tunnels ssh-config-mode ssh spacemacs-theme spaceline-all-the-icons solarized-theme smartparens smart-mode-line-powerline-theme ripgrep rg paredit-everywhere multishell multi-term magithub magit-topgit magit-tbdiff magit-imerge magit-gitflow magit-gh-pulls magit-find-file magit-filenotify kaolin-themes hl-todo go-tag go-snippets go-imports go-impl go-guru go-gen-test go-fill-struct go-errcheck go-complete go-autocomplete go-add-tags flycheck-yamllint flycheck-inline flycheck-gometalinter company-go color-theme-solarized color-theme-sanityinc-solarized color-theme-modern color-theme-approximate bubbleberry-theme atom-one-dark-theme atom-dark-theme ag))))
