local cmd = vim.api.nvim_create_user_command

cmd('SqlFormat', '!sqlformat -a %', {})

-- easy access commands
cmd('Plugins', 'edit ~/.config/nvim/lua/plugins/', {})
cmd('Mappings', 'edit ~/.config/nvim/lua/core/mappings.lua', {})
cmd('Commands', 'edit ~/.config/nvim/lua/core/commands.lua', {})
cmd('Options', 'edit ~/.config/nvim/lua/core/options.lua', {})
cmd('VimNotes', 'edit ~/.config/nvim/vim-notes.txt', {})
cmd('LuaNotes', 'edit ~/.config/nvim/lua/lua-notes.lua', {})
cmd('Zsh', 'edit ~/.zshrc', {})
cmd('ZshLocal', 'edit ~/.zshrc.local', {})

cmd('Glow', "lua require('cerin.utils').glow(<f-args>)", { complete = 'file', nargs = '?' })

cmd('W', ':noa write', {})

cmd('DisableIndentLines', "lua require('indent_blankline.commands').disable()", {})
cmd('EnableIndentLines', "lua require('indent_blankline.commands').enable()", {})

cmd('LspLogLevel', "lua require('cerin.utils').set_log_level(<f-args>)", { nargs = 1 })

cmd('GRW', ':Gread | noa W', { nargs = 0 })
cmd('Sync', ':Lazy sync', { nargs = 0 })

local function rg_in_cwd(cmdtable)
  local oildir = require('oil').get_current_dir()
  if not (oildir == nil) then
    vim.cmd.Rg(cmdtable.fargs[1], oildir)
  else
    vim.cmd.Rg(cmdtable.fargs[1], vim.fn.expand '%:h')
  end
end
cmd('Crg', rg_in_cwd, { nargs = 1 })
