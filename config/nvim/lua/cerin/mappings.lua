local nmap = function(tbl)
  vim.keymap.set('n', tbl[1], tbl[2], tbl[3])
end

local default_opts = { noremap = true, silent = true }

vim.keymap.set('n', '<leader>j', require('cerin.tsquery_jest_runner').run_jest_test, default_opts)

nmap { '<leader>cc', require('cerin.utils').close_all_float_windows, default_opts }
nmap { '<leader>gq', require('cerin.utils').filter_out_noise, default_opts }
nmap { '<leader>gQ', require('cerin.utils').filter_in_noise, default_opts }
nmap { '<leader>dd', require('cerin.utils').print_diagnostic, default_opts }

nmap { '<leader>gh', ':Git log -- %<CR>', { desc = '[G]it file [h]istory' } }
nmap { 'gh', ':Gitsigns stage_hunk', { desc = '[G]it file [h]istory' } }
local M = {}

-- M.telescope_mappings = function()
--   nmap { '<leader>fc', require('cerin.telescope').find_controllers, default_opts }
--   nmap { '<leader>fv', require('cerin.telescope').find_views, default_opts }
--   nmap { '<leader>fj', require('cerin.telescope').find_js_files, default_opts }
--   nmap { '<leader>ft', require('cerin.telescope').find_js_test_files, default_opts }
-- end

return M
