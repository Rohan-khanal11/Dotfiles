-- ================================================================
--  Stormbound Ink — Neovim (vim.pack-based)
--  Palette / highlights live in lua/mono.lua
-- ================================================================


-- ================================================================
--  Leader
-- ================================================================

vim.g.mapleader      = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true


-- ================================================================
--  Core options
-- ================================================================

local o = vim.opt

-- UI
o.termguicolors  = true
o.number         = true
o.relativenumber = true
o.cursorline     = true
o.signcolumn     = 'yes'
o.showmode       = false
o.wrap           = false
o.scrolloff      = 10
o.sidescrolloff  = 8
o.winblend       = 20
o.pumblend       = 20

-- Whitespace display
o.list      = true
o.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Behavior
o.mouse       = 'a'
o.confirm     = true
o.undofile    = true
o.breakindent = true
o.clipboard   = 'unnamedplus'
o.completeopt = { 'menuone', 'noselect' }
o.updatetime  = 250
o.timeoutlen  = 300

-- Search
o.ignorecase = true
o.smartcase  = true
o.inccommand = 'split'

-- Splits
o.splitright = true
o.splitbelow = true

-- Tabs & indentation
o.tabstop     = 4
o.shiftwidth  = 4
o.softtabstop = 4
o.expandtab   = true
o.smartindent = true


-- ================================================================
--  Plugins
-- ================================================================

vim.pack.add({
    { src = 'https://github.com/stevearc/oil.nvim' },
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope.nvim' },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    { src = 'https://github.com/nvim-tree/nvim-web-devicons' },
    { src = 'https://github.com/brenoprata10/nvim-highlight-colors' },
    { src = 'https://github.com/MeanderingProgrammer/render-markdown.nvim' },
})


-- ================================================================
--  Colorscheme (palette + highlights in lua/mono.lua)
-- ================================================================

require('mono').setup({ transparent = true })
require('mono').load()


-- ================================================================
--  Color display (#hex, rgb(), hsl(), named colors)
-- ================================================================

require('nvim-highlight-colors').setup({
    render              = 'virtual',   -- 'background' | 'foreground' | 'virtual'
    virtual_symbol      = '■',
    virtual_symbol_position = 'inline',
    enable_hex          = true,
    enable_short_hex    = true,
    enable_rgb          = true,
    enable_hsl          = true,
    enable_var_usage    = true,
    enable_named_colors = true,
    enable_tailwind     = false,
})

vim.keymap.set('n', '<leader>tc', '<cmd>HighlightColors Toggle<CR>', { desc = '[T]oggle [C]olor display' })


-- ================================================================
--  Markdown
-- ================================================================

-- Neovim bundles the markdown / markdown_inline tree-sitter parsers,
-- and its markdown ftplugin starts highlighting automatically.
require('render-markdown').setup({
    file_types   = { 'markdown' },
    render_modes = { 'n', 'c', 't' },   -- raw text while inserting
    heading  = { sign = false },
    code     = { sign = false, width = 'block', right_pad = 1 },
    bullet   = { icons = { '●', '○', '◆', '◇' } },
})

vim.keymap.set('n', '<leader>mp', '<cmd>RenderMarkdown toggle<CR>', { desc = '[M]arkdown [P]review toggle' })

vim.api.nvim_create_autocmd('FileType', {
    group   = vim.api.nvim_create_augroup('StormMarkdown', { clear = true }),
    pattern = 'markdown',
    callback = function()
        local l = vim.opt_local
        l.wrap         = true
        l.linebreak    = true
        l.conceallevel = 2
        l.spell        = true
        l.shiftwidth   = 2
        l.tabstop      = 2
        l.softtabstop  = 2
    end,
})


-- ================================================================
--  Oil
-- ================================================================

require('oil').setup({
    view_options = { show_hidden = true },
})

vim.keymap.set('n', '<leader>e', '<cmd>Oil<CR>', { desc = 'Open file explorer' })


-- ================================================================
--  Telescope
-- ================================================================

local telescope = require('telescope')
local builtin   = require('telescope.builtin')

telescope.setup({
    defaults = {
        sorting_strategy = 'ascending',
        winblend         = 20,
        layout_config    = { prompt_position = 'top' },
    },
})

vim.keymap.set('n', '<leader>sf', builtin.find_files,  { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep,   { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sb', builtin.buffers,     { desc = '[S]earch [B]uffers' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags,   { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume,      { desc = '[S]earch [R]esume' })


-- ================================================================
--  LSP
-- ================================================================

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('StormLspAttach', { clear = true }),
    callback = function(ev)
        local map = function(keys, fn, desc)
            vim.keymap.set('n', keys, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc })
        end

        -- Navigation
        map('gd', vim.lsp.buf.definition,      'Go to definition')
        map('gD', vim.lsp.buf.declaration,     'Go to declaration')
        map('gr', builtin.lsp_references,      'Go to references')
        map('gi', builtin.lsp_implementations, 'Go to implementation')
        map('K',  vim.lsp.buf.hover,           'Hover docs')

        -- Symbols
        map('<leader>ds', builtin.lsp_document_symbols,  'Document symbols')
        map('<leader>ws', builtin.lsp_workspace_symbols, 'Workspace symbols')

        -- Actions
        map('<leader>rn', vim.lsp.buf.rename,      'Rename symbol')
        map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
        map('<leader>f',  function()
            vim.lsp.buf.format({ async = true })
        end, 'Format buffer')

        -- Diagnostics
        map('[d',        function() vim.diagnostic.jump({ count = -1, float = true }) end, 'Previous diagnostic')
        map(']d',        function() vim.diagnostic.jump({ count = 1, float = true }) end,  'Next diagnostic')
        map('<leader>q', vim.diagnostic.setloclist, 'Diagnostics to loclist')
    end,
})


-- ================================================================
--  Diagnostics UI
-- ================================================================

vim.diagnostic.config({
    virtual_text     = { prefix = '●' },
    signs            = true,
    underline        = true,
    update_in_insert = false,
    severity_sort    = true,
    float = {
        border = 'rounded',
        source = true,
    },
})


-- ================================================================
--  Keymaps
-- ================================================================

local map = vim.keymap.set

map('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Window navigation
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move to left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move to right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move to lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move to upper window' })

-- Terminal
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Move by display line when no count is given
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true })
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true })


-- ================================================================
--  Autocommands
-- ================================================================

local ag = vim.api.nvim_create_augroup
local au = vim.api.nvim_create_autocmd

-- Highlight on yank
au('TextYankPost', {
    group    = ag('StormYank', { clear = true }),
    callback = function() vim.hl.on_yank() end,
})

-- Trim trailing whitespace on save (skipped for markdown, where two
-- trailing spaces mean a hard line break)
au('BufWritePre', {
    group = ag('StormTrimWhitespace', { clear = true }),
    callback = function()
        if vim.bo.filetype == 'markdown' then return end
        local pos = vim.api.nvim_win_get_cursor(0)
        vim.cmd([[%s/\s\+$//e]])
        vim.api.nvim_win_set_cursor(0, pos)
    end,
})

-- Restore cursor position
au('BufReadPost', {
    group = ag('StormCursorRestore', { clear = true }),
    callback = function()
        local mark       = vim.api.nvim_buf_get_mark(0, '"')
        local line_count = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= line_count then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})


-- ================================================================
--  Neovide
-- ================================================================

if vim.g.neovide then
    vim.g.neovide_transparency           = 0.5
    vim.g.neovide_background_color       = '#00000000'
    vim.g.neovide_floating_blur_amount_x = 6
    vim.g.neovide_floating_blur_amount_y = 6
end


-- ================================================================
--  Mode indicator / statusline (highlights in mono.lua)
-- ================================================================

local modes = {
    n = 'NORMAL',  i = 'INSERT',  v = 'VISUAL',
    V = 'V-LINE',  ['\22'] = 'V-BLOCK',
    c = 'COMMAND', R = 'REPLACE', t = 'TERMINAL',
    s = 'SELECT',  S = 'S-LINE',
}

local hl_map = {
    n       = 'StatusNormal',
    i       = 'StatusInsert',
    v       = 'StatusVisual',
    V       = 'StatusVisual',
    ['\22'] = 'StatusVisual',
    R       = 'StatusReplace',
    c       = 'StatusCommand',
    t       = 'StatusTerminal',
}

function _G.StatusLine()
    local mode  = vim.fn.mode()
    local label = modes[mode] or mode:upper()
    local hi    = hl_map[mode] or 'StatusNormal'
    return '%#' .. hi .. '# ' .. label .. ' %#StatusLine#| %f %m%=%l:%c '
end

vim.opt.statusline = '%{%v:lua.StatusLine()%}'
