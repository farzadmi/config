" Steve's .vimrc file
" Curated since Dec 2013

if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

execute pathogen#infect()
execute pathogen#helptags()

" Turn on filetype identification prior to using any auto commands
if has("autocmd")
    " Enable file type detection.
    filetype plugin indent on
endif

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

set history=1000	" keep 50 lines of command line history
set incsearch		" do incremental searching

""""""""""""""""""""""""""""""
" Save Options
""""""""""""""""""""""""""""""
set hidden   	    " Keep buffers open when opening a new file
set nobackup		" do not keep a backup file, use versions instead
set noswapfile      " Don't use swap space

""""""""""""""""""""""""""""""
" Display and Colors
""""""""""""""""""""""""""""""
set number          " Turn on line numbers
set ruler			" show the cursor position all the time
set showcmd			" display incomplete commands
set showmode        " Always show what mode we're currently editing in
set cursorline      " Underline the current line for quick orientation

""""""""""""""""""""""""""""""
" Set tabbing options
""""""""""""""""""""""""""""""
set tabstop=4		" Make a tab equal to 4 spaces 
set softtabstop=4   " When hitting <BS>, pretend like a tab is removed, even if spaces
set shiftwidth=4	" Set the number of spaces to use for auto-indenting 
set shiftround		" Use a multiple of shiftwidth when indenting with '>' or '<'
set smarttab		" Insert tabs at the start of a line according to shiftwidth and not tabstop 	
set expandtab		" Insert spaces rather than tab characters
if has("autocmd")
    autocmd FileType python set expandtab   
endif

""""""""""""""""""""""""""""""
" Configure wildmenu for help with : commands
""""""""""""""""""""""""""""""
set wildmenu

""""""""""""""""""""""""""""""
" Set up code folding
""""""""""""""""""""""""""""""
set foldenable
set foldmethod=syntax
set foldlevel=99

""""""""""""""""""""""""""""""
" Key Mappings
""""""""""""""""""""""""""""""
" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  filetype plugin indent on

  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" Code Folding

" Map tasklist plugin
map <leader>td <Plug>TaskList

" Map tagbar plugin
nmap <F8> :TagbarToggle<CR>

" Python Code Completion
au FileType python set omnifunc=pythoncomplete#Complete
let g:SuperTabDefaultCompletionType = "context"
set completeopt=menuone,longest,preview
