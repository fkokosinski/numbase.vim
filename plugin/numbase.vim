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

function! s:GetNumBase(num) abort
    for [base, regex] in items(g:numbase#base_regex)
        if a:num =~? regex
            return str2nr(base)
        endif
    endfor
endfunction

function! s:GetBaseDigit(num) abort
    if a:num < 10
        return a:num . ''
    else
        return nr2char(a:num + char2nr('a') - 10)
    endif
endfunction

function! s:GetBaseNum(num, base) abort
    let l:num = str2nr(a:num, s:GetNumBase(a:num))
    let l:out = ''

    while l:num > 0
        let l:out = s:GetBaseDigit(float2nr(fmod(l:num, a:base))) . l:out
        let l:num = l:num / a:base
    endwhile

    return get(g:numbase#base_prefix, a:base, '') . l:out
endfunction

function! numbase#ChangeBase(dir) abort
   let l:num = expand('<cword>')
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
   execute 'normal! ciw' . s:GetBaseNum(l:num, g:numbase#base[l:next_idx])
   let @@ = reg
endfunction

function! numbase#ChangeBaseLines(dir) abort
    " get coordinates
    let [start_x, start_y] = getpos("'<")[1:2]
    let [end_x, end_y] = getpos("'>")[1:2]

    " change base in every line in selected block
    for lineno in range(start_x, end_x)
        execute 'normal! ' . lineno . 'G' . start_y  . 'lh'
        call numbase#ChangeBase(a:dir)
    endfor
endfunction
