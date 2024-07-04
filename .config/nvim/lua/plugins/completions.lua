return {
	-- LSP completion source
	{
		"hrsh7th/cmp-nvim-lsp",
	},
	-- Snippet engine and additional snippets
	{
		"L3MON4D3/LuaSnip",
		dependencies = {
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
		},
		config = function()
			local ls = require("luasnip")
			local types = require("luasnip.util.types")

			ls.config.set_config({
				history = true,
				updateevents = "TextChanged,TextChangedI",
				enable_autosnippets = true,
			})

			-- Load snippets from friendly-snippets
			require("luasnip.loaders.from_vscode").lazy_load({
				languages = {
					ejs = "html", -- Load HTML snippets for EJS files
					javascript = "javascript", -- Load JavaScript snippets
				},
			})

			-- Extend filetypes to include HTML snippets in JavaScript, JSX, and EJS files
			ls.filetype_extend("javascript", { "html" })
			ls.filetype_extend("javascriptreact", { "html" })
			ls.filetype_extend("ejs", { "html" })

			-- Keybindings for expanding and jumping through snippets
			vim.api.nvim_set_keymap("i", "<C-k>", "<cmd>lua require'luasnip'.expand_or_jump()<CR>", { silent = true })
			vim.api.nvim_set_keymap("s", "<C-k>", "<cmd>lua require'luasnip'.expand_or_jump()<CR>", { silent = true })
			vim.api.nvim_set_keymap("i", "<C-j>", "<cmd>lua require'luasnip'.jump(-1)<CR>", { silent = true })
			vim.api.nvim_set_keymap("s", "<C-j>", "<cmd>lua require'luasnip'.jump(-1)<CR>", { silent = true })
		end,
	},
	-- Completion engine
	{
		"hrsh7th/nvim-cmp",
		config = function()
			local cmp = require("cmp")

			cmp.setup({
				snippet = {
					expand = function(args)
						require("luasnip").lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},
				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = true }),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" }, -- Snippet completion
					{ name = "buffer" }, -- Buffer completion
					{ name = "path" }, -- Path completion
					{ name = "emmet_vim" }, -- Emmet completion
				}),
			})

			-- Emmet configuration
			vim.g.user_emmet_leader_key = "<C-Z>" -- You can change this to your preferred key
			vim.g.user_emmet_settings = {
				javascript = {
					extends = "jsx",
				},
				typescriptreact = {
					extends = "jsx",
				},
				javascriptreact = {
					extends = "jsx",
				},
			}
		end,
	},
	-- Emmet plugin
	{
		"mattn/emmet-vim",
	},
}
