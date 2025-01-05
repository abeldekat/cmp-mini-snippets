-- :h cmp-develop

local cmp = require("cmp")
local util = require("vim.lsp.util")

local source = {}

-- Creates a markdown representation of the snippet
-- A fenced code block after convert_input_to_markdown_lines is probably ok.
---@return string
local function get_documentation(snippet)
  local header = (snippet.prefix or "") .. " _ `[" .. vim.bo.filetype .. "]`\n"
  local docstring = { "", "```" .. vim.bo.filetype, snippet.body, "```" }
  local documentation = { header .. "---", (snippet.desc or ""), docstring }
  documentation = util.convert_input_to_markdown_lines(documentation)

  return table.concat(documentation, "\n")
end

-- Remove the word inserted by nvim-cmp and insert snippet
-- It's safe to assume that mode is insert during completion
local function insert_snippet(snippet, word)
  local cursor = vim.api.nvim_win_get_cursor(0)
  cursor[1] = cursor[1] - 1 -- nvim_buf_set_text: line is zero based
  local start_col = cursor[2] - #word
  vim.api.nvim_buf_set_text(0, cursor[1], start_col, cursor[1], cursor[2], {})

  local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
  insert({ body = snippet.body }) -- insert at cursor
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
function source:is_available()
  return _G.MiniSnippets ~= nil -- ensure that user has explicitly setup mini.snippets
end

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
      data = { snippet = snippet }, -- cmp-luasnip only stores the snippet-id...
    }
  end
  callback(items)
end

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

---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
  insert_snippet(completion_item.data.snippet, completion_item.word)
  callback(completion_item)
end

return source
