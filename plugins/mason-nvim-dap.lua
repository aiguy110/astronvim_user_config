return {
  "jay-babu/mason-nvim-dap.nvim",
  opts = {
    handlers = {
      python = function()
        local dap = require("dap")
        dap.adapters.python = {
          type = "executable",
          command = "/usr/bin/python3",
          args = {
            "-m",
            "debugpy.adapter",
          },
        }

        dap.configurations.python = {
          {
            type = "python",
            request = "launch",
            name = "Launch file",
            program = "${file}", -- This configuration will launch the current file if used.
            args = function()
              local args = {}
              for arg in vim.fn.input("Arguments: "):gmatch("%S+") do
                table.insert(args, arg)
              end
              return args
            end,
          },
        }
      end,
    },
  },
}
