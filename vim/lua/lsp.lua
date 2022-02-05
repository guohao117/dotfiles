local M = {}
local function config_nvim_lsp(cb_init)
    local nvim_lsp = require'lspconfig'
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities.textDocument.completion.completionItem.snippetSupport = true
	capabilities.textDocument.completion.completionItem.resolveSupport = {
		properties = {
			'documentation',
			'detail',
			'additionalTextEdits',
			}
		}
    nvim_lsp.gopls.setup{ init_options = { usePlaceholders = true }; capabilities = capabilities; on_attach = cb_init }
    nvim_lsp.rust_analyzer.setup{ capabilities = capabilities, capabilities = capabilities; on_attach = cb_init }
    nvim_lsp.pyright.setup{ capabilities = capabilities; on_attach = cb_init }
    if vim.call('has', 'mac') == 1 then
        nvim_lsp.clangd.setup{ cmd = {"/usr/local/opt/llvm/bin/clangd", "--background-index"}; capabilities = capabilities; on_attach = cb_init }
    else
        nvim_lsp.clangd.setup{ capabilities = capabilities; on_attach = cb_init }
    end
end

function M.setup()
    config_nvim_lsp(
        function(client, result)
            local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
            -- require'ncm2'.register_lsp_source(client, result)
            local opts = { noremap=true, silent=true }
            buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
            -- buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
            buf_set_keymap('n', 'gd', '<cmd>Telescope lsp_definitions theme=ivy<CR>', opts)
            buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
            -- buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
            buf_set_keymap('n', 'gi', '<cmd>Telescope lsp_implementations theme=ivy<CR>', opts)
            buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
			buf_set_keymap('n', 'ca', '<cmd>Telescope lsp_code_actions theme=cursor<CR>', opts)
            buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
            buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
            buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
            buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
            buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
            -- buf_set_keymap('n', 'gr', '<cmd>Telescope lsp_references<CR>', opts)
            buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
            buf_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
            buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
            buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
            buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)
            -- Set some keybinds conditional on server capabilities
            if client.resolved_capabilities.document_formatting then
                buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
            elseif client.resolved_capabilities.document_range_formatting then
                buf_set_keymap("n", "<space>f", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
            end
            -- Set autocommands conditional on server_capabilities
            if client.resolved_capabilities.document_highlight then
                -- hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
                -- hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
                -- hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
                vim.api.nvim_exec([[
                augroup lsp_document_highlight
                    autocmd! * <buffer>
                    autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
                    autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
                augroup END
                ]], false)
            end
        end
    )
end

return M
