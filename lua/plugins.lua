-- lua/plugins.lua
return {
	-- Plugin Manager (lazy.nvim manages itself)
	{ "folke/lazy.nvim", version = "*", lazy = false },

	-- Colorschemes
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			vim.cmd([[colorscheme tokyonight]]) -- Set Tokyonight as the default colorscheme
		end,
	},

	-- File Explorer
	{
		"kyazdani42/nvim-tree.lua", -- File tree sidebar (replaces netrw)
		cmd = { "NvimTreeToggle", "NvimTreeRefresh" },
		keys = {
			{ "<C-a>", "<cmd>NvimTreeToggle<CR>", desc = "Toggle file tree" },
			{ "<C-r>", "<cmd>NvimTreeRefresh<CR>", desc = "Refresh file tree" },
		},
		config = function()
			require("nvim-tree").setup({
				hijack_netrw = true,
				view = { width = 30 },
				renderer = { icons = { show = { git = true, folder = true, file = true, folder_arrow = true } } },
			})
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- Icons for file tree
	},

	-- Which-Key (leader cheat-sheet)
	{
		"folke/which-key.nvim",
		dependencies = { "echasnovski/mini.icons" }, -- Icons for which-key
		event = "VeryLazy",
		config = function()
			require("which-key").setup({ plugins = { spelling = { enabled = true } } })
		end,
	},

	-- Formatting & lint helpers
	{ "stevearc/conform.nvim", event = "BufWritePre", config = false }, -- real config lives in lua/config/format.lua

	-- Fuzzy Finder (files, grep, etc.)
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		dependencies = { "nvim-lua/plenary.nvim" },

		-- Lazy‑load on these keymaps -------------------------------------------
		keys = {
			-- Find in git tracked files
			{
				"<C-p>",
				function()
					local builtin = require("telescope.builtin")
					-- recurse_submodules = true so git submodule contents are listed
					-- Try submodules first (requires *no* --others flag)
					local ok = pcall(builtin.git_files, { recurse_submodules = true })
					if not ok then
						-- Fallback: root-only but include untracked files
						ok = pcall(builtin.git_files, { show_untracked = true })
					end
					if not ok then
						builtin.find_files()
					end
				end,
				desc = "Find files (incl. dot‑files)",
			},
			-- Grep all files in working directory
			{
				"<C-g>",
				function()
					require("telescope.builtin").live_grep()
				end,
				desc = "Live Grep",
			},
			-- Find git branches
			{
				"<C-b>",
				function()
					require("telescope.builtin").git_branches()
				end,
				desc = "Git Branches",
			},
			-- Grep in current file or buffer
			{
				"<C-f>",
				function()
					require("telescope.builtin").live_grep({ search_dirs = { vim.fn.expand("%:p") } })
				end,
			},
		},

		config = function()
			local telescope = require("telescope")
			local actions = require("telescope.actions")

			telescope.setup({
				---------------------------------------------------------------------
				-- Defaults apply to *all* pickers ----------------------------------
				---------------------------------------------------------------------
				defaults = {
					prompt_prefix = "🔍 ",
					mappings = { i = { ["<Esc>"] = actions.close } },
					file_ignore_patterns = {
						"^%.git/", -- keep .git ignored
						"^%.idea/",
						"^%.vscode/",
						"^%.venv/",
						"^node_modules/",
						"^%.cache/",
						"%.DS_Store$",
						"^docs/html/",
					},
				},
			})
		end,
	},

	-- Dashboard (start screen)
	{
		"nvimdev/dashboard-nvim", -- new repo name
		lazy = false, -- load immediately
		priority = 1001, -- after colorscheme (1000), before the rest
		config = function()
			local db = require("dashboard")
			db.setup({
				theme = "doom",
				config = {
					header = { "Dashboard" },
					center = {
						{ desc = "  Find File           ", action = "Telescope find_files" },
						{ desc = "🔍 Live Grep           ", action = "Telescope live_grep" },
						{ desc = "  File Explorer       ", action = "NvimTreeToggle" },
						{ desc = "  Git Branches        ", action = "Telescope git_branches" },
						{ desc = "👋 Quit                ", action = "qa" },
					},
				},
			})
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Statusline and Bufferline
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		config = function()
			require("lualine").setup({
				options = { theme = "tokyonight", section_separators = "", component_separators = "" },
				extensions = { "nvim-tree", "quickfix" },
			})
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" }, -- for file icons in statusline
	},
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		config = function()
			require("bufferline").setup({
				options = {
					numbers = "none",
					diagnostics = "nvim_lsp",
					show_buffer_close_icons = false,
					show_close_icon = false,
				},
			})
		end,
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- Git integration
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			require("gitsigns").setup({
				current_line_blame = true,
				on_attach = function(bufnr)
					local gs = package.loaded.gitsigns
					-- Navigate hunks with ]c/[c
					vim.keymap.set("n", "]c", function()
						gs.next_hunk()
					end, { buffer = bufnr, desc = "Next hunk" })
					vim.keymap.set("n", "[c", function()
						gs.prev_hunk()
					end, { buffer = bufnr, desc = "Prev hunk" })
					-- Stage/undo stage hunk
					vim.keymap.set("n", "<Leader>hs", gs.stage_hunk, { buffer = bufnr, desc = "Stage hunk" })
					vim.keymap.set("n", "<Leader>hu", gs.undo_stage_hunk, { buffer = bufnr, desc = "Undo stage hunk" })
					-- Preview hunk
					vim.keymap.set("n", "<Leader>hp", gs.preview_hunk, { buffer = bufnr, desc = "Preview hunk" })
				end,
			})
		end,
	},

	{
		"williamboman/mason.nvim",
		opts = {
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "…",
					package_uninstalled = "✗",
				},
			},
		},
	},

	-- LSP (Language Server Protocol) and related plugins
	{
		"neovim/nvim-lspconfig", -- Collection of configurations for built-in LSP client
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- LSP UI enhancements
			{ "nvimdev/lspsaga.nvim", config = true }, -- LSP UIs (hover docs, code actions, rename, diagnostics, and floating terminal)
			-- Automatically install LSP servers (optional, e.g., mason.nvim could be used here)
		},
		config = function()
			-- Customize diagnostic display (virtual text, signs, etc.)
			vim.diagnostic.config({ virtual_text = false, signs = true, float = { border = "rounded" } })
			-- Show diagnostic popup on hover
			vim.api.nvim_create_autocmd("CursorHold", {
				callback = function()
					vim.diagnostic.open_float(nil, { focusable = false })
				end,
			})

			-- Enable language servers with the above on_attach and capabilities
			-- lua
			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = { ".git" },
			})
			vim.lsp.enable("lua_ls")

			-- golang
			vim.lsp.config("gopls", {
				cmd = { "gopls" },
				filetypes = { "go" },
				root_markers = { ".git" },
			})
			vim.lsp.enable("gopls")

			-- Rust
			vim.lsp.config("rust-analyzer", {
				cmd = { "rust-analyzer" },
				filetypes = { "rs" },
				root_markers = {
					".git",
					"Cargo.toml",
				},
			})
			vim.lsp.enable("rust-analyzer")

			-- Typescript/Javascript
			vim.lsp.config("typescript-language-server", {
				cmd = { "typescript-language-server" },
				filetypes = {
					"ts",
					"js",
					"tsx",
					"jsx",
				},
				root_markers = {
					".git",
					"package.json",
				},
			})
			vim.lsp.enable("typescript-language-server")

			-- Kotlin
			vim.lsp.config("kotlin-lsp", {
				cmd = { "kotlin-lsp" },
				filetypes = { "kt" },
				root_markers = { ".git" },
			})
			vim.lsp.enable("kotlin-lsp")

			-- C#
			vim.lsp.config("omnisharp", {
				cmd = { "OmniSharp" },
				filetypes = { "cs" },
				root_markers = { ".git" },
			})
			vim.lsp.enable("omnisharp")
		end,
	},

	-- Autocompletion framework and snippet engine
	{
		"petertriho/cmp-git",
		dependencies = { "hrsh7th/nvim-cmp" },
		opts = {
			filetypes = { "gitcommit" },
			remotes = { "upstream", "origin" }, -- in order of most to least prioritized
		},
		init = function()
			table.insert(require("cmp").get_config().sources, { name = "git" })
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
			"hrsh7th/cmp-buffer", -- Buffer words completion
			"hrsh7th/cmp-path", -- File path completion
			"f3fora/cmp-spell", -- Spell suggestions source
			"saadparwaiz1/cmp_luasnip", -- Snippet completions
			"L3MON4D3/LuaSnip", -- Snippet engine (LuaSnip, replacing vim-vsnip)
			"rafamadriz/friendly-snippets", -- Collection of snippets for many languages
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			require("luasnip.loaders.from_vscode").lazy_load() -- Load VSCode-style snippets from friendly-snippets

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body) -- Use LuaSnip to expand snippet
					end,
				},
				mapping = cmp.mapping.preset.insert({
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.close(),
					["<Down>"] = cmp.mapping(
						cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
						{ "i" }
					),
					["<Up>"] = cmp.mapping(
						cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
						{ "i" }
					),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = true,
					}),
				}),
				sources = cmp.config.sources({
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
				}, {
					{ name = "buffer" },
					{ name = "spell" },
				}),
			})
		end,
	},

	-- AI Assistant (GitHub Copilot) - using Lua plugin for better integration
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		config = function()
			require("copilot").setup({
				suggestion = { auto_trigger = true, keymap = { accept = "<Tab>" } },
			})
		end,
	},

	-- Editing enhancements
	{ "kylechui/nvim-surround", event = "VeryLazy", config = true }, -- Surround text objects easily (replaces tpope/vim-surround)
	{ "tpope/vim-endwise", ft = { "ruby", "vim", "lua", "bash" } }, -- Automatically add "end" in certain filetypes (Ruby, etc.)
	{ "mg979/vim-visual-multi", branch = "master", keys = { "<C-n>", "<C-down>", "<C-up>" } }, -- Multi-cursor editing (Ctrl-N to add cursors)
	{ "stevearc/dressing.nvim", event = "VeryLazy", config = true }, -- Better UI for vim.ui (input/select) dialogs
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl", -- tells lazy.nvim the module name changed
		event = "BufReadPost",
		opts = {
			indent = { char = "│" }, -- or leave blank for default ▏
			scope = { enabled = false }, -- disable rainbow scope lines if you like
		},
	},

	-- Syntax and Language Support (Tree-sitter and filetype plugins)
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				ensure_installed = {
					"bash",
					"c",
					"cmake",
					"cpp",
					"css",
					"csv",
					"diff",
					"dockerfile",
					"gitcommit",
					"gitignore",
					"go",
					"javascript",
					"jinja",
					"json",
					"lua",
					"markdown",
					"markdown_inline",
					"nginx",
					"nix",
					"proto",
					"python",
					"rust",
					"terraform",
					"toml",
					"tsx",
					"typescript",
					"yaml",
				},
				highlight = { enable = true },
				indent = { enable = true },
			})
		end,
	},
}
