set encoding=utf-8
set fileencodings=utf-8,gb2312,gbk,big5,ucs-bom,cp936.chinese
set termencoding=utf-8
"Get out of VI's compatible mode..
set nocompatible
set noswapfile

"Sets how many lines of history VIM har to remember
set history=400

"Set to auto read when a file is changed from the outside
set autoread

"Have the mouse enabled all the time:
" set mouse=a

"Set mapleader
"let mapleader = ","
"let g:mapleader = ","


"Fast saving
nmap <leader>w :w!<cr>
nmap <leader>f :find<cr>

"Fast reloading of the .vimrc
map <leader>s :source ~/.vimrc<cr>
"Fast editing of .vimrc
map <leader>e :e! ~/.vimrc<cr>
"When .vimrc is edited, reload it
"autocmd! bufwritepost vimrc source ~/vim_local/vimrc

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Colors and Fonts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Enable syntax hl
"syntax enable

"Set font to Monaco 10pt
if has("gui_running")
  set guioptions-=T
  let psc_style='cool'
  colorscheme murphy
else
  set background=dark
  colorscheme zellner
endif

"Some nice mapping to switch syntax (useful if one mixes different languages in one file)
map <leader>1 :set syntax=cheetah<cr>
map <leader>2 :set syntax=xhtml<cr>
map <leader>3 :set syntax=python<cr>
map <leader>4 :set ft=javascript<cr>
map <leader>5 :set syntax=<cr>
map <leader>6 :syntax sync fromstart<cr>

"autocmd BufEnter * :syntax sync fromstart

"Highlight current
if has("gui_running")
  set cursorline
  hi cursorline guibg=#333333 
  hi CursorColumn guibg=#333333
endif

"Omni menu colors
hi Pmenu guibg=#333333
hi PmenuSel guibg=#555555 guifg=#ffffff

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" VIM userinterface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"Always show current position
set ruler

"The commandbar is 2 high
set cmdheight=2

"Show line number
set nu

"Tab is 4 space
set shiftwidth=4
set tabstop=4

"find sth 
set ic

"下面两行在进行编写代码时，在格式对起上很有用；
"第一行，vim使用自动对起，也就是把当前行的对起格式应用到下一行；
"第二行，依据上面的对起格式，智能的选择对起方式，对于类似C语言编
"写上很有用
set autoindent
set smartindent
"设置匹配模式，类似当输入一个左括号时会匹配相应的那个右括号
set showmatch

set backspace=indent,eol,start

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" UserDefined
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" gnore case when searching
" set ignorecase
set incsearch
" Set magic on
set magic
" Highlight search things
set hlsearch
" switch buffers with Tab
map <C-Tab> :bn<CR>
map <S-Tab> :bp<CR>
" NERDTree
map <F9> :NERDTreeToggle<CR>
set pastetoggle=<F6>
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugin configuration
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" taglist
let Tlist_Auto_Highlight_Tag = 1
let Tlist_Auto_Open = 1
let Tlist_Auto_Update = 1
let Tlist_Close_On_Select = 0
let Tlist_Compact_Format = 0
let Tlist_Display_Prototype = 0
let Tlist_Display_Tag_Scope = 1
let Tlist_Enable_Fold_Column = 0
let Tlist_Exit_OnlyWindow = 1
let Tlist_File_Fold_Auto_Close = 0
let Tlist_GainFocus_On_ToggleOpen = 0
let Tlist_Hightlight_Tag_On_BufEnter = 1
let Tlist_Inc_Winwidth = 0
let Tlist_Max_Submenu_Items = 1
let Tlist_Max_Tag_Length = 30
let Tlist_Process_File_Always = 0
let Tlist_Show_Menu = 0
let Tlist_Show_One_File = 0
let Tlist_Sort_Type = "order"
let Tlist_Use_Horiz_Window = 0
let Tlist_Use_Right_Window = 1
let Tlist_WinWidth = 40
let tlist_php_settings = 'php;c:class;i:interfaces;d:constant;f:function'
map <F12> :TlistToggle<CR>

" minibufex
let g:miniBufExplMapWindowNavVim = 1 
let g:miniBufExplMapWindowNavArrows = 1 
let g:miniBufExplMapCTabSwitchBufs = 1 
let g:miniBufExplModSelTarget = 1 

" COMMANDT
map <C-F9> :CommandT<CR>
