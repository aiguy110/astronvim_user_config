-- Create an autocmd group for Markdown wrapping
vim.api.nvim_create_augroup("WrapMarkdown", { clear = true })

-- Enable wrap and linebreak for Markdown files
vim.api.nvim_create_autocmd("FileType", {
  group = "WrapMarkdown",
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- Disable wrap in code blocks
vim.api.nvim_create_autocmd("Syntax", {
  group = "WrapMarkdown",
  pattern = "markdown",
  callback = function()
    local syntax = vim.fn.synIDattr(vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1), "name")
    if syntax == "markdownCodeBlock" then
      vim.opt_local.wrap = false
    end
  end,
})

-- Function to toggle nvim-cmp
local cmp = require'cmp'
local function toggle_cmp()
  if cmp.get_config().enabled then
    cmp.setup { enabled = false }
    print("nvim-cmp disabled")
  else
    cmp.setup { enabled = true }
    print("nvim-cmp enabled")
  end
end

-- Create a Neovim command to toggle nvim-cmp
vim.api.nvim_create_user_command('ToggleCmp', function()
  toggle_cmp()
end, {})


return {
  -- Configure AstroNvim updates
  updater = {
    remote = "origin", -- remote to use
    channel = "stable", -- "stable" or "nightly"
    version = "latest", -- "latest", tag name, or regex search like "v1.*" to only do updates before v2 (STABLE ONLY)
    branch = "nightly", -- branch name (NIGHTLY ONLY)
    commit = nil, -- commit hash (NIGHTLY ONLY)
    pin_plugins = nil, -- nil, true, false (nil will pin plugins on stable only)
    skip_prompts = false, -- skip prompts about breaking changes
    show_changelog = true, -- show the changelog after performing an update
    auto_quit = false, -- automatically quit the current session after a successful update
    remotes = { -- easily add new remotes to track
      --   ["remote_name"] = "https://remote_url.come/repo.git", -- full remote url
      --   ["remote2"] = "github_user/repo", -- GitHub user/repo shortcut,
      --   ["remote3"] = "github_user", -- GitHub user assume AstroNvim fork
    },
  },

  -- Set colorscheme to use
  colorscheme = "astrodark",

  -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
  diagnostics = {
    virtual_text = true,
    underline = true,
  },

  lsp = {
    -- customize lsp formatting options
    formatting = {
      -- control auto formatting on save
      format_on_save = {
        enabled = false, -- enable or disable format on save globally
        allow_filetypes = { -- enable format on save for specified filetypes only
          -- "go",
        },
        ignore_filetypes = { -- disable format on save for specified filetypes
          -- "python",
        },
      },
      disabled = { -- disable formatting capabilities for the listed language servers
        -- disable lua_ls formatting capability if you want to use StyLua to format your lua code
        -- "lua_ls",
      },
      timeout_ms = 1000, -- default format timeout
      -- filter = function(client) -- fully override the default formatting function
      --   return true
      -- end
    },
    -- enable servers that you already have installed without mason
    servers = {
      'pylsp',
      'jdtls'
    },
    -- custom server configuration
    config = {
      pylsp = {
        settings = {
          pylsp = {
            plugins = {
              pycodestyle = {
                maxLineLength = 140
              },
              flake8 = {
                maxLineLength = 140
              }
            }
          }
        }
      },
      jdtls = function()
        return {
          cmd = {
            'docker',
            'run',
            '--pid=host',
            '-i',
            '-v',
            vim.fn.getcwd() .. ':' .. vim.fn.getcwd(),
            '-v',
            os.getenv('HOME') .. '/.m2:/root/.m2',
            '--network',
            'host',
            'kaylebor/eclipse.jdt.ls:v0.60.0'
          },
          filetypes = {'java'},
          root_dir = require('lspconfig.util').root_pattern('pom.xml', 'gradle.build'),
        }
      end
    }
  },

  -- Configure require("lazy").setup() options
  lazy = {
    defaults = { lazy = true },
    performance = {
      rtp = {
        -- customize default disabled vim plugins
        disabled_plugins = { "tohtml", "gzip", "matchit", "zipPlugin", "netrwPlugin", "tarPlugin" },
      },
    },
  },

  -- This function is run last and is a good place to configuring
  -- augroups/autocommands and custom filetypes also this just pure lua so
  -- anything that doesn't fit in the normal config locations above can go here
  polish = function()
    -- Set up custom filetypes
    -- vim.filetype.add {
    --   extension = {
    --     foo = "fooscript",
    --   },
    --   filename = {
    --     ["Foofile"] = "fooscript",
    --   },
    --   pattern = {
    --     ["~/%.config/foo/.*"] = "fooscript",
    --   },
    -- }
  end,
}
