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
" Top level bigdefs
fun! s:HaskellFoldMaster( line ) "{{{
    return a:line =~# '^data\s'
      \ || a:line =~# '^type\s'
      \ || a:line =~# '^newtype\s'
      \ || a:line =~# '^class\s'
      \ || a:line =~# '^instance\s'
      \ || a:line =~  '^[^:]\+\s*::'
endfunction "}}}

" Top Level one line shooters.
fun! s:HaskellSnipGlobal(line) "{{{
    return a:line =~# '^module'
      \ || a:line =~# '^import'
      \ || a:line =~# '^infix[lr]\s'
endfunction "}}}

" The real folding function
fun! haskellFold#HaskellFold( lineNum ) "{{{
    let line = getline( a:lineNum )

    " Beginning of comment
    if line =~ '^\s*--' || line =~ '^\s*{-'
        return 2
    endif

    if s:HaskellSnipGlobal( line )
        return 0
    endif

    if line =~ '^\s*$'
        let nextline = getline(a:lineNum + 1)
        if s:HaskellFoldMaster( nextline ) > 0 || s:HaskellSnipGlobal( nextline ) > 0
            \ || nextline =~ "^--" || nextline =~ "^{-"
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
fun! haskellFold#HaskellFoldText() "{{{
    let i = v:foldstart
    let retVal = ''
    let began = 0

    let commentOnlyLine = '^\s*--.*$'
    let monoLineComment = '\s*--.*$'
    let nonEmptyLine    = '^\s\+\S'
    let emptyLine       = '^\s*$'
    let multilineCommentBegin = '^\s*{-'
    let multilineCommentEnd = '-}'

    let short = get(g:, 'haskellFold_ShortText', 0)
    let isMultiLine = 0

    let line = getline(i)
    while i <= v:foldend

        if isMultiLine
            if line =~ multilineCommentEnd
                let isMultiLine = 0
                let line = substitute(line, '.*-}', '', '')

                if line =~ emptyLine
                    let i = i + 1
                    let line = getline(i)
                end
            else
                let i = i + 1
                let line = getline(i)
            end
        else
            if line =~ multilineCommentBegin
                let isMultiLine = 1
                continue
            elseif began == 0 && !(line =~ commentOnlyLine)
                let retVal = substitute(line, monoLineComment, ' ','')
                let began = 1
            elseif began != 0 && line =~ nonEmptyLine && !short
                let tempVal = substitute( line, '\s\+\(.*\)$', ' \1', '' )
                let retVal = retVal . substitute(tempVal, '\s\+--.*', ' ','')
            elseif began != 0
                break
            endif

            let i = i + 1
            let line = getline(i)
        endif
    endwhile

    if retVal == ''
        " We didn't found any meaningfull text
        return foldtext()
    endif

    return retVal
endfunction "}}}
