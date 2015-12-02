;;; package --- Summary
;;; Commentary:
;;;  Code:
;; load-pathの追加関数
(defun add-to-load-path (&rest paths)
  (let (path)
	(dolist (path paths paths)
	  (let ((default-directory (expand-file-name (concat user-emacs-directory path))))
		(add-to-list 'load-path default-directory)
		(if (fboundp 'normal-top-level-add-subdirs-to-load-path)
			            (normal-top-level-add-subdirs-to-load-path))))))

;; load-pathに追加するフォルダ
;; 2つ以上フォルダを指定する場合の引数 => (add-to-load-path "elisp" "xxx" "xxx")
(add-to-load-path "elisp" "elpa/yasnippet-20151101.1535/")

(require 'package) ;; You might already have this line
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize) ;; You might already have this line

(require 'yasnippet)
(yas-global-mode 1)

;; auto-complete
(require 'auto-complete)
(global-auto-complete-mode t)
(define-key ac-complete-mode-map "\C-n" 'ac-next)
(define-key ac-complete-mode-map "\C-p" 'ac-previous)

;; python コード補完
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)

(projectile-global-mode)
(require 'helm-projectile)
;; プロジェクトに関連するファイルをhelm-for-filesに追加
(defadvice helm-for-files (around update-helm-list activate)
  (let ((helm-for-files-preferred-list
         (helm-for-files-update-list)))
    ad-do-it))

(defun helm-for-files-update-list ()
  `(helm-source-buffers-list
    helm-source-recentf
    helm-source-ghq
    helm-source-files-in-current-dir
    helm-source-file-cache
    ,(if (projectile-project-p)
     helm-source-projectile-files-list)))

;; helm-agをプロジェクトルートから
(defun projectile-helm-ag ()
  (interactive)
  (helm-ag (projectile-project-root)))

;; git
(require 'magit)

(set-face-foreground 'magit-hash "black") ;リビジョン
(set-face-background 'magit-diff-hunk-heading "grey")
(set-face-background 'magit-diff-hunk-heading-highlight "grey")
(set-face-background 'magit-diff-added "grey")
(set-face-background 'magit-diff-added-highlight "grey")
(set-face-background 'magit-diff-removed "grey")
(set-face-background 'magit-diff-removed-highlight "grey")

;;(global-git-gutter-mode t)
;;(setq git-gutter:added-sign "++")
;;(setq git-gutter:deleted-sign-sign "--")
;;(setq git-gutter:modified-sign "==")
;;(set-face-foreground 'git-gutter:added  "green")
;;(set-face-foreground 'git-gutter:deleted  "yellow")
;;(set-face-background 'git-gutter:modified "magenta")

(require 'multi-term)
(setq multi-term-program shell-file-name)

;; linum-mode
(global-linum-mode t)
(setq linum-delay t)
(defadvice linum-schedule (around my-linum-schedule () activate)
  (run-with-idle-timer 0.2 nil #'linum-update-current))

;; コントロール用のバッファを同一フレーム内に表示
(setq ediff-window-setup-function 'ediff-setup-windows-plain)
;; diffのバッファを上下ではなく左右に並べる
(setq ediff-split-window-function 'split-window-horizontally)

;; 初期画面をスクラッチに
(setq inhibit-startup-message t)

;; タブ幅
(setq default-tab-width 4)

;; C-hでバックスペース
(keyboard-translate ?\C-h ?\C-?)

;; メニューバーを消す
(menu-bar-mode -1)

;;; 対応する括弧を光らせる。
(show-paren-mode 1)

;;; カーソルの位置が何行目かを表示する
(line-number-mode t)
(global-set-key [f6] 'linum-mode)
(setq linum-format "%4d ")

;;; バックアップファイルを作らない
(setq backup-inhibited t)

;;; 終了時にオートセーブファイルを消す
(setq delete-auto-save-files t)

;;; 補完時に大文字小文字を区別しない
(setq completion-ignore-case t)
(setq read-file-name-completion-ignore-case t)

;; タイトルバーに日時を表示する
(setq display-time-day-and-date t
      display-time-24hr-format t)
(setq display-time-string-forms
      '((if display-time-day-and-date
			        (format "%s/%s/%s " year month day)
		        "")
		(format "%s:%s%s"
				(if display-time-24hr-format 24-hours 12-hours)
				minutes
				(if display-time-24hr-format "" am-pm))))
(display-time)
(cond (window-system
       (setq frame-title-format
			            '((multiple-frames "")
						              display-time-string))
       (remove-hook 'global-mode-string 'display-time-string)))

(global-font-lock-mode t)

;;
;; whitespace
;;
;(require 'whitespace)
;(setq whitespace-style '(face           ; faceで可視化
;						 trailing       ; 行末
;						 tabs           ; タブ
;						 empty          ; 先頭/末尾の空行
;						 space-mark     ; 表示のマッピング
;						 tab-mark
;						 ))

;(setq whitespace-display-mappings
;	  '((tab-mark ?\t [?\u00BB ?\t] [?\\ ?\t])))

;(global-whitespace-mode 1)


;; python-mode hack
(require 'highlight-indentation)
(add-hook 'python-mode-hook 'highlight-indentation-mode)
(set-face-background 'highlight-indentation-face "#e3e3d3")
(set-face-background 'highlight-indentation-current-column-face "#c3b3b3")

;(add-hook 'python-mode-hook 'py-autopep8-enable-on-save)
;(add-hook 'python-mode-hook
;          (lambda ()
;            (define-key python-mode-map "\"" 'electric-pair)
;            (define-key python-mode-map "\'" 'electric-pair)
;            (define-key python-mode-map "(" 'electric-pair)
;            (define-key python-mode-map "[" 'electric-pair)
;            (define-key python-mode-map "{" 'electric-pair)))
(defun electric-pair ()
  "Insert character pair without sournding spaces"
  (interactive)
  (let (parens-require-spaces)
    (insert-pair)))

(add-hook 'python-mode-hook '(lambda () 
     (define-key python-mode-map "\C-m" 'newline-and-indent)))

(require 'tramp-cmds)
;;(when (load "flymake" t)
;;  (defun flymake-pyflakes-init ()
     ; Make sure it's not a remote buffer or flymake would not work
;;     (when (not (subsetp (list (current-buffer)) (tramp-list-remote-buffers)))
;;      (let* ((temp-file (flymake-init-create-temp-buffer-copy
;;                         'flymake-create-temp-inplace))
;;             (local-file (file-relative-name
;;                          temp-file
;;                          (file-name-directory buffer-file-name))))
;;        (list "pyflakes" (list local-file)))))
;;  (add-to-list 'flymake-allowed-file-name-masks
;;               '("\\.py\\'" flymake-pyflakes-init)))
;; 
;;(add-hook 'python-mode-hook
;;          (lambda ()
;;            (flymake-mode t)))

;;flycheck
(add-hook 'after-init-hook #'global-flycheck-mode)

(autoload 'ruby-mode "ruby-mode"
  "Mode for editing ruby source files" t)
(add-to-list 'auto-mode-alist '("\\.rb$latex " . ruby-mode))
(add-to-list 'auto-mode-alist '("Capfile$" . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile$" . ruby-mode))

;;;; for ctags.el
(require 'ctags nil t)
(setq tags-revert-without-query t)
(setq ctags-command "ctags-exuberant -R --fields=\"+afikKlmnsSzt\" ")
(global-set-key (kbd "<f5>") 'ctags-create-or-update-tags-table)
(global-set-key (kbd "M-.") 'ctags-search)

(defun window-resizer ()
  "Control window size and position."
  (interactive)
  (let ((window-obj (selected-window))
		(current-width (window-width))
		(current-height (window-height))
		(dx (if (= (nth 0 (window-edges)) 0) 1
			  -1))
		(dy (if (= (nth 1 (window-edges)) 0) 1
			  -1))
		c)
	(catch 'end-flag
	  (while t
		(message "size[%dx%d]"
				 (window-width) (window-height))
		(setq c (read-char))
		(cond ((= c ?l)
			   (enlarge-window-horizontally dx))
			  ((= c ?h)
			   (shrink-window-horizontally dx))
			  ((= c ?j)
			   (enlarge-window dy))
			  ((= c ?k)
			   (shrink-window dy))
			  ;; otherwise
			  (t
			   (message "Quit")
			   (throw 'end-flag t)))))))
(global-set-key "\C-c\C-r" 'window-resizer)

