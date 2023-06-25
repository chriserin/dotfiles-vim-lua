local core_mappings = require 'core.mappings'

require('lazy').setup({
  {
    'hrsh7th/nvim-cmp',
    dependencies = {
      -- snippet engine, required by cmp
      {
        'L3MON4D3/LuaSnip',
        dependencies = {
          -- snippets!
          'rafamadriz/friendly-snippets',
        },
      },
      -- LSP driven completions
      'hrsh7th/cmp-nvim-lsp',
      -- completion from buffer text
      'hrsh7th/cmp-buffer',
      -- file path completion
      'hrsh7th/cmp-path',
      -- command line completion
      'hrsh7th/cmp-cmdline',
      -- neovim lua config api completion
      'hrsh7th/cmp-nvim-lua',
      -- emoji completion (triggered by `:`)
      'hrsh7th/cmp-emoji',
      -- snippets in completion sources
      'saadparwaiz1/cmp_luasnip',
      -- git completions
      'petertriho/cmp-git',
      -- tmux pane completion
      'andersevenrud/cmp-tmux',
      -- icons for the completion menu
      'onsails/lspkind.nvim',
    },
    config = function()
      require('plugins.cmp').setup()
    end,
  },

  -- installs/updates LSPs, linters and DAPs
  {
    'williamboman/mason.nvim',
    dependencies = {
      -- handles connection of LSP Configs and Mason
      'williamboman/mason-lspconfig.nvim',

      -- Collection of configurations for the built-in LSP client
      'neovim/nvim-lspconfig',

      -- required for setting up capabilities for cmp
      'hrsh7th/cmp-nvim-lsp',

      {
        'SmiteshP/nvim-navic',
        dependencies = 'neovim/nvim-lspconfig',
      },

      -- elixir commands from elixirls
      {
        'elixir-tools/elixir-tools.nvim',
        dependencies = { 'neovim/nvim-lspconfig', 'nvim-lua/plenary.nvim' },
      },
    },
    config = function()
      require('plugins.lsp').setup()
    end,
  },

  -- LSP UI utils
  {
    'glepnir/lspsaga.nvim',
    branch = 'main',
    config = function()
      require('plugins.lspsaga').setup()
    end,
  },

  -- LSP Output Panel
  {
    'mhanberg/output-panel.nvim',
    event = 'VeryLazy',
    opts = {},
  },

  -- automatically install tools using mason
  {
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    dependencies = {
      'williamboman/mason.nvim',
    },
    config = function()
      require('plugins.mason-tool-installer').setup()
    end,
  },

  -- Neovim as a language server to inject LSP diagnostics, code
  -- actions, and more via Lua.
  {
    'jose-elias-alvarez/null-ls.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',

      'lukas-reineke/lsp-format.nvim',
    },
    config = function()
      require('plugins.null-ls').setup()
    end,
  },

  -- like leap, but with tiny hops
  {
    'phaazon/hop.nvim',
    branch = 'v2',
    keys = core_mappings.hop_mappings,
    opts = {
      keys = 'etovxqpdygfblzhckisuran',
    },
  },

  --  pretty diagnostics, references, telescope results, quickfix and location
  --  list to help you solve all the trouble your code is causing.
  {
    'folke/trouble.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    keys = core_mappings.trouble_mappings,
    opts = {},
  },

  -- modern vim command line replacement, requires nvim 0.9 or higher
  {
    'folke/noice.nvim',
    enabled = true,
    event = 'VeryLazy',
    opts = {
      lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      presets = {
        -- you can enable a preset by setting it to true, or a table that will override the preset config
        -- you can also add custom presets that you can enable/disable with enabled=true
        bottom_search = true, -- use a classic bottom cmdline for search
        long_message_to_split = true, -- long messages will be sent to a split
        lsp_doc_border = true, -- add a border to hover docs and signature help
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
  },

  -- color schemes
  ----------------
  {
    'folke/tokyonight.nvim',
    lazy = false, -- make sure we load this during startup
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require('tokyonight').setup {
        style = 'storm',
        transparent = true,
      }

      vim.cmd [[colorscheme tokyonight]]
    end,
  },

  -- highlight color hex codes with their color (fast!)
  {
    'norcalli/nvim-colorizer.lua',
    opts = {
      '*',
      '!lazy',
    },
  },

  -- highlight and search todo/fixme/hack etc comments
  {
    'folke/todo-comments.nvim',
    dependencies = 'nvim-lua/plenary.nvim',
    opts = {},
  },

  -- status line
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
    config = function()
      require('plugins.lualine').setup()
    end,
  },

  -- Visual git gutter (also used by feline)
  {
    'lewis6991/gitsigns.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('plugins.gitsigns').setup()
    end,
  },

  -- syntax highlighting for zinit (zsh plugin manager)
  { 'zdharma-continuum/zinit-vim-syntax', ft = { 'zsh' } },

  -- Comment out code easily
  {
    'numToStr/Comment.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('plugins.comment').setup()
    end,
  },

  -- delete unused buffers
  { 'schickling/vim-bufonly', cmd = 'BO' },

  -- nginx syntax support
  { 'chr4/nginx.vim' },

  -- run tests at the speed of thought
  {
    'janko-m/vim-test',
    dependencies = { 'benmills/vimux' },
    init = function()
      vim.g['test#strategy'] = 'vimux'
      -- accommodations for Malomo's unusual folder structure on Dash
      vim.cmd [[let test#javascript#jest#file_pattern = '\v(__tests__/.*|(spec|test|__tests__))\.(js|jsx|coffee|ts|tsx)$']]
    end,
    config = function()
      require('core.mappings').vim_test_mappings()
    end,
  },

  -- Highlight Yanked String
  { 'machakann/vim-highlightedyank' },

  -- git integration
  {
    'tpope/vim-fugitive',
    config = function()
      require('core.mappings').fugitive_mappings()
    end,
  },

  -- github support for fugitive
  {
    'tpope/vim-rhubarb',
    dependencies = { 'tpope/vim-fugitive' },
  },

  --  Better syntax highlighting (and more)
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'RRethy/nvim-treesitter-endwise',
      'nvim-treesitter/playground',
      'nvim-treesitter/nvim-treesitter-context',
    },
    config = function()
      require('plugins.treesitter').setup()
    end,
  },

  -- support for MJML templates
  {
    'amadeus/vim-mjml',
  },

  -- auto complete closable pairs
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    opts = {},
  },

  -- auto close html/tsx tags using TreeSitter
  {
    'windwp/nvim-ts-autotag',
    opts = {},
  },

  -- file tree
  {
    'nvim-tree/nvim-tree.lua',
    keys = require('core.mappings').nvim_tree_mappings,
    cmd = 'NvimTreeToggle',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('plugins.nvimtree').setup()
    end,
  },

  -- growing collection of settings, commands and mappings put together to make
  -- working with the location list/window and the quickfix list/window smoother
  'romainl/vim-qf',

  -- Simple plugin for placing signs in buffer's gutter next to lines that appear in the QuickFix results.
  'matthias-margush/qfx.vim',

  -- navigate to directory of current file using `-`
  'tpope/vim-vinegar',

  -- automatically adjusts 'shiftwidth' and 'expandtab' heuristically
  'tpope/vim-sleuth',

  -- ruby gem info directly in a Gemfile
  { 'alexbel/vim-rubygems', ft = { 'ruby' } },

  -- Elixir: {{{

  -- elixir text objects
  {
    'kevinkoltz/vim-textobj-elixir',
    dependencies = { 'kana/vim-textobj-user' },
    ft = { 'elixir' },
  },

  -- pulls info on hex packages (dependencies mattn/webapi-vim)
  { 'lucidstack/hex.vim', ft = { 'elixir' }, dependencies = { 'mattn/webapi-vim' } },
  -- }}},

  -- add text object for HTML attributes - allows dax cix etc
  {
    'whatyouhide/vim-textobj-xmlattr',
    dependencies = { 'kana/vim-textobj-user' },
  },

  -- graphql support
  'jparise/vim-graphql',

  -- Vim sugar for the UNIX shell commands that need it the most.
  'tpope/vim-eunuch',

  -- allow (non-native) plugins to the . command
  'tpope/vim-repeat',

  -- Surround text with closures
  'tpope/vim-surround',

  -- vim projectionist allows creating :Esomething custom shortcuts (required by vim rake)
  {
    'tpope/vim-projectionist',
    config = function()
      require('plugins.projectionist').setup()
    end,
  },

  -- vim unimpaired fixes daily annoyances
  'tpope/vim-unimpaired',

  -- abolish.vim: easily search for, substitute, and abbreviate multiple variants
  -- of a word
  'tpope/vim-abolish',

  -- Support emacs keybindings in insert mode
  'tpope/vim-rsi',

  -- RagTag: Auto-close html tags + mappings for template scripting languages
  'tpope/vim-ragtag',

  -- smarter gx mapping
  {
    'chrishrb/gx.nvim',
    event = { 'BufEnter' },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },

  -- automatic bulleted lists
  {
    'dkarter/bullets.vim',
    init = function()
      vim.g.bullets_enabled_file_types = {
        'markdown',
        'text',
        'gitcommit',
        'scratch',
      }
    end,
  },

  -- replacement for matchit
  {
    'andymass/vim-matchup',
    init = function()
      vim.g.matchup_matchparen_deferred = 1
    end,
  },

  -- window animations
  { 'camspiers/animate.vim' },

  -- show trailing white spaces and automatically delete them on write
  {
    'zakharykaplan/nvim-retrail',
    config = function()
      require('plugins.retrail').setup()
    end,
  },

  -- Convert code to multiline
  {
    'AndrewRadev/splitjoin.vim',
    init = function()
      vim.g.splitjoin_align = 1
      vim.g.splitjoin_trailing_comma = 1
      vim.g.splitjoin_ruby_curly_braces = 0
      vim.g.splitjoin_ruby_hanging_args = 0
    end,
  },

  -- Toggle between different language verbs or syntax styles
  {
    'AndrewRadev/switch.vim',
    init = function()
      vim.g.switch_custom_definitions = {
        { 'up', 'down', 'change' },
        { 'add', 'drop', 'remove' },
        { 'create', 'drop' },
        { 'row', 'column' },
        { 'first', 'second', 'third', 'fourth', 'fifth' },
        { 'yes', 'no' },
      }
    end,
  },

  -- The ultimate undo history visualizer for VIM
  {
    'mbbill/undotree',
    config = function()
      require('core.mappings').undotree_mappings()
    end,
  },

  -- Rust support
  { 'rust-lang/rust.vim', ft = { 'rust' } },

  --  Indent lines (visual indication)
  {
    'lukas-reineke/indent-blankline.nvim',
    config = function()
      require('plugins.indent_blankline').setup()
    end,
  },

  -- resize windows in vim naturally
  {
    'simeji/winresizer',
    cmd = 'WinResizerStartResize',
    config = function()
      require('core.mappings').winresizer_mappings()
    end,
  },

  -- smooth scrolling in neovim
  {
    'declancm/cinnamon.nvim',
    opts = {},
  },

  -- fuzzy find things
  {
    'nvim-telescope/telescope.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-telescope/telescope-file-browser.nvim',
      'nvim-telescope/telescope-github.nvim',
      'olacin/telescope-cc.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      'm-demare/attempt.nvim',
      'folke/tokyonight.nvim',
    },
    config = function()
      require('plugins.telescope').setup()
    end,
  },

  -- better ui for vim.ui commands
  {
    'stevearc/dressing.nvim',
    opts = {},
  },

  -- RipGrep - grep is dead. All hail the new king RipGrep.
  {
    'jremmen/vim-ripgrep',
    init = function()
      -- allow hidden files to be searched and smart case
      vim.g.rg_command = 'rg --vimgrep --hidden --smart-case'
      vim.g.rg_highlight = 1
    end,
    config = function()
      require('core.mappings').ripgrep_mappings()
    end,
  },

  -- displays a popup with possible key bindings e.g. <leader>f will show f as
  -- the next possible character
  {
    'folke/which-key.nvim',
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {},
  },

  -- same as tabular but by Junegunn and way easier
  {
    'junegunn/vim-easy-align',
    config = function()
      require('core.mappings').easy_align_mappings()
    end,
  },

  -- Single tabpage interface for easily cycling through diffs for all modified files for any git rev.
  {
    'sindrets/diffview.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
    },
  },

  -- manage github gists
  { 'mattn/gist-vim', cmd = 'Gist', dependencies = { 'mattn/webapi-vim' } },

  -- PostgreSQL highlighting
  { 'exu/pgsql.vim' },

  -- Helm Chart syntax
  { 'towolf/vim-helm' },

  -- attempt stuff using scratch buffer and pre-configured bootstrap
  {
    'm-demare/attempt.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    config = function()
      require('plugins.attempt').setup()
    end,
  },

  --- TMUX ---

  -- tmux config file stuff
  { 'tmux-plugins/vim-tmux', ft = 'tmux' },

  -- seamless tmux/vim pane navigation
  'christoomey/vim-tmux-navigator',

  -- Resize tmux panes and Vim windows with ease.
  'RyanMillerC/better-vim-tmux-resizer',

  -- support editorconfig files
  'gpanders/editorconfig.nvim',

  -- notifications
  {
    'rcarriga/nvim-notify',
    config = function()
      local notify = require 'notify'
      notify.setup {
        background_colour = '#000',
      }
      vim.notify = notify
    end,
  },
}, { concurrency = 8 })
