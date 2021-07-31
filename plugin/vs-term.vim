let g:foo = 0
let g:term_id = 0
let g:term_exists = 0
let g:term_shell = "bash"

function Hide_prev_term()
  let l:qlist = []
  windo if &buftype == "terminal" | call add(l:qlist, winnr()) | endif
  for q in l:qlist
    execute q . "hide" 
  endfor
  unlet l:qlist
endfunction

function Hide_prev_term_all()
  tabdo call Hide_prev_term()
endfunction

function New_term()
  let l:count = 0
  tabdo if l:count == 0 | 
	\ bo new | 
	\ exec printf("edit term:///bin/%s",g:term_shell) | 
	\ let g:foo = bufnr('%') |
	\ let g:term_id = b:terminal_job_id | 
	\ exec 'resize ' 12 |
	\ wincmd k | 
	\ let l:count += 1 | 
	\ else | 
	\ execute "bo sbuffer" g:foo |
	\ exec 'resize ' 12 |
	\ wincmd k | 
	\ let l:count += 1 | 
	\ endif
  tabdo let t:is_term_open = 1
  let g:term_exists = 1
  unlet l:count
endfunction

function Hide_term()
  let l:term_win_num = 0
  if g:term_exists == 1
    if t:is_term_open == 1
      windo if bufnr('%') == g:foo | let l:term_win_num = winnr() | endif
      execute l:term_win_num . "hide"
      let t:is_term_open = 0
    endif
  endif
  unlet l:term_win_num
endfunction

function Hide_term_all()
  tabdo call Hide_term()
endfunction

function Show_term()
  if g:term_exists == 1
    if t:is_term_open == 0
      execute "bo sbuffer" g:foo
      exec 'resize ' 12
      wincmd k
      let t:is_term_open = 1
    endif
  endif
endfunction

function Show_term_all()
  tabdo call Show_term()
endfunction

autocmd FileType python let b:f = "python"
autocmd FileType java let b:f = "java"
autocmd FileType c let b:f = "c"
autocmd FileType sh let b:f = "sh"
autocmd FileType cpp let b:f = "cpp"

function Run_program()
  let l:program_path = expand('%:p')
  let l:term_win_num = 0
  let l:program_win_num = winnr()
  if g:term_exists == 0
    call New_term()
  endif
  if t:is_term_open == 0
    call Show_term()
  endif
  windo if bufnr('%') == g:foo | let l:term_win_num = winnr() | endif
  exec l:program_win_num . "wincmd w"
  let l:f = b:f
  exec l:term_win_num . "wincmd w"
  if l:f == "python"
    call chansend(g:term_id, "python " . l:program_path . "\n")
  elseif l:f == "c"
    call chansend(g:term_id, "gcc " . l:program_path . " && " . "./a.out" . "\n") 
  elseif l:f == "sh"
    call chansend(g:term_id, "chmod +x ". l:program_path . " && ." . l:program_path . "\n") 
  elseif l:f == "cpp"
    call chansend(g:term_id, "g++ " . l:program_path . " && " . "./a.out" . "\n") 
  endif
  startinsert
  exec l:program_win_num . "wincmd w"
  "autocmd FileType python call chansend(g:term_id, "python " . l:program_path . "\n")  
endfunction

function IRun_program()
  let l:program_path = expand('%:p')
  let l:term_win_num = 0
  let l:program_win_num = winnr()
  if g:term_exists == 0
    call New_term()
  endif
  if t:is_term_open == 0
    call Show_term()
  endif
  windo if bufnr('%') == g:foo | let l:term_win_num = winnr() | endif
  exec l:program_win_num . "wincmd w"
  let l:f = b:f
  exec l:term_win_num . "wincmd w"
  if l:f == "python"
    call chansend(g:term_id, "python " . l:program_path . "\n")
  elseif l:f == "c"
    call chansend(g:term_id, "gcc " . l:program_path . " && " . "./a.out" . "\n") 
  elseif l:f == "sh"
    call chansend(g:term_id, "chmod +x ". l:program_path . " && ." . l:program_path . "\n") 
  elseif l:f == "cpp"
    call chansend(g:term_id, "g++ " . l:program_path . " && " . "./a.out" . "\n") 
  endif
  startinsert
  "autocmd FileType python call chansend(g:term_id, "python " . l:program_path . "\n")  
endfunction

function Clear_term()
  let l:term_win_num = 0
  let l:program_win_num = winnr()
  if g:term_exists == 1
    if t:is_term_open == 1
      windo if bufnr('%') == g:foo | let l:term_win_num = winnr() | endif
      exec l:program_win_num . "wincmd w"
      exec l:term_win_num . "wincmd w"
      call chansend(g:term_id, "clear" . "\n")
      startinsert
      exec l:program_win_num . "wincmd w"
    endif
  endif
endfunction

autocmd TabNew * let t:is_term_open = 0|call Show_term()

function Focus_term()
  let l:term_win_num = 0
  if g:term_exists == 0
    call New_term()
  endif
  if t:is_term_open == 0
    call Show_term()
  endif
  windo if bufnr('%') == g:foo | let l:term_win_num = winnr() | endif
  exec l:term_win_num . "wincmd w"
  startinsert
endfunction

" My key bindings
nnoremap tt :call Focus_term()<CR>
nnoremap tc :call Clear_term()<CR>
