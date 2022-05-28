local present, lspsetup = pcall(require, 'nvim-lsp-setup')

if not present then
  return
end

local M = {}

local appearance_mods = function()
  -- set a border around lsp hover popover and signature help
  vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = 'rounded',
  })

  vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = 'rounded',
  })
end

M.setup = function()
  -- Make runtime files discoverable to the lua server
  local runtime_path = vim.split(package.path, ';')
  table.insert(runtime_path, 'lua/?.lua')
  table.insert(runtime_path, 'lua/?/init.lua')

  local on_attach = function(_, bufnr)
    -- Enable completion triggered by <c-x><c-o> (not sure this is necessary with
    -- vmp plugin)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    -- Use an on_attach function to only map the following keys
    -- after the language server attaches to the current buffer
    require('core.mappings').lsp_mappings(bufnr)
  end

  -- set up global mappings for diagnostics
  require('core.mappings').lsp_diagnostic_mappings()

  lspsetup.setup {
    -- I'll use my own mappings
    default_mappings = false,

    -- Global on_attach
    on_attach = on_attach,

    -- Global capabilities (cmp_nvim_lsp will automatically advertise
    -- capabilities) as per https://github.com/junnplus/nvim-lsp-setup#cmp-nvim-lsp
    -- capabilities = not necessary...

    -- Configuration of LSP servers
    servers = {
      -- Install LSP servers automatically
      -- LSP server configuration please see: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md

      -- Markdown
      prosemd_lsp = {},

      -- SQL
      sqlls = {},

      -- HTML snippets
      emmet_ls = {},

      -- TypeScript and JavaScript
      tsserver = {},

      -- Dockerfile
      dockerls = {},

      -- JSON
      jsonls = require 'plugins.lsp.jsonls',

      -- YAML
      yamlls = {
        on_attach = function(client, bufnr)
          on_attach(client, bufnr)

          -- disable and reset diagnostics for helm files (because the LS can't
          -- read them properly)
          if vim.bo[bufnr].buftype ~= '' or vim.bo[bufnr].filetype == 'helm' then
            vim.diagnostic.disable(bufnr)
            vim.defer_fn(function()
              vim.diagnostic.reset(nil, bufnr)
            end, 1000)
          end
        end,
      },

      -- CSS
      cssls = {},

      -- HTML
      html = {},

      -- Bash
      bashls = {},

      -- VimScript
      vimls = {},

      -- Lua
      sumneko_lua = {
        settings = {
          Lua = {
            runtime = {
              -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
              version = 'LuaJIT',
              -- Setup your lua path
              path = runtime_path,
            },
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { 'vim' },
            },
            workspace = {
              -- Make the server aware of Neovim runtime files
              library = vim.api.nvim_get_runtime_file('', true),
            },
            -- Do not send telemetry data containing a randomized but unique identifier
            telemetry = {
              enable = false,
            },
          },
        },
      },

      -- Elixir
      elixirls = {
        on_attach = function(client, bufnr)
          -- regular on_attach for lsp
          on_attach(client, bufnr)
          require('elixir').on_attach(client, bufnr)
        end,
      },
    },
  }

  appearance_mods()
end

return M
