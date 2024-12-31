local cmp = require("cmp")
local util = require("vim.lsp.util")

local source = {}

---@class cmp_mini_snippets.Option
---@field public dummy boolean

---@type cmp_mini_snippets.Option
local defaults = {
  dummy = false,
}

-- copied from cmp-luasnip:
-- the options are being passed via cmp.setup.sources, e.g.
-- require('cmp').setup { sources = { { name = 'mini_snippets', opts = {...} } } }
local function init_options(params)
  params.option = vim.tbl_deep_extend("keep", params.option, defaults)
  vim.validate({
    dummy = { params.option.dummy, "boolean" },
  })
end

-- copied from cmp-luasnip:
local function get_documentation(snip, data)
  local header = (snip.name or "") .. " _ `[" .. data.filetype .. "]`\n"
  local docstring = { "", "```" .. vim.bo.filetype, snip:get_docstring(), "```" }
  local documentation = { header .. "---", (snip.dscr or ""), docstring }
  documentation = util.convert_input_to_markdown_lines(documentation)
  documentation = table.concat(documentation, "\n")

  doc_cache[data.filetype] = doc_cache[data.filetype] or {}
  doc_cache[data.filetype][data.snip_id] = documentation
  return documentation
end

source.new = function() return setmetatable({}, { __index = source }) end

-- copied from cmp-luasnip:
source.get_keyword_pattern = function()
  vim.print("get_keyword_pattern")
  return "\\%([^[:alnum:][:blank:]]\\|\\w\\+\\)"
end

-- Not in cmp-path or cmp-buffer:
-- function source:get_debug_name() return "mini.snippets" end

function source:complete(params, callback)
  vim.print("source complete")
  vim.print(params)

  init_options(params)

  local items = {}

  callback(items)
end

-- copied from cmp-luasnip:
function source:resolve(completion_item, callback)
  vim.print("source complete")
  vim.print(completion_item)

  -- local item_snip_id = completion_item.data.snip_id
  -- local snip = require("luasnip").get_id_snippet(item_snip_id)
  -- local doc_itm = doc_cache[completion_item.data.filetype] or {}
  -- doc_itm = doc_itm[completion_item.data.snip_id] or get_documentation(snip, completion_item.data)
  -- completion_item.documentation = {
  --   kind = cmp.lsp.MarkupKind.Markdown,
  --   value = doc_itm,
  -- }
  callback(completion_item)
end

-- not in cmp-path or cmp-buffer!
function source:execute(completion_item, callback)
  vim.print("source execute")
  vim.print(completion_item)

  -- -- text cannot be cleared before, as TM_CURRENT_LINE and
  -- -- TM_CURRENT_WORD couldn't be set correctly.
  -- require("luasnip").snip_expand(snip, {
  -- 	-- clear word inserted into buffer by cmp.
  -- 	-- cursor is currently behind word.
  -- 	clear_region = clear_region,
  -- 	expand_params = expand_params,
  -- })
  callback(completion_item)
end

return source
