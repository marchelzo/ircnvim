" File:   ircnvim.vim --- IRC in Neovim
" Author: Bradley Garagan <bradgaragan@gmail.com>
"
" This plugin works by communiating via job control (:h job-control) with
" another process which acts as a server (marchelzo/ircnvim-rs).
"
" The process can send any of the following:
"
" STARTING
" UPDATE
" GOTO room
" STATUS statusline
" QUIT
" ERROR error_message
" NICK nickname
"
" And it will respond to all of the following:
"
" ROOM-PREVIOUS
" ROOM-NEXT
" INPUT text

augroup IrcGroup
    autocmd!
    autocmd BufLeave ~/.ircnvim/*/*         if !exists('b:irc_input_buffer') | call IrcUpdateBuffer() | endif
    autocmd TabEnter ~/.ircnvim/*/server    execute "normal! G\<C-w>j"
    autocmd TabEnter ~/.ircnvim/*/channel_* execute "normal! G\<C-w>j"
    autocmd TabEnter ~/.ircnvim/*/*_input   call s:UpdateBuffer()
augroup END

function! s:GotoRoom(room)
    let [roomname, filename] = split(a:room, ' ')
    silent! execute "silent! normal! \<C-w>k"
    silent! execute "silent! edit! " . filename

    let &l:statusline = roomname
    silent! setlocal nonumber
    silent! setlocal norelativenumber
    silent! setlocal autoread
    let g:irc_nick = t:irc_nick
    silent! setlocal syn=irc
    silent! setlocal linebreak
    silent! setlocal breakindent
    silent! setlocal breakindentopt=shift:31
    silent! setlocal breakat&
    silent! setlocal buftype=nofile
    silent! execute "silent! normal! G\<C-w>j"

    let bufname = filename . "_input"
    if !bufexists(bufname)
        silent! execute "silent! edit! " . bufname
    else
        silent! execute "silent! buffer! " . bufname
    endif

    if exists('b:irc_input_buffer')
        return
    endif

    let b:irc_input_buffer = 1
    silent! setlocal backspace=start,indent
    silent! setlocal nonumber
    silent! setlocal buftype=nofile
    silent! setlocal bufhidden=hide
    silent! setlocal norelativenumber
    silent! setlocal virtualedit=onemore
    silent! setlocal statusline=%!t:irc_status
    silent! setlocal noshowmode
    ino <buffer> <silent> <CR> <C-o>:call<Space>IrcInput()<CR>
    ino <buffer> <silent> <Up> <C-o>:exe<Space>"normal!<Space>k"<Space>\|<Space>startinsert!<CR>
    ino <buffer> <silent> <Down> <C-o>:exe<Space>"normal!<Space>j"<Space>\|<Space>startinsert!<CR>
    ino <buffer> <silent> <S-Left> <C-o>:call<Space>IrcRoomPrevious()<CR>
    ino <buffer> <silent> <S-Right> <C-o>:call<Space>IrcRoomNext()<CR>
    resize 1
    redraw!
endfunction

function! s:UpdateStatus(status)
    let t:irc_status = a:status
    redrawstatus
endfunction

function! s:UpdateBuffer()
    let m = mode()
    if !exists('b:irc_input_buffer')
        return
    endif
    silent! execute "normal! \<C-w>k"
    silent! execute "normal! \<C-w>j"
    if m == 'i'
        startinsert
        redraw
    endif
endfunction

function! s:Quit()
    stopinsert
    quit
    redraw!
    if exists('t:irc_error_msg')
        echohl ErrorMsg
        echo t:irc_error_msg . ' (press any key)'
        echohl None
        call getchar()
    endif
endfunction

function! s:HandleMessage(msg)
    if match(a:msg, "^GOTO ") != -1
        call s:GotoRoom(strpart(a:msg, 5))
    elseif match(a:msg, "^UPDATE$") != -1
        call s:UpdateBuffer()
    elseif match(a:msg, "^STATUS ") != -1
        call s:UpdateStatus(strpart(a:msg, 7))
    elseif match(a:msg, "^NICK ") != -1
        let t:irc_nick = strpart(a:msg, 5)
    elseif match(a:msg, "^ERROR ") != -1
        let t:irc_error_msg = strpart(a:msg, 6)
    elseif match(a:msg, "^QUIT$") != -1
        call s:Quit()
    endif
endfunction

function! s:IrcHandler(job_id, data, event)
  if a:event == 'stdout'
    for str in a:data
        call s:HandleMessage(str)
    endfor
  elseif a:event == 'stderr'
  else
    if !exists('t:irc_error_msg')
        let t:irc_error_msg = 'IRC process has terminated'
    endif
    call s:Quit()
  endif
endfunction

let s:callbacks = {
\ 'on_stdout': function('s:IrcHandler'),
\ 'on_stderr': function('s:IrcHandler'),
\ 'on_exit': function('s:IrcHandler')
\ }

function! IrcUpdateBuffer()
    silent! normal! G
    let n = line('$') + 1
    if n > 30
        silent! execute "read! tail -n +" . n . " %"
    else
        silent! edit!
    endif
    let g:irc_nick = t:irc_nick
    silent! setlocal syn=irc
    silent! normal! G0
endfunction

function! IrcInput()
    call jobsend(t:irc_job, ['INPUT ' . getline('.'), ''])
    silent! normal! G
    if getline('.') != ''
        silent! normal! o
    endif
endfunction

function! IrcRoomPrevious()
    call jobsend(t:irc_job, ['ROOM-PREVIOUS', ''])
endfunction

function! IrcRoomNext()
    call jobsend(t:irc_job, ['ROOM-NEXT', ''])
endfunction

function! IRC(...)
    unlet! t:irc_error_msg
    enew!
    setlocal splitbelow
    exe "normal! \<C-w>n"
    let t:irc_status = 'Connecting...'
    let t:irc_nick = ''
    if exists('a:1')
        let t:irc_job = jobstart(['/usr/bin/env', 'ircnvim', a:1], s:callbacks)
    else
        let t:irc_job = jobstart(['/usr/bin/env', 'ircnvim'], s:callbacks)
    endif
    resize 1
    startinsert!
endfunction

command! -nargs=* IRC call IRC(<f-args>)
