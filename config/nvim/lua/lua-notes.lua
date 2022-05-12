

-- This file is me lernin some lua
-- Comment code with `--` ... obviously

print 'hi'

print('hi')

print({1, 2, 3})

vim.pretty_print({1, 2, 3})

vim.pretty_print(vim)

local list_table = { 1, 2, 3, 4 }

-- get length of list
print(#list_table)

local lookup_table = {a = 1, b = 2, c = 3}

vim.pretty_print(lookup_table)
print(#lookup_table)


local edit_plugin = function(plugin_name)
  local packer = require("packer")
  local packer_root = packer.config.package_root

  vim.cmd("edit " .. packer_root .. "/packer/start/" ..  plugin_name)
end

-- edit_plugin("vim-fugitive")
-- vim.cmd [[command! -nargs=* -complete=customlist,v:lua.require'packer'.plugin_complete  PackerInstall lua require('packer').install(<f-args>)]]
vim.api.nvim_create_user_command("PackerEdit", "lua require('core.utils').edit_plugin(<f-args>)", {complete = require("packer").plugin_complete, nargs = 1})

require('core.utils').edit_plugin("vim-rsi")

vim.pretty_print(require('core.utils'))

package.loaded['core.utils'] = nil
vim.pretty_print(package.loaded['core.utils'])
