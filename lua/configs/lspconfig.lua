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
      -- tsserver crawls the whole root for auto-import candidates. In a monorepo
      -- that also holds git worktrees (full repo copies) that is several times
      -- the real source tree, so exclude everything that is not first-party src.
      autoImportFileExcludePatterns = {
        "**/.worktrees/**",
        "**/node_modules/**",
        "**/dist/**",
        "**/.next/**",
        "**/.turbo/**",
      },
      experimental = {
        maxInlayHintLength = 30, -- keep long inferred types from swamping the line
        completion = { enableServerSideFuzzyMatch = true },
      },
    },
  },
})

-- eslint: diagnostics only by default. `:EslintFixAll` / the autocmd below
-- applies --fix on save, which runs before conform's prettier pass.
-- eslint's flat config here uses typescript-eslint `projectService`, so the
-- server builds its OWN full TypeScript program -- a second one next to
-- vtsls's, ~2GB and ~20s of CPU on a cold open of any monorepo TS file.
-- Diagnostics are worth that on demand, not on every :edit, so the server is
-- opt-in per session via :EslintStart (`yarn lint` still covers CI).
vim.g.eslint_lsp_enabled = false

vim.lsp.config("eslint", {
  settings = {
    workingDirectories = { mode = "auto" },
  },
})

vim.api.nvim_create_user_command("EslintStart", function()
  vim.g.eslint_lsp_enabled = true
  vim.lsp.enable "eslint"
  vim.cmd "edit" -- re-trigger FileType so eslint attaches to this buffer
end, { desc = "start the eslint LSP for this session (heavy: type-aware)" })

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

-- tailwindcss: completion/hover/colors for utility classes. The classRegex
-- entries teach it to look inside cva()/clsx()/cn() calls and `class:`-style
-- props, which it otherwise ignores outside plain class="" attributes.
vim.lsp.config("tailwindcss", {
  -- only apps/web is a tailwind project; rooting at the monorepo makes the
  -- server scan every workspace (and every worktree copy) for content files.
  root_markers = { "tailwind.config.ts", "tailwind.config.js", "tailwind.config.cjs" },
  settings = {
    tailwindCSS = {
      validate = true,
      classAttributes = { "class", "className", "classList", "ngClass" },
      experimental = {
        classRegex = {
          { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
          { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "tw`([^`]*)", "([^`]*)" },
        },
      },
      lint = {
        cssConflict = "warning",
        invalidApply = "error",
        invalidConfigPath = "error",
        invalidScreen = "error",
        invalidTailwindDirective = "error",
        invalidVariant = "error",
        recommendedVariantOrder = "warning",
      },
    },
  },
})

local servers = { "html", "cssls", "vtsls", "gopls", "emmet_language_server", "tailwindcss" }
vim.lsp.enable(servers)
