" pypi - Simple plugin for checking the latest version of the Python package in Vim.
" Maintainer: kf <7kfpun@gmail.com>

scriptencoding utf-8


function! s:Strip(input_string)
    return substitute(a:input_string, '^\s*\(.\{-}\)\s*$', '\1', '')
endfunction


function! s:CleanLine(line)
    return s:Strip(substitute(a:line, "[#=><].*", "", ""))
endfunction


function! pypi#PypiCheck(package_name)
    let package_name = s:CleanLine(a:package_name)
    if !strlen(package_name)
        return
    endif

    let request_uri = 'https://pypi.python.org/pypi/'.package_name.'/json'
    try
        let response = webapi#http#get(request_uri)
        if response.status == 200
            return webapi#json#decode(response.content)['info']['version']
        else
            echomsg 'Package could not be found.'
        endif
    catch
        echoerr 'Something wrong with the internet: '.v:exception
    endtry
endfunction


function! s:ReplaceLatestVersion(line_number, text)
    let old_line = getline(a:line_number)
    if old_line =~ a:text
        echomsg 'It is already the latest version.'
        return
    endif

    if g:pypi_replace_with_comment
        let replace_text = a:text.'  # updated from: '.old_line
    else
        let replace_text = a:text
    endif
    call setline(a:line_number, replace_text)
endfunction


function! s:CheckLine(line, position)
    if a:position == ''
        let a:position = '.'
    endif

    let package = s:CleanLine(a:line)

    let latest_version = pypi#PypiCheck(package)
    if latest_version != '0'
        if g:pypi_print_results
            echo package.': '.latest_version
        endif

        if g:pypi_replace_latest_version
            let new_text = package.g:pypi_replace_type.latest_version
            call s:ReplaceLatestVersion(a:position, new_text)
        endif
    endif
endfunction


function! pypi#Pypi(...)
    if len(a:000)
        for package in a:000
            echo package.': '.pypi#PypiCheck(package)
        endfor
    else
        call s:CheckLine(getline('.'), '.')
    endif
endfunction
