-- :h cmp-develop

---@class cmp_mini_snippets.Options
---@field use_items_cache? boolean completion items are cached using default mini.snippets context

---@type cmp_mini_snippets.Options
local defaults = {
  use_items_cache = true, -- allow the user to disable caching completion items
}

local cmp = require("cmp")
local util = require("vim.lsp.util")

local source = {}

source.new = function()
  local self = setmetatable({}, { __index = source })
  self.items_cache = {}
  return self
end

---@return cmp_mini_snippets.Options
local function get_valid_options(params)
  local opts = vim.tbl_deep_extend("keep", params.option, defaults)
  vim.validate({
    use_items_cache = { opts.use_items_cache, "boolean" },
  })
  return opts
end

---Return the keyword pattern for triggering completion (optional).
---If this is omitted, nvim-cmp will use a default keyword pattern. See |cmp-config.completion.keyword_pattern|.
---Using the same keyword pattern as cmp-luasnip
---@return string
source.get_keyword_pattern = function() return "\\%([^[:alnum:][:blank:]]\\|\\w\\+\\)" end

---Return whether this source is available in the current context or not (optional).
---@return boolean
function source:is_available()
  ---@diagnostic disable-next-line: undefined-field
  return _G.MiniSnippets ~= nil -- ensure that user has explicitly setup mini.snippets
end

local function to_items(snippets, context)
  local items = {}

  for _, snip in ipairs(snippets) do
    items[#items + 1] = {
      word = snip.prefix,
      label = snip.prefix,
      kind = cmp.lsp.CompletionItemKind.Snippet,
      data = { snip = snip, context = context },
    }
  end
  return items
end

-- NOTE: Completion items are cached by default using the default 'mini.snippets' context
--
-- 1. vim.b.minisnippets_config can contain buffer-local snippets.
-- 2. a buffer can contain code in multiple languages
--
-- See :h MiniSnippets.default_prepare
--
---Invoke completion (required).
---@param params cmp.SourceCompletionApiParams
---@param callback fun(response: lsp.CompletionResponse|nil)
function source:complete(params, callback)
  local opts = get_valid_options(params)

  local _, context = MiniSnippets.default_prepare({})
  local cache = self.items_cache
  local cache_key = "buf=" .. context.buf_id .. ",lang=" .. context.lang
  local items = {}

  if opts.use_items_cache and cache[cache_key] then
    items = cache[cache_key]
  else
    local snippets = MiniSnippets.expand({ match = false, insert = false })
    items = to_items(vim.deepcopy(snippets), context)

    if opts.use_items_cache then cache[cache_key] = items end
  end

  callback(items)
end

-- Creates a markdown representation of the snippet
---@return string
local function get_documentation(snip, context)
  local header = (snip.prefix or "")
  local sep = "---"
  local desc = (snip.desc or "")
  local docstring = { "```" .. context.lang, snip.body, "```" }
  local result = util.convert_input_to_markdown_lines({ header, sep, desc, docstring })

  return table.concat(result, "\n")
end

---Resolve completion item (optional). This is called right before the completion is about to be displayed.
---Useful for setting the text shown in the documentation window (`completion_item.documentation`).
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:resolve(completion_item, callback)
  if not completion_item.documentation then
    completion_item.documentation = {
      kind = cmp.lsp.MarkupKind.Markdown,
      value = get_documentation(completion_item.data.snip, completion_item.data.context),
    }
  end

  callback(completion_item)
end

-- Remove the word inserted by nvim-cmp and insert snippet
-- It's safe to assume that mode is insert during completion
local function insert_snippet(snip, word)
  local cursor = vim.api.nvim_win_get_cursor(0)
  cursor[1] = cursor[1] - 1 -- nvim_buf_set_text: line is zero based
  local start_col = cursor[2] - #word
  vim.api.nvim_buf_set_text(0, cursor[1], start_col, cursor[1], cursor[2], {})

  local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
  insert({ body = snip.body }) -- insert at cursor
end

---Executed after the item was selected.
---@param completion_item lsp.CompletionItem
---@param callback fun(completion_item: lsp.CompletionItem|nil)
function source:execute(completion_item, callback)
  insert_snippet(completion_item.data.snip, completion_item.word)
  callback(completion_item)
end

return source
