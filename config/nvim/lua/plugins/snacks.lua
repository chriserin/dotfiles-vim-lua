-- A collection of small QoL plugins for Neovim
---@type LazySpec
return {
  'folke/snacks.nvim',
  priority = 1000,
  keys = require('core.mappings').snack_mappings,
  lazy = false,
  init = function(_self)
    -- Setup some globals for debugging (lazy-loaded)
    _G.dbg = function(...)
      Snacks.debug.inspect(...)
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    _G.dd = function(...)
      Snacks.debug.inspect(...)
    end

    ---@diagnostic disable-next-line: duplicate-set-field
    _G.bt = function()
      Snacks.debug.backtrace()
    end

    vim.print = _G.dd

    -- tell LSPs when a file has been renamed (via NvimTree)
    local prev = { new_name = '', old_name = '' } -- Prevents duplicate events
    vim.api.nvim_create_autocmd('User', {
      pattern = 'NvimTreeSetup',
      callback = function()
        local events = require('nvim-tree.api').events
        events.subscribe(events.Event.NodeRenamed, function(data)
          if prev.new_name ~= data.new_name or prev.old_name ~= data.old_name then
            data = data
            Snacks.rename.on_rename_file(data.old_name, data.new_name)
          end
        end)
      end,
    })
  end,
  ---@module "snacks"
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    statuscolumn = { enabled = true },
    ---@class snacks.indent.Config
    indent = {
      enabled = true,
      animate = { enabled = false },
      -- this is what makes the scope look like an arrow
      chunk = { enabled = true },
    },
    words = { enabled = true },
    ---@class snacks.zen.Config
    zen = { enabled = true },
    scope = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        ---@type snacks.dashboard.Item[]
        keys = {
          { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
          { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
          { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
          { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
          {
            icon = ' ',
            key = 'c',
            desc = 'Config',
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = '󰣪 ', key = 'm', desc = 'Mason', action = ':Mason' },
          { icon = '󰒲 ', key = 'l', desc = 'Lazy', action = ':Lazy', enabled = package.loaded.lazy ~= nil },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
        -- Used by the `header` section
        header = [[
███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
    (btw)]],
      },
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
        { section = 'startup' },
      },
    },
  },
}
