-- Surround text with closures
---@type LazySpec
return {
  'kylechui/nvim-surround',
  event = { 'BufReadPost', 'BufNewFile' },
  version = '*',
  opts = {},
}
