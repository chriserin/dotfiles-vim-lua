
local nmap = function(tbl)
  vim.keymap.set('n', tbl[1], tbl[2], tbl[3])
end

local default_opts = { noremap = true, silent = true }
vim.keymap.set({'n', 'v', 'o'}, 'H', require('cerin.tree-climber').goto_parent)
vim.keymap.set({'n', 'v', 'o'}, 'L', require('cerin.tree-climber').goto_child, default_opts)
vim.keymap.set({'n', 'v', 'o'}, 'K', require('cerin.tree-climber').goto_prev, default_opts)
vim.keymap.set('n', '<c-k>', require('cerin.tree-climber').swap_prev, default_opts)
vim.keymap.set('n', '<c-j>', require('cerin.tree-climber').swap_next, default_opts)
vim.keymap.set('n', '<leader>j', require('cerin.tsquery_jest_runner').run_jest_test, default_opts)

local M = {}

M.telescope_mappings = function()
  nmap { '<leader>fc', require('cerin.telescope').find_controllers, default_opts }
  nmap { '<leader>fv', require('cerin.telescope').find_views, default_opts }
  nmap { '<leader>fj', require('cerin.telescope').find_js_files, default_opts }
  nmap { '<leader>ft', require('cerin.telescope').find_js_test_files, default_opts }
end

return M
