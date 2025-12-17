colorscheme delek

if v:progname == 'vi'
  set noloadplugins
endif

" Add plugins
if &loadplugins
  if has('packages')
  " should use packadd! 
  endif
endif

" Automatic, language-dependent indentation, syntax coloring and other
" functionality.
"
" Must come *after* the `:packadd!` calls above otherwise the contents of
" package "ftdetect" directories won't be evaluated.
filetype indent plugin on
syntax on
set showmatch " show matching braces when over one side
