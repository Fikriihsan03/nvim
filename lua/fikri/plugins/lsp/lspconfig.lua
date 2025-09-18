-- import lspconfig plugin safely
local lspconfig_status, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status then
	return
end

-- import cmp-nvim-lsp plugin safely
local cmp_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not cmp_ok then
	return
end

-- capabilities untuk completion
local capabilities = cmp_nvim_lsp.default_capabilities()

-- =========================
-- Helper: pasang keymap LSP
-- =========================
local function set_my_lsp_keymaps(bufnr, client)
	if vim.b[bufnr] and vim.b[bufnr].__lsp_maps then
		return
	end
	vim.b[bufnr] = vim.b[bufnr] or {}
	vim.b[bufnr].__lsp_maps = true

	local opts = { noremap = true, silent = true, buffer = bufnr }

	vim.keymap.set("n", "gf", "<cmd>Lspsaga finder<CR>", opts)
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
	vim.keymap.set("n", "gd", "<cmd>Lspsaga peek_definition<CR>", opts)
	vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
	vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
	vim.keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
	vim.keymap.set("n", "<leader>D", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
	vim.keymap.set("n", "<leader>d", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts)
	vim.keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
	vim.keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)
	vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
	vim.keymap.set("n", "<leader>o", "<cmd>LSoutlineToggle<CR>", opts)

	-- formatting (null-ls only)
	vim.keymap.set("n", "<leader>lf", function()
		vim.lsp.buf.format({
			async = true,
			filter = function(c)
				return c.name == "null-ls"
			end,
		})
	end, opts)

	-- typescript specific
	if client and client.name == "ts_ls" then
		vim.keymap.set("n", "<leader>rf", ":TypescriptRenameFile<CR>", opts)
		vim.keymap.set("n", "<leader>oi", ":TypescriptOrganizeImports<CR>", opts)
		vim.keymap.set("n", "<leader>ru", ":TypescriptRemoveUnused<CR>", opts)
	end
end

-- Autocmd LspAttach
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client then
			set_my_lsp_keymaps(args.buf, client)
		end
	end,
})

-- Fallback: BufEnter cek client yang udah attach
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
	callback = function(args)
		for _, client in pairs(vim.lsp.get_clients({ bufnr = args.buf })) do
			set_my_lsp_keymaps(args.buf, client)
		end
	end,
})

-- ================================
-- CONFIG & ENABLE SEMUA SERVER
-- ================================
local servers = {
	lua_ls = {
		settings = {
			Lua = {
				diagnostics = { globals = { "vim" } },
				workspace = {
					library = {
						vim.fn.expand("$VIMRUNTIME/lua"),
						vim.fn.stdpath("config") .. "/lua",
					},
				},
			},
		},
	},
	pyright = {},
	ts_ls = {},
	html = {},
	cssls = {},
	jsonls = {},
	tailwindcss = {},
	vue_ls = {},
	intelephense = {},
	jdtls = {},
	emmet_ls = {},
}

for name, config in pairs(servers) do
	vim.lsp.config(
		name,
		vim.tbl_deep_extend("force", {
			capabilities = capabilities,
		}, config)
	)
	vim.lsp.enable(name)
end
