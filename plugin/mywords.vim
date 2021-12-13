
if exists('g:loaded_mywords')
    finish
endif
let g:loaded_mywords = 1

call luaeval('require"mywords"')
