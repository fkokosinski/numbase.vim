let g:bases = [2, 10, 16]

function! GetNumBase(num)
    if a:num =~? '\v^0b[01]+$'
        return 2
    elseif a:num =~? '\v^[0-9]+$'
        return 10
    elseif a:num =~? '\v^0x[0-9a-f]+$'
        return 16
    endif
endfunction

function! GetBaseDigit(num)
    if a:num < 10
        return a:num . ""
    else
        return nr2char(a:num + 87)
    endif
endfunction

function! GetBaseNum(num, base)
    let l:num = str2nr(a:num, GetNumBase(a:num))
    let l:out = ""

    while l:num > 0
        let l:out = GetBaseDigit(float2nr(fmod(l:num, a:base))) . l:out
        let l:num = l:num / a:base
    endwhile

    if a:base == 2
        let l:out = "0b" . l:out
    elseif a:base == 16
        let l:out = "0x" . l:out
    endif

    return l:out
endfunction

function! ToggleNumber(dir)
    let l:num = expand("<cword>")
    let l:base = GetNumBase(l:num)

    let l:base_idx = index(g:bases, l:base)
    if l:base_idx + 1 == len(g:bases)
        let l:next_idx = 0
    else
        let l:next_idx = l:base_idx + a:dir
    endif

    let reg = @@
    execute "normal! ciw" . GetBaseNum(l:num, g:bases[l:next_idx])
    let @@ = reg
endfunction
