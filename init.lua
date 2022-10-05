-- init.lua - Neovim Configuration

-- Plugins ---------------------------------------------------------------------
-- Requires pre-installation of junegunn/vim-plug

local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/plugged')

Plug 'preservim/nerdtree'                      -- NERDTree File Browser
Plug 'neovim/nvim-lspconfig'                   -- Neovim default LSP configs
Plug 'hrsh7th/nvim-cmp'                        -- Autocomplete
Plug 'hrsh7th/cmp-nvim-lsp'                    -- Autocomplete/LSP interface
Plug 'udalov/kotlin-vim'                       -- Kotlin Syntax Highlighting
Plug 'habamax/vim-godot'                       -- GDScript support

-- Themes
Plug('catppuccin/nvim', { as = 'catppuccin' }) -- Catppuccin Theme
Plug 'sainnhe/sonokai'

vim.call('plug#end')

-- Globals ---------------------------------------------------------------------

-- Paths to dependencies (i.e. LSP binaries)
local paths = {
    omnisharp_binary = '/Users/cameron/bin/omnisharp/OmniSharp.exe',
    godot_binary = '/Applications/Godot.app',
}

-- Helpers that should be globally constant on a given platform. Useful for
-- per-system conditional configuration.
local globals = {
    platform = vim.loop.os_uname().sysname,
    is_windows = vim.loop.os_uname().sysname == 'Windows_NT',
    is_mac = vim.loop.os_uname().sysname == 'Darwin',
}

-- Leader Setup ----------------------------------------------------------------

vim.g.mapleader = ','

local function leader_key(key, command)
    vim.keymap.set('n', '<leader>' .. key, command)
end

-- Misc ------------------------------------------------------------------------

vim.g.fileformats = 'unix'
vim.g.fileformat = 'unix'

leader_key('r', ':source $MYVIMRC<CR>')
leader_key('p', ':set paste!<CR>:set paste?<CR>')

-- File Browsing ---------------------------------------------------------------
-- Requires 'preservim/nerdtree'

leader_key('a', ':NERDTreeToggle<CR>')

vim.g.NERDTreeIgnore = {
    -- Unity's .meta files
    '\\.meta$[[file]]',
    -- Godot's .import files
    '\\.import$[[file]]',
    -- C# project files
    '\\.csproj$[[file]]',
    '\\.sln$[[file]]',
}

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

-- Terminal --------------------------------------------------------------------

vim.keymap.set('t', '<Esc>', '<C-\\><C-n>') -- Esc -> Normal Mode

if (globals.is_windows) then
    -- On Windows, set the default shell to Powershell.
    -- from :help shell-powershell
    vim.cmd([[
        let &shell = executable('pwsh') ? 'pwsh' : 'powershell'
        let &shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
        let &shellredir = '-RedirectStandardOutput %s -NoNewWindow -Wait'
        let &shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
        set shellquote= shellxquote=
    ]])
end

-- Autocomplete ----------------------------------------------------------------

local cmp = require('cmp') -- Requires 'hrsh7th/nvim-cmp'

vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }

local window_styling = cmp.config.window.bordered({
    border = 'single'
})


cmp.setup({
    snippet = {
        expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
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
    -- See /neovim/nvim-lspconfig README for suggestions.
    leader_key('f', vim.lsp.buf.formatting)
end

 -- Ties 'nvim-cmp' and 'nvim-lspconfig' together via 'cmp_nvim_lsp'
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = cmp_nvim_lsp.update_capabilities(capabilities)

-- Requires pre-installation of rust-analyzer
lspconfig['rust_analyzer'].setup({
    capabilities = capabilities,
    on_attach = on_attach,
})

-- Requires:
-- * Pre-installation of Omnisharp/omnisharp-roslyn
-- * Pre-installation of Mono (only on non-Windows platforms)
-- * Mono on PATH (only on non-Windows platforms)
local pid = vim.fn.getpid()

local runner = { "mono" }
if (globals.is_windows) then
    runner = {}
end 

local omnisharp_bin = paths.omnisharp_binary
lspconfig['omnisharp'].setup({
    capabilities = capabilities,
    on_attach = on_attach,
    cmd = {
        unpack(runner),
        omnisharp_bin,
        '--languageserver',
        '--hostPID',
        tostring(pid),
    },
    root_dir = function (fname)
        -- Expects Neovim to be opened in the directory containing the project
        return vim.fn.getcwd()
    end
})

-- Requires Godot installed (and running at LSP startup time)
vim.g.godot_executable = paths.godot_binary
lspconfig['gdscript'].setup({
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    }
})

-- Language Specifics ----------------------------------------------------------

local function set_pattern_as_filetype(pattern, filetype)
    vim.api.nvim_create_autocmd(
        { 'BufNewFile', 'BufRead' },
        {
            pattern = { pattern },
            callback = function() vim.bo.filetype = filetype end,
        }
    )
end

set_pattern_as_filetype('BUCK', 'bzl')

local function set_language_settings(language, tab_size, tab_type, line_length)
    vim.api.nvim_create_autocmd(
        { 'FileType' },
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

set_language_settings('lua',      4, 'space', 80)
set_language_settings('cs',       2, 'space', 100)
set_language_settings('rust',     4, 'space', 100)
set_language_settings('kotlin',   2, 'space', 100)
set_language_settings('bzl',      4, 'space', 100)
set_language_settings('cpp',      2, 'space', 100)
set_language_settings('gdscript', 4, 'space', 80)

