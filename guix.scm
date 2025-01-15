(define-module (guile-aiscm)
 #:use-module (guix)
 #:use-module (guix build-system gnu)
 #:use-module (guix git-download)                    ;for ‘git-predicate’
 #:use-module ((guix licenses) #:prefix license:)
 #:use-module (gnu packages autotools)
 #:use-module (gnu packages base)
 #:use-module (gnu packages bdw-gc)
 #:use-module (gnu packages gettext)
 #:use-module (gnu packages gl)
 #:use-module (gnu packages guile)
 #:use-module (gnu packages haskell-xyz)
 #:use-module (gnu packages image)
 #:use-module (gnu packages imagemagick)
 #:use-module (gnu packages llvm)
 #:use-module (gnu packages machine-learning)
 #:use-module (gnu packages pkg-config)
 #:use-module (gnu packages protobuf)
 #:use-module (gnu packages pulseaudio)
 #:use-module (gnu packages video)
 #:use-module (gnu packages web)
 #:use-module (gnu packages xorg))

(define-public vcs-file?
  ;; Return true if the given file is under version control.
  (or (git-predicate (dirname (dirname (current-source-directory))))
      (const #t)))                      ;not in a Git checkout

(define-public guile-aiscm
  (package
    (name "guile-aiscm")
    (version "0.26.1-dev")
    (source (local-file "." "aiscm-checkout"
                        #:recursive? #t
                        #:select? vcs-file?))
    ;; (source (origin
    ;;           (method git-fetch)
    ;;           (uri (git-reference
    ;;                 (url "https://github.com/wedesoft/aiscm")
    ;;                 (commit "v0.25.2")))
    ;;           (file-name (git-file-name name version))
    ;;           (sha256
    ;;            (base32
    ;;             "1sagpxwrqxkn5b9zqzd07c9r7swmw45q672pa8fy6s71iw6a0x77"))))
    (build-system gnu-build-system)
    (arguments
     (list
      #:make-flags
      #~(list (string-append "GUILE_CACHE=" #$output "/lib/guile/3.0/site-ccache")
              (string-append "GUILE_EXT=" #$output "/lib/guile/3.0/extensions")
              (string-append "GUILE_SITE=" #$output "/share/guile/site/3.0"))
      #:phases
      '(modify-phases %standard-phases
        (add-after 'unpack 'build-reproducibly
          (lambda _
            (substitute* "doc/Makefile.am"
              (("\\$\\(DATE\\)") "1970-01-01"))))
        (add-after 'unpack 'find-clearsilver
          (lambda* (#:key inputs #:allow-other-keys)
            (substitute* "configure.ac"
              (("/usr/local/include/ClearSilver")
               (string-append (assoc-ref inputs "clearsilver")
                              "/include/ClearSilver")))
            (substitute* "aiscm/Makefile.am"
              (("-lneo_utl" m)
               (string-append m " -lstreamhtmlparser")))
            (setenv "C_INCLUDE_PATH"
                    (string-append (assoc-ref inputs "clearsilver")
                                   "/include/ClearSilver:"
                                   (or (getenv "C_INCLUDE_PATH") "")))))
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
        ;; This test fails because our version of tensorflow is too old
        ;; to provide tf-string-length.
        (add-after 'unpack 'disable-broken-test
          (lambda _
            (substitute* "tests/test_tensorflow.scm"
              (("\\(test-eqv \"determine string length" m)
               (string-append "#;" m)))))
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
           pulseaudio
           tensorflow))
    (native-inputs
     (list clang-14
           llvm-14
           pkg-config
           protobuf-c-for-aiscm
           autoconf
           automake
           gettext-minimal
           libtool
           which))
    (home-page "https://wedesoft.github.io/aiscm/")
    (synopsis "Guile extension for numerical arrays and tensors")
    (description "AIscm is a Guile extension for numerical arrays and tensors.
Performance is achieved by using the LLVM JIT compiler.")
    (license license:gpl3+)))

guile-aiscm
