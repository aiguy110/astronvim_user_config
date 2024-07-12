function Trim(s)
  return s:match("^%s*(.-)%s$")
end


function IsCent7()
  return Trim(vim.fn.system("cat /etc/centos-release | grep -c 'CentOS Linux release 7'")) == '1'
end


local function get_parsers()
  local parsers_to_install = {
    "c",
    "css",
    "go",
    "graphql",
    "http",
    "json",
    "lua",
    "python",
    "rust",
  }

  -- The following parsers will fail to compile on CentOS 7 and cause annoying error messages
  if not IsCent7() then
    table.insert(parsers_to_install, "bash")
    table.insert(parsers_to_install, "comment")
    table.insert(parsers_to_install, "html")
    table.insert(parsers_to_install, "javascript")
    table.insert(parsers_to_install, "typescript")
  end

  return parsers_to_install
end


local function get_ignore_install()
  if IsCent7() then
    return { "markdown", "bash", "vim", "comment", "html", "javascript", "typescript" }
  else
    return {}
  end
end


return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      -- A list of parser names, or "all" (the four listed parsers should always be installed)
      ensure_installed = get_parsers(),

      ignore_install = get_ignore_install(),

      -- 

      -- Enable indentation
      indent = {
        enable = false,
      },

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      highlight = {
        -- `false` will disable the whole extension
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },
      playground = {
        enable = true,
        disable = {},
        updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
        persist_queries = false, -- Whether the query persists across vim sessions
        keybindings = {
          toggle_query_editor = "o",
          toggle_hl_groups = "i",
          toggle_injected_languages = "t",
          toggle_anonymous_nodes = "a",
          toggle_language_display = "I",
          focus_language = "f",
          unfocus_language = "F",
          update = "R",
          goto_node = "<cr>",
          show_help = "?",
        },
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
    },
    build = ":TSUpdate",
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
    dependencies = {
      {
        "nvim-treesitter/playground",
        cmd = {
          "TSPlaygroundToggle",
          "TSHighlightCapturesUnderCursor",
        },
        keys = {
          { "<F2>", "<cmd>TSHighlightCapturesUnderCursor<cr>", desc = "Show highlight group under cursor" },
        },
      },
    },
  },
}
