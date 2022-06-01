local cmd = vim.api.nvim_create_user_command

cmd('SqlFormat', "!sqlformat -a %", {})

-- easy access commands
cmd('Plugins', "edit ~/.config/nvim/lua/plugins/init.lua", {})
cmd('Mappings', "edit ~/.config/nvim/lua/core/mappings.lua", {})
cmd('Commands', "edit ~/.config/nvim/lua/core/commands.lua", {})
cmd('Options', "edit ~/.config/nvim/lua/core/options.lua", {})
cmd('VimNotes', "edit ~/.config/nvim/vim-notes.txt", {})
cmd('LuaNotes', "edit ~/.config/nvim/lua/lua-notes.lua", {})
cmd('Zsh', "edit ~/.zshrc", {})
cmd('ZshLocal', "edit ~/.zshrc.local", {})

cmd(
  "PackerEdit",
  "lua require('cerin.utils').edit_plugin(<f-args>)",
  {complete = require("packer").plugin_complete, nargs = 1}
)

cmd("Glow", "lua require('cerin.utils').glow(<f-args>)", {complete = 'file', nargs = '?'})

cmd('W', ':noa write', {})
