local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Global mappings.
vim.g.mapleader = " "      -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = " " -- Same for `maplocalleader`

-- Keymapping
vim.keymap.set('n', "<leader>pf", vim.cmd.Ex, { desc = "Explore project files (netrw)" })
vim.keymap.set('n', "<C-s>", vim.cmd.w, { desc = "Save file" })

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
    desc = 'Highlight when yanking (copying) text',
    group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
    callback = function()
        vim.highlight.on_yank()
    end,
})

require("lazy").setup({
    -- Theme
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000
    },

    -- Show keymap hints
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 300
        end,
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
        }
    },

    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.6',
        dependencies = { 'nvim-lua/plenary.nvim' },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set('n', "<leader>ff", builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        end,
    },

    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
    },

    { 'VonHeikemen/lsp-zero.nvim',       branch = 'v3.x' },
    { 'neovim/nvim-lspconfig' },
    { 'hrsh7th/cmp-nvim-lsp' },
    { 'hrsh7th/nvim-cmp' },
    { 'L3MON4D3/LuaSnip' },
})

require('nvim-treesitter.configs').setup {
    highlight = { enable = true, additional_vim_regex_highlighting = false }
}

local lsp_zero = require('lsp-zero')

-- only do lsp keymaps on active buffer
lsp_zero.on_attach(function(client, bufnr)
    -- see :help lsp-zero-keybindings
    -- to learn the available actions
    _ = client
    lsp_zero.default_keymaps({ buffer = bufnr })
    local opts = { buffer = bufnr }

    vim.keymap.set('n', 'gq', function()
        if vim.bo.filetype == 'py' then
            vim.cmd(":!black " .. vim.api.nvim_buf_get_name(0))
        else
            vim.lsp.buf.format({ async = false, timeout_ms = 10000 })
        end
    end, opts)
end)

vim.diagnostic.config({
    signs = false
})

vim.opt.signcolumn = 'no'

lsp_zero.set_server_config({
    on_init = function(client)
        client.server_capabilities.semanticTokensProvider = nil
    end,
})

require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = {},
    handlers = {
        -- default handlers
        function(server_name)
            require('lspconfig')[server_name].setup({})
        end,
        -- this is the "custom handler" for `example_server`
        --- in your own config you should replace `example_server`
        --- with the name of a language server you have installed
        lua_ls = function()
            --- in this function you can setup
            --- the language server however you want.
            --- in this example we just use lspconfig

            require('lspconfig').lua_ls.setup({
                settings = {
                    Lua = {
                        diagnostics = { globals = { 'vim' }, }
                    }
                }
            })
        end,
    },
})
