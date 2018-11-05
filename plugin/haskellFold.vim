if exists("g:__HASKELLFOLD_VIM__")
    finish
endif

let g:__HASKELLFOLD_VIM__ = 1

fun! SetHaskellFolding() "{{{
    setlocal foldexpr=haskellFold#HaskellFold(v:lnum)
    setlocal foldtext=haskellFold#HaskellFoldText()
    setlocal foldmethod=expr
endfunction "}}}
