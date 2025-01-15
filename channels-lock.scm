(list (channel
       (inherit %default-guix-channel)
       (url "https://codeberg.org/guix/guix-mirror")
       (branch "master")
       (commit
        "ede407920553f5d1ec58944db949ae13e94c6c56"))
      ;; (channel
      ;;  (name 'eadt)
      ;;  (introduction
      ;;   (make-channel-introduction
      ;;    "dd67b1d76ad17d4a06a91010caebff1402bad018"
      ;;    (openpgp-fingerprint
      ;;     "B724 2743 FCCF 36F8 E594  2C28 1220 B298 34D4 EEC2")))
      ;;  (url "https://gitlab.com/wehlutyk/eadt-channel")
      ;;  (branch "main")
      ;;  (commit
      ;;   "7d6b2c166d3a75e895f9c877bac7123415c6f952"))
      )

;; Local Variables:
;; mode: lisp-data
;; End:
