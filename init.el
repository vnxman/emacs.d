;; maybe try this theme outhttps://github.com/mclear-tools/bespoke-themes
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
	("org" . "https://orgmode.org/elpa/")
	("elpa" . "https://elpa.gnu.org/packages/")))

;;; BOOTSTRAP USE-PACKAGE
(package-initialize)

(setq use-package-always-ensure t)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))

;;; My Stuff
(setq gv/is-termux
      (string-suffix-p
       "Android" (string-trim (shell-command-to-string "uname -a"))))

(defun gv/read ()
  (interactive)
  (async-shell-command
   (concat "tts.sh '" (x-get-clipboard)"'")))
(defun sudo-save ()
  (interactive)
  (if (not buffer-file-name)
      (write-file (concat "/sudo:root@localhost:" (read-file-name "File:")))
    (write-file (concat "/sudo:root@localhost:" buffer-file-name))))

;;; EVIL MODE
(progn
  ;; Vim style undo
  (use-package undo-fu)
  (use-package undo-fu-session
    :after undo-fu
    :init
    (global-undo-fu-session-mode))

  (use-package  evil
    :after undo-fu
    :init
    (setq evil-want-Y-yank-to-eol t)
    (setq evil-want-keybinding nil)
    (setq evil-split-window-below t)
    (setq evil-split-window-right t)
    (setq evil-undo-system 'undo-fu)
    :config
    (evil-mode 1)
    (evil-set-leader 'normal " ")
    (global-set-key (kbd "<escape>") 'keyboard-escape-quit)
    (evil-define-key 'normal   'global (kbd "<leader>t") 'capitalize-dwim)
    (evil-define-key 'visual   'global (kbd "<leader>t") 'capitalize-dwim)
    (evil-define-key 'insert   'global (kbd "M-n")       'hippie-expand)
    ;; Better lisp bindings
    (evil-define-key 'normal   'global (kbd "(")         'evil-previous-open-paren)
    (evil-define-key 'normal   'global (kbd ")")         'evil-next-close-paren)
    (evil-define-key 'operator 'global (kbd "(")         'evil-previous-open-paren)
    (evil-define-key 'operator 'global (kbd ")")         'evil-previous-close-paren))

  ;; evil mode in other modes live viewing pdfs
  (use-package  evil-collection
    :config
    (evil-collection-init))

  ;; Enable Commentary
  (use-package evil-commentary
    :config
    (evil-commentary-mode 1))
  ;; Enable Surround
  (use-package evil-surround
    :config
    (global-evil-surround-mode 1))
  ;; Enable Lion
  (use-package evil-lion
    :config
    (evil-lion-mode 1)
    (evil-define-key 'normal 'global (kbd "gl") 'evil-lion-left)
    (evil-define-key 'normal 'global (kbd "gL") 'evil-lion-right))
  ;; Cursor Shape
  (use-package evil-terminal-cursor-changer
    :config
    (unless (display-graphic-p)
      (evil-terminal-cursor-changer-activate))))

;;; TERMINAL SETTINGS
(if (display-graphic-p)
    (set-face-background 'default "#000000")
  (progn (set-face-background 'default "undefinded")
	 (add-to-list 'term-file-aliases
		      '("st-256color" . "xterm-256color"))
	 (xterm-mouse-mode t))
	(global-set-key (kbd "<mouse-4>") 'next-line)
	(global-set-key (kbd "<mouse-5>") 'previous-line))

;;; COMPLETION
(use-package vertico
  :init
  (vertico-mode))
(use-package orderless
  :custom (completion-styles '(orderless)))
(use-package marginalia
  :after vertico
  :custom
  (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  :init
  (marginalia-mode))
(use-package consult
  :after vertico
  :bind (("C-s" . consult-line)
	 ("C-M-l" . consult-imenu)
	 ("C-M-j" . persp-switch-to-buffer*)
	 :map minibuffer-local-map)
  :custom
  (completion-in-region-function #'consult-completion-in-region)
  :config
  (evil-define-key 'normal 'global (kbd "<leader>j") 'consult-imenu))
(use-package affe
  :after orderless
  :config
  ;; only exclude git files
  (setq affe-find-command "find  -not -path '*/\\.nnn*' -not -path '*/\\.git*' -type f")
  ;; Configure Orderless
  (setq affe-regexp-function #'orderless-pattern-compiler
	affe-highlight-function #'orderless--highlight)

  ;; Manual preview key for `affe-grep'
  (consult-customize affe-grep :preview-key (kbd "M-."))
  (evil-define-key 'normal 'global (kbd "gO") '(lambda () (interactive)
						(affe-grep "~/Documents/org")))
  (evil-define-key 'normal 'global (kbd "<leader>g") 'affe-grep)
  (evil-define-key 'normal 'global (kbd "<leader>f") 'affe-find))

;;; THEMEING
(use-package badger-theme
  :config
  (load-theme 'badger t)
  (set-frame-parameter (selected-frame) 'alpha '(90 90))
  (add-to-list 'default-frame-alist '(alpha 90 90))
  (set-cursor-color "#dc322f")
  (set-face-attribute 'region nil :background "#666" :foreground "#ffffff"))

;;; WRITING
(use-package writegood-mode
  :config
  (add-hook 'flyspell-mode-hook 'writegood-mode))
(use-package flyspell-correct
  :config
  (add-hook 'org-mode-hook 'turn-on-flyspell) ;spell checking
  (add-hook 'mu4e-compose-mode-hook 'turn-on-flyspell)
  (add-hook 'mail-mode-hook 'turn-on-flyspell)
  (evil-define-key 'normal 'global (kbd "<backspace>")
    'flyspell-correct-previous))

;;; ORG
(use-package org
  :ensure org-plus-contrib
  :config
  ;;archive completed tasks
  (defun my-org-archive-done-tasks ()
    (interactive)
    (progn
      (org-map-entries 'org-archive-subtree "/DONE" 'file)
      (org-map-entries 'org-archive-subtree "/CANCELLED" 'file)))

  (evil-define-key 'normal 'global (kbd "<leader>y") 'org-store-link)
  (evil-define-key 'normal 'global (kbd "gA") 'org-agenda)
  (evil-define-key 'normal 'global (kbd "gC") 'org-capture)

  (setq org-ellipsis " ▾"
	org-hide-emphasis-markers t
        org-special-ctrl-a/e t
	org-src-fontify-natively t
	org-fontify-quote-and-verse-blocks t
	org-src-tab-acts-natively t
	org-edit-src-content-indentation 2
	org-hide-block-startup nil
	org-src-preserve-indentation nil
	org-startup-folded 'content
	org-cycle-separator-lines 2)

  (setq org-default-notes-file (concat org-directory "/refile.org"))
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-todo-keywords
	'((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
	  (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANCELLED(k@)")))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
	'(("d" "Today's Tasks"
	   ((agenda "" ((org-agenda-span 1)
			(org-agenda-overriding-header "Today's Tasks")))))
	  ;; ("d" "Dashboard"
	  ;;  ((agenda "" ((org-deadline-warning-days 7)))
	  ;;   (todo "NEXT"
	  ;; 	  ((org-agenda-overriding-header "Next Tasks")))
	  ;;   (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

	  ("n" "Next Tasks"
	   ((todo "NEXT"
		  ((org-agenda-overriding-header "Next Tasks")))))


	  ("W" "Work Tasks" tags-todo "+work")

	  ;; Low-effort next actions
	  ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
	   ((org-agenda-overriding-header "Low Effort Tasks")
	    (org-agenda-max-todos 20)
	    (org-agenda-files org-agenda-files)))))

  (setq org-capture-templates
	'(("t" "Todo" entry (file "~/Documents/org/refile.org")
	   "* TODO %?\nDEADLINE: %T\n  %a")
	  ("m" "Meeting" entry (file+headline "~/Documents/org/mylife.org" "Meetings")
	   "* Meeting with  %?\nSCHEDULED: %T\n")
	  ("r" "Refund" entry (file+olp "~/Documents/org/Work.org"
					"Work" "Refunds")
	   "* TODO Refund %?\n%?  %a\n")
	  ("w" "Waitlist" entry (file+olp "~/Documents/org/Work.org"
					  "Work" "Waitlist")
	   "* %?\n%? %a\n")
	  ("v" "Video Idea" entry (file+olp "~/Documents/org/youtube.org"
					    "YouTube" "Video Ideas")
	   "* %?\n%? %a\n")
	  ("c" "Cool Thing" entry (file+datetree "~/Documents/org/archive.org")
	   "* %?\nEntered on %U\n  %i\n  %a")))
  (setq org-refile-targets
	'(("Work.org"    :maxlevel . 1)
	  ("archive.org" :maxlevel . 1)
	  ("mylife.org"  :maxlevel . 1)))
  (advice-add 'org-refile :after 'org-save-all-org-buffers))
(use-package org-contacts
  :ensure nil
  :after org
  :custom (org-contacts-files '("~/Documents/org/contacts.org")))
(use-package org-download
  :if (not gv/is-termux)
  :init
  (setq org-directory "~/Documents/org")
  (setq org-agenda-files (seq-filter (lambda (x) (not (string-match "completed.org" x)))
				     (directory-files-recursively org-directory "\\.org$")))
  (setq-default org-download-screenshot-method "gnome-screenshot -a -f %s")
  (setq-default org-download-image-dir "./pic")
  (exwm-input-set-key (kbd "s-i") 'org-download-screenshot)
  :after org
  :config
  (add-hook 'dired-mode-hook 'org-download-enable))
(use-package org-superstar
  :if (not gv/is-termux)
  :after org
  :config
  (if (display-graphic-p)
      (add-hook 'org-mode-hook #'org-superstar-mode)))
(use-package org-tempo
  :ensure nil
  :config
  (add-to-list 'org-structure-template-alist '("sh" . "src sh"))
  (add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
  (add-to-list 'org-structure-template-alist '("sc" . "src scheme"))
  (add-to-list 'org-structure-template-alist '("ts" . "src typescript"))
  (add-to-list 'org-structure-template-alist '("py" . "src python"))
  (add-to-list 'org-structure-template-alist '("go" . "src go")))
(require 'org-indent)

;;; Git
(use-package magit
  :config
  (evil-define-key 'normal 'global (kbd "Q") 'magit))
(use-package git-gutter
  :config
  (global-git-gutter-mode +1))

;;; Completion
(use-package company
  :config (global-company-mode nil)
  (add-hook 'org-mode-hook 'company-mode) ;org files
  (add-hook 'mu4e-compose-mode-hook 'company-mode) ;email
  (setq company-idle-delay 0.1
	company-minimum-prefix-length 1))

;;; VTERM AND ESHELL
(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

(use-package esh-autosuggest);company for eshell
(use-package xterm-color)

;;; LANGS
(use-package fennel-mode)
(use-package racket-mode)

;;; LSP using eglot
(use-package eglot
  :commands eglot
  :config
  (defconst my/eclipse-jdt-home "/usr/share/java/jdtls/plugins/org.eclipse.equinox.launcher.gtk.linux.x86_64_1.2.200.v20210406-1409.jar")

(defun my/eclipse-jdt-contact (interactive)
  (let ((cp (getenv "CLASSPATH")))
    (setenv "CLASSPATH" (concat cp ":" my/eclipse-jdt-home))
    (unwind-protect
        (eglot--eclipse-jdt-contact nil)
      (setenv "CLASSPATH" cp))))

(setcdr (assq 'java-mode eglot-server-programs) #'my/eclipse-jdt-contact)
  (add-hook 'c-mode-common-hook 'eglot)
  (add-hook 'java-mode-hook 'eglot)
  (add-to-list 'eglot-server-programs '(c-mode . ("ccls")))
  (add-to-list 'eglot-server-programs '(java-mode . ("jdtls"))))

;; As the built-in project.el support expects to use vc-mode hooks to
;; find the root of projects we need to provide something equivalent
;; for it.
(use-package project
  ;; Cannot use :hook because 'project-find-functions does not end in -hook
  ;; Cannot use :init (must use :config) because otherwise
  ;; project-find-functions is not yet initialized.
  :config
  (defun my-git-project-finder (dir)
    "Integrate .git project roots."
    (let ((dotgit (and (setq dir (locate-dominating-file dir ".git"))
		       (expand-file-name dir))))
      (and dotgit
	   (cons 'transient (file-name-directory dotgit)))))
  (add-hook 'project-find-functions 'my-git-project-finder))

(use-package ibuffer
  :ensure nil
  :config
  (setq ibuffer-expert t)
  (setq ibuffer-show-empty-filter-groups nil)
;; Use human readable Size column instead of original one
(define-ibuffer-column size-h
  (:name "Size" :inline t)
  (cond
   ((> (buffer-size) 1000000) (format "%7.1fM" (/ (buffer-size) 1000000.0)))
   ((> (buffer-size) 100000) (format "%7.0fk" (/ (buffer-size) 1000.0)))
   ((> (buffer-size) 1000) (format "%7.1fk" (/ (buffer-size) 1000.0)))
   (t (format "%8d" (buffer-size)))))

;; Modify the default ibuffer-formats
  (setq ibuffer-formats
	'((mark modified read-only " "
		(name 18 18 :left :elide)
		" "
		(size-h 9 -1 :right)
		" "
		(mode 16 16 :left :elide)
		" "
		filename-and-process)))

  (define-key global-map (kbd "C-x C-b") #'ibuffer)
  (add-hook 'ibuffer-mode-hook #'hl-line-mode))

;;; DEFAULTS
(use-package emacs
  :ensure nil
  :config
  (set-frame-font "RobotoMono Nerd Font 14" nil t)
  (setq delete-by-moving-to-trash t)
  (setq backup-by-copying t)
  (setq backup-inhibited t)
  (setq make-backup-files nil)
  (setq create-lockfiles nil)
  (setq auto-save-default nil)
  (setq inhibit-startup-screen t)
  (blink-cursor-mode -1)
  ;; Add border
  (menu-bar-mode -1)               ; To disable the menu bar, place the following line in your .emacs file:
  (unless gv/is-termux
    (scroll-bar-mode -1))             ; To disable the scroll bar, use the following line:
  (tool-bar-mode -1)               ; To disable the toolbar, use the following line:
  (fset 'yes-or-no-p 'y-or-n-p)    ; don't ask to spell out "yes"
  (show-paren-mode 1)              ; Highlight parenthesis
  (setq x-select-enable-primary t) ; use primary as clipboard in emacs
  (global-auto-revert-mode t)
  (setq hippie-expand-try-functions-list
	'(try-expand-dabbrev
	  try-expand-dabbrev-all-buffers
	  try-expand-dabbrev-from-kill
	  try-complete-lisp-symbol-partially
	  try-complete-lisp-symbol
	  try-complete-file-name-partially
	  try-complete-file-name
	  try-expand-all-abbrevs
	  try-expand-list
	  try-expand-line))
  (add-hook 'c-mode-common-hook   'hs-minor-mode)
  (add-hook 'emacs-lisp-mode-hook 'hs-minor-mode)
  (add-hook 'java-mode-hook       'hs-minor-mode)
  (add-hook 'lisp-mode-hook       'hs-minor-mode)
  (add-hook 'perl-mode-hook       'hs-minor-mode)
  (add-hook 'sh-mode-hook         'hs-minor-mode)
  (add-hook 'emacs-lisp-mode-hook 'prettify-symbols-mode)
  ;; Vim like scrolling
  (setq scroll-step            1
	scroll-conservatively  10000)
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
	'(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))
(use-package savehist
  :init
  (savehist-mode t))

;;; EXTRA UI
(use-package beacon ; Highlight cursor postion after movement
  :init
  (beacon-mode 1))
(use-package rainbow-mode ; Display hex colors in emacs
  :init
  (rainbow-mode t))

;;; DIRED
(use-package dired
  :ensure nil
  :custom ((dired-listing-switches "-aghoA --group-directories-first"))
  :config
  (add-hook 'dired-mode-hook 'dired-omit-mode)
  ;; Hide . and .. in dired
  (setq dired-omit-files
	(rx (or (seq bol (? ".") "#")
		(seq bol "." eol)
		(seq bol ".." eol))))

  (setq dired-hide-details-mode t)
  (evil-collection-define-key 'normal 'dired-mode-map
    "-" 'dired-up-directory)
  (define-key  evil-normal-state-map (kbd "-") (lambda () (interactive)
						 (dired "."))))
(use-package dired-open
  :config
  (setq dired-open-extensions '(("pdf" . "zathura")
				("ps"  . "zathura")
				("mkv" . "mpv")
				("mp4" . "mpv")
				("mp3" . "mpv"))))

;;; EMAIL
(unless gv/is-termux
  (add-to-list 'load-path "/usr/share/emacs/site-lisp/mu4e"))
(use-package mu4e
  :if (not gv/is-termux)
  :ensure nil
  :config
  ;; This is set to 't' to avoid mail syncing issues when using mbsync
  (setq mu4e-change-filenames-when-moving t)

  ;; Show full email address
  (setq mu4e-view-show-addresses 't)

  ;; where to put attachemnts
  (setq mu4e-attachment-dir  "~/Downloads")

  ;; use mu4e for e-mail in emacs
  (setq mail-user-agent 'mu4e-user-agent)

  (setq mu4e-maildir "~/.local/share/mail")

  ;; This prevents saving the email to the Sent folder since gmail will do this for us on their end.
  (setq mu4e-sent-messages-behavior 'delete)
  (setq message-kill-buffer-on-exit t)

  ;; allow for updating mail using 'U' in the main view:
  (setq mu4e-get-mail-command "mailsync"
	sendmail-program "/usr/bin/msmtp"
	message-sendmail-extra-arguments '("--read-envelope-from")
	send-mail-function 'smtpmail-send-it
	message-sendmail-f-is-evil t
	message-send-mail-function 'message-send-mail-with-sendmail)

  ;;images in emails
  (setq mu4e-view-show-images t)
  (define-abbrev-table 'mu4e-compose-mode-abbrev-table
    '(("sin" "Sincerely, \nGavin Jaeger-Freeborn" nil 1)))
  (add-hook 'mu4e-compose-mode-hook #'abbrev-mode)
  (add-to-list 'auto-mode-alist '("^/tmp/neomutt.*\\'" . mail-mode))

  ;; something about ourselves
  (setq mu4e-contexts
	(list
	 ;; Personal account
	 (make-mu4e-context
	  :name "Personal"
	  :match-func
	  (lambda (msg)
	    (when msg
	      (string-prefix-p "/personal" (mu4e-message-field msg :maildir))))
	  :vars '((user-mail-address                . "gavinfreeborn@gmail.com")
		  (user-full-name                   . "Gavin Jaeger-Freeborn")
		  (mu4e-drafts-folder               . "/personal/[Gmail].Drafts")
		  (mu4e-sent-folder                 . "/personal/[Gmail].Sent Mail")
		  (mu4e-refile-folder               . "/personal/[Gmail].All Mail")
		  (mu4e-trash-folder                . "/personal/[Gmail].Trash")))

	 ;; Info Work account
	 (make-mu4e-context
	  :name "Info"
	  :match-func
	  (lambda (msg)
	    (when msg
	      (string-prefix-p "/info" (mu4e-message-field msg :maildir))))
	  :vars '((user-mail-address                . "info@flatwaternorth.ca")
		  (user-full-name                   . "Gavin Jaeger-Freeborn")
		  (mu4e-drafts-folder               . "/info/[Gmail].Drafts")
		  (mu4e-sent-folder                 . "/info/[Gmail].Sent Mail")
		  (mu4e-refile-folder               . "/info/[Gmail].All Mail")
		  (mu4e-trash-folder                . "/info/[Gmail].Trash")))

	 ;; Coach Work account
	 (make-mu4e-context
	  :name "Coach"
	  :match-func
	  (lambda (msg)
	    (when msg
	      (string-prefix-p "/coach" (mu4e-message-field msg :maildir))))
	  :vars '((user-mail-address                . "coach@flatwaternorth.ca")
		  (user-full-name                   . "Gavin Jaeger-Freeborn")
		  (mu4e-drafts-folder               . "/coach/[Gmail].Drafts")
		  (mu4e-sent-folder                 . "/coach/[Gmail].Sent Mail")
		  (mu4e-refile-folder               . "/coach/[Gmail].All Mail")
		  (mu4e-trash-folder                . "/coach/[Gmail].Trash")))))
  ;; Contacts
  (setq mail-personal-alias-file  "~/.config/mutt/aliases")
  (setq mu4e-org-contacts-file  "~/Documents/org/contacts.org")
  (add-to-list 'mu4e-headers-actions
	       '("org-contact-add" . mu4e-action-add-org-contact) t)
  (add-to-list 'mu4e-view-actions
	       '("org-contact-add" . mu4e-action-add-org-contact) t)

  (setq mu4e-bookmarks '((:name "To Handle"
				:query "(flag:flagged OR flag:unread OR NOT flag:replied) AND date:3m..now" :key 116)
			 (:name "Today's messages"
				:query "date:today..now" :key 118)
			 (:name "Last 7 days"
				:query "date:7d..now" :hide-unread t :key 119)
			 (:name "Messages with images"
				:query "mime:image/*" :key 112))))

;; (use-package quelpa-use-package)
;; (use-package matrix-client
;;   :if (not gv/is-termux)
;;   :quelpa (matrix-client :fetcher github :repo "alphapapa/matrix-client.el"
;;                          :files (:defaults "logo.png" "matrix-client-standalone.el.sh")))
;; (use-package eaf
;;   :if (not gv/is-termux)
;;   :load-path "~/.emacs.d/site-lisp/emacs-application-framework" ; Set to "/usr/share/emacs/site-lisp/eaf" if installed from AUR
;;   :init
;;   (use-package epc :defer t :ensure t)
;;   (use-package ctable :defer t :ensure t)
;;   (use-package deferred :defer t :ensure t)
;;   (use-package s :defer t :ensure t)
;;   (use-package eaf-evil :ensure nil)
;;   :custom
;;   (eaf-browser-continue-where-left-off t)
;;   :config
;;   (eaf-setq eaf-browser-default-search-engine "duckduckgo")
;;   (eaf-setq eaf-browser-enable-adblocker "true")
;;   (eaf-bind-key scroll_up "C-n" eaf-pdf-viewer-keybinding)
;;   (eaf-bind-key scroll_down "C-p" eaf-pdf-viewer-keybinding)
;;   (eaf-bind-key take_photo "p" eaf-camera-keybinding)
;;   (eaf-bind-key nil "M-q" eaf-browser-keybinding))

;;; BETTER PDFS
;https://github.com/politza/pdf-tools
; annotate pdfs with c-c c-a
; hl with c-c c-a h
; for help M-x pdf-tools-help RET
(use-package pdf-tools
  :config
  ;; pdf auto refresh
  (add-hook 'doc-view-mode-hook 'auto-revert-mode))
(use-package transmission)
;;; EXWM
(use-package exwm
  :if (not gv/is-termux)
  :config
  (add-hook 'exwm-update-class-hook
	    (lambda ()
	      (exwm-workspace-rename-buffer exwm-class-name)))

  (add-hook 'exwm-manage-finish-hook
	    (lambda ()
	      (when (and exwm-class-name
			 (or (string= exwm-class-name "qutebrowser")
			     (string= exwm-class-name "libreoffice-writer")
			     (string= exwm-class-name "libreoffice-calc")
			     (string= exwm-class-name "Google-chrome")
			     (string= exwm-class-name "Brave-browser")))
		(exwm-input-set-local-simulation-keys nil))))

  (add-hook 'exwm-update-title-hook
	    (lambda ()
	      (pcase exwm-class-name
		("qutebrowser" (exwm-workspace-rename-buffer (format "qb: %s" exwm-title)))
		("libreoffice-writer" (exwm-workspace-rename-buffer (format "Writer: %s" exwm-title)))
		("libreoffice-calc" (exwm-workspace-rename-buffer (format "Calc: %s" exwm-title)))
		("St" (exwm-workspace-rename-buffer (format "%s" exwm-title))))))
  (setq exwm-input-global-keys
	`( ([?\s-h] . windmove-left)
	   ([?\s-l] . windmove-right)
	   ;; Window Managment
	   ([?\s-j] . edwina-select-next-window)
	   ([?\s-k] . edwina-select-previous-window)
	   ([?\s-s] . edwina-dec-nmaster)
	   ([?\s-a] . edwina-inc-nmaster)
	   ([?\s-v] . edwina-zoom)
	   (,(kbd "s-]")           . edwina-inc-mfact)
	   (,(kbd "s-[")           . edwina-dec-mfact)
	   (,(kbd "s-q")           . edwina-delete-window)
	   (,(kbd "<s-backspace>") . edwina-delete-window)
	   (,(kbd "<s-return>")    . edwina-clone-window)
	   ([?\s-g] . exwm-workspace-switch)
	   ([?\s-f] . exwm-layout-set-fullscreen)
	   ([?\s-q] . edwina-delete-window) ; closing windows
	   ([?\s-c] . inferior-octave)
	   ([?\s-C] . (lambda ()
			(interactive)
			(progn (kill-this-buffer)
			       (edwina-delete-window))))
	   ;; reset exwm
	   ([?\s-r] . (lambda ()
			(interactive)
			(progn (exwm-reset)
			       (edwina-arrange))))
	   ;; tile exwm
	   ([?\s-t] . (lambda ()
			(interactive)
			(progn (exwm-reset)
			       (edwina-arrange))))

	   ;; open a terminal
	   (,(kbd "s-T") . (lambda ()
			     (interactive)
			     (progn (edwina-clone-window)
				    (vterm))))
	   ;; launch any program
	   ([?\s-d] . (lambda (command)
			(interactive (list (read-shell-command "λ ")))
			(start-process-shell-command command nil command)))
	   ;; screen and audio controls
	   (,(kbd "C-s-f") . (lambda ()
			       (interactive)
			       (start-process-shell-command "cm up 5" nil "cm up 5")))
	   (,(kbd "C-s-a") . (lambda ()
			       (interactive)
			       (start-process-shell-command "cm down 5" nil "cm down 5")))
	   (,(kbd "C-s-d") . (lambda ()
			       (interactive)
			       (start-process-shell-command "cl up 5" nil "cl up 5")))
	   (,(kbd "C-s-s") . (lambda ()
			       (interactive)
			       (start-process-shell-command "cl dowm 5" nil "cl down 5")))
	   ;; web browser
	   ([?\s-w] . (lambda ()
			(interactive)
			(start-process-shell-command "ducksearch" nil "ducksearch")))

	   (,(kbd "s-E") . mu4e)
	   (,(kbd "s-e") . eshell)
	   ;;powermanager
	   ([?\s-x] . (lambda ()
			(interactive)
			(start-process-shell-command "power_menu.sh" nil "power_menu.sh")))
	   ([?\s-m] . (defun remind-timer (reminder)
			(interactive "reminder?")
			(egg-timer-do-schedule 3 reminder)))
	   ([?\s-b] . consult-buffer)
	   (,(kbd "s-B") . ibuffer)
	   ([?\s-=] . (lambda ()
			(interactive )
			(start-process-shell-command "Connections" nil
						     "dmenu_connection_manager.sh")))
	   ([?\s-p] . (lambda ()
			(interactive)
			(start-process-shell-command "Clipmenu" nil "clipmenu")))
	   ,@(mapcar (lambda (i)
		       `(,(kbd (format "s-%d" i))
			 (lambda ()
			   (interactive)
			   (exwm-workspace-switch-create ,i))))
		     (number-sequence 1 9))))
  (define-key exwm-mode-map [?\C-q] 'exwm-input-send-next-key)
  (fringe-mode 1)
  (exwm-enable)
  ;; start programs for exwm
  (start-process-shell-command "blueman-applet" nil "blueman-applet")
  (start-process-shell-command "nm-applet" nil "nm-applet")
  :init (setq mouse-autoselect-window t
	      focus-follows-mouse t))
(use-package exwm-systemtray
  :ensure nil
  :after exwm
  :config
  (exwm-systemtray-enable)
  (setq exwm-systemtray-height 23))
(use-package exwm-randr
  :ensure nil
  :after exwm
  :config
  (setq exwm-randr-workspace-output-plist '(3 "HDMI2"))
  (add-hook 'exwm-randr-screen-change-hook
	    (lambda ()
	      (start-process-shell-command
	       "xrandr" nil "xrandr --output eDP1 --primary --auto --left-of HDMI2 --auto")))
  (exwm-randr-enable))
(use-package exwm-mff
  :after exwm
  :config
  (exwm-mff-mode t))
(use-package edwina
  :after exwm
  :config
  (setq display-buffer-base-action '(display-buffer-below-selected)))
(use-package winner
  :ensure nil
  :config
  (exwm-input-set-key (kbd "s-u") 'winner-undo)
  (exwm-input-set-key (kbd "s-r") 'winner-redo)
  :init
  (winner-mode 1))

;;; MODELINE
(use-package mini-modeline
  :if (not gv/is-termux)
  :init
  (require 'battery)
  (setq mini-modeline-r-format
	(list
	 ;; value of `mode-name'
	 ;; value of current buffer name
	 '(:eval (propertize "%b, " 'face 'font-lock-variable-name-face))
	 '(:eval (propertize (if (eq 'emacs evil-state) "  " "  ")
			     'face 'epa-validity-high))

	 ;; value of current line number
	 '(:eval (propertize " %l,%c" 'face 'font-lock-comment-face))
	 '(:eval (propertize " %p" 'face 'font-lock-comment-face))
	 " "
	 ;; major mode
	 '(:eval (propertize " (%m) " 'face 'font-lock-comment-face))
	 ;; ;; spaces to align right
	 ;; '(:eval (propertize
	 ;; 		" " 'display
	 ;; 		`((space :align-to (- (+ right right-fringe right-margin)
	 ;; 				      ,(+ 10 (string-width mode-name)))))))
	 '(:eval (propertize
		  (format-time-string "%a, %b %d %I:%M%p")
		  'face 'change-log-list))
	 " "
	 '(:eval (propertize
		  (battery-format "[%p]" (funcall battery-status-function))
		  'face 'org-checkbox))
	 "    "))
  :config
  (mini-modeline-mode t))
(use-package server
  :ensure nil
  :config
  (unless (server-running-p)
    (server-start)))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("43f03c7bf52ec64cdf9f2c5956852be18c69b41c38ab5525d0bedfbd73619b6a" default))
 '(helm-minibuffer-history-key "M-p")
 '(org-agenda-files
   '("/home/gavinok/Documents/org/Work.org" "/home/gavinok/Documents/org/today.org"))
 '(package-selected-packages
   '(flymake-grammarly bespoke-themes beacon dired-open eglot literate-calc-mode calfw calfw-org ccls lsp-mode affe symon vertico consult org-notifications egg-timer org-plus-contrib volume ivy-youtube ytel esh-autosuggest pomidor ivy-clipmenu pdf-tools mini-modeline org-gcal org-alert edwina orderless corfu magit git-gutter org-download exwm-mff evil-mff evil-exwm-state typo-suggest type-suggest company helpful racket-mode fennel-mode undo-fu undo-fu-session org-bullets evil-collection ivy evil-lion evil-surround evil-commentary evil)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
