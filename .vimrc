" Steve's .vimrc file
" Curated since Dec 2013

if v:progname =~? "evim"
  finish
endif

" Use Vim settings, rather than Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible

source ~/.vim/bundle/pathogen/autoload/pathogen.vim
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

""""""""""""""""""""""""""""""
" Save Options
""""""""""""""""""""""""""""""
set hidden   	    " Keep buffers open when opening a new file
set autowrite       " Automatically save file when hiding a buffer
set confirm         " If you try to abondon a buffer, prompt for a save first
set nobackup		" do not keep a backup file, use versions instead
set noswapfile      " Don't use swap space

""""""""""""""""""""""""""""""
" Display and Colors
""""""""""""""""""""""""""""""
set ruler			" show the cursor position all the time
set showcmd			" display incomplete commands
set showmode        " Always show what mode we're currently editing in
set cursorline      " Underline the current line for quick orientation

""""""""""""""""""""""""""""""
" Line number configuration
""""""""""""""""""""""""""""""
if &diff
    " In diff mode (i.e. vimdiff)
    set number norelativenumber
else
    " Default edit mode
    set number relativenumber	" Default set line numbers relative to the cursor
endif

function! NumberToggle()
    if &relativenumber == 1
        set number norelativenumber
    else
        set number relativenumber
    endif
endfunc

" Map a toggle for turning off relative line numbering
nnoremap <leader>n :call NumberToggle()<CR>

" Auto switch between absolute and relative line numbers
if has("autocmd")
    :au FocusLost * :set number norelativenumber
    :au FocusGained * :set number relativenumber

    autocmd InsertEnter * :set number norelativenumber
    autocmd InsertLeave * :set number relativenumber
endif

""""""""""""""""""""""""""""""
" Set tabbing options
""""""""""""""""""""""""""""""
set tabstop=4		" Make a tab equal to 4 spaces 
set softtabstop=4   " When hitting <BS>, pretend like a tab is removed, even if spaces
set shiftwidth=4	" Set the number of spaces to use for auto-indenting 
set shiftround		" Use a multiple of shiftwidth when indenting with '>' or '<'
set smarttab		" Insert tabs at the start of a line according to shiftwidth and not tabstop 	
set expandtab		" Insert spaces rather than tab characters
set autoindent      " Automatically indent newlines to the same indentation of the previous line
if has("autocmd")
    autocmd FileType python set expandtab   
endif

""""""""""""""""""""""""""""""
" Configure the status line
""""""""""""""""""""""""""""""
set laststatus=2 " Always have the statusline visible

function! InsertStatuslineColor(mode)
    if a:mode == 'i'
        hi statusline guibg=Cyan ctermfg=red guifg=Black ctermbg=0
    elseif a:mode == 'r'
        hi statusline guibg=Purple ctermfg=Purple guifg=Black ctermbg=0
    else
        hi statusline guibg=DarkRed ctermfg=DarkRed guifg=Black ctermbg=0
    endif
endfunction

au InsertEnter * call InsertStatuslineColor(v:insertmode)
au InsertLeave * hi statusline guibg=DarkGrey ctermfg=yellow guifg=White ctermbg=black

" default the statusline to green when entering Vim
hi statusline guibg=DarkGrey ctermfg=yellow guifg=White ctermbg=black

" Formats the statusline
set statusline=%f                           " file name
set statusline+=[%{strlen(&fenc)?&fenc:'none'}, "file encoding
set statusline+=%{&ff}] "file format
set statusline+=%y      "filetype
" set statusline+=%h      "help file flag
set statusline+=%m      "modified flag
set statusline+=%r      "read only flag

" Puts in the current git status
"if count(g:pathogen_disabled, 'Fugitive') < 1   
    "set statusline+=%{fugitive#statusline()}
"endif

" Puts in syntastic warnings
"if count(g:pathogen_disabled, 'Syntastic') < 1  
    "set statusline+=%#warningmsg#
    "set statusline+=%{SyntasticStatuslineFlag()}
    "set statusline+=%*
"endif

set statusline+=\ %=                        " align left
set statusline+=Line:%l/%L[%p%%]            " line X of Y [percent of file]
set statusline+=\ Col:%c                    " current column
set statusline+=\ Buf:%n                    " Buffer number
set statusline+=\ [%b][0x%B]\               " ASCII and byte code under cursor

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
" Search Customization
""""""""""""""""""""""""""""""
" Redo vims non-standard regex searches to be python compatible
nnoremap / /\v
vnoremap / /\v      

set incsearch		" do incremental searching (search as you type)
set gdefault        " Turn on g option in substitute command by default (i.e. replace all occurrances in a line)
set ignorecase      " Do case insensitive searches by default
set smartcase       " If an upper case character is included, searches become case sensitive

" Clear highlighted searches
nnoremap <leader><space> :noh<cr>

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch      " Highlight search occurances
endif

""""""""""""""""""""""""""""""
" Other Key Mappings
""""""""""""""""""""""""""""""
" Don't use Ex mode, use Q for formatting
map Q gq

" Create an insert line command that doesn't go into --insert-- mode
noremap oo o<esc>
nnoremap OO O<esc>

" Escalate to root in order to save
cmap w!! w !sudo tee >/dev/null %

" Map tasklist plugin
map <leader>l <Plug>TaskList

" Map tagbar plugin
nmap <F5> :TagbarToggle<CR>
nmap <F4> :NERDTreeToggle<CR>

" Create bindings for GIT in vimdiff
if &diff
    map <leader>dr :diffget RE<CR>
    map <leader>dl :diffget LO<CR>
    map <leader>db :diffget BA<CR>
endif

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
    set mouse=a
    set term=xterm
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    " The joys of Fortran programming...
    let fortran_free_source=1
    " let fortran_more_precise=1
    " let fortran_dialect="f77"

    " Finally turn on highlighting features
    syntax on
    set hlsearch
endif

""""""""""""""""""""""""""""""
" Configurations for specific filetypes
""""""""""""""""""""""""""""""
if has("autocmd")
  
    " Python configuration
    augroup pycmd
        au! 

        autocmd FileType python setlocal nowrap
        autocmd FileType python map <leader>r :!python %<CR>
        autocmd FileType python map <leader>m :make<CR>
        autocmd FileType python map <leader>d :Pyclewn pdb %<CR>
    augroup END

    augroup ml
        au!

        autocmd FileType matlab setlocal nowrap
        autocmd FileType matlab map <leader>r :!matlab -nodesktop -nosplash -r %<CR>
    augroup END

    augroup fortran
        au!

        autocmd FileType fortran setlocal textwidth=96
    augroup END

    augroup jpl
        au!

        autocmd FileType rdf setlocal nowrap
    augroup END

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

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" Python Code Completion
" au FileType python set omnifunc=pythoncomplete#Complete
" let g:SuperTabDefaultCompletionType = "context"
" set completeopt=menuone,longest,preview
"
let ropevim_vim_completion=1
