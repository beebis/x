"set viminfo='25,\"50,n~/.viminfo
call plug#begin('~/.vim/plugged')
Plug 'ollykel/v-vim'
"PlugInstall
call plug#end()
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

set ic
set sm
set smartindent
execute pathogen#infect()
syntax on
filetype plugin indent on
set mouse=a
"colorscheme happy_hacking
"colorscheme elflord
"colorscheme jellybean
colorscheme pink-moon
"set background=dark

"let g:Powerline_symbols = 'unicode'
"python from powerline.vim import setup as powerline_setup
"python powerline_setup()
"python del powerline_setup

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"
let g:airline_theme='alduin'
"let g:airline_theme='aurora'
set encoding=utf-8
set t_Co=256
let g:airline#extensions#tmuxline#enabled = 1
let g:netrw_banner = 0
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_altv = 1
let g:netrw_winsize = 25
"augroup ProjectDrawer
"  autocmd!
"  autocmd VimEnter * :Vexplore
"augroup END
