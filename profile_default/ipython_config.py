c = get_config()
c.TerminalInteractiveShell.editor = u'vim'  # Use vim as the editor.
c.TerminalInteractiveShell.readline_parse_and_bind = \
        ['tab: complete',
         '"\\C-l": clear-screen',
         'set show-all-if-ambiguous off',  # only change from the defaults
         '"\\C-o": tab-insert',
         '"\\C-r": reverse-search-history',
         '"\\C-s": forward-search-history',
         '"\\C-p": history-search-backward',
         '"\\C-n": history-search-forward',
         '"\\e[A": history-search-backward',
         '"\\e[B": history-search-forward',
         '"\\C-k": kill-line',
         '"\\C-u": unix-line-discard']
