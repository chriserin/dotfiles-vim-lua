local cmd = vim.api.nvim_create_user_command
local utils = require 'core.utils'

cmd('PrettyPrintJSON', '%!jq', {})
cmd('PrettyPrintXML', '!tidy -mi -xml -wrap 0 %', {})
cmd('PrettyPrintHTML', '!tidy -mi -xml -wrap 0 %', {})
cmd('BreakLineAtComma', ':normal! f,a<CR><esc>', {})
cmd('Retab', ':set ts=2 sw=2 et<CR>:retab<CR>', {})
cmd('CopyFullName', "let @+=expand('%')", {})
cmd('CopyPath', "let @+=expand('%:h')", {})
cmd('CopyFileName', "let @+=expand('%:t')", {})

cmd('RefreshJsonSchemas', utils.download_json_schemas, {})
cmd('Plugins', "edit ~/.config/nvim/lua/plugins/init.lua", {})
cmd('Mappings', "edit ~/.config/nvim/lua/core/mappings.lua", {})
cmd('Commands', "edit ~/.config/nvim/lua/core/commands.lua", {})
cmd('VimNotes', "edit ~/.config/nvim/vim-notes.txt", {})
cmd('LuaNotes', "edit ~/.config/nvim/lua/lua-notes.lua", {})
