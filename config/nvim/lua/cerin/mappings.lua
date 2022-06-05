
-- M.jester_mappings = function()
--   nmap { '<leader>j', ":lua require('jester').run()<cr>" }
-- end

vim.keymap.set('n', '<leader>j', ":lua require('cerin.tsquery_jest_runner').run_jest_test()<cr>")
