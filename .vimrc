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
nmap <F12> :call ToggleHex()<CR>

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction

" Map the tab toggler to make split screens full
nmap t% :tabedit %<CR>
nmap td :tabclose<CR>

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

if has("mouse_sgr")
    set ttymouse=sgr
else
    set ttymouse=xterm2
end

""""""""""""""""""""""""""""""
" Configurations for specific filetypes
""""""""""""""""""""""""""""""
if has("autocmd")
  
    " Python configuration
    augroup pycmd
        au! 

        " Override Jedi keymapping that conflict with my mapping
        let g:jedi#rename_command = 0
        " Set python options
        autocmd FileType python setlocal textwidth=80
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

        " The joys of Fortran programming...
        let fortran_free_source=1
        " let fortran_more_precise=1
        " let fortran_dialect="f77"
        autocmd FileType fortran setlocal textwidth=96
        autocmd FileType fortran map <leader>r :!%<CR>
    augroup END

    augroup cxx
        au!

        autocmd FileType c setlocal nowrap
        autocmd FileType cpp setlocal nowrap
    augroup END

    augroup jpl
        au!

        autocmd FileType rdf setlocal nowrap
    augroup END

    augroup tex
        au!

        autocmd FileType tex setlocal wrap
        autocmd FileType tex setlocal textwidth=100
        autocmd FileType tex setlocal spell spelllang=en_us
    augroup END

    " vim -b : edit binary using xxd-format!
    augroup Binary
        au!

        " set binary option for all binary files before reading them
        au BufReadPre *.bin,*.hex,*.raw,*.tvp,*.slc setlocal binary

        " if on a fresh read the buffer variable is already set, it's wrong
        au BufReadPost *
            \ if exists('b:editHex') && b:editHex |
            \   let b:editHex = 0 |
            \ endif

        " convert to hex on startup for binary files automatically
        au BufReadPost *
            \ if &binary | Hexmode | endif

        " When the text is freed, the next time the buffer is made active it will
        " re-read the text and thus not match the correct mode, we will need to
        " convert it again if the buffer is again loaded.
        au BufUnload *
            \ if getbufvar(expand("<afile>"), 'editHex') == 1 |
            \   call setbufvar(expand("<afile>"), 'editHex', 0) |
            \ endif

        " before writing a file when editing in hex mode, convert back to non-hex
        au BufWritePre *
            \ if exists("b:editHex") && b:editHex && &binary |
            \  let oldro=&ro | let &ro=0 |
            \  let oldma=&ma | let &ma=1 |
            \  silent exe "%!xxd -r" |
            \  let &ma=oldma | let &ro=oldro |
            \  unlet oldma | unlet oldro |
            \ endif

        " after writing a binary file, if we're in hex mode, restore hex mode
        au BufWritePost *
            \ if exists("b:editHex") && b:editHex && &binary |
            \  let oldro=&ro | let &ro=0 |
            \  let oldma=&ma | let &ma=1 |
            \  silent exe "%!xxd" |
            \  exe "set nomod" |
            \  let &ma=oldma | let &ro=oldro |
            \  unlet oldma | unlet oldro |
            \ endif
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

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
set t_Co=256        " Turn on 256 color support
color jellybeans
syntax on
set hlsearch
"
" Set status line colors
if has("autocmd")
    au InsertEnter * hi statusline guibg=DarkGrey ctermfg=white guifg=White ctermbg=red
    au InsertLeave * hi statusline guibg=DarkGrey ctermfg=0 guifg=White ctermbg=yellow
endif

" default the statusline to green when entering Vim
hi Normal ctermbg=none
hi statusline guibg=DarkGrey ctermfg=0 guifg=White ctermbg=yellow

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

" Get rid of annoying delay after escape key
if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif

