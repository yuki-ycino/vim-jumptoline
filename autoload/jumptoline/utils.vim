
function! jumptoline#utils#same_buffer(target, bnr, fullpath)
    return (a:bnr == a:target) || (bufnr(a:fullpath) == a:target)
endfunction

function! jumptoline#utils#get_target_wininfos(bnr, fullpath) abort
    let xs = []
    for x in getwininfo()
        let x['modified'] = getbufvar(x['bufnr'], '&modified', 0)
        if (x['tabnr'] == tabpagenr()) && (!x['terminal']) && (jumptoline#utils#same_buffer(x['bufnr'], a:bnr, a:fullpath) || !x['modified'])
            let xs += [x]
        endif
    endfor
    return xs
endfunction

function! jumptoline#utils#adjust_and_setpos(lnum, col)
    let line = getline(a:lnum)
    let s = ''
    let adjust_col = 0
    for c in split(line, '\zs')
        if strdisplaywidth(s) < a:col
            let s ..= c
            let adjust_col += 1
        else
            break
        endif
    endfor
    call setpos('.', [0, a:lnum, adjust_col, 0])
endfunction

function! jumptoline#utils#find_thefile(target)
    let path = expand(a:target)
    if filereadable(path)
        return [path]
    endif
    for info in getwininfo()
        for s in [fnamemodify(bufname(info['bufnr']), ':p:h'), getcwd(info['winnr'], info['tabnr'])]
            let xs = split(s, '[\/]')
            for n in reverse(range(0, len(xs) - 1))
                let path = expand(join(xs[:n] + [(a:target)], '/'))
                if filereadable(path)
                    return [path]
                endif
            endfor
        endfor
    endfor
    return []
endfunction

