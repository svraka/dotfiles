(setq native-comp-deferred-compilation nil)

(if (boundp 'native-comp-eln-load-path)
    (setcar native-comp-eln-load-path (expand-file-name "eln-cache/"
                                                        user-emacs-directory)))
