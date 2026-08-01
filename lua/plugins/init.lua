return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- needed for format on save
    cmd = { "ConformInfo", "FormatDisable", "FormatEnable" },
    keys = {
      {
        "<leader>fm",
        function()
          require("conform").format { async = true, lsp_format = "fallback" }
        end,
        mode = { "n", "v" },
        desc = "format buffer / selection",
      },
    },
    opts = require "configs.conform",
    config = function(_, opts)
      require("conform").setup(opts)

      -- :FormatDisable -> globally, :FormatDisable! -> this buffer only
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then
          vim.b.disable_autoformat = true
        else
          vim.g.disable_autoformat = true
        end
      end, { desc = "disable format on save", bang = true })

      vim.api.nvim_create_user_command("FormatEnable", function()
        vim.b.disable_autoformat = false
        vim.g.disable_autoformat = false
      end, { desc = "re-enable format on save" })
    end,
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- lazy.nvim defaults to lazy = true here, so these triggers are what make
    -- the :Diffview* commands exist at all.
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewRefresh" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "diffview open" },
      { "<leader>gD", "<cmd>DiffviewOpen origin/HEAD...HEAD<cr>", desc = "diffview vs branch base" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "diffview close" },
      { "<leader>gh", "<cmd>DiffviewFileHistory<cr>", desc = "diffview branch history" },
      { "<leader>gf", "<cmd>DiffviewFileHistory --follow %<cr>", desc = "diffview current file history" },
      { "<leader>gf", ":DiffviewFileHistory --follow<cr>", mode = "v", desc = "diffview selection history" },
      { "<leader>ge", "<cmd>DiffviewToggleFiles<cr>", desc = "diffview toggle file panel" },
    },
    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = { layout = "diff3_mixed" },
      },
    },
  },

  {
    "kylechui/nvim-surround",
    version = "^4.0.0", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    -- Optional: See `:h nvim-surround.configuration` and `:h nvim-surround.setup` for details
    -- config = function()
    --     require("nvim-surround").setup({
    --         -- Put your configuration here
    --     })
    -- end
  },
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "jsdoc",
        "json",
        "jsonc",
        "yaml",
        "markdown",
        "markdown_inline",
        "go",
        "gomod",
        "gosum",
        "gowork",
      },
    },
  },
}
