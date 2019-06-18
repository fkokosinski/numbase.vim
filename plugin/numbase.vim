let g:numbase#base = [
            \2,
            \10,
            \16,
            \]

let g:numbase#base_regex = {
            \'2':   '\v^0b[01]+$',
            \'10':  '\v^[0-9]+$',
            \'16':  '\v^0x[0-9a-f]+$',
            \}

let g:numbase#base_prefix = {
            \'2':   '0b',
            \'16':  '0x',
            \}

" Get number base
"
" Parameters:
" num (String): Number to get base from
"
" Returns:
" Integer: Number base
function! s:GetNumBase(num) abort
    for [base, regex] in items(g:numbase#base_regex)
        if a:num =~? regex
            return str2nr(base)
        endif
    endfor
endfunction

" Get digit from a multiple digit number in base 10. Assumes digits of value
" greater than 9 are encoded with consecutive lowercase latin script
" characters
"
" Parameters:
" num (Integer): Digit(s) to encode
"
" Returns:
" String: Encoded digit
function! s:GetBaseDigit(num) abort
    if a:num < 10
        return a:num . ""
    else
        return nr2char(a:num + char2nr('a'))
    endif
endfunction

" Convert number to a new base
"
" Parameters:
" num (String): Number to convert
" base (Integer): Base to convert num to
"
" Returns:
" String: converted number to a given base
function! s:GetBaseNum(num, base) abort
    let l:num = str2nr(a:num, s:GetNumBase(a:num))
    let l:out = ""

    while l:num > 0
        let l:out = s:GetBaseDigit(float2nr(fmod(l:num, a:base))) . l:out
        let l:num = l:num / a:base
    endwhile

    return get(g:numbase#base_prefix, a:base, '') . l:out
endfunction

" Toggle number base
"
" Parameters:
" dir (Integer): index incerement in relation to current base index in
"                numbase#bases list
function! numbase#ChangeBase(dir) abort
   let l:num = expand("<cword>")
   let l:base = s:GetNumBase(l:num)

   " get next base index in numbase#base list
   let l:base_idx = index(g:numbase#base, l:base)
   if l:base_idx + 1 == len(g:numbase#base)
       let l:next_idx = 0
   else
       let l:next_idx = l:base_idx + a:dir
   endif

   " save register and change text; restore register
   let reg = @@
   execute "normal! ciw" . s:GetBaseNum(l:num, g:numbase#base[l:next_idx])
   let @@ = reg
endfunction
