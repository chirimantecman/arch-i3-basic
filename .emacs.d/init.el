;; ---------------------------------------------------------------------
;; init.el
;;
;; This is the top level init file for my emacs configuration.  This
;; configuration is organized in different org-mode files that document
;; the same and hold the actual emacs-lisp code.

;; The top level org-mode file is config-org/config.org.
;; ---------------------------------------------------------------------


;; --- MISC ------------------------------------------------------------
;; A setting for efficient garbage collection.
(setq gc-cons-threshold (eval-when-compile (* 1024 1024 10)))


;; --- GUI -------------------------------------------------------------

;; ---------------------------------------------------------------------
;; Turn off GUI elements early. Previously had these as custom set
;; vars.
;; (taken from [https://www.youtube.com/watch?v=gRb3bq0NiXY])
;; ---------------------------------------------------------------------
(when window-system
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (tooltip-mode -1))


;; --- PACKAGES SETUP --------------------------------------------------

;;----------------------------------------------------------------------
;; package - package management platform for Emacs.
;;----------------------------------------------------------------------
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
	     '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;;----------------------------------------------------------------------
;; use-package - for simplifying your .emacs.
;; First we make sure it's installed. Then we set it up.
;;----------------------------------------------------------------------
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; From use-package README.
(eval-when-compile
  (require 'use-package))
;(require 'diminish)
(require 'bind-key)


;; --- ORG CONFIG FILE -------------------------------------------------

;; Load the top level file.
(if (file-exists-p "/config-org/config.elc")
    (require "/config-org/config")
  (org-babel-load-file (concat user-emacs-directory "/config-org/config.org")))
