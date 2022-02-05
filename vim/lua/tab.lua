local M = {}
local cmp = require'cmp'
local luasnip = require'luasnip'

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("[_%w]") ~= nil
end

local feedkey = function(key, mode)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local function t(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

function M.smart_tab(fallback)
    if cmp.visible() then
        cmp.select_next_item()
    elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
    elseif vim.fn["delimitMate#ShouldJump"]() == 1 then
        vim.api.nvim_feedkeys(t("<Plug>delimitMateS-Tab"), 'm', true)
    elseif has_words_before() then
        cmp.complete()
    else
        fallback()
    end
end

function M.smart_s_tab(fallback)
    if cmp.visible() then
        cmp.select_prev_item()
    elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
    else
        fallback()
    end
end

function M.setup()
end

return M

