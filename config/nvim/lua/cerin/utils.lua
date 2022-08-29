local M = {}

function M.edit_plugin(plugin_name)
  local packer = require 'packer'
  local packer_root = packer.config.package_root

  vim.cmd('edit ' .. packer_root .. '/packer/start/' .. plugin_name)
end

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
      print('Closing window', win)
    end
  end
end

return M
