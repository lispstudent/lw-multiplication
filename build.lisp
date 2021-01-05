(in-package "CL-USER")

(load-all-patches)

(require 'asdf)

(let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
  (when (probe-file quicklisp-init)
    (load quicklisp-init)))


;#+MSWINDOWS (load "C:/apps/asdf/asdf.lisp")

(push "/home/lisp/quicklisp/local-projects/lw-multiplication/" asdf:*central-registry*)

;; (probe-file "./")

;; Without this, russian text is loaded incorrectly:

(defun force-utf-8-file-encoding (pathname ef-spec buffer length)
  (declare (ignore pathname buffer length))
  (system:merge-ef-specs ef-spec :utf-8))

(set-default-character-element-type 'character)

(setf stream::*default-external-format* '(:utf-8 :eol-style :lf))

(setf system:*file-encoding-detection-algorithm*
      '(force-utf-8-file-encoding))

(ql:quickload :multiplication)

(asdf:load-system :multiplication/core)

#+OS-MACOSX
(let* ((app-path (merge-pathnames #P"Multitrainer.app" (lispworks:current-pathname)))
       (bundle (create-macos-application-bundle
                app-path
                ;; Do not copy file associations...
                :document-types nil
                :application-icns (asdf/system:system-relative-pathname :multiplication
                                                                        "logo/logo.icns")
                ;; ...or CFBundleIdentifier from the LispWorks bundle
                :identifier "com.40ants.multitrainer"
                :version "0.1.0"
                ))))

#+MSWINDOWS
(let* ((app-path (merge-pathnames #P"Multitrainer.exe" (lispworks:current-pathname))))
  (deliver 'multiplication/core::start 
           app-path
           4
           :interface :capi
           :registry-path "multitrainer"
           :icon-file  (asdf/system:system-relative-pathname :multiplication
                                                             "logo/logo.ico")
           :startup-bitmap-file nil))
