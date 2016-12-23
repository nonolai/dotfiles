syntax on
set nocompatible

" Vundle stuff
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Bundle 'tomasr/molokai'
Plugin 'bcicen/vim-vice'

Plugin 'VundleVim/Vundle.vim'
Plugin 'davidzchen/vim-bazel'
Plugin 'Valloric/YouCompleteMe.git'
call vundle#end()

filetype indent plugin on
set backspace=indent,eol,start

" Molokai Color Scheme Settings
"colorscheme molokai
"set background=dark
"let g:molokai_termcolors = 256

" Vice Color Scheme Settings
colorscheme vice

"" Revert always make background transparent
hi Normal ctermbg=none
hi NonText ctermbg=none
hi LineNr ctermbg=none

set mouse=a

set tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
autocmd FileType python setlocal tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
autocmd FileType html setlocal tabstop=2 softtabstop=0 expandtab shiftwidth=2 smarttab
autocmd FileType go setlocal tabstop=2 softtabstop=0 noexpandtab shiftwidth=2 smarttab

set number
set ruler

set nohlsearch

let mapleader=","
nmap <leader>b :ls<CR>:b<space>
nmap <leader>h :set hlsearch!<CR>
nmap <leader>r :source $MYVIMRC<CR>
