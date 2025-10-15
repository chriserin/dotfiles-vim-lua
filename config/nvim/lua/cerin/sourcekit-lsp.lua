vim.lsp.config.sourcekit = {
  cmd = { 'sourcekit-lsp' },
  filetypes = { 'swift' },
  root_markers = { { 'Package.swift' }, '.git' },
}

vim.lsp.enable 'sourcekit'
