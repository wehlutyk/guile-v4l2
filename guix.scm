(use-modules
 (guix)
 (guix build-system gnu)
 (guix git-download)                    ;for ‘git-predicate’
 ((guix licenses) #:prefix license:)
 (gnu packages autotools)
 (gnu packages base)
 (gnu packages bdw-gc)
 (gnu packages gettext)
 (gnu packages gl)
 (gnu packages guile)
 (gnu packages haskell-xyz)
 (gnu packages image)
 (gnu packages imagemagick)
 (gnu packages llvm)
 (gnu packages machine-learning)
 (gnu packages pkg-config)
 (gnu packages protobuf)
 (gnu packages pulseaudio)
 (gnu packages video)
 (gnu packages web)
 (gnu packages xorg))

(define-public vcs-file?
  ;; Return true if the given file is under version control.
  (or (git-predicate (dirname (dirname (current-source-directory))))
      (const #t)))                      ;not in a Git checkout

(define-public guile-v4l2
  (package
    (name "guile-v4l2")
    (version "0.0.1-dev")
    (source (local-file "." "guile-v4l2-checkout"
                        #:recursive? #t
                        #:select? vcs-file?))
    (build-system gnu-build-system)
    (arguments
     (list
      #:make-flags
      #~(list (string-append "GUILE_CACHE=" #$output "/lib/guile/3.0/site-ccache")
              (string-append "GUILE_EXT=" #$output "/lib/guile/3.0/extensions")
              (string-append "GUILE_SITE=" #$output "/share/guile/site/3.0"))
      #:phases
      '(modify-phases %standard-phases
        ;; (add-after 'unpack 'build-reproducibly
        ;;   (lambda _
        ;;     (substitute* "doc/Makefile.am"
        ;;       (("\\$\\(DATE\\)") "1970-01-01"))))
        ;; (add-after 'unpack 'find-clearsilver
        ;;   (lambda* (#:key inputs #:allow-other-keys)
        ;;     (substitute* "configure.ac"
        ;;       (("/usr/local/include/ClearSilver")
        ;;        (string-append (assoc-ref inputs "clearsilver")
        ;;                       "/include/ClearSilver")))
        ;;     (substitute* "aiscm/Makefile.am"
        ;;       (("-lneo_utl" m)
        ;;        (string-append m " -lstreamhtmlparser")))
        ;;     (setenv "C_INCLUDE_PATH"
        ;;             (string-append (assoc-ref inputs "clearsilver")
        ;;                            "/include/ClearSilver:"
        ;;                            (or (getenv "C_INCLUDE_PATH") "")))))
        (add-after 'build 'load-extensions
          (lambda* (#:key outputs #:allow-other-keys)
            (substitute* (find-files "." ".*\\.scm")
              (("\\(load-extension \"libguile-aiscm-(.*)\" *\"(.*)\"\\)" _ a o)
               (string-append
                (object->string
                 `(or (false-if-exception
                       (load-extension
                        ,(string-append "libguile-aiscm-" a) ,o))
                      (load-extension
                       ,(string-append (assoc-ref outputs "out")
                                       "/lib/guile/"
                                       (effective-version)
                                       "/extensions/libguile-aiscm-"
                                       a
                                       ".so")
                       ,o))))))))
        (add-after 'unpack 'use-llvm-config
          (lambda _
            (substitute* "m4/ax_llvmc.m4"
              (("llvm-config-14") "llvm-config")
              ;; For some reason this library is not on the link list.
              (("(LLVM_LIBS=\"\\$\\(\\$ac_llvm_config_path --libs \\$1\\))\"" _ m)
               (string-append m " -lLLVMMCJIT\"")))

            ;; Because of this message:
            ;; symbol lookup error: ./.libs/libguile-aiscm-core.so: undefined symbol: LLVMInitializeX86TargetInfo
            ;; This probably needs to differ when building on architectures
            ;; other than x86_64.
            (substitute* "aiscm/Makefile.am"
              (("LLVM_LIBS\\)") "LLVM_LIBS) \
-lLLVMX86AsmParser -lLLVMX86CodeGen -lLLVMX86Desc -lLLVMX86Info"))))
        ;; Use Clang instead of GCC.
        (add-before 'configure 'prepare-build-environment
          (lambda _
            (setenv "AR" "llvm-ar")
            (setenv "NM" "llvm-nm")
            (setenv "CC" "clang")
            (setenv "CXX" "clang++"))))))
    (inputs
     (list clearsilver
           ffmpeg-4
           freeglut
           guile-3.0
           imagemagick
           libgc
           libjpeg-turbo
           libomp
           libxi
           libxmu
           libxpm
           libxt
           libxv
           mesa
           mjpegtools
           pandoc
           pulseaudio))
    (native-inputs
     (list clang-14
           llvm-14
           pkg-config
           autoconf
           automake
           gettext-minimal
           libtool
           which))
    (home-page "")
    (synopsis "From AIscm")
    (description "From AIscm.")
    (license license:gpl3+)))

guile-v4l2
