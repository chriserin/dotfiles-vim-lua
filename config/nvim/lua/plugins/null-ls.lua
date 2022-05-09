local present, null_ls = pcall(require, 'null-ls')

if not present then
  return
end

local prettier_filetypes = {
  'javascript',
  'javascriptreact',
  'typescript',
  'typescriptreact',
  'vue',
  'css',
  'scss',
  'less',
  'html',
  'json',
  'jsonc',
  'yaml',
  'markdown',
  'graphql',
  'handlebars',
  'svelte',
  'ruby',
}

local augroup = vim.api.nvim_create_augroup('LspFormatting', {})

-- these LSPs should not be used for formatting
local lsp_formatter_exclusions = {
  sumneko_lua = true
}

local format_on_save = function(client, bufnr)
  local supports_formatting = client.supports_method 'textDocument/formatting'
  local excluded = lsp_formatter_exclusions[client.name]

    if supports_formatting then
    vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = augroup,
      buffer = bufnr,
      callback = function()
        -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead.
        -- also check this comment:
        -- https://github.com/jose-elias-alvarez/null-ls.nvim/issues/844#issuecomment-1118414695
  print(vim.inspect(client.name))
  print(vim.inspect(excluded))
        -- if not excluded then
        vim.lsp.buf.formatting_sync()
      -- end
      end,
    })
  end
end
local M = {}

M.setup = function()
  local formatting = null_ls.builtins.formatting
  local diagnostics = null_ls.builtins.diagnostics
  local completion = null_ls.builtins.completion

  null_ls.setup {
    sources = {
      -- formatting.prettier.with {
      --   filetypes = prettier_filetypes,
      --   only_local = 'node_modules/.bin',
      -- },
      formatting.stylelint,
      formatting.isort,
      formatting.cmake_format,
      formatting.terraform_fmt,
      formatting.codespell,
      formatting.stylua,

      diagnostics.eslint,
      diagnostics.rubocop,

      completion.spell,
    },
    on_attach = function (client, bufnr )
      require('plugins.lsp').common_on_attach(client, bufnr)
        format_on_save(client, bufnr)
    end
  }
end

return M
