" Make vim more useful
set nocompatible

" Enable filetype plugins
filetype plugin indent on

" Enable syntax highlighting if available
if has('syntax')
  syntax enable
endif

" Change mapleader
let mapleader=" "
let g:mapleader=" "

function s:plug_download_dir()
  if !empty($LOCALAPPDATA)
    return $LOCALAPPDATA.'/vim-plug'
  endif

  if !empty($XDG_DATA_HOME)
    return $XDG_DATA_HOME.'/vim-plug'
  endif

  return $HOME.'/.local/share/vim-plug'
endfunction

let s:plug_home_dir=s:plug_download_dir()
let s:vim_home_dir=$HOME . '/.vim'

if !filereadable(s:plug_home_dir.'/plug.vim')
  let s:plug_download_url='https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  call system('curl -fLo '.s:plug_home_dir.'/plug.vim --create-dirs '.s:plug_download_url)

  if !isdirectory(s:plug_home_dir.'/plugged')
    call mkdir(s:plug_home_dir.'/plugged', 'p')
  endif
endif

if !isdirectory(s:vim_home_dir.'/autoload')
  call mkdir(s:vim_home_dir.'/autoload', 'p')

  if !filereadable(s:vim_home_dir.'/autoload/plug.vim')
    call system('ln -s '.s:plug_home_dir.'/plug.vim '.s:vim_home_dir.'/autoload/plug.vim')
  endif

  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin(s:plug_home_dir.'/plugged')

Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-fugitive'
Plug 'ryanoasis/vim-devicons'

if filereadable($HOME.'/.wakatime.cfg')
  Plug 'wakatime/vim-wakatime'
endif

call plug#end()

try
  " let ayucolor="dark"     " light, dark & mirage
  colorscheme ayu

" Vim color scheme http://vimcolors.com/
  set termguicolors
  set t_Co=256
  catch
    hi! Comment ctermfg=240
    hi! CursorLine ctermbg=None
    hi! CursorLineNr cterm=None ctermbg=None
    hi! ColorColumn ctermbg=237
    hi! LineNr cterm=None ctermfg=240
    hi! Visual ctermbg=238
    hi! TabLineSel ctermbg=240
    hi! StatusLine ctermbg=238
    hi! StatusLineNC ctermbg=None
endtry

if !has('nvim')
  " set esckeys          " Allow cursor keys in insert mode.
  " set ttymouse=xterm   " Set mouse type to xterm.

  " let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
  " let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"

set encoding=utf-8 nobomb  " BOM often causes trouble
set mouse=a   " Enable moouse in all in all modes

  " if has("mac") || has("macunix")
  "   set <A-j>=∆
  "   set <A-k>=˚
  " endif
endif

if has('clipboard')
  set clipboard=unnamedplus
endif

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

set laststatus=2

set ruler        " Show cursor position
set noshowmode   " Hide the current mode
set report=0     " Show all command reports
set updatetime=50

" Completion
if has('wildmenu')
  set wildmenu
endif

set wildmode=longest:full,full
set wildchar=<TAB>
set completeopt=menu,menuone,noselect
set showfulltag  " Show full completion tags

" Scrolling
set scrolloff=5      " Start scrolling three lines before horizontal border of window
set sidescrolloff=3  " Start scrolling three columns before vertical border of window

" Navigation
set switchbuf=usetab

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

nnoremap <Esc><Esc> :noh<CR> " Double <esc> to clear search highlight

" Window splitting
set splitbelow  " New window goes below
set splitright  " New windows goes right

" Folding
set nofoldenable
set foldmethod=indent

" Whitespace characters
set list
set listchars=eol:¬,tab:→\ ,trail:·,extends:…,precedes:…
set fillchars=foldopen:,foldclose:,vert:│,fold:·,foldsep:\ ,diff:-

set suffixes=.bak,~,.cache,.swp,.swo,.o,.d,.info,.aux,.dvi,.bin,.cb,.dmg,.exe,.ind,.idx,.inx,.out,.toc,.pyc,.pyd,.dll
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.pdf,*.o,*.obj,*.min.js
set wildignore+=*/vendor/*,*/node_modules/*,*/.git/*,*/DS_Store

" Move lines - use ALT+J/K to move line up and down
nnoremap <A-j> :m .+1<CR>==         " Move lines down
nnoremap <A-k> :m .-2<CR>==         " Move lines up
inoremap <A-j> <Esc>:m .+1<CR>==gi  " Move lines down
inoremap <A-k> <Esc>:m .-2<CR>==gi  " Move lines up
vnoremap <A-j> :m '>+1<CR>gv=gv     " Move lines down
vnoremap <A-k> :m '<-2<CR>gv=gv     " Move lines up

" Split navigation - use <leader>H/J/K/L instead of CTRL+H/J/K/L to navigate window
nnoremap <leader>h <C-w>h " Go to left window
nnoremap <leader>j <C-w>j " Go to window below
nnoremap <leader>k <C-w>k " Go to window above
nnoremap <leader>l <C-w>l " Go to right window

" Resize window - Use CTRL + arrow keys
nmap <A-Up> :resize+2<CR>     " Increase window height
nmap <A-Down> :resize-2<CR>   " Decrease window height
nmap <A-Left> <C-W><          " Decrease window width
nmap <A-Right> <C-W>>         " Increase window width

" Speed up viewport scrolling
nnoremap <C-e> 4<C-e> " Scroll 4 lines down
nnoremap <C-y> 4<C-y> " Scroll 4 lines up

" Buffers navigation
nnoremap [b :bprevious<CR> " Previous Buffer
nnoremap ]b :bnext<CR>     " Next Buffer

" Keep cursor in the middle while in search results
nmap n nzzzv  " Previeous search result
nmap N Nzzzv  " Next search result

" Better indenting
vmap < <gv    " Dedent line
vmap > >gv    " Indent line

" Copy to system clipboard
nnoremap <leader>y \"+y<CR>
nnoremap <leader>Y \"+Y<CR>
vnoremap <leader>y \"+y<CR>
vnoremap <leader>Y \"+Y<CR>

" Actual delete word
noremap <leader>d \"_d<CR>
