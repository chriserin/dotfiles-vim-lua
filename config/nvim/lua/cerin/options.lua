local opt = vim.opt

-- swap file is more trouble than it's worth.  I got that undo history!
opt.swapfile = false

-- turn off the color column.  I'm looking for less visual noise.
opt.colorcolumn = ''

-- for some reason a low value here (like 100) will screw up the jumplist on
-- ctrl-o
-- opt.updatetime = 1000

-- reload the initial file after plugin eval to ensure all ft settings get set.
-- This allows the netrw ft to get setl nomod and to be hidden.
vim.schedule(function()
  vim.cmd 'buffer 1'
end)

vim.g.qf_auto_quit = 0
-- vim.lsp.set_log_level 'INFO'
