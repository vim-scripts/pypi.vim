" pypi - Get the latest version of the package in Vim
" Maintainer: kf <7kfpun@gmail.com>

scriptencoding utf-8


if (exists("g:loaded_pypi") && g:loaded_pypi) || &cp
    finish
endif
let g:loaded_pypi = 1


silent! call webapi#json#decode('{}')
if !exists('*webapi#json#decode')
    echohl ErrorMsg | echomsg "pypi.vim requires webapi (https://github.com/mattn/webapi-vim)" | echohl None
    finish
endif


function! s:check_defined(variable, default)
    if !exists(a:variable)
        let {a:variable} = a:default
    endif
endfunction


call s:check_defined('g:pypi_print_results', 1)
call s:check_defined('g:pypi_replace_latest_version', 1)
call s:check_defined('g:pypi_replace_type', '==')
call s:check_defined('g:pypi_replace_with_comment', 0)


command! -nargs=* -range Pypi :<line1>,<line2>call pypi#Pypi(<f-args>)
