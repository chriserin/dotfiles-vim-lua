local M = {}

local default_find_command = {
  'fd',
  '--type',
  'f',
  '--strip-cwd-prefix',
  '--hidden',
  '--follow',
  '--ignore-file',
  '~/.gitignore',
}

local with_extensions = function(extensions)
  local cloned_find_command = vim.list_slice(default_find_command)

  vim.list_extend(cloned_find_command, extensions)

  return {
    find_command = cloned_find_command
  }
end

M.find_controllers = function()
  local extensions = {
    ".*_controller.ex$"
  }

  require('telescope.builtin').find_files(
    with_extensions(extensions)
  )
end

M.find_views = function()
  local extensions = {
    ".*_view.ex$"
  }

  require('telescope.builtin').find_files(
    with_extensions(extensions)
  )
end

M.find_js_files = function()
  local extensions = {
    "-E",
    "*test*",
    ".*.(js|jsx|ts|tsx)$"
  }

  require('telescope.builtin').find_files(
    with_extensions(extensions)
  )
end

M.find_js_test_files = function()
  local extensions = {
    ".*.test.(js|jsx|ts|tsx)$"
  }

  require('telescope.builtin').find_files(
    with_extensions(extensions)
  )
end

return M
