local prettier = { "prettier" }

local options = {
  formatters_by_ft = {
    lua = { "stylua" },

    -- typescript / react
    javascript = prettier,
    javascriptreact = prettier,
    typescript = prettier,
    typescriptreact = prettier,

    -- web / data files prettier also owns
    css = prettier,
    scss = prettier,
    html = prettier,
    json = prettier,
    jsonc = prettier,
    yaml = prettier,
    markdown = prettier,
    graphql = prettier,

    -- go: goimports fixes the import block, gofmt is the canonical pass
    go = { "goimports", "gofmt" },
  },

  -- conform's prettier resolves node_modules/.bin/prettier first (per-repo version
  -- and plugins win), then falls back to the global install.

  format_on_save = function(bufnr)
    -- :FormatDisable / :FormatDisable! escape hatch, see below
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
      return
    end
    return {
      timeout_ms = 2000,
      lsp_format = "fallback",
    }
  end,
}

return options
