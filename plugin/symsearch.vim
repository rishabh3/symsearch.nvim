if exists('g:loaded_symsearch') | finish | endif " prevent loading file twice
let s:save_cpo = &cpo " save user coptions
set cpo&vim           " reset them to defaults

" command to run our plugin
command! SymMethodSearch lua require("symsearch").show_symbols("methods") 
command! SymFieldSearch lua require("symsearch").show_symbols("fields")
command! SymClassSearch lua require("symsearch").show_symbols("class")
command! ReloadSymbols lua require("symsearch").reload_symbols()

augroup SymSearch
    autocmd BufLeave * lua require("symsearch").cleanup()
augroup end

let g:loaded_symsearch = 1
