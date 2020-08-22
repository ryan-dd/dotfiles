syntax on
filetype plugin indent on
set nocompatible
inoremap jk <ESC>
set laststatus=2
set hidden " enable changing buffers without saving
set lazyredraw

let mapleader = " "
" Prevent leader key from inserting a space 
nnoremap <SPACE> <Nop> 

set number
set relativenumber
" Toggle relative line numbering
nnoremap <Leader>rr :set norelativenumber!<CR>
set tabstop=2 " number of visual spaces per TAB
set shiftwidth=2 " '>' uses spaces
set expandtab "insert spaces on tab
set list
set listchars=tab:>~ " Show tab characters as symbols
set cursorline
" set showmatch " highlights matching braces
set encoding=utf-8
" Disable modelines, bc its a possible security risk
set modelines=0
set nomodeline

nnoremap <Leader>s :w<CR>
nnoremap <Leader>q :q<CR>
nnoremap <Leader>z :source ~/.vimrc<CR> 
 
" backups
set undofile
set backup
set noswapfile
" set cached vim stuff in its own directory
set undodir=~/.vim/.undo//
set backupdir=~/.vim/.backup//
set directory=~/.vim/.swp//

"--- Copy and Paste ---
" use system clipboard as default copy buffer
set clipboard^=unnamed,unnamedplus
" yank relative path
nnoremap <leader>yf :let @+=expand("%")<CR>
" yank absolute path
nnoremap <leader>ya :let @+=expand("%:p")<CR>
" yank filename
nnoremap <leader>yt :let @+=expand("%:t")<CR>
" yank directory name
nnoremap <leader>yh :let @+=expand("%:p:h")<CR>

"--- Search and Navigation ---
set path+=** " adds all files in cwd for find
set wildmenu
set incsearch " when searching, put cursor on next occurrence
set ignorecase " ignore case when searching
set wildignorecase 
set wildignore+=**/*.pyc*/**
set wildignore+=**/*pycache*/**

" vim splits 
nnoremap <Leader>j <C-w>j 
nnoremap <Leader>k <C-w>k 
nnoremap <Leader>l <C-w>l 
nnoremap <Leader>h <C-w>h 
set splitbelow
set splitright

" Buffer commands
nnoremap <Leader>b :ls<CR>:b<SPACE>
nnoremap <Leader>n :bn<CR>
nnoremap <Leader>p :bp<CR>
nnoremap <Leader>d :bd

" search working directory
nnoremap <Leader>ff :vimgrep  **/* <Left><Left><Left><Left><Left><Left>
" search working directory with word under cursor
command! VIMGREP :execute 'vimgrep '.expand('<cword>').' **/*'
nnoremap <Leader>fw :VIMGREP<CR>

nnoremap <Leader>cc :cclose<CR>
nnoremap <Leader>co :copen<CR>
nnoremap <Leader>cn :cn<CR>
nnoremap <Leader>cp :cp<CR>

" rename in current buffers
nnoremap <leader>rn :execute 'bufdo %s/'.expand('<cword>').'//gec<Left><Left><Left><Left><Left>

"---Netrw settings---
let g:netrw_banner=0
" let g:netrw_liststyle=3 " tree view
let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro' " Set line numbers in netrw
let g:netrw_list_hide = '\(^\|\s\s\)\zs\.\S\+' " hide dotfiles in netrw
let g:netrw_fastbrowse=0 " turn off persistent hidden buffer behavior
nnoremap - :E<CR>
nnoremap <Leader>E :E .<CR>

"---Plugins---
call plug#begin('~/.vim/plugged')
    Plug 'mhinz/vim-signify'
    Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
    Plug 'junegunn/fzf.vim'
    Plug 'morhetz/gruvbox'
    Plug 'neoclide/coc.nvim', {'branch': 'release'}
call plug#end()
colorscheme gruvbox
set bg=dark
set updatetime=300

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" nmap <leader>rn <Plug>(coc-rename)
"don't give |ins-completion-menu| messages.
set shortmess+=c
set signcolumn=yes " always show signcolumns
" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


"------No-Plugin git utils------
" Print line numbers changed in current file from last commit 
command! GDN call s:show_line_nums_git_diff()
" highlight lines changed in current file from last commit
command! GDH call s:highlight_changed()
" quickfix with all git files changed
command! -nargs=1 Gdiff call s:get_diff_files(<q-args>)
command! CM call clearmatches()

nnoremap <leader>gh :GDH<CR>
nnoremap <leader>gc :CM<CR>
nnoremap <leader>gn :GDN<CR>

" vimdiff
command! Dtool :execute '!git difftool '.expand(@%)
nnoremap <leader>gd :Dtool<CR>
nnoremap <leader>gs :w!<CR>
nnoremap <leader>gq :qa!<CR>

function! s:show_line_nums_git_diff()
    let l:command = substitute("git blame -p filename | grep '0000' | awk '{print $3}'", "filename", expand(@%), "")
    echom(system(command))
endfunction

function! s:highlight_changed()
    call clearmatches()
    let l:command = substitute("git blame -p filename | grep '0000' | awk '{print $3}'", "filename", expand(@%), "")
    let line_nums = split(system(l:command), '\n')
    highlight GitChanged ctermbg=yellow guibg=yellow
    for numba in line_nums
        let m = matchaddpos("GitChanged", [[numba]])
    endfor
endfunction

let s:git_status_dictionary = {
      \ "A": "Added",
      \ "B": "Broken",
      \ "C": "Copied",
      \ "D": "Deleted",
      \ "M": "Modified",
      \ "R": "Renamed",
      \ "T": "Changed",
      \ "U": "Unmerged",
      \ "X": "Unknown"
      \ }

function! s:get_diff_files(rev)
  let title = 'Gdiff '.a:rev
  let command = 'git diff --name-status '.a:rev
  let lines = split(system(command), '\n')
  let items = []

  for line in lines
    let filename = matchstr(line, "\\S\\+$")
    let status = s:git_status_dictionary[matchstr(line, "^\\w")]
    let item = { "filename": filename, "text": status }

    call add(items, item)
  endfor

  let list = {'title': title, 'items': items}

  call setqflist([], 'r', list)

  copen
endfunction

" Open files in quicklist for bufdo commands
nnoremap <leader> oa :OpenAll<CR>
command! OpenAll call s:QuickFixOpenAll()
function! s:QuickFixOpenAll()
    if empty(getqflist())
        return
    endif
    let s:prev_value = ""
    for d in getqflist()
        let s:curr_val = bufname(d.bufnr)
        if (s:curr_val != s:prev_val)
            exec "edit " . s:curr_val
        endif
        let s:prev_val = s:curr_val
    endfor
endfunction
