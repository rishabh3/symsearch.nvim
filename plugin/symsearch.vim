if exists('g:loaded_symsearch') | finish | endif " prevent loading file twice
let s:save_cpo = &cpo " save user coptions
set cpo&vim           " reset them to defaults

" command to run our plugin
command! SymMethodSearch lua require("symsearch").show_method_symbols() 
command! SymFieldSearch lua require("symsearch").show_field_symbols()
command! SymClassSearch lua require("symsearch").show_class_symbols()
command! ReloadSymbols lua require("symsearch").reload_symbols()

let g:loaded_symsearch = 1
