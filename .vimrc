" Make vim more useful
set nocompatible

" Set extra options when running in GUI mode
if has("gui_running")
  set guioptions-=T
  set background=dark
  set guioptions+=e
  set t_Co=256
  set guitablabel=%M\ %t
endif

set guifont=Menlo\ 12

" Pathogen
execute pathogen#infect()

" Enable syntax highlighting
syntax on

" Enable filetype plugins
filetype plugin indent on

" Change mapleader
let mapleader = ","
let g:mapleader = ","

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Turn backup off, since most stuff is in SVN, git et.c anyway...
set backupdir=~/.cache/vim/backup
set directory=~/.cache/vim/swap
set undodir=~/.cache/vim/undo

" Set some junk
set autoindent smartindent copyindent                 " Auto/Smart/Copy indent from last line when starting new line.
set backspace=indent,eol,start
set encoding=utf-8 nobomb                             " BOM often causes trouble
set esckeys                                           " Allow cursor keys in insert mode.
set formatoptions=
set formatoptions+=c                                  " Format comments
set formatoptions+=r                                  " Continue comments by default
set formatoptions+=o                                  " Make comment when using o or O from comment line
set formatoptions+=q                                  " Format comments with gq
set formatoptions+=n                                  " Recognize numbered lists
set formatoptions+=2                                  " Use indent from 2nd line of a paragraph
set formatoptions+=l                                  " Don't break lines that are already long
set formatoptions+=1                                  " Break before 1-letter words
set gdefault                                          " By default add g flag to search/replace. Add g to toggle.
set hidden                                            " When a buffer is brought to foreground, remember undo history and marks.
set history=500                                       " Increase history from 20 default to 500
set hlsearch                                          " Highlight searches
set ignorecase                                        " Ignore case of searches.
set incsearch                                         " Highlight dynamically as pattern is typed.
set smartcase                                         " Ignore 'ignorecase' if search patter contains uppercase characters.
set lispwords+=defroutes                              " Compojure
set lispwords+=defpartial,defpage                     " Noir core
set lispwords+=defaction,deffilter,defview,defsection " Ciste core
set lispwords+=describe,it                            " Speclj TDD/BDD
set magic                                             " Enable extended regexes.
set mouse=a                                           " Enable moouse in all in all modes.
set noerrorbells                                      " Disable error bells.
set visualbell                                        " Use visual bell instead of audible bell (annnnnoying)
set nojoinspaces                                      " Only insert single space after a '.', '?' and '!' with a join command.
set nostartofline                                     " Don't reset cursor to start of line when moving around.
set nohidden                                          " close the buffer when I close a tab (I use tabs more than buffers)
set nowrap                                            " Do not wrap lines.
set nu                                                " Enable line numbers.
set ofu=syntaxcomplete#Complete                       " Set omni-completion method.
set report=0                                          " Show all changes.
set shortmess=atI                                     " Don't show the intro message when starting vim.
set showmode                                          " Show the current mode.
set scrolloff=3                                       " Start scrolling three lines before horizontal border of window.
set expandtab                                         " Use spaces instead of tabs
set shiftwidth=4                                      " The # of spaces for indenting.
set sidescrolloff=3                                   " Start scrolling three columns before vertical border of window.
set sidescroll=2                                      " if wrap is off, this is fasster for horizontal scrolling
set smarttab                                          " At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shiftwidth spaces.
set softtabstop=2                                     " Tab key results in 2 spaces
set tabstop=4                                         " a tab is four spaces
set splitbelow                                        " New window goes below
set splitright                                        " New windows goes right
set showcmd                                           " Show us the command we're typing
set showfulltag                                       " show full completion tags
set title                                             " Show the filename in the window titlebar.
set ttyfast                                           " Send more characters at a given time.
set ttymouse=xterm                                    " Set mouse type to xterm.
set undofile                                          " Persistent Undo.
set suffixes=.bak,~,.swp,.swo,.o,.d,.info,.aux,.log,.dvi,.pdf,.bin,.bbl,.blg,.brf,.cb,.dmg,.exe,.ind,.idx,.ilg,.inx,.out,.toc,.pyc,.pyd,.dll
set wildchar=<TAB>                                    " Character for CLI TAB-completion.
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj,*.min.js
set wildignore+=*/smarty/*,*/vendor/*,*/node_modules/*,*/.git/*,*/.hg/*,*/.svn/*,*/.sass-cache/*,*/log/*,*/tmp/*,*/build/*,*/ckeditor/*
set wildmenu                                          " Hitting TAB in command mode will show possible completions above command line.
set wildmode=list:longest                             " Complete only until point of ambiguity.
set winminheight=0                                    " Allow splits to be reduced to a single line.
set wrapscan                                          " Searches wrap around end of file

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Status Line
set laststatus=2                                      " Always show status line
" hi User1 guibg=#455354 guifg=fg      ctermbg=238 ctermfg=fg  gui=bold,underline cterm=bold,underline term=bold,underline
" hi User2 guibg=#455354 guifg=#CC4329 ctermbg=238 ctermfg=196 gui=bold           cterm=bold           term=bold
"set statusline=\ %n\ \%1*\ %<%.99t%2*\ %h%w%m%r\ %*%y\ [%{&ff}\ →\ %{strlen(&fenc)?&fenc:'No\ Encoding'}]%=%-16(\ L%l,C%c\ %)%P


let g:Powerline_symbols='unicode'

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

if !exists('g:airline_powerline_fonts')
  let g:airline#extensions#tabline#left_sep = ' '
  let g:airline#extensions#tabline#left_alt_sep = '|'

  let g:airline_left_sep          = '▶'
  let g:airline_left_alt_sep      = '»'
  let g:airline_right_sep         = '◀'
  let g:airline_right_alt_sep     = '«'

  let g:airline#extensions#branch#prefix     = '⤴' "➔, ➥, ⎇
  let g:airline#extensions#readonly#symbol   = '⊘'
  let g:airline#extensions#linecolumn#prefix = '¶'
  let g:airline#extensions#paste#symbol      = 'ρ'

  let g:airline_symbols.linenr = '␊'
  let g:airline_symbols.branch = '⎇'
  let g:airline_symbols.paste = 'ρ'
  let g:airline_symbols.whitespace = 'Ξ'
else
  let g:airline_theme = 'hybrid'

  let g:airline#extensions#tabline#left_sep = ''
  let g:airline#extensions#tabline#left_alt_sep = ''

  " powerline symbols
  let g:airline_left_sep = ''
  let g:airline_left_alt_sep = ''
  let g:airline_right_sep = ''
  let g:airline_right_alt_sep = ''

  let g:airline_symbols.branch = ''
  let g:airline_symbols.readonly = ''
  let g:airline_symbols.linenr = ''
endif

" Powerline.VIM (binding)
"set rtp+=$HOME/.local/lib/python2.7/site-packages/powerline/bindings/vim

" Speed up viewport scrolling
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" Faster split resizing (+,-)
if bufwinnr(1)
  map + <C-W>+
  map - <C-W>-
endif

" Better split switching (Ctrl-j, Ctrl-k, Ctrl-h, Ctrl-l)
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-H> <C-W>h
map <C-L> <C-W>l

" Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
nmap <M-j> mz:m+<cr>`z
nmap <M-k> mz:m-2<cr>`z
vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

if has("mac") || has("macunix")
  nmap <D-j> <M-j>
  nmap <D-k> <M-k>
  vmap <D-j> <M-j>
  vmap <D-k> <M-k>
endif

" Sudo write (,W)
noremap <leader>W :w !sudo tee %<CR>

" Remap :W to :w
command W w

" Better mark jumping (line + col)
nnoremap ' `

" Hard to type things
"imap >> →
"imap << ←
"imap ^^ ↑
"imap VV ↓
"imap aaa λ

" Toggle show tabs and trailing spaces (,c)
set lcs=eol:¬,tab:›\ ,trail:·,extends:>,precedes:<
"set fcs=fold:-
nnoremap ,c <Esc>:set list!<CR>

" Clear last search (,qs)
map ,qs <Esc>:noh<CR>

" Fix page up and down
map <PageUp> <C-U>
map <PageDown> <C-D>
imap <PageUp> <C-O><C-U>
imap <PageDown> <C-O><C-D>

" Tab Navgations?
set switchbuf=usetab
imap <C-PageUp> :tabprevious<CR>
imap <C-PageDown> :tabNext<CR>
nmap <C-PageUp> :tabprevious<CR>
nmap <C-PageDown> :tabNext<CR>

" Pencil.VIM
let g:pencil#wrapModeDefault = 'hard'   " or 'soft'

augroup pencil
  autocmd!
  autocmd FileType markdown,mkd,md call pencil#init()
  autocmd FileType textile call pencil#init()
  autocmd FileType text call pencil#init({'wrap': 'hard'})
augroup END

" NeoComplCache.VIM
let g:neocomplcache_enable_at_startup = 1
" Use smartcase.
let g:neocomplcache_enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplcache_min_syntax_length = 3

" Multiple-cursor.VIM
let g:multi_cursor_use_default_mapping=0
" Default mapping
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

