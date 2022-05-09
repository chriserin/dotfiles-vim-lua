local M = {}

function M.edit_plugin(plugin_name)
  local packer = require('packer')
  local packer_root = packer.config.package_root

  vim.cmd('edit ' .. packer_root .. '/packer/start/' ..  plugin_name)
end

local open_glow = function(path)
  vim.cmd("edit term://glow " .. path)
end

local normalize_path = function(path)
  if(path == nil) then
    return vim.fn.expand('%')
  else
    return path
  end
end

function M.glow(path)
  local normalizedPath = normalize_path(path)
  open_glow(normalizedPath)
end

return M
