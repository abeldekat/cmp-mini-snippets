--[[
:h cmp-develop
--]]

local cmp = require("cmp")
local util = require("vim.lsp.util")

local source = {}

-- Creates a markdown representation f the snippet
---@return string
local function get_documentation(snippet)
  local header = (snippet.label or "") .. "\n"
  local docstring = { "", "```", snippet.body, "```" }
  local documentation = { header .. "---", (snippet.desc or ""), docstring }
  documentation = util.convert_input_to_markdown_lines(documentation)

  return table.concat(documentation, "\n")
end

source.new = function() return setmetatable({}, { __index = source }) end

---Return the keyword pattern for triggering completion (optional).
---If this is omitted, nvim-cmp will use a default keyword pattern. See |cmp-config.completion.keyword_pattern|.
---@return string
source.get_keyword_pattern = function() -- same as cmp-luasnip!
  return "\\%([^[:alnum:][:blank:]]\\|\\w\\+\\)"
end

-- Copied from :h nvim-cmp as a reminder...
---Return trigger characters for triggering completion (optional).
-- function source:get_trigger_characters() return { "." } end

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available() -- lazy-loading...
  local ok, _ = pcall(require, "mini.snippets")
  return ok
end

-- TODO: cmp-luasnip caches the produced list by ft
--
---Invoke completion (required).
-- -@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(_, callback)
  local items = {}
  local snippets = MiniSnippets.expand({ match = false, insert = false })
  if not snippets then return items end

  for _, snippet in ipairs(snippets) do
    items[#items + 1] = {
      word = snippet.prefix,
      label = snippet.prefix,
      kind = cmp.lsp.CompletionItemKind.Snippet,
      data = {
        -- cmp-luasnip also has priority, filetype, show_condition and auto...
        snippet = snippet, -- cmp-luasnip only stores the snippet-id...
      },
    }
  end
  callback(items)
end

-- TODO: cmp-luasnip caches the produced documentation as well
--
---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback) -- modified from cmp-luasnip:
  local snippet = completion_item.data.snippet
  completion_item.documentation = {
    kind = cmp.lsp.MarkupKind.Markdown,
    value = get_documentation(snippet),
  }
  callback(completion_item)
end

-- TODO: cmp-luasnip has a fairly extensive implementation. Keep it simple for now.
-- TODO: Maybe this can be optimized by passing the choosen snippet to MiniSnippets.expand...
--
---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
  MiniSnippets.expand()
  callback(completion_item)
end

return source
