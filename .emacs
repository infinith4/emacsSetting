(setq load-path (cons "~/.emacs.d/elisp" load-path))
;; まず、install-elisp のコマンドを使える様にします。
(require 'install-elisp)
;; 次に、Elisp ファイルをインストールする場所を指定します。
(setq install-elisp-repository-directory "~/.emacs.d/elisp/")
;; Emacs 23より前のバージョンを利用している方は
;; user-emacs-directory変数が未定義のため次の設定を追加
(when (< emacs-major-version 23)
  (defvar user-emacs-directory "~/.emacs.d/"))

;; load-path を追加する関数を定義
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

;; 引数のディレクトリとそのサブディレクトリをload-pathに追加
(add-to-load-path "elisp" "conf" "public_repos")

;; auto-installの設定
(when (require 'auto-install nil t)	; ←1●
  ;; 2●インストールディレクトリを設定する 初期値は ~/.emacs.d/auto-install/
  (setq auto-install-directory "~/.emacs.d/elisp/")
  ;; EmacsWikiに登録されているelisp の名前を取得する
  (auto-install-update-emacswiki-package-name t)
  ;; 必要であればプロキシの設定を行う
  ;; (setq url-proxy-services '(("http" . "localhost:8339")))
  ;; 3●install-elisp の関数を利用可能にする
  (auto-install-compatibility-setup)) ; 4●

;; perl-completion
(add-hook 'cperl-mode-hook
          (lambda()
            (require 'perl-completion)
            (perl-completion-mode t)))

(add-hook  'cperl-mode-hook
           (lambda ()
             (when (require 'auto-complete nil t) ; no error whatever auto-complete.el is not installed.
               (auto-complete-mode t)
               (make-variable-buffer-local 'ac-sources)
               (setq ac-sources
                     '(ac-source-perl-completion)))))

;; ▼要拡張機能インストール▼
;;; P114-115 auto-installを利用する
;; (install-elisp "http://www.emacswiki.org/emacs/download/redo+.el")
(when (require 'redo+ nil t)
  ;; C-' にリドゥを割り当てる
  (global-set-key (kbd "C-'") 'redo)
  ;; 日本語キーボードの場合C-. などがよいかも
  ;; (global-set-key (kbd "C-.") 'redo)
  ) ; ←ここでC-x C-eで設定反映

;; ▼要拡張機能インストール▼
;;; P130-131 利用可能にする
;;(when (require 'auto-complete-config nil t)
;;  (add-to-list 'ac-dictionary-directories 
;;    "~/.emacs.d/elisp/")
;;  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
;;  (ac-config-default))
;; auto-complete
(require 'auto-complete)
(global-auto-complete-mode t)
;; あとC-n, C-pで選択できるように追加
(define-key ac-complete-mode-map "\C-n" 'ac-next)          
(define-key ac-complete-mode-map "\C-p" 'ac-previous)

;; cperl-mode-hook
(defalias 'perl-mode 'cperl-mode)
(setq auto-mode-alist (cons '("\\.t$" . cperl-mode) auto-mode-alist))

;; perl-completion-mode
(add-hook 'cperl-mode-hook
	  (lambda()
	    (perl-completion-mode t)))

;; auto-complete-mode
(add-hook 'cperl-mode-hook
	  (lambda ()
	    (when (require 'auto-complete nil t) ; no error whatever auto-complete.el is not installed.
  (auto-complete-mode t)
  (make-variable-buffer-local 'ac-sources)
  (setq ac-sources '(ac-source-perl-completion)))))

;; flymake-mode
(add-hook 'cperl-mode-hook
          (lambda ()
	    (flymake-mode t)))

;;(set-language-environment ‘Japanese)

(autoload 'python-mode "python-mode" "Major mode for editing Python programs" t)
(autoload 'py-shell "python-mode" "Python shell" t)
(setq auto-mode-alist (cons '("\\.py\\'" . python-mode) auto-mode-alist))

(autoload 'pymacs-apply "pymacs")
(autoload 'pymacs-call "pymacs")
(autoload 'pymacs-eval "pymacs" nil t)
(autoload 'pymacs-exec "pymacs" nil t)
(autoload 'pymacs-load "pymacs" nil t)
(eval-after-load "pymacs"
'(add-to-list 'pymacs-load-path "~/.pymacs"))

(add-hook 'python-mode-hook '(lambda ()
			       (require 'pycomplete)
			       ))
(kill-buffer "*scratch*")
(kill-buffer "*Messages*")

;;(require 'ac-python)
;;(add-to-list 'ac-modes 'python-mode)


;;(global-set-key (kbd "C-l") 'ac-complete-pycomplete-pycomplete)

(defun ac-complete-pycomplete-pycomplete ()
  (interactive)
  (auto-complete '(ac-source-python)))

(setq ac-source-python  '((prefix "\\(?:\\.\\|->\\)\\(\\(?:[a-zA-Z_][a-zA-Z0-9_]*\\)?\\)" nil 1)
			  (candidates . ac-py-candidates)
			  (requires . 0)))

(defun ac-py-candidates ()
  (pycomplete-pycomplete (py-symbol-near-point) (py-find-global-imports)))

(defun my-ac-python-mode ()
  (setq ac-sources '(ac-source-words-in-same-mode-buffers ac-source-dictionary)))
(add-hook 'python-mode-hook 'my-ac-python-mode)

(add-to-list 'load-path "~/.emacs.d/site-lisp/jedi/emacs-deferred")
(add-to-list 'load-path "~/.emacs.d/site-lisp/jedi/emacs-epc")
(add-to-list 'load-path "~/.emacs.d/site-lisp/jedi/emacs-ctable")
(add-to-list 'load-path "~/.emacs.d/site-lisp/jedi/emacs-jedi")
;;(require 'auto-complete-config)
;;(require 'python)
;;(require 'jedi)
;;(add-hook 'python-mode-hook 'jedi:ac-setup)
;;(define-key python-mode-map (kbd "<C-tab>") 'jedi:complete)
;;(setq jedi:complete-on-dot t)
