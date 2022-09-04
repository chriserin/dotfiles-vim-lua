local opt = vim.opt

-- swap file is more trouble than it's worth.  I got that undo history!
opt.swapfile = false

-- turn off the color column.  I'm looking for less visual noise.
opt.colorcolumn = ''

-- for some reason a low value here (like 100) will screw up the jumplist on
-- ctrl-o
-- opt.updatetime = 1000
