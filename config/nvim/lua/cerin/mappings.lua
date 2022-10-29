local nmap = function(tbl)
  vim.keymap.set('n', tbl[1], tbl[2], tbl[3])
end

local default_opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>j', require('cerin.tsquery_jest_runner').run_jest_test, default_opts)

nmap { '<leader>cc', require('cerin.utils').close_all_float_windows, default_opts }
nmap { 'gt', require('cerin.utils').filter_out_noise, default_opts }
nmap { 'gT', require('cerin.utils').filter_in_noise, default_opts }

local M = {}

M.telescope_mappings = function()
  nmap { '<leader>fc', require('cerin.telescope').find_controllers, default_opts }
  nmap { '<leader>fv', require('cerin.telescope').find_views, default_opts }
  nmap { '<leader>fj', require('cerin.telescope').find_js_files, default_opts }
  nmap { '<leader>ft', require('cerin.telescope').find_js_test_files, default_opts }
end

return M
