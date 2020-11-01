" Make vim more useful
set nocompatible

" Enable filetype plugins
filetype plugin indent on

" Enable syntax highlighting
syntax on

if has('unix')
  " set backupdir=$HOME/.cache/vim/backup
  set directory=$HOME/.vim/swap
  set undodir=$HOME/.vim/undo

  " auto-install vim-plug
  if empty(glob($HOME . '/.vim/autoload/plug.vim'))
    silent !curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    "autocmd VimEnter * PlugInstall
    autocmd VimEnter * PlugInstall | source $MYVIMRC
  endif

  call plug#begin($HOME . '/.vim/autoload/plugged')
else
  set shell=powershell

  set shellquote= shellpipe=\| shellxquote=
  set shellcmdflag=\ -ExecutionPolicy\ RemoteSigned\ -NoProfile\ -Nologo\ -NonInteractive\ -Command
  set shellredir=\|\ Out-File\ -Encoding\ UTF8

  set directory=$LOCALAPPDATA/nvim-data/swap

  " auto-install vim-plug
  if empty(glob($LOCALAPPDATA . '/nvim/autoload/plug.vim'))
    silent !curl -fLo $LOCALAPPDATA/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    "autocmd VimEnter * PlugInstall
    autocmd VimEnter * PlugInstall | source $MYVIMRC
  endif

  call plug#begin($LOCALAPPDATA . '/nvim/autoload/plugged')
endif

  Plug 'mattn/emmet-vim'
  Plug 'tpope/vim-fugitive'
  Plug 'gregsexton/gitv', { 'on': ['Gitv'] }
  Plug 'tpope/vim-surround'
  Plug 'dense-analysis/ale'
  Plug 'editorconfig/editorconfig-vim'
  Plug 'kien/ctrlp.vim', { 'on': ['CtrlP'] }
  Plug 'Lokaltog/vim-easymotion'
  Plug 'godlygeek/tabular'
  Plug 'reedes/vim-pencil'
  Plug 'terryma/vim-multiple-cursors'
  Plug 'tpope/vim-commentary'
  Plug 'joonty/vdebug'
  Plug 'matze/vim-move'
  Plug 'majutsushi/tagbar'
  Plug 'neoclide/coc.nvim', { 'branch': 'release', 'do': { -> coc#util#install() } }
  Plug 'posva/vim-vue', { 'for': 'vue' }
  Plug 'wakatime/vim-wakatime'

  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'Yggdroot/indentLine'
  Plug 'ayu-theme/ayu-vim'
  Plug 'ryanoasis/vim-devicons'
  Plug 'jwalton512/vim-blade', { 'for': 'blade.php' }

  Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
  " Plug 'tiagofumo/vim-nerdtree-syntax-highlight'

  "Plug 'ervandew/supertab'
  Plug 'shawncplus/phpcomplete.vim', { 'for': 'php' }
  Plug 'dsawardekar/wordpress.vim'

  "if has('nvim')
  "  Plug 'wvffle/vimterm'
  "  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  "else
  "  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  "  Plug 'roxma/nvim-yarp'
  "  Plug 'roxma/vim-hug-neovim-rpc'
  "endif

call plug#end()

" Set extra options when running in GUI mode
if has('gui_running')
  set guifont=Fira\ Code

  set guioptions-=T
  set guioptions+=e
  set guitablabel=%M\ %t

  set t_Co=256
else
  " highlight Comment ctermfg=Gray
endif

" Vim color scheme http://vimcolors.com/
set termguicolors

try
  let ayucolor="dark"     " light, dark & mirage
  colorscheme ayu
catch /^Vim\%((\a\+)\)\=:E185/
  " deal with it
endtry

" hi Normal guibg=#000000
" hi NonText guibg=#000000 ctermbg=000

" Change mapleader
let mapleader = ","
let g:mapleader = ","

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Set some junk

" Auto/Smart/Copy indent from last line when starting new line.
set autoindent smartindent copyindent
set backspace=indent,eol,start

" BOM often causes trouble
set encoding=utf-8 nobomb

set formatoptions=
set formatoptions+=c  " Format comments
set formatoptions+=r  " Continue comments by default
set formatoptions+=o  " Make comment when using o or O from comment line
set formatoptions+=q  " Format comments with gq
set formatoptions+=n  " Recognize numbered lists
set formatoptions+=2  " Use indent from 2nd line of a paragraph
set formatoptions+=l  " Don't break lines that are already long
set formatoptions+=1  " Break before 1-letter words

" By default add g flag to search/replace. Add g to toggle.
set gdefault

" When a buffer is brought to foreground, remember undo history and marks.
set hidden

" Increase history from 20 default to 500
set history=500

" Highlight searches
set hlsearch

" Ignore case of searches.
set ignorecase

" Highlight dynamically as pattern is typed.
set incsearch

" Ignore 'ignorecase' if search patter contains uppercase characters.
set smartcase

" Compojure
set lispwords+=defroutes

" Noir core
set lispwords+=defpartial,defpage

" Ciste core
set lispwords+=defaction,deffilter,defview,defsection

" Speclj TDD/BDD
set lispwords+=describe,it

" Enable extended regexes.
set magic

" Enable moouse in all in all modes.
set mouse=a

" Disable error bells.
set noerrorbells

" Use visual bell instead of audible bell (annnnnoying)
set visualbell

" Only insert single space after a '.', '?' and '!' with a join command.
set nojoinspaces

" Don't reset cursor to start of line when moving around.
set nostartofline

" close the buffer when I close a tab (I use tabs more than buffers)
set nohidden

" Do not wrap lines.
" set nowrap

" Enable line numbers.
set nu

" Set omni-completion method.
set ofu=syntaxcomplete#Complete

" Show all changes.
set report=0

" Don't show the intro message when starting vim.
set shortmess=atI

" Show the current mode.
set showmode

" Start scrolling three lines before horizontal border of window.
set scrolloff=3

" Use spaces instead of tabs
set expandtab

" The # of spaces for indenting.
set shiftwidth=4

" Start scrolling three columns before vertical border of window.
set sidescrolloff=3

" if wrap is off, this is fasster for horizontal scrolling
set sidescroll=2

" At start of line, <Tab> inserts shiftwidth spaces, <Bs> deletes shiftwidth spaces.
set smarttab

" Tab key results in 2 spaces
set softtabstop=2

" a tab is four spaces
set tabstop=4

" New window goes below
set splitbelow

" New windows goes right
set splitright

" Show us the command we're typing
set showcmd

" show full completion tags
set showfulltag

" Show the filename in the window titlebar.
set title

" Send more characters at a given time.
set ttyfast

" Persistent Undo.
set undofile
set suffixes=.bak,~,.swp,.swo,.o,.d,.info,.aux,.log,.dvi,.pdf,.bin,.bbl,.blg,.brf,.cb,.dmg,.exe,.ind,.idx,.ilg,.inx,.out,.toc,.pyc,.pyd,.dll

" Character for CLI TAB-completion.
set wildchar=<TAB>
set wildignore+=*.jpg,*.jpeg,*.gif,*.png,*.gif,*.psd,*.o,*.obj,*.min.js
set wildignore+=*/smarty/*,*/vendor/*,*/node_modules/*,*/.git/*,*/.hg/*,*/.svn/*,*/.sass-cache/*,*/log/*,*/tmp/*,*/build/*,*/ckeditor/*

" Hitting TAB in command mode will show possible completions above command line.
set wildmenu

" Complete only until point of ambiguity.
set wildmode=list:longest

" Allow splits to be reduced to a single line.
set winminheight=0

" Searches wrap around end of file
set wrapscan

" Confirm before exit if file has changed
set confirm

if !has('nvim')
  set esckeys          " Allow cursor keys in insert mode.
  set ttymouse=xterm   " Set mouse type to xterm.

  nnoremap <silent> <ESC>OA <UP>
  nnoremap <silent> <ESC>OB <DOWN>
  nnoremap <silent> <ESC>OC <RIGHT>
  nnoremap <silent> <ESC>OD <LEFT>
  inoremap <silent> <ESC>OA <UP>
  inoremap <silent> <ESC>OB <DOWN>
  inoremap <silent> <ESC>OC <RIGHT>
  inoremap <silent> <ESC>OD <LEFT>
endif

" Use Ctrl+Z as it should be
nnoremap <C-z> :undo<cr>
inoremap <C-z> <esc>:undo<cr>i

" Switch CWD to the directory of the open buffer
map <leader>cd :cd %:p:h<cr>:pwd<cr>

" Speed up viewport scrolling
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" Faster split resizing [+,-] for height and Alt+[+,-] for width
if bufwinnr(1)
  noremap + <C-W>+
  noremap - <C-W>-
  noremap <A-+> <C-W><
  noremap <A--> <C-W>>
endif

" Better split switching (Ctrl-j, Ctrl-k, Ctrl-h, Ctrl-l)
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-H> <C-W>h
noremap <C-L> <C-W>l

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

if !exists('g:vdebug_options')
  let g:vdebug_options = {}
endif

let g:vdebug_options.port = 9000

" Toggle show tabs and trailing spaces (,c)
set lcs=eol:¬,tab:›\ ,trail:·,extends:>,precedes:<
"set fcs=fold:-
nnoremap ,c <Esc>:set list!<CR>

" Clear last search (,qs)
map <Esc> :noh<CR>

" Tab Navgations?
set switchbuf=usetab

" Create new tab with Ctrl+T and open NerdTree
nnoremap <C-t>  :tabnew +:NERDTreeCWD .<CR>
inoremap <C-t>  <Esc>:tabnew +:NERDTreeCWD .<CR>i

" Close tab with Alt+W,Alt+T
nnoremap <A-w><A-t>  :tabclose<CR>
inoremap <A-w><A-t>  <Esc>:tabclose<CR>i
" Close buffer with Alt+W,Alt+B
nnoremap <A-w><A-b>  :bd<CR>
inoremap <A-w><A-b>  <Esc>:bd<CR>i

" Tabs navigation using Ctrl+PageUp Ctrl+PageDown
nnoremap <C-PageUp>    :tabprevious<CR>
nnoremap <C-PageDown>  :tabnext<CR>
inoremap <C-PageUp>    <Esc>:tabprevious<CR>i
inoremap <C-PageDown>  <Esc>:tabnext<CR>i

" Buffer navigation: Alt+PageUp Alt+PageDown
nnoremap <A-PageUp>    :bprev!<CR>
inoremap <A-PageUp>    <Esc>:bprev!<CR>
nnoremap <A-PageDown>  :bnext!<CR>
nnoremap <A-PageDown>  <Esc>:bnext!<CR>

" Useful mappings for managing tabs
map <leader>tn :tabnew<cr>
map <leader>to :tabonly<cr>
map <leader>tc :tabclose<cr>
map <leader>tm :tabmove

" Opens a new tab with the current buffer's path
" Super useful when editing files in the same directory
map <leader>te :tabedit <c-r>=expand("%:p:h")<cr>/

" Pencil.VIM
let g:pencil#wrapModeDefault = 'hard'   " or 'soft'

augroup pencil
  autocmd!
  autocmd FileType markdown,mkd,md call pencil#init()
  autocmd FileType textile call pencil#init()
  autocmd FileType text call pencil#init({'wrap': 'hard'})
augroup END

"" NERDTree configuration
let g:NERDTreeShowHidden = 1     " Show hidden files/directories
let g:NERDTreeMinimalUI = 1      " Remove bookmarks and help text from NERDTree
let g:NERDTreeChDirMode = 2
" Hide certain files and directories from NERDTree
let g:NERDTreeIgnore = [ '^\.DS_Store$', '\.git$', '\.vscode$', 'node_modules', '\.rbc$', '\~$', '\.pyc$', '\.db$', '\.sqlite$', '__pycache__']
let g:NERDTreeSortOrder = ['^__\.py$', '\/$', '*', '\.swp$', '\.bak$', '\~$']
let g:nerdtree_tabs_focus_on_files = 1
let g:NERDTreeMapOpenInTabSilent = '<RightMouse>'
let g:NERDTreeWinSize = 36
" Custom icons for expandable/expanded directories
let g:NERDTreeDirArrowExpandable = '⬏'
let g:NERDTreeDirArrowCollapsible = '⬎'

nnoremap <silent> <F2> :NERDTreeFind<CR>
nnoremap <C-k><C-b> :NERDTreeToggle<CR>
inoremap <C-k><C-b> <Esc>:NERDTreeToggle<CR>

" CtrlP Settings
nnoremap <C-p> :CtrlP<CR>
inoremap <C-p> <Esc>:CtrlP<CR>i
" Open file in current window/buffer
let g:ctrlp_open_new_file = 'r'
" Ignore some stuffs
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/](node_modules|bower_components|vendor)|(\.(git|hg|svn|vscode))$',
  \ 'file': '\v\.(exe|so|dll|zip)$',
  \ }

" Deoplete.VIM
"let g:deoplete#enable_at_startup = 1

" COC.VIM
" use <tab> for trigger completion and navigate to next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
inoremap <silent><expr> <TAB>
  \ pumvisible() ? "\<C-n>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()

" Close preview window when completion is done.
autocmd! CompleteDone * if pumvisible() == 0 | pclose | endif

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" https://github.com/neoclide/coc.nvim/issues/590
autocmd! FileType php set iskeyword+=$
autocmd! BufNewFile,BufRead *.blade.php set ft=blade

let g:coc_filetype_map = {
  \ 'blade': 'html'
  \ }

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

let g:airline_theme = 'wombat'
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#enabled = 1
let g:airline#extensions#branch#format = 2

let g:airline_symbols.whitespace = 'Ξ'
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.notexists = 'Ɇ'
let g:airline_symbols.linenr = '☰'
let g:airline_symbols.linenr = '␊'
let g:airline_symbols.linenr = '␤'
let g:airline_symbols.linenr = '¶'

" powerline symbols
let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''

" COC integration
let g:airline#extensions#coc#enabled = 1
" ALE integration
let g:airline#extensions#ale#enabled = 1
" Fugitive integration
let g:airline#extensions#fugitiveline#enabled = 1
" CSV file integration
let g:airline#extensions#csv#enabled = 1
" PO file integration
let g:airline#extensions#po#enabled = 1

set colorcolumn=80,100
set ruler

" Linters Settings
" See https://github.com/dense-analysis/ale
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'jsx': ['stylelint', 'eslint'],
\   'vue': ['prettier', 'eslint'],
\   'html': ['prettier', 'stylelint'],
\   'php': ['langserver', 'phpcs', 'php-cs-fixer', 'phpmd', 'phpstan', 'php'],
\}
let g:ale_pattern_options = {
\   '\.min\.js$': {'ale_linters': [], 'ale_fixers': []},
\   '\.min\.css$': {'ale_linters': [], 'ale_fixers': []},
\}

let g:ale_pattern_options_enabled = 1

let g:ale_lint_on_text_changed = 'never'
let g:ale_lint_on_insert_leave = 1
" let g:ale_lint_on_enter = 0

"let g:ale_sign_error = '⌧'
"let g:ale_sign_warning = '╳'

"let g:ale_open_list = 1
let g:ale_keep_list_window_open = 1
let g:ale_sign_column_always = 1
let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%severity%:%linter%] %s'
let g:ale_set_balloons = 1
" let g:ale_cursor_detail = 1

let g:airline#extensions#ale#enabled = 1
let g:ale_javascript_eslint_suppress_missing_config = 1
