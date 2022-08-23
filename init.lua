-- init.lua - Neovim Configuration

-- Plugins ---------------------------------------------------------------------
-- Requires pre-installation of junegunn/vim-plug

local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'preservim/nerdtree'                      -- NERDTree File Browser
Plug 'neovim/nvim-lspconfig'                   -- Neovim default LSP configs
Plug 'hrsh7th/nvim-cmp'                        -- Autocomplete
Plug 'hrsh7th/cmp-nvim-lsp'                    -- Autocomplete/LSP interface

-- Themes
Plug('catppuccin/nvim', { as = 'catppuccin' }) -- Catppuccin Theme
Plug 'sainnhe/sonokai'

vim.call('plug#end')

-- Leader Setup ----------------------------------------------------------------

vim.g.mapleader = ','

local function leader_key(key, command)
    vim.keymap.set('n', '<leader>' .. key, command)
end

-- Misc ------------------------------------------------------------------------

leader_key('r', ':source $MYVIMRC<CR>')
leader_key('p', ':set paste!<CR>:set paste?<CR>')

-- File Browsing ---------------------------------------------------------------
-- Requires 'preservim/nerdtree'

leader_key('a', ':NERDTreeToggle<CR>')

-- Mouse -----------------------------------------------------------------------

vim.opt.mouse = 'a'

-- Editor Presentation ---------------------------------------------------------

vim.opt.number = true

local function setup_catppuccin(flavor)
    -- Available Flavors: macchiato, latte, frappe, mocha
    vim.g.catppucin_flavour = flavor or 'mocha'
    require('catppuccin').setup()
    vim.cmd [[colorscheme catppuccin]]
end

local function setup_sonokai(variant)
    -- Available Variants: default, atlantis, andromeda, shusia, maia
    vim.g.sonokai_style = variant or 'default'
    vim.cmd [[colorscheme sonokai]]
end

setup_sonokai()

-- Searching -------------------------------------------------------------------

vim.opt.hlsearch = true
vim.opt.incsearch = true

leader_key('h', ':set hlsearch!<CR>')

-- Buffers ---------------------------------------------------------------------

vim.opt.hidden = true

leader_key('b', ':ls<CR>:b<space>')
leader_key('n', ':bnext<CR>')
leader_key('N', ':bprev<CR>')

-- Splits ----------------------------------------------------------------------

vim.opt.splitbelow = true
vim.opt.splitright = true

leader_key('|', ':vsp %<CR>')
leader_key('-', ':sp %<CR>')

-- Autocomplete ----------------------------------------------------------------

local cmp = require('cmp') -- Requires 'hrsh7th/nvim-cmp'

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

local window_styling = cmp.config.window.bordered({
    border = 'single'
})


cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
        end,
    },
    window = {
        completion = window_styling,
        documentation = window_styling,
    },
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'vsnip' },
        { name = 'buffer' },
    })
})

-- LSPs ------------------------------------------------------------------------

local lspconfig = require('lspconfig')       -- Requires 'neovim/nvim-lspconfig'
local cmp_nvim_lsp = require('cmp_nvim_lsp') -- Requires 'hrsh7th/cmp-nvim-lsp'

local on_attach = function(client, buffer_number)
    -- TODO: See /neovim/nvim-lspconfig README for suggestions
end

 -- Ties 'nvim-cmp' and 'nvim-lspconfig' together via 'cmp_nvim_lsp'
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

-- Requires pre-installation of rust-analyzer
lspconfig['rust_analyzer'].setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

-- Requires pre-installation of Omnisharp/omnisharp-roslyn
local pid = vim.fn.getpid()
local omnisharp_bin = "C:\\Users\\Cameron\\bin\\Omnisharp\\OmniSharp.exe"
lspconfig['omnisharp'].setup{
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(pid) },
    root_dir = function (fname)
        -- Expects Neovim to be opened in the directory containing the project
        return vim.fn.getcwd()
    end
}

-- Language Specifics ----------------------------------------------------------

local function set_language_settings(language, tab_size, tab_type, line_length)
    vim.api.nvim_create_autocmd(
        { "FileType" },
        {
            pattern = { language },
            callback = function()
                vim.bo.tabstop = tab_size
                vim.bo.softtabstop = tab_size
                vim.bo.shiftwidth = tab_size
                vim.bo.expandtab = (tab_type == 'space')
                if line_length > 0 then
                    vim.wo.colorcolumn = tostring(line_length + 1)
                end
            end,
        }
    )
end

set_language_settings('lua',  4, 'space', 80)
set_language_settings('cs',   2, 'space', 100)
set_language_settings('rust', 4, 'space', 100)
