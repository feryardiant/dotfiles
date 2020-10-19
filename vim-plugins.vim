" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
    silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    "autocmd VimEnter * PlugInstall
    "autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/autoload/plugged')

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