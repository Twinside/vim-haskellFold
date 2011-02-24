" =============================================================================
" Descriptions:  Provide a function providing folding information for haskell
"           files.
" Maintainer:        Vincent B (twinside@gmail.com)
" Warning: Assume the presence of type signatures on top of your functions to
"          work well.
" Usage:   drop in ~/vimfiles/plugin or ~/.vim/plugin
" Version:     1.2
" Changelog: - 1.2 : Reacting to file type instead of file extension.
"            - 1.1 : Adding foldtext to bet more information.
"            - 1.0 : initial version
" =============================================================================
if exists("g:__HASKELLFOLD_VIM__")
    finish
endif
let g:__HASKELLFOLD_VIM__ = 1

" Top level bigdefs
fun! s:HaskellFoldMaster( line ) "{{{
    return a:line =~ '^data\s'
      \ || a:line =~ '^type\s'
      \ || a:line =~ '^newdata\s'
      \ || a:line =~ '^class\s'
      \ || a:line =~ '^instance\s'
      \ || a:line =~ '^[^:]\+\s*::'
endfunction "}}}

" Top Level one line shooters.
fun! s:HaskellSnipGlobal(line) "{{{
    return a:line =~ '^module'
      \ || a:line =~ '^import'
      \ || a:line =~ '^infix[lr]\s'
endfunction "}}}

" The real folding function
fun! HaskellFold( lineNum ) "{{{
    let line = getline( a:lineNum )

    " Beginning of comment
    if line =~ '^\s*--' 
        return 2
    endif

    if s:HaskellSnipGlobal( line )
        return 0
    endif

    if line =~ '^\s*$'
        let nextline = getline(a:lineNum + 1)
        if s:HaskellFoldMaster( nextline ) > 0 || s:HaskellSnipGlobal( nextline ) > 0
            \ || nextline =~ "^--"
            return 0
        else
            return -1
        endif
    endif

    return 1
endfunction "}}}

" This function skim over function definitions
" skiping comments line :
" -- ....
" and merging lines without first non space element, to
" catch the full type expression.
fun! HaskellFoldText() "{{{
	let i = v:foldstart
	let retVal = ''
	let began = 0

	while i <= v:foldend
        let line = getline(i)
        if began == 0 && !(line =~ '^\s*--.*$')
            let retVal = substitute(line, '\s\+--.*', ' ','')
            let began = 1
        elseif began != 0 && line =~ '^\s\+\S'
            let retVal = retVal . substitute( substitute( line
                                                      \ , '\s\+\(.*\)$'
                                                      \ , ' \1', '' )
                                          \ , '\s\+--.*', ' ','')
        elseif began != 0
            break
        endif

		let i = i + 1
    endwhile

    if retVal == ''
        " We didn't found any meaningfull text
        return foldtext()
    endif

    return retVal
endfunction "}}}

fun! s:setHaskellFolding() "{{{
    setlocal foldexpr=HaskellFold(v:lnum)
    setlocal foldtext=HaskellFoldText()
    setlocal foldmethod=expr
endfunction "}}}

augroup HaskellFold
    au!
    au FileType Haskell call s:setHaskellFolding()
augroup END

