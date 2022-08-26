local present, bufferline = pcall(require, 'bufferline')

if not present then
  return
end

local default = {
  options = {
    diagnostics = 'nvim_lsp',
    always_show_bufferline = false,
    show_close_icon = false,
    show_buffer_close_icons = false,
    offsets = {
      {
        filetype = 'NvimTree',
        text = 'File Explorer',
        text_align = 'center',
      },
    },
  },
}

local M = {}

M.setup = function()
  ---@diagnostic disable-next-line: redundant-parameter
  bufferline.setup(default)
end

return M
