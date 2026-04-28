;; ──────────────────────────────────────────────────────────────────────────────
;; Org directory helper
;; ──────────────────────────────────────────────────────────────────────────────

(defvar my/org-dir
  "C:/Users/AndrewGuthrie/iCloudDrive/iCloud~com~appsonthemove~beorg/org/")

(defun my/org (path)
  "Return absolute path to PATH inside my/org-dir."
  (expand-file-name path my/org-dir))


;; ──────────────────────────────────────────────────────────────────────────────
;; Package system
;; ──────────────────────────────────────────────────────────────────────────────

(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org"   . "https://orgmode.org/elpa/")
                         ("elpa"  . "https://elpa.gnu.org/packages/")))
(unless package-archive-contents
  (package-refresh-contents))

(require 'use-package)
(setq use-package-always-ensure t)


;; ──────────────────────────────────────────────────────────────────────────────
;; Startup performance
;; ──────────────────────────────────────────────────────────────────────────────

;; Raise GC threshold during init — cuts startup time by ~30-50% on Windows.
;; Reset to a reasonable value once Emacs is fully loaded.
(setq gc-cons-threshold (* 100 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 8 1024 1024))))

;; Native compilation (Emacs 28+): compile packages asynchronously in the
;; background. Warnings are suppressed — check *Warnings* if something breaks.
(when (featurep 'native-compile)
  (setq native-comp-async-report-warnings-errors nil
        native-comp-deferred-compilation t))


;; ──────────────────────────────────────────────────────────────────────────────
;; UI / appearance
;; ──────────────────────────────────────────────────────────────────────────────

(setq inhibit-startup-message t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq-default line-spacing 1)
(global-visual-line-mode 1)

;; ESC quits prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; Theme
(load-theme 'catppuccin :no-confirm)
(setq catppuccin-flavor 'mocha) ;; or 'latte, 'frappe, 'macchiato
(catppuccin-reload)


;; ──────────────────────────────────────────────────────────────────────────────
;; which-key — show available keybindings in a popup
;; ──────────────────────────────────────────────────────────────────────────────

(use-package which-key
  :init
  (which-key-mode 1)
  :config
  (setq which-key-idle-delay 0.5
        which-key-max-description-length 40))


;; ──────────────────────────────────────────────────────────────────────────────
;; general.el — cleaner keybinding declarations
;; ──────────────────────────────────────────────────────────────────────────────

(use-package general
  :config
  (general-define-key
   :prefix "C-c"
   "a" '(org-agenda          :which-key "agenda")
   "c" '(org-capture         :which-key "capture")
   "l" '(org-store-link      :which-key "store link")
   "j" '((lambda () (interactive) (org-capture nil "jj")) :which-key "journal entry")
   "t" '((lambda () (interactive) (org-capture nil "tt")) :which-key "task")
   "e" '((lambda () (interactive) (org-capture nil "e"))  :which-key "energy log")
   "p" '((lambda () (interactive) (org-capture nil "pp")) :which-key "pastoral care")
   "b" '((lambda () (interactive) (org-capture nil "bb")) :which-key "book recomendations"))

  (general-define-key
   :prefix "C-c n"
   "l" '(org-roam-buffer-toggle  :which-key "roam buffer")
   "f" '(org-roam-node-find      :which-key "find node")
   "i" '(org-roam-node-insert    :which-key "insert node")))
   ;; Note: dailies keymap is bound via :bind-keymap in org-roam below (C-c n d)


;; ──────────────────────────────────────────────────────────────────────────────
;; Completion — Vertico + Consult + Orderless
;; ──────────────────────────────────────────────────────────────────────────────

(use-package vertico
  :init
  (vertico-mode 1)
  :config
  (setq vertico-cycle t))

(use-package savehist
  :init
  (savehist-mode 1))

(use-package orderless
  :config
  (setq completion-styles '(orderless basic)
        completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :init
  (marginalia-mode 1))

(use-package consult
  :bind (("C-s"   . consult-line)
         ("C-x b" . consult-buffer)
         ("M-y"   . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-g o" . consult-org-heading)
         ("C-c s" . consult-ripgrep))
  :config
  (setq consult-preview-key 'any))

(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim))
  :config
  (setq embark-prompter 'embark-keymap-prompter))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :hook ((org-mode  . corfu-mode)
         (text-mode . corfu-mode)
         (prog-mode . corfu-mode))
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.2
        corfu-cycle t))


;; ──────────────────────────────────────────────────────────────────────────────
;; Org mode
;; ──────────────────────────────────────────────────────────────────────────────

(use-package org
  :config
  (setq org-agenda-files (list my/org-dir))

  ;; Habit tracking
  (add-to-list 'org-modules 'org-habit)
  (require 'org-habit)
  (setq org-habit-graph-column 50
        org-habit-preceding-days 21
        org-habit-show-habits-only-for-today nil)

  ;; Refile
  (setq org-refile-targets `((,(my/org "RACC.org") :maxlevel . 1)))
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  ;; Tags
  (setq org-tag-alist
        '((:startgroup)
          (:endgroup)
          ("Conversation"        . ?c)
          ("Meeting"             . ?m)
          ("Pastoral-Visit"      . ?p)
          ("ICARE"               . ?I)
          ("Outreach_and_Action" . ?o)
          ("CEW"                 . ?C)
          ("Board"               . ?b)
          ("Stewardship_and_Finance" . ?f)
          ("Worship"             . ?w)
          ("DESC"                . ?D)
          ("Liturgy"             . ?l)
          ("FLDOC"               . ?F))))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(font-lock-add-keywords 'org-mode
  '(("^ *\\([-]\\) "
     (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

(add-hook 'before-save-hook 'time-stamp)


;; ──────────────────────────────────────────────────────────────────────────────
;; Org capture templates
;; ──────────────────────────────────────────────────────────────────────────────

(setq org-capture-templates
  `(("t" "Tasks / Projects")
    ("tt" "Task" entry (file+olp ,(my/org "RACC.org") "Tasks" "Inbox")
     "* TODO %?\n" :empty-lines 1)
    ("b" "book recomendations")
    ("bb" "book recomendations" entry (file+olp ,(my/org "LIT.org") "Book recomendations")
         "** %?" :empty-lines 0)
    ("j" "Journal Entries")
    ("jj" "Journal" entry
         (file+olp+datetree ,(my/org "Journal.org"))
         "\n* %<%I:%M %p> - Journal :journal:\n\n%?\n\n"
         :clock-in :clock-resume
         :empty-lines 1)
    ("p" "Pastoral Care")
    ("pp" "Pastoral Care" entry
         (file+olp+datetree ,(my/org "Pastoral Care.org"))
         "\n* %<%I:%M %p> - Conversation :Pastoral_Care:\n\n%?\n\n"
         :clock-in :clock-resume
         :empty-lines 1)
    ("e" "Energy" plain
         (file ,(my/org "Life/Energy.org"))
         "| %U | %(let ((hour (string-to-number (format-time-string \"%H\"))))
                    (cond ((< hour 12) \"Morning\")
                          ((< hour 17) \"Afternoon\")
                          ((< hour 21) \"Evening\")
                          (t \"Night\"))) | %^{Energy Level (1-10)} | %? |")))


;; ──────────────────────────────────────────────────────────────────────────────
;; Org Roam
;; ──────────────────────────────────────────────────────────────────────────────

(use-package emacsql :ensure t)

(use-package org-roam
  :init
  (setq org-roam-v2-ack t)
  :custom
  (org-roam-directory (my/org "Roam"))
  (org-roam-completion-everywhere t)
  (org-roam-dailies-capture-templates
   '(("D" "Daily" entry "* %<%I:%M %p>: %?"
      :if-new (file+head "%<%Y-%m-%d>.org"
                         "#+title: %<%Y-%m-%d>\n#+filetags: :Daily:\n"))))
  (org-roam-capture-templates
   '(("z" "Zettel" plain "%?"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :Zettel:\n")
      :unnarrowed t)
     ("c" "creator" plain "* Projects  %?\n\n* References \n\n"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :Creator:\n")
      :unnarrowed t)
     ("i" "idea" plain "* Idea  \n%?\n* References \n[[file:~/org/Roam/20260409095239-idea.org][Idea]]"
      :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                         "#+title: ${title}\n#+filetags: :Idea:\n")
      :unnarrowed t)))
  :bind (:map org-mode-map
         ("C-M-i" . completion-at-point)
         :map org-roam-dailies-map
         ("Y" . org-roam-dailies-capture-yesterday)
         ("T" . org-roam-dailies-capture-tomorrow))
  :bind-keymap
  ("C-c n d" . org-roam-dailies-map)
  :config
  (require 'org-roam-dailies)
  (org-roam-db-autosync-mode))

(use-package org-roam-ui
  :defer t  ;; loads only when you call M-x org-roam-ui-mode
  :config
  (setq org-roam-ui-node-color-fn
        (lambda (node)
          (let ((tags (org-roam-node-tags node)))
            (cond
             ((member "Lit"      tags) "#FF6B6B")
             ((member "Zettel"   tags) "#4ECDC4")
             ((member "Question" tags) "#45B7D1")
             ((member "Idea"     tags) "#888888")
             (t "#cccccc"))))))


;; ──────────────────────────────────────────────────────────────────────────────
;; Org present
;; ──────────────────────────────────────────────────────────────────────────────

(use-package visual-fill-column
  :defer t
  :config
  (setq visual-fill-column-width 110
        visual-fill-column-center-text t))

(use-package org-present
  :defer t
  :hook ((org-present-mode      . my/org-present-start)
         (org-present-mode-quit . my/org-present-end)))

(defun my/org-present-start ()
  (visual-fill-column-mode 1)
  (visual-line-mode 1))

(defun my/org-present-end ()
  (visual-fill-column-mode 0)
  (visual-line-mode 0))


;; ──────────────────────────────────────────────────────────────────────────────
;; Habit — auto-complete after clocked time
;; ──────────────────────────────────────────────────────────────────────────────

(defvar my-habit-threshold (* 10 60)
  "Seconds of clocked time needed to auto-complete the habit.")

(add-hook 'org-clock-out-hook
          (lambda ()
            (when (>= (org-clock-get-clocked-time)
                      (/ my-habit-threshold 60))
              (org-todo "DONE"))))


;; ──────────────────────────────────────────────────────────────────────────────
;; Outlook calendar sync
;; ──────────────────────────────────────────────────────────────────────────────

(require 'url)

(defvar my/outlook-ics-url
  "https://outlook.office365.com/owa/calendar/abaa183c61c3455c9220d50fcce590af@jaxdisciples.org/8b753f0a24274aa685aae43a940527969468786746798330342/calendar.ics")
(defvar my/outlook-ics-file (my/org "outlook.ics"))
(defvar my/outlook-org-file (my/org "outlook-calendar.org"))

(defun my/ics-to-org-timestamp (ics)
  (when (string-match
         "\\([0-9]\\{4\\}\\)\\([0-9]\\{2\\}\\)\\([0-9]\\{2\\}\\)T?\\([0-9]\\{2\\}\\)?\\([0-9]\\{2\\}\\)?"
         ics)
    (let* ((year  (match-string 1 ics))
           (month (match-string 2 ics))
           (day   (match-string 3 ics))
           (hour  (or (match-string 4 ics) "00"))
           (min   (or (match-string 5 ics) "00"))
           (time  (encode-time 0 (string-to-number min) (string-to-number hour)
                               (string-to-number day)
                               (string-to-number month)
                               (string-to-number year))))
      (format-time-string "<%Y-%m-%d %a %H:%M>" time))))

(defun my/org-existing-uids ()
  (let ((uids (make-hash-table :test 'equal)))
    (when (file-exists-p my/outlook-org-file)
      (with-current-buffer (find-file-noselect my/outlook-org-file)
        (org-map-entries
         (lambda ()
           (let ((uid (org-entry-get (point) "OUTLOOK_UID")))
             (when uid (puthash uid t uids))))
         nil 'file)))
    uids))

(defun my/outlook-download ()
  (url-copy-file my/outlook-ics-url my/outlook-ics-file t))

(defun my/outlook-sync ()
  (interactive)
  (my/outlook-download)
  (let ((existing (my/org-existing-uids)))
    (with-temp-buffer
      (insert-file-contents my/outlook-ics-file)
      (goto-char (point-min))
      (while (re-search-forward "BEGIN:VEVENT" nil t)
        (let (uid summary dtstart)
          (when (re-search-forward "UID:\\(.*\\)" nil t)
            (setq uid (match-string 1)))
          (when (re-search-forward "SUMMARY:\\(.*\\)" nil t)
            (setq summary (match-string 1)))
          (when (re-search-forward "DTSTART.*:\\([0-9T]+\\)" nil t)
            (setq dtstart (match-string 1)))
          (unless (gethash uid existing)
            (let ((org-time (my/ics-to-org-timestamp dtstart)))
              (with-current-buffer (find-file-noselect my/outlook-org-file)
                (goto-char (point-max))
                (insert (format "* %s\nSCHEDULED: %s\n:PROPERTIES:\n:OUTLOOK_UID: %s\n:END:\n\n"
                                summary org-time uid))
                (save-buffer)))))))))

(run-with-idle-timer 5 nil #'my/outlook-sync)




;; ──────────────────────────────────────────────────────────────────────────────
;; Misc utilities
;; ──────────────────────────────────────────────────────────────────────────────

(use-package magit)

(defun markdown-convert-buffer-to-org ()
  "Convert current buffer from Markdown to Org and save as .org file."
  (interactive)
  (shell-command-on-region
   (point-min) (point-max)
   (format "pandoc -f markdown -t org -o %s"
           (concat (file-name-sans-extension (buffer-file-name)) ".org"))))

;; Open org directory on startup
(find-file (my/org "RACC.org"))

(defun my/open-startup-screen ()
  (interactive)
  (if (fboundp 'dashboard-refresh-buffer) (dashboard-refresh-buffer)
    (if (fboundp 'startify) (startify)
      (switch-to-buffer (my/org "RACC.org")))))
(global-set-key (kbd "C-c s") #'my/open-startup-screen)


;; ──────────────────────────────────────────────────────────────────────────────
;; Custom (managed by Emacs — do not edit by hand)
;; ──────────────────────────────────────────────────────────────────────────────

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("afde6368be6868e8e3dd53fad1ac51223d5484f9e6836496e7987802c9a9663d"
     default))
 '(org-agenda-files
   '("C:/Users/AndrewGuthrie/iCloudDrive/iCloud~com~appsonthemove~beorg/org/habits.org"
     "C:/Users/AndrewGuthrie/iCloudDrive/iCloud~com~appsonthemove~beorg/org/outlook-calendar.org"
     "C:/Users/AndrewGuthrie/iCloudDrive/iCloud~com~appsonthemove~beorg/org/Birthdays.org"
     "C:/Users/AndrewGuthrie/iCloudDrive/iCloud~com~appsonthemove~beorg/org/Journal.org"
     "C:/Users/AndrewGuthrie/iCloudDrive/iCloud~com~appsonthemove~beorg/org/Life/Home.org"
     "C:/Users/AndrewGuthrie/iCloudDrive/iCloud~com~appsonthemove~beorg/org/RACC.org"))
 '(package-selected-packages
   '(catppuccin-theme command-log-mode corfu embark embark-consult
		      general magit marginalia modus-themes orderless
		      org-bullets org-present org-roam org-roam-ui
		      pdf-tools simple-httpd sqlite3 vertico
		      visual-fill-column websocket which-key wombag)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
