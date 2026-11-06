-- ================================================================
--  Stormbound Mono — pure black & white theme (lua/mono.lua)
--  Use:  require('mono').load()   -- or .setup({ transparent = false }) first
--  Hierarchy comes from brightness + bold/italic/underline, not hue.
-- ================================================================

local M = {}

M.opts = { transparent = true }

M.palette = {
    black = '#000000',
    g1    = '#0A0A0A',
    g2    = '#141414',
    g3    = '#1E1E1E',
    g4    = '#2B2B2B',
    g5    = '#3D3D3D',
    g6    = '#5C5C5C',
    g7    = '#7A7A7A',
    g8    = '#9A9A9A',
    g9    = '#BDBDBD',
    white = '#E8E8E8',
    pure  = '#FFFFFF',
}

local function groups(p, transparent)
    local bg = transparent and 'none' or p.black

    return {
        -- ── Base UI ──────────────────────────────────────────
        Normal       = { fg = p.white, bg = bg },
        NormalNC     = { fg = p.white, bg = bg },
        NormalFloat  = { fg = p.white, bg = bg },
        FloatBorder  = { fg = p.g6,    bg = bg },
        FloatTitle   = { fg = p.pure,  bg = bg, bold = true },
        EndOfBuffer  = { fg = p.g4 },
        SignColumn   = { fg = p.g6,    bg = bg },
        FoldColumn   = { fg = p.g6,    bg = bg },
        Folded       = { fg = p.g7,    bg = p.g2 },
        ColorColumn  = { bg = p.g2 },
        Conceal      = { fg = p.g7 },
        Cursor       = { fg = p.black, bg = p.pure },
        lCursor      = { fg = p.black, bg = p.pure },
        CursorLine   = { bg = p.g2 },
        CursorColumn = { bg = p.g2 },
        LineNr       = { fg = p.g5 },
        CursorLineNr = { fg = p.pure, bold = true },
        WinSeparator = { fg = p.g4 },
        VertSplit    = { fg = p.g4 },
        Visual       = { bg = p.g5 },
        VisualNOS    = { bg = p.g4 },
        Whitespace   = { fg = p.g4 },
        NonText      = { fg = p.g4 },
        SpecialKey   = { fg = p.g5 },
        MatchParen   = { fg = p.pure, bg = p.g5, bold = true },
        Directory    = { fg = p.pure, bold = true },
        Title        = { fg = p.pure, bold = true },

        -- ── Search ───────────────────────────────────────────
        Search    = { fg = p.black, bg = p.g8 },
        CurSearch = { fg = p.black, bg = p.pure, bold = true },
        IncSearch = { fg = p.black, bg = p.pure, bold = true },
        Substitute = { fg = p.black, bg = p.g9 },

        -- ── Messages ─────────────────────────────────────────
        ErrorMsg   = { fg = p.pure, bold = true, underline = true },
        WarningMsg = { fg = p.g9,   bold = true },
        MoreMsg    = { fg = p.g8 },
        ModeMsg    = { fg = p.g9, bold = true },
        Question   = { fg = p.g9 },

        -- ── Popup menu ───────────────────────────────────────
        Pmenu      = { fg = p.g9,    bg = p.g2 },
        PmenuSel   = { fg = p.black, bg = p.white },
        PmenuSbar  = { bg = p.g3 },
        PmenuThumb = { bg = p.g6 },
        PmenuKind  = { fg = p.g7, bg = p.g2 },
        WildMenu   = { fg = p.black, bg = p.white },

        -- ── Tabline ──────────────────────────────────────────
        TabLine     = { fg = p.g7, bg = p.g2 },
        TabLineSel  = { fg = p.black, bg = p.white, bold = true },
        TabLineFill = { bg = p.g1 },

        -- ── Spell ────────────────────────────────────────────
        SpellBad   = { undercurl = true, sp = p.white },
        SpellCap   = { undercurl = true, sp = p.g7 },
        SpellRare  = { undercurl = true, sp = p.g6 },
        SpellLocal = { undercurl = true, sp = p.g6 },

        -- ── Diff ─────────────────────────────────────────────
        DiffAdd    = { fg = p.pure, bg = p.g3 },
        DiffChange = { bg = p.g2 },
        DiffDelete = { fg = p.g6, bg = p.g2 },
        DiffText   = { fg = p.pure, bg = p.g5, bold = true },
        Added      = { fg = p.white },
        Changed    = { fg = p.g8 },
        Removed    = { fg = p.g6 },

        -- ── Syntax (vim) ─────────────────────────────────────
        Comment        = { fg = p.g6 },
        SpecialComment = { fg = p.g7, bold = true },
        Todo           = { fg = p.black, bg = p.g8, bold = true },
        Constant       = { fg = p.g9 },
        String         = { fg = p.g9 },
        Character      = { fg = p.g9 },
        Number         = { fg = p.g8 },
        Boolean        = { fg = p.g8, bold = true },
        Float          = { fg = p.g8 },
        Identifier     = { fg = p.white },
        Function       = { fg = p.pure },
        Statement      = { fg = p.pure, bold = true },
        Conditional    = { fg = p.pure, bold = true },
        Repeat         = { fg = p.pure, bold = true },
        Label          = { fg = p.pure, bold = true },
        Operator       = { fg = p.g8 },
        Keyword        = { fg = p.pure, bold = true },
        Exception      = { fg = p.pure, bold = true },
        PreProc        = { fg = p.g8, italic = true },
        Include        = { fg = p.g8, italic = true },
        Define         = { fg = p.g8, italic = true },
        Macro          = { fg = p.g8, italic = true },
        Type           = { fg = p.white, italic = true },
        StorageClass   = { fg = p.pure, bold = true },
        Structure      = { fg = p.white, italic = true },
        Typedef        = { fg = p.white, italic = true },
        Special        = { fg = p.g9 },
        SpecialChar    = { fg = p.pure },
        Delimiter      = { fg = p.g7 },
        Underlined     = { underline = true },
        Error          = { fg = p.pure, bold = true, underline = true },

        -- ── Treesitter ───────────────────────────────────────
        ['@variable']                  = { fg = p.white },
        ['@variable.builtin']          = { fg = p.pure, italic = true },
        ['@variable.parameter']        = { fg = p.g9, italic = true },
        ['@variable.member']           = { fg = p.g9 },
        ['@property']                  = { fg = p.g9 },
        ['@field']                     = { fg = p.g9 },
        ['@constant']                  = { fg = p.g9 },
        ['@constant.builtin']          = { fg = p.g8, bold = true },
        ['@module']                    = { fg = p.g9 },
        ['@namespace']                 = { fg = p.g9 },
        ['@function']                  = { fg = p.pure },
        ['@function.call']             = { fg = p.pure },
        ['@function.builtin']          = { fg = p.pure, italic = true },
        ['@function.method']           = { fg = p.pure },
        ['@function.method.call']      = { fg = p.pure },
        ['@constructor']               = { fg = p.white, bold = true },
        ['@keyword']                   = { fg = p.pure, bold = true },
        ['@keyword.function']          = { fg = p.pure, bold = true },
        ['@keyword.return']            = { fg = p.pure, bold = true, italic = true },
        ['@keyword.operator']          = { fg = p.pure, bold = true },
        ['@keyword.import']            = { fg = p.g8, italic = true },
        ['@string']                    = { fg = p.g9 },
        ['@string.escape']             = { fg = p.pure, bold = true },
        ['@string.regexp']             = { fg = p.g8 },
        ['@character']                 = { fg = p.g9 },
        ['@number']                    = { fg = p.g8 },
        ['@boolean']                   = { fg = p.g8, bold = true },
        ['@type']                      = { fg = p.white, italic = true },
        ['@type.builtin']              = { fg = p.g9, italic = true },
        ['@attribute']                 = { fg = p.g8, italic = true },
        ['@operator']                  = { fg = p.g8 },
        ['@punctuation.delimiter']     = { fg = p.g7 },
        ['@punctuation.bracket']       = { fg = p.g7 },
        ['@punctuation.special']       = { fg = p.g8 },
        ['@comment']                   = { fg = p.g6 },
        ['@comment.todo']              = { fg = p.black, bg = p.g8, bold = true },
        ['@comment.note']              = { fg = p.black, bg = p.g7, bold = true },
        ['@comment.warning']           = { fg = p.black, bg = p.g9, bold = true },
        ['@comment.error']             = { fg = p.black, bg = p.pure, bold = true },
        ['@tag']                       = { fg = p.pure, bold = true },
        ['@tag.attribute']             = { fg = p.g8, italic = true },
        ['@tag.delimiter']             = { fg = p.g7 },

        -- ── Markup / Markdown ────────────────────────────────
        ['@markup.heading']            = { fg = p.pure, bold = true },
        ['@markup.heading.1.markdown'] = { fg = p.pure,  bold = true },
        ['@markup.heading.2.markdown'] = { fg = p.white, bold = true },
        ['@markup.heading.3.markdown'] = { fg = p.g9,    bold = true },
        ['@markup.heading.4.markdown'] = { fg = p.g9 },
        ['@markup.heading.5.markdown'] = { fg = p.g8 },
        ['@markup.heading.6.markdown'] = { fg = p.g7 },
        ['@markup.strong']             = { fg = p.pure, bold = true },
        ['@markup.italic']             = { fg = p.white, italic = true },
        ['@markup.strikethrough']      = { fg = p.g6, strikethrough = true },
        ['@markup.underline']          = { underline = true },
        ['@markup.raw']                = { fg = p.g9, bg = p.g2 },
        ['@markup.link']               = { fg = p.g9 },
        ['@markup.link.label']         = { fg = p.white, underline = true },
        ['@markup.link.url']           = { fg = p.g7, underline = true },
        ['@markup.quote']              = { fg = p.g7, italic = true },
        ['@markup.list']               = { fg = p.g8 },
        ['@markup.list.checked']       = { fg = p.white },
        ['@markup.list.unchecked']     = { fg = p.g6 },

        RenderMarkdownH1 = { fg = p.pure,  bold = true },
        RenderMarkdownH2 = { fg = p.white, bold = true },
        RenderMarkdownH3 = { fg = p.g9,    bold = true },
        RenderMarkdownH4 = { fg = p.g9 },
        RenderMarkdownH5 = { fg = p.g8 },
        RenderMarkdownH6 = { fg = p.g7 },
        RenderMarkdownH1Bg = { fg = p.pure, bg = p.g4 },
        RenderMarkdownH2Bg = { bg = p.g3 },
        RenderMarkdownH3Bg = { bg = p.g2 },
        RenderMarkdownH4Bg = { bg = p.g2 },
        RenderMarkdownH5Bg = { bg = p.g1 },
        RenderMarkdownH6Bg = { bg = p.g1 },
        RenderMarkdownCode       = { bg = p.g2 },
        RenderMarkdownCodeInline = { fg = p.white, bg = p.g3 },
        RenderMarkdownBullet     = { fg = p.g8 },
        RenderMarkdownQuote      = { fg = p.g7 },
        RenderMarkdownDash       = { fg = p.g5 },
        RenderMarkdownLink       = { fg = p.g9 },
        RenderMarkdownTableHead  = { fg = p.pure, bold = true },
        RenderMarkdownTableRow   = { fg = p.g8 },
        RenderMarkdownChecked    = { fg = p.white },
        RenderMarkdownUnchecked  = { fg = p.g6 },

        -- ── Diagnostics (differ by style, not color) ─────────
        DiagnosticError = { fg = p.pure },
        DiagnosticWarn  = { fg = p.g9 },
        DiagnosticInfo  = { fg = p.g8 },
        DiagnosticHint  = { fg = p.g7 },
        DiagnosticOk    = { fg = p.g9 },

        DiagnosticVirtualTextError = { fg = p.pure, bg = 'none', bold = true },
        DiagnosticVirtualTextWarn  = { fg = p.g9,   bg = 'none', italic = true },
        DiagnosticVirtualTextInfo  = { fg = p.g8,   bg = 'none', italic = true },
        DiagnosticVirtualTextHint  = { fg = p.g7,   bg = 'none', italic = true },

        DiagnosticUnderlineError = { undercurl = true,  sp = p.pure },
        DiagnosticUnderlineWarn  = { undercurl = true,  sp = p.g8 },
        DiagnosticUnderlineInfo  = { underdotted = true, sp = p.g7 },
        DiagnosticUnderlineHint  = { underdashed = true, sp = p.g6 },

        DiagnosticSignError = { fg = p.pure, bg = bg },
        DiagnosticSignWarn  = { fg = p.g9,   bg = bg },
        DiagnosticSignInfo  = { fg = p.g8,   bg = bg },
        DiagnosticSignHint  = { fg = p.g7,   bg = bg },

        -- ── LSP ──────────────────────────────────────────────
        LspReferenceText  = { bg = p.g3 },
        LspReferenceRead  = { bg = p.g3 },
        LspReferenceWrite = { bg = p.g4, underline = true },
        LspInlayHint      = { fg = p.g6, italic = true },
        LspSignatureActiveParameter = { fg = p.pure, bold = true, underline = true },

        -- ── Telescope ────────────────────────────────────────
        TelescopeNormal         = { fg = p.white, bg = bg },
        TelescopeBorder         = { fg = p.g6,    bg = bg },
        TelescopeTitle          = { fg = p.pure,  bold = true },
        TelescopePromptNormal   = { fg = p.pure,  bg = bg },
        TelescopePromptBorder   = { fg = p.g6,    bg = bg },
        TelescopePromptPrefix   = { fg = p.pure,  bold = true },
        TelescopePromptTitle    = { fg = p.black, bg = p.white, bold = true },
        TelescopeResultsTitle   = { fg = p.g8 },
        TelescopePreviewTitle   = { fg = p.black, bg = p.g8, bold = true },
        TelescopeSelection      = { fg = p.pure,  bg = p.g4, bold = true },
        TelescopeSelectionCaret = { fg = p.pure,  bg = p.g4 },
        TelescopeMatching       = { fg = p.pure,  bold = true, underline = true },
        TelescopeMultiSelection = { fg = p.g9 },

        -- ── Oil ──────────────────────────────────────────────
        OilDir       = { fg = p.pure, bold = true },
        OilDirIcon   = { fg = p.g8 },
        OilFile      = { fg = p.white },
        OilLink      = { fg = p.g8, italic = true },
        OilLinkTarget = { fg = p.g6 },
        OilCreate    = { fg = p.pure, bold = true },
        OilDelete    = { fg = p.g6, strikethrough = true },
        OilMove      = { fg = p.g9 },
        OilCopy      = { fg = p.g9 },
        OilChange    = { fg = p.g8, italic = true },
        OilHidden    = { fg = p.g6 },
        OilSize      = { fg = p.g6 },
        OilMtime     = { fg = p.g6 },

        -- ── Statusline ───────────────────────────────────────
        StatusLine   = { fg = p.g8, bg = p.g3 },
        StatusLineNC = { fg = p.g6, bg = p.g2 },

        StatusNormal   = { fg = p.black, bg = p.white, bold = true },
        StatusInsert   = { fg = p.pure,  bg = p.g5,    bold = true },
        StatusVisual   = { fg = p.black, bg = p.g7,    bold = true },
        StatusReplace  = { fg = p.black, bg = p.g9,    bold = true, underline = true },
        StatusCommand  = { fg = p.g9,    bg = p.g3,    bold = true },
        StatusTerminal = { fg = p.g8,    bg = p.g2,    bold = true },
    }
end

local function terminal_colors(p)
    local t = {
        p.black, p.g6, p.g7, p.g8, p.g8, p.g9, p.g9, p.white,
        p.g4,    p.g7, p.g8, p.g9, p.g9, p.white, p.white, p.pure,
    }
    for i, col in ipairs(t) do
        vim.g['terminal_color_' .. (i - 1)] = col
    end
end

function M.load()
    vim.cmd('highlight clear')
    if vim.fn.exists('syntax_on') == 1 then vim.cmd('syntax reset') end

    vim.o.termguicolors = true
    vim.o.background    = 'dark'
    vim.g.colors_name   = 'stormbound-mono'

    for name, spec in pairs(groups(M.palette, M.opts.transparent)) do
        vim.api.nvim_set_hl(0, name, spec)
    end
    terminal_colors(M.palette)
end

function M.setup(opts)
    M.opts = vim.tbl_deep_extend('force', M.opts, opts or {})
end

return M
