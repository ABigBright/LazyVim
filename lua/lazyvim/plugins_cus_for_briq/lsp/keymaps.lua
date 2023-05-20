local M = {}

-- @type PluginLspKeys
M._keys = nil

-- @return (LazyKeys|{has?:string})[]
function M.get()
  local format = function()
    require("lazyvim.plugins.lsp.format").format({ force = true })
  end
  if not M._keys then
  ---@class PluginLspKeys
    -- stylua: ignore
    M._keys =  {
      { "<leader>ed", vim.diagnostic.open_float, desc = "line diagnostics" },
      { "<leader>el", "<cmd>LspInfo<cr>", desc = "lsp info" },
      { "<leader>jc", "<cmd>Telescope lsp_definitions<cr>", desc = "goto definition", has = "definition" },
      { "<leader>jh", "<cmd>Telescope lsp_references<cr>", desc = "goto references" },
      { "<leader>jD", vim.lsp.buf.declaration, desc = "goto declaration" },
      { "<leader>jI", "<cmd>Telescope lsp_implementations<cr>", desc = "goto implementation" },
      { "<leader>jg", "<cmd>Telescope lsp_type_definitions<cr>", desc = "goto T[y]pe definition" },
      { "K", vim.lsp.buf.hover, desc = "hover" },
      { "gK", vim.lsp.buf.signature_help, desc = "signature help", has = "signatureHelp" },
      { "<c-k>", vim.lsp.buf.signature_help, mode = "i", desc = "signature help", has = "signatureHelp" },
      { "]d", M.diagnostic_goto(true), desc = "next diagnostic" },
      { "[d", M.diagnostic_goto(false), desc = "prev diagnostic" },
      { "]e", M.diagnostic_goto(true, "ERROR"), desc = "next error" },
      { "[e", M.diagnostic_goto(false, "ERROR"), desc = "prev error" },
      { "]w", M.diagnostic_goto(true, "WARN"), desc = "next warning" },
      { "[w", M.diagnostic_goto(false, "WARN"), desc = "prev warning" },
      { "<leader>ei", format, desc = "format document", has = "documentFormatting" },
      { "<leader>ei", format, desc = "format range", mode = "v", has = "documentRangeFormatting" },
      { "<leader>ec", vim.lsp.buf.code_action, desc = "code action", mode = { "n", "v" }, has = "codeAction" },
      {
        "<leader>eC",
        function()
          vim.lsp.buf.code_action({
            context = {
              only = {
                "source",
              },
              diagnostics = {},
            },
          })
        end,
        desc = "source action",
        has = "codeAction",
      }
    }
    if require("lazyvim.util").has("inc-rename.nvim") then
      M._keys[#M._keys + 1] = {
        "<leader>er",
        function()
          local inc_rename = require("inc_rename")
          return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
        end,
        expr = true,
        desc = "rename",
        has = "rename",
      }
    else
      M._keys[#M._keys + 1] = { "<leader>er", vim.lsp.buf.rename, desc = "rename", has = "rename" }
    end
  end
  return M._keys
end

function M.on_attach(client, buffer)
  local Keys = require("lazy.core.handler.keys")
  local keymaps = {} -- @type table<string,LazyKeys|{has?:string}>

  for _, value in ipairs(M.get()) do
    local keys = Keys.parse(value)
    if keys[2] == vim.NIL or keys[2] == false then
      keymaps[keys.id] = nil
    else
      keymaps[keys.id] = keys
    end
  end

  for _, keys in pairs(keymaps) do
    if not keys.has or client.server_capabilities[keys.has .. "Provider"] then
      local opts = Keys.opts(keys)
      ---@diagnostic disable-next-line: no-unknown
      opts.has = nil
      opts.silent = opts.silent ~= false
      opts.buffer = buffer
      vim.keymap.set(keys.mode or "n", keys[1], keys[2], opts)
    end
  end
end

function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

return M
