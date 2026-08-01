require("nvchad.configs.lspconfig").defaults()

-- read :h vim.lsp.config for changing options of lsp servers

-- gopls: staticcheck + the analyzers that catch the usual Go footguns,
-- plus inlay hints for the things that are invisible at the call site.
vim.lsp.config("gopls", {
  settings = {
    gopls = {
      gofumpt = false, -- formatting is conform's job (goimports + gofmt)
      staticcheck = true,
      usePlaceholders = true,
      completeUnimported = true,
      analyses = {
        unusedparams = true,
        unusedwrite = true,
        nilness = true,
        shadow = false,
        useany = true,
      },
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
    },
  },
})

-- vtsls: the TS server. Formatting stays off so prettier is the single source
-- of truth; inlay hints on for parameter names and inferred types.
local ts_inlay_hints = {
  parameterNames = { enabled = "literals" },
  parameterTypes = { enabled = true },
  variableTypes = { enabled = false },
  propertyDeclarationTypes = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  enumMemberValues = { enabled = true },
}

vim.lsp.config("vtsls", {
  settings = {
    typescript = {
      updateImportsOnFileMove = { enabled = "always" },
      inlayHints = ts_inlay_hints,
    },
    javascript = {
      updateImportsOnFileMove = { enabled = "always" },
      inlayHints = ts_inlay_hints,
    },
    vtsls = {
      autoUseWorkspaceTsdk = true, -- respect the repo's own typescript version
      experimental = {
        maxInlayHintLength = 30, -- keep long inferred types from swamping the line
        completion = { enableServerSideFuzzyMatch = true },
      },
    },
  },
})

-- eslint: diagnostics only by default. `:EslintFixAll` / the autocmd below
-- applies --fix on save, which runs before conform's prettier pass.
vim.lsp.config("eslint", {
  settings = {
    workingDirectories = { mode = "auto" },
  },
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("eslint_fix_on_save", { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= "eslint" then
      return
    end

    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = args.buf,
      callback = function()
        if vim.g.disable_autoformat or vim.b[args.buf].disable_autoformat then
          return
        end
        vim.cmd "LspEslintFixAll"
      end,
    })
  end,
})

-- emmet: abbreviation expansion (div.foo>ul>li*3<C-y>, or via completion) in
-- html/css/jsx/tsx. It emits className= automatically in the jsx filetypes.
vim.lsp.config("emmet_language_server", {
  init_options = {
    showExpandedAbbreviation = "always",
    showAbbreviationSuggestions = true,
    preferences = {
      -- self-close void elements, which is what JSX wants
      ["output.selfClosingStyle"] = "xhtml",
    },
  },
})

local servers = { "html", "cssls", "vtsls", "eslint", "gopls", "emmet_language_server" }
vim.lsp.enable(servers)
