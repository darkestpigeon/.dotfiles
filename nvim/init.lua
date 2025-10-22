-- Neovim basic options
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.wo.relativenumber = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv('HOME') .. '/.vim/undodir'
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.o.completeopt = 'menuone,noselect'
vim.o.breakindent = true
vim.o.clipboard = 'unnamedplus'
vim.opt.scrolloff = 8
vim.opt.isfname:append('@-@')
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.ignorecase = true
vim.o.smartcase = true
vim.opt.colorcolumn = '80'

vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.list = true

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Specify Python host for Neovim
vim.g.python3_host_prog = os.getenv('HOME') .. '/.pyenv/versions/neovim/bin/python'

-- Lazy.nvim plugin loader
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable',
    lazypath
  }
end
vim.opt.rtp:prepend(lazypath)

-- Plugin setup using lazy.nvim
require('lazy').setup({
  -- Git-related plugins
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth
  'tpope/vim-sleuth',

  -- LSP configuration and related plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
      'folke/neodev.nvim'
    },
  },

  {'L3MON4D3/LuaSnip', version="v2.*", build="make install_jsregexp"},

  -- Show pending keybinds
  { 'folke/which-key.nvim', opts = {} },

  -- Color scheme
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'catppuccin'
    end,
  },

  -- Status line plugin
  {
    'nvim-lualine/lualine.nvim',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'catppuccin',
        component_separators = '|',
        section_separators = '',
      },
      sections = {
        lualine_a = {
          {
            'buffers',
            mode = 2 -- buffer name + buffer index
          },
          {
            'filename',
            path = 1 -- relative path
          }
        }
      }
    },
  },

  -- Indentation guides plugin
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    opts = {},
  },

  -- Commenting plugin
  { 'numToStr/Comment.nvim', opts = {} },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable 'make' == 1 end,
      },
    },
  },

  -- Treesitter for code highlighting and navigation
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    build = ':TSUpdate',
  },

  -- Harpoon for quick file navigation
  {
    'ThePrimeagen/harpoon',
    dependencies = { 'nvim-lua/plenary.nvim' },
  },

  'mbbill/undotree',
})

-- Keymaps configuration
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })
vim.keymap.set('n', 'J', 'mzJ`z')
vim.keymap.set('x', '<leader>p', '"_dP')
vim.keymap.set({ 'n', 'v' }, '<leader>y', '"+y')
vim.keymap.set({ 'n', 'v' }, '<leader>d', '"_d')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')
vim.keymap.set('n', '<leader>pv', vim.cmd.Ex, { desc = "Open file manager" })

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = '*',
})

-- Telescope configuration
require('telescope').setup({
  defaults = {
    mappings = { i = { ['<C-u>'] = false, ['<C-d>'] = false } },
  },
})
pcall(require('telescope').load_extension, 'fzf')
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10, previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', require('telescope.builtin').resume, { desc = '[S]earch [R]esume' })

-- Treesitter configuration (deferred for faster startup)
vim.defer_fn(function()
  require('nvim-treesitter.configs').setup({
    ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript', 'vimdoc', 'vim', 'bash', 'json', 'yaml', 'toml', 'nim' },
    auto_install = false,
    highlight = { enable = true },
    indent = { enable = true },
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = '<c-space>',
        node_incremental = '<c-space>',
        scope_incremental = '<c-s>',
        node_decremental = '<M-space>',
      },
    },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = { ['aa'] = '@parameter.outer', ['ia'] = '@parameter.inner', ['af'] = '@function.outer', ['if'] = '@function.inner', ['ac'] = '@class.outer', ['ic'] = '@class.inner' },
      },
      move = {
        enable = true,
        set_jumps = true,
        goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
        goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
        goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
        goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
      },
      swap = {
        enable = true,
        swap_next = { ['<leader>a'] = '@parameter.inner' },
        swap_previous = { ['<leader>A'] = '@parameter.inner' },
      },
    },
  })
end, 0)

-- LSP settings and keymaps
local on_attach = function(_, bufnr)
  local nmap = function(modes, keys, func, desc)
    if desc then desc = 'LSP: ' .. desc end
    vim.keymap.set(modes, keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('n', '<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('n', '<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('n', 'gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
  nmap('n', 'gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('n', 'gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
  nmap('n', '<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
  nmap('n', '<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('n', '<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  nmap('n', 'K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('i', '<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
  nmap('n', 'gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('n', '<leader>wl', function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, '[W]orkspace [L]ist Folders')
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function() vim.lsp.buf.format() end, { desc = 'Format current buffer with LSP' })
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- This will run whenever ANY LSP attaches to ANY buffer
    on_attach(vim.lsp.get_client_by_id(ev.data.client_id), ev.buf)
  end,
})

require('which-key').add({
  {'<leader>c', group = '[C]ode' },
  {'<leader>d', group = '[D]ocument' },
  {'<leader>g', group = '[G]it' },
  {'<leader>h', group = 'More git' },
  {'<leader>r', group = '[R]ename' },
  {'<leader>s', group = '[S]earch' },
  {'<leader>w', group = '[W]orkspace' },
})


local servers = {
  clangd = {},
  pyright = {},
  lua_ls = { Lua = { workspace = { checkThirdParty = false }, telemetry = { enable = false } } },
  nim_langserver = {}
}

require('neodev').setup()

require('mason').setup()
require('mason-lspconfig').setup({
  ensure_installed = vim.tbl_keys(servers),
  handlers = {
    function(server_name)
      require('lspconfig')[server_name].setup({
        capabilities = capabilities,
        settings = servers[server_name],
        filetypes = (servers[server_name] or {}).filetypes,
      })
    end,
  }
})


local luasnip = require 'luasnip'
require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup({})


vim.keymap.set('n', '<C-e>', require('harpoon.ui').toggle_quick_menu, { desc = 'Open harpoon menu' })
vim.keymap.set('n', '<leader>t', require('harpoon.mark').add_file, { desc = 'Add file to harpoon' })
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
