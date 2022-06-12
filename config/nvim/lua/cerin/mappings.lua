
local keyopts = { noremap = true, silent = true }
vim.keymap.set({'n', 'v', 'o'}, 'H', require('cerin.tree-climber').goto_parent)
vim.keymap.set({'n', 'v', 'o'}, 'L', require('cerin.tree-climber').goto_child, keyopts)
vim.keymap.set({'n', 'v', 'o'}, 'J', require('cerin.tree-climber').goto_next, keyopts)
vim.keymap.set({'n', 'v', 'o'}, 'K', require('cerin.tree-climber').goto_prev, keyopts)
vim.keymap.set('n', '<c-k>', require('cerin.tree-climber').swap_prev, keyopts)
vim.keymap.set('n', '<c-j>', require('cerin.tree-climber').swap_next, keyopts)
vim.keymap.set('n', '<leader>j', require('cerin.tsquery_jest_runner').run_jest_test, keyopts)
