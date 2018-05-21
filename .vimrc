setlocal foldmethod=syntax
:color slate
call pathogen#infect()

let g:tex_fold_enabled=1
set showcmd             " Show (partial) command in status line.
set showmatch           " Show matching brackets.
set ignorecase          " Do case insensitive matching
set smartcase           " Do smart case matching
set incsearch           " Incremental search
set hlsearch            " Highlight search
set autowrite           " Automatically save before commands like :next and :make
set hidden              " Hide buffers when they are abandoned
set mouse=a             " Enable mouse usage (all modes)
set expandtab
set shiftwidth=4
set softtabstop=4
set smartindent
set spell spelllang=en_gb
set encoding=utf-8
set fileencoding=utf-8
set wrap linebreak textwidth=0
set visualbell
"set autochdir " or http://vim.wikia.com/wiki/Set_working_directory_to_the_current_file
command! W w
command! RandomLine execute 'normal! '.(system('sh -c "echo -n $RANDOM"') % line('$')).'G'
com! FormatJSON %!python -m json.tool

" Vim Markdown Support with Folding
set nocompatible
if has("autocmd")
    filetype plugin indent on
endif
au BufNewFile,BufRead *.tt set filetype=html

let g:vim_markdown_initial_foldlevel=20
let g:table_mode_corner_corner="|"
let g:table_mode_corner="|"

let g:vimwiki_list = [{'path': "$HOME/Dropbox/Global/wiki", 'template_path': "$HOME/Dropbox/Global/wiki/templates", 'template_default': 'default', 'syntax': 'markdown', 'ext': '.md', 'path_html': "$HOME/Dropbox/Global/wiki_html", 'custom_wiki2html': 'vimwiki_markdown', 'template_ext': '.tpl'}]
let g:vimwiki_table_mappings=0
let g:vimwiki_table_auto_fmt=0

"Twiddle case
function! TwiddleCase(str)
    if a:str ==# toupper(a:str)
	let result = tolower(a:str)
    elseif a:str ==# tolower(a:str)
	let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
    else
	let result = toupper(a:str)
    endif
	return result
    endfunction
vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv

"Indent simplification
nnoremap > >>
nnoremap < <<
vnoremap > >gv
vnoremap < <gv

"Recentre search match
nnoremap n nzz
nnoremap N nzz


nmap <silent> ./ :nohlsearch<CR>

" Macros
" :reg s to display contents of macro s
let @a = 'i\action{}{P1}{}hhhhhh'
let @c = 'cc\marginpar{Complete}'
let @d = '|A \tiny{(Mmm-YY)}'
let @s = '{jV}k:sort u'
let @u = 'yypV:s/./-/g:noh'
let @l = '/Todayj:r ~/Dropbox/Global/wiki/DailyTasks.md'
