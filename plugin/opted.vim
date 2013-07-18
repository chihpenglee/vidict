" opted.vim
" Author:      Dorai Sitaram
" URL:         http://www.ccs.neu.edu/~dorai/vidict/vidict.html
" Last Change: 2004-04-08 

" Plugin for consulting the Online Plain Text English Dictionary
" (OPTED).  OPTED may be obtained from
" http://www.mso.anu.edu.au/~ralph/OPTED

" To use: Set the vim global variable g:opted_dir to the pathname
" of the directory containing the OPTED HTML files.  If you don't set
" g:opted_dir, it will be assumed to be the directory v003 in your home
" directory.

func! s:opted_html_to_txt(in, out)
  exec 'e ' . a:out
  setl ma
  0,$d
  exec 'r ' . a:in
  "setl tw=55
  0i
! The Online Plain Text English Dictionary, OPTED, v0.03,
! compiled by Ralph S. Sutherland, http://www.mso.anu.edu.au/~ralph/OPTED,
! from the Project Gutenberg etext of 
! the 1913 edition of Webster's Unabridged Dictionary

.
  g#^</\?[HTMB]#d
  %s#</\?B>#*#g
  %s#^<P>#\r#g
  %s#</\?[PI]>##g
  0
  norm }VGgq
  sil! w
  bd
endfunc

func! s:make_opted_txt_files()
  let currdir = getcwd()
  exec 'lcd ' . g:opted_dir
  let more_sav = &more
  set nomore
  sil! e wb1913_start.txt
  setl ma
  0,$d
  i
  You have opened the Online Plain Text English Dictionary (OPTED).
  Use Vim tag commands (:help tag) to search for headwords in this window.
  For example,     :tj lexicon
            or     :tj /lexicon
.
  0
  sil! w

  let htmlfiles = glob('wb1913_*.html')
  let htmlfiles = substitute(htmlfiles, '\n', ' ', 'g')
  while htmlfiles !~ '^\s*$'
    let in = substitute(htmlfiles, '^\s*\([^ ]\+\)\s*.*$', '\1', '')
    let htmlfiles = substitute(htmlfiles, '^\s*[^ ]\+\s*\(.*\)$', '\1', '')
    let out = substitute(in, '\.html$', '.txt', '')
    echo 'Converting ' . in . ' to ' . out . ' ...'
    sil! call s:opted_html_to_txt(in, out)
  endwhile

  b wb1913_start.txt
  sil! helptags %:p:h
  bd

  let &more = more_sav
  exec 'lcd ' . currdir
  return 1
endfunc

func! Delete_prev_opted_buf()
  if g:dict_buf_nr > 0
    let w = bufwinnr(g:dict_buf_nr)
    if w > 0
      let b = winbufnr(w)
      if b > 0
        exec 'bd ' . b
      endif
    endif
  endif
endfunc

func! Browse_opted()
	"add a variable s:word
	let s:word = expand('<cword>')
  let madep = 0
  if !exists('g:opted_dir')
    let g:opted_dir = expand("~/v003")
  endif
  if !filereadable(expand(g:opted_dir . '/tags'))
    let madep = s:make_opted_txt_files()
  else
    let madep = 1
  endif
  if !madep
    return
  endif
  exec 'sp ' . g:opted_dir . '/wb1913_start.txt'
  res 5

  " jump to definitions
  exec 'tj ' . s:word
endfunc

"nmap gm :call Browse_opted()<cr>:tj<space>
nmap gm :call Browse_opted()<cr><cr>

let g:dict_buf_nr = 0

au bufread wb1913_*.txt setl bh=wipe noma |
      \ call Delete_prev_opted_buf() |
      \ let g:dict_buf_nr = bufnr('%')

"au bufleave wb1913_*.txt call Delete_prev_opted_buf()
