---@type LazySpec
return {
  'chriserin/ft.nvim',
  dir = '~/projects/features/ft.nvim',
  event = { 'BufReadPre *.ft', 'BufNewFile *.ft' },
  cmd = { 'FtSync', 'FtList', 'FtStatus' },
  opts = {},
}
