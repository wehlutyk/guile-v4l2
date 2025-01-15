(list (channel
       (inherit %default-guix-channel)
       (url "https://codeberg.org/guix/guix-mirror"))
      (channel
       (name 'eadt)
       (introduction
        (make-channel-introduction
         "dd67b1d76ad17d4a06a91010caebff1402bad018"
         (openpgp-fingerprint
          "B724 2743 FCCF 36F8 E594  2C28 1220 B298 34D4 EEC2")))
       (url "https://gitlab.com/wehlutyk/eadt-channel")))

;; Local Variables:
;; mode: lisp-data
;; End:
