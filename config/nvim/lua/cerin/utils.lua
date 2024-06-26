local M = {}

local open_glow = function(path)
  vim.cmd('edit term://glow ' .. path)
end

local normalize_path = function(path)
  if path == nil then
    return vim.fn.expand '%'
  else
    return path
  end
end

function M.glow(path)
  local normalizedPath = normalize_path(path)
  open_glow(normalizedPath)
end

function M.close_all_float_windows()
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' then
      vim.api.nvim_win_close(win, false)
    end
  end
end

function M.filter_out_noise()
  require('indent_blankline.commands').disable()
  vim.opt_local.number = false
  require('gitsigns.config').config.signcolumn = false
  require('gitsigns.actions').refresh()
  vim.diagnostic.hide()
end

function M.filter_in_noise()
  require('indent_blankline.commands').enable()
  vim.opt_local.number = true
  require('gitsigns.config').config.signcolumn = true
  require('gitsigns.actions').refresh()
  vim.diagnostic.show(nil, 0, nil, nil)
end

function M.print_diagnostic()
  print('Source: ' .. vim.diagnostic.get_next().source)
end

function M.set_log_level(log_level)
  print('LOG LEVEL ' .. log_level)
  vim.lsp.set_log_level(log_level)
end

return M
