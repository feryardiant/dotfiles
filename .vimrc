" Make vim more useful
set nocompatible

" Enable filetype plugins
filetype plugin indent on

" Pathogen
call plug#begin()

Plug 'mattn/emmet-vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'tpope/vim-fugitive'
Plug 'gregsexton/gitv'
Plug 'tpope/vim-surround'
Plug 'dense-analysis/ale'
Plug 'editorconfig/editorconfig-vim'
Plug 'kien/ctrlp.vim', { 'on': 'CtrlP' }
Plug 'Lokaltog/vim-easymotion'
Plug 'godlygeek/tabular'
Plug 'ervandew/supertab'
Plug 'reedes/vim-pencil'
Plug 'terryma/vim-multiple-cursors'
Plug 'joonty/vdebug'
Plug 'matze/vim-move'
Plug 'posva/vim-vue', { 'for': 'vue' }

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'Yggdroot/indentLine'
Plug 'ayu-theme/ayu-vim'
Plug 'ryanoasis/vim-devicons'

Plug 'shawncplus/phpcomplete.vim', { 'for': 'php' }

if has('nvim')
  Plug 'wvffle/vimterm'
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif

call plug#end()

" Enable syntax highlighting
syntax on

" Set extra options when running in GUI mode
if has('gui_running')
  set guifont=Menlo\ for\ Powerline

  set guioptions-=T
  set guioptions+=e
  set guitablabel=%M\ %t

  set t_Co=256
else
  " highlight Comment ctermfg=Gray
endif

" Vim color scheme http://vimcolors.com/
set termguicolors
"set background=dark

try
  let ayucolor="dark"     " light, dark & mirage
  colorscheme ayu
catch /^Vim\%((\a\+)\)\=:E185/
  " deal with it
endtry

hi Normal guibg=#000000
"hi NonText guibg=#000000 ctermbg=000

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
set undofile                                          " Persistent Undo.
set suffixes=.bak,~,.swp,.swo,.o,.d,.info,.aux,.log,.dvi,.pdf,.bin,.bbl,.blg,.brf,.cb,.dmg,.exe,.ind,.idx,.ilg,.inx,.out,.toc,.pyc,.pyd,.dll
set wildchar=<TAB>                                    " Character for CLI TAB-completion.
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj,*.min.js
set wildignore+=*/smarty/*,*/vendor/*,*/node_modules/*,*/.git/*,*/.hg/*,*/.svn/*,*/.sass-cache/*,*/log/*,*/tmp/*,*/build/*,*/ckeditor/*
set wildmenu                                          " Hitting TAB in command mode will show possible completions above command line.
set wildmode=list:longest                             " Complete only until point of ambiguity.
set winminheight=0                                    " Allow splits to be reduced to a single line.
set wrapscan                                          " Searches wrap around end of file

if !has('nvim')
  set esckeys                                         " Allow cursor keys in insert mode.
  set ttymouse=xterm                                  " Set mouse type to xterm.

  nnoremap <silent> <ESC>OA <UP>
  nnoremap <silent> <ESC>OB <DOWN>
  nnoremap <silent> <ESC>OC <RIGHT>
  nnoremap <silent> <ESC>OD <LEFT>
  inoremap <silent> <ESC>OA <UP>
  inoremap <silent> <ESC>OB <DOWN>
  inoremap <silent> <ESC>OC <RIGHT>
  inoremap <silent> <ESC>OD <LEFT>
endif

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

nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
vnoremap <A-k> :m '<-2<CR>gv=gv

if has("mac") || has("macunix")
  nmap <D-j> <M-j>
  nmap <D-k> <M-k>
  vmap <D-j> <M-j>
  vmap <D-k> <M-k>
endif

" Sudo write (,W)
noremap <leader>W :w !sudo tee %<CR>

if !has('nvim')
  " Remap :W to :w
  command W w
endif

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
map <Esc> :noh<CR>

" Fix page up and down
"map <PageUp> <C-U>
"map <PageDown> <C-D>
"imap <PageUp> <C-O><C-U>
"imap <PageDown> <C-O><C-D>

" Tab Navgations?
set switchbuf=usetab
"map <C-PageUp>    :bprev!<CR>
"map <C-PageDown>  :bnext!<CR>
map <C-t>         :tabnew<CR>
map <C-w>         :tabclose<CR>
"inoremap <C-PageUp>    <Esc>:tabprevious<CR>i
"inoremap <C-PageDown>  <Esc>:tabnext<CR>i
inoremap <C-t>         <Esc>:tabnew<CR>i
" inoremap <C-w>         <Esc>:tabclose<CR>i

" Pencil.VIM
let g:pencil#wrapModeDefault = 'hard'   " or 'soft'

augroup pencil
  autocmd!
  autocmd FileType markdown,mkd,md call pencil#init()
  autocmd FileType textile call pencil#init()
  autocmd FileType text call pencil#init({'wrap': 'hard'})
augroup END

"" NERDTree configuration
let g:NERDTreeShowHidden = 1
let g:NERDTreeChDirMode = 2
let g:NERDTreeIgnore = ['\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder = ['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:NERDTreeShowBookmarks = 1
let g:nerdtree_tabs_focus_on_files = 1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeMapOpenInTab = '<C-ENTER>'
let g:NERDTreeWinSize = 36

nnoremap <silent> <F2> :NERDTreeFind<CR>
noremap <F3> :NERDTreeToggle<CR>

" CtrlP Settings
let g:ctrlp_custom_ignore='\v[\/](node_modules|bower_components|vendor)|(\.(git|hg|svn|vscode))'

" Deoplete.VIM
let g:deoplete#enable_at_startup = 1

" Multiple-cursor.VIM
let g:multi_cursor_use_default_mapping=0

" Default mapping
let g:multi_cursor_prev_key = '<C-n>'
let g:multi_cursor_next_key = '<C-S-N>'
let g:multi_cursor_skip_key = '<C-x>'
let g:multi_cursor_quit_key = '<Esc>'

"let g:Powerline_symbols = 'unicode'
let g:airline_powerline_fonts = 1

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_theme='wombat'
let g:airline#extensions#tabline#enabled=1

let g:airline_symbols.whitespace = 'Ξ'
let g:airline_symbols.linenr = '¶'
let g:airline_symbols.linenr = 'Ξ'
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''

set colorcolumn=80,100
"set ruler

" Status Line
set laststatus=2  " Always show status line
"set statusline=\ %n\ \%1*\ %<%.99t%2*\ %h%w%m%r\ %*%y\ [%{&ff}\ →\ %{strlen(&fenc)?&fenc:'No\ Encoding'}]%=%-16(\ L%l,C%c\ %)%P

set statusline=%#warningmsg#
set statusline=%*

" Linters Settings
" See https://github.com/dense-analysis/ale
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'jsx': ['stylelint', 'eslint'],
\   'vue': ['eslint'],
\}
let g:ale_pattern_options = {
\   '\.min\.js$': {'ale_linters': [], 'ale_fixers': []},
\   '\.min\.css$': {'ale_linters': [], 'ale_fixers': []},
\}

let g:ale_pattern_options_enabled = 1

let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
" let g:ale_lint_on_enter = 0

let g:ale_sign_error = '»'
let g:ale_sign_warning = '›'

"let g:ale_open_list = 1
"let g:ale_keep_list_window_open = 1
let g:ale_sign_column_always = 1
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%severity%:%linter%] %s'

let g:airline#extensions#ale#enabled = 1
let g:ale_javascript_eslint_suppress_missing_config = 1

" VimTerm Settings
if has('nvim')
  tnoremap <F12> <C-\><C-n> :call vimterm#toggle() <CR>
else
  nnoremap <F12> :call vimterm#toggle() <CR>
endif

" Powerline.VIM (binding)
"set rtp+=$HOME/.local/lib/python2.7/site-packages/powerline/bindings/vim
