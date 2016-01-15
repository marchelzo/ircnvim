" Vim syntax file
" Language:     IRC
" Maintainer:   Bradley Garagan <bradgaragan@gmail.com>
" Last Change:  January 10, 2016

" Example of text you might expect to find in an IRC buffer:
" 
"  [04:17:34]     <marchelzo>  My nick is marchelzo.
"  [04:17:34]     !!!          /jion is not a valid command
"  [04:17:34]                  someuser has joined #vim

if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

syn match IrcTimestamp        '^ \[..:..:..\] '                     nextgroup=IrcNick,IrcWarning,IrcNotificationType
syn match IrcNick             '\s\+<\S\+>\s'                        contains=IrcMyNick nextgroup=IrcMessage
syn match IrcWarning          '\s\{,16}!!!\s'                       nextgroup=IrcMessage
syn match IrcNotificationType '\(\s\{16}\)\|\(\s\{,16}[^ !<]\+\s\)' contained nextgroup=IrcNotification
syn match IrcNotification     '.*$'                                 contained contains=IrcMentioned
syn match IrcMessage          '.*$'                                 contained contains=IrcMentioned

if exists('g:irc_nick')
    exe "syn match IrcMentioned        '" . n . "'                           contained"
    exe "syn match IrcMyNick           '\\s*<" . g:irc_nick . ">\\s*'        contained"
endif

hi! def link IrcAction           ErrorMsg
hi! def link IrcMessage          Normal
hi! def link IrcMentioned        Special
hi! def link IrcMyNick           Identifier
hi! def link IrcTimestamp        Comment
hi! def link IrcNick             String
hi! def link IrcWarning          WarningMsg
hi! def link IrcNotificationType Constant
hi! def link IrcNotification     Comment

let b:current_syntax = "irc"
