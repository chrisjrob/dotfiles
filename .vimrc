setlocal foldmethod=syntax
:color slate
call pathogen#infect()

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
set scrolloff=5

"set autochdir " or http://vim.wikia.com/wiki/Set_working_directory_to_the_current_file
command! W w
command! RandomLine execute 'normal! '.(system('sh -c "echo -n $RANDOM"') % line('$')).'G'
command! FormatJSON %!python -m json.tool

" Windows clipboard
if system('uname -r') =~ "Microsoft"
    augroup Yank
        autocmd!
        autocmd! TextYankPost * :call system('clip.exe ',@")
    augroup END
endif

" Vim Markdown Support with Folding
set nocompatible
if has("autocmd")
    filetype plugin indent on
endif
autocmd BufNewFile,BufFilePre,BufRead *.tt set filetype=html
autocmd BufNewFile,BufFilePre,BufRead *.md set filetype=markdown
autocmd BufReadPost *.doc,*.docx,*.rtf,*.odp,*.odt silent %!pandoc "%" -tplain -o /dev/stdout

let g:tex_fold_enabled=1
let g:markdown_folding=1
let g:vim_markdown_folding_level=2
let g:table_mode_corner_corner="|"
let g:table_mode_corner="|"

let g:vimwiki_list = [{'path': "$HOME/Dropbox/Global/wiki", 'template_path': "$HOME/Dropbox/Global/wiki/templates", 'template_default': 'default', 'syntax': 'markdown', 'ext': '.md', 'path_html': "$HOME/Dropbox/Global/wiki_html", 'custom_wiki2html': 'vimwiki_markdown', 'template_ext': '.tpl', 'auto_diary_index': 1, 'auto_generate_links': 1}]
let g:vimwiki_table_mappings=0
let g:vimwiki_table_auto_fmt=0

" Stop *.md files behaving as vimwiki outside of vimwiki paths
let g:vimwiki_global_ext=0

" Temporary fix as auto_diary_index not working
autocmd BufEnter diary.md :VimwikiDiaryGenerateLinks

"Rebuild Spell files
for d in glob('~/.vim/spell/*.add', 1, 1)
    if filereadable(d) && (!filereadable(d . '.spl') || getftime(d) > getftime(d . '.spl'))
        exec 'mkspell! ' . fnameescape(d)
    endif
endfor

"Folding with Regex https://vim.fandom.com/wiki/Folding_with_Regular_Expression
"nnoremap \z :setlocal foldexpr=(getline(v:lnum)=~@/)?0:(getline(v:lnum-1)=~@/)\\|\\|(getline(v:lnum+1)=~@/)?1:2 foldmethod=expr foldlevel=0 foldcolumn=2<CR>
"nnoremap \z :setlocal foldexpr=(getline(v:lnum)=~@/)?0:1 foldmethod=expr foldlevel=0 foldcolumn=2<CR>
nnoremap \z :setlocal foldexpr=getline(v:lnum)!~@/ foldmethod=expr foldlevel=0<CR>:noh<CR>

nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>
vnoremap <Space> za

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

"Persistent undo
set undofile                " Save undos after file closes
set undodir=$HOME/.vim/undo " where to save undo histories
set undolevels=1000         " How many undos
set undoreload=10000        " number of lines to save for undo

" Shortcut for clear search
nmap <silent> ./ :nohlsearch<CR>

" Macros
" :reg s to display contents of macro s

" minutes - add latex action command to document at cursor
let @a = 'i\action{}{P1}{}hhhhhh'

" minutes - replace current line with action complete
let @c = 'cc\marginpar{Complete}'

" minutes - add date stamp
let @d = '|A \tiny{(' . strftime("%b-%y") . ')}'

" fix smart characters: –‘’“”
let @f = ':%s:[\xa0]: :ge | %s:[u2013]:-:ge | %s:[u2020]:\&dagger;:ge | %s:[u2018u2019]:u0027:ge | %s:[u201cu201d]:u0022:ge'

" Date stamp
let @i = '|A' . strftime("%e %B %Y") . ''

" load daily tasks
let @l = '/Todayj:r ~/Dropbox/Global/wiki/DailyTasks.md'

" propercase (titlecase)
let @p = ':s:\v(\w)(\S*):\u\1\L\2:g:noh'

" convert tabs into table
let @t = ':s/\v(^|\t|$)/\|/g:noh'
" sort unique
let @s = '{jV}k:sort u'

" underline current line
let @u = 'yypV:s/./-/g:noh'


" Note of .vim/bundle repositories
" git@github.com:arecarn/vim-crunch.git
" git@github.com:arecarn/vim-selection.git
" git@github.com:dhruvasagar/vim-table-mode.git
" git@github.com:godlygeek/tabular.git
" git@github.com:plasticboy/vim-markdown.git
" git@github.com:vim-scripts/loremipsum.git
" git@github.com:vim-scripts/openscad.vim.git
" git@github.com:vimwiki/vimwiki.git
" git@github.com:mattn/calendar-vim
