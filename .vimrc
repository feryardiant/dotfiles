" Make vim more useful
set nocompatible

" Enable filetype plugins
filetype plugin indent on

" Enable syntax highlighting
syntax enable

" Change mapleader
let mapleader = " "
let g:mapleader = " "

" Vim color scheme http://vimcolors.com/
set t_Co=256
set termguicolors

set mouse=a   " Enable moouse in all in all modes
set clipboard=unnamedplus
set conceallevel=3

set noerrorbells   " Disable error bells
set visualbell     " Use visual bell instead of audible bell (annnnnoying)
set nojoinspaces   " Only insert single space after a '.', '?' and '!' with a join command
set nostartofline  " Don't reset cursor to start of line when moving around

set confirm   " Confirm before exit if file has changed
set nohidden  " Close the buffer when tab is closed
set nowrap    " Do not wrap lines

set ffs=unix,dos,mac    " Use Unix as the standard file type
set colorcolumn=80,100,120

set formatoptions=
set formatoptions+=c  " Format comments
set formatoptions+=r  " Continue comments by default
set formatoptions+=o  " Make comment when using o or O from comment line
set formatoptions+=q  " Format comments with gq
set formatoptions+=n  " Recognize numbered lists
set formatoptions+=2  " Use indent from 2nd line of a paragraph
set formatoptions+=l  " Don't break lines that are already long
set formatoptions+=1  " Break before 1-letter words

set nu relativenumber   " Enable line numbers
set cursorline          " Highlight line under the cursor

" Persistent Undo
set undofile
set undolevels=10000

set ruler        " Show cursor position
set noshowmode   " Hide the current mode
set report=0     " Show all command reports
set updatetime=50

" Completion
set wildmenu
set wildmode=longest:full,full
set wildchar=<TAB>
set completeopt=menu,menuone,noselect
set showfulltag  " Show full completion tags

" Scrolling
set scrolloff=5      " Start scrolling three lines before horizontal border of window
set sidescrolloff=3  " Start scrolling three columns before vertical border of window

" Indentation
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

" Auto/Smart/Copy indent from last line when starting new line
set autoindent smartindent copyindent
set backspace=indent,eol,start

" Searches
set hlsearch    " Highlight searches
set incsearch   " Highlight dynamically as pattern is typed
set ignorecase  " Ignore case of searches
set smartcase   " Ignore 'ignorecase' if search patter contains uppercase characters
set wrapscan    " Searches wrap around end of file

" Window splitting
set splitbelow  " New window goes below
set splitright  " New windows goes right

" Toggle show tabs and trailing spaces (,c)
set list
set listchars=eol:¬,tab:→\ ,trail:·,extends:…,precedes:…
set fillchars=foldopen:,foldclose:,vert:│,fold:\ ,foldsep:\ ,diff:-

set suffixes=.bak,~,.cache,.swp,.swo,.o,.d,.info,.aux,.dvi,.bin,.cb,.dmg,.exe,.ind,.idx,.inx,.out,.toc,.pyc,.pyd,.dll
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.pdf,*.o,*.obj,*.min.js
set wildignore+=*/smarty/*,*/vendor/*,*/node_modules/*,*/.git/*,*/.hg/*,*/.svn/*,*/.sass-cache/*

nmap <ESC> :noh<CR> " Clear search highlight
imap <ESC> :noh<CR><Esc> " Clear search highlight

" Move lines - use ALT+J/K to move line up and down
nnoremap <A-j> :move+1<CR>==         " Move lines down
nnoremap <A-k> :move-2<CR>==         " Move lines up
inoremap <A-j> <Esc>:move+1<CR>==gi  " Move lines down
inoremap <A-k> <Esc>:move-2<CR>==gi  " Move lines up
vnoremap <A-j> :move'>+1<CR>gv=gv      " Move lines down
vnoremap <A-k> :move'<-2<CR>gv=gv      " Move lines up

" Split navigation - use <leader>H/J/K/L instead of CTRL+H/J/K/L to navigate window
nnoremap <leader>h <C-w>h " Go to left window
nnoremap <leader>j <C-w>j " Go to window below
nnoremap <leader>k <C-w>k " Go to window above
nnoremap <leader>l <C-w>l " Go to right window

" Resize window - Use CTRL + arrow keys
nmap <A-Up> :resize+2<CR>              " Increase window height
nmap <A-Down> :resize-2<CR>            " Decrease window height
nmap <A-Left> :vertical resize-2<CR>   " Decrease window width
nmap <A-Right> :vertical resize+2<CR>  " Increase window width

" Keep cursor in the middle while in search results
nmap n nzzzv
nmap N Nzzzv

" Better indenting
vmap < <gv
vmap > >gv

" Copy to system clipboard
noremap <leader>y \"+y'
noremap <leader>Y \"+Y'

" Actual delete word
noremap <leader>d \"_d'

" Make behavior more like common editors
inoremap <S-Left> <Esc>vb  " Select character left
inoremap <S-Right> <Esc>ve " Select character right

" Buffer controls - Use <leader>[/] to navigate between buffers
nnoremap <leader>[ :bprevious " Previous Buffer
nnoremap <leader>] :bnext     " Next Buffer

" Tab controls - Use <leader>{/} to navigate between tabs
noremap <leader>{ :tabprevious " Previous Tab
noremap <leader>} :tabnext     " Next Tab
noremap <A-w> :tabclose        " Close Tab
