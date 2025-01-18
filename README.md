# cmp_mini_snippets

This plugin is a completion source for [nvim-cmp],
providing the snippets produced by [mini.snippets].

[mini.snippets] is a plugin to manage and expand snippets.

Currently, [mini.snippets] is in [beta].

## Installation

<details>
<summary>mini.deps</summary>

```lua
local add, later = MiniDeps.add, MiniDeps.later

later(function()
  add({ -- Do read the installation section in the readme of mini.snippets!
    source = "echasnovski/mini.snippets",
    depends = { "rafamadriz/friendly-snippets" }
  })
  local snippets = require("mini.snippets")
  -- :h MiniSnippets-examples:
  snippets.setup({ snippets = { snippets.gen_loader.from_lang() }})

  add({ -- Do read the installation section in the readme of nvim-cmp!
    source = "hrsh7th/nvim-cmp",
    depends = { "abeldekat/cmp-mini-snippets" }, -- this plugin
  })
  local cmp = require("cmp")
  require'cmp'.setup({
    snippet = {
      expand = function(args) -- mini.snippets expands snippets from lsp...
        ---@diagnostic disable-next-line: undefined-global
        local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
        insert({ body = args.body }) -- Insert at cursor
      end,
    },
    sources = cmp.config.sources({ { name = "mini_snippets" } }),
    mapping = cmp.mapping.preset.insert(), -- more opts...
  })
end)
```

</details>

<details>
<summary>lazy.nvim</summary>

```lua
return {
  { -- Do read the installation section in the readme of mini.snippets!
    "echasnovski/mini.snippets",
    dependencies = "rafamadriz/friendly-snippets",
    event = "InsertEnter", -- don't depend on other plugins to load...
    -- :h MiniSnippets-examples:
    opts = function()
      local snippets = require("mini.snippets")
      return { snippets = { snippets.gen_loader.from_lang() }}
    end,
  },

  { -- Do read the installation section in the readme of nvim-cmp!
    "hrsh7th/nvim-cmp",
    main = "cmp",
    dependencies = { "abeldekat/cmp-mini-snippets" }, -- this plugin
    event = "InsertEnter",
    opts = function()
      local cmp = require("cmp")
      return {
        snippet = {
          expand = function(args) -- mini.snippets expands snippets from lsp...
            ---@diagnostic disable-next-line: undefined-global
            local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
            insert({ body = args.body }) -- Insert at cursor
          end,
        },
        sources = cmp.config.sources({ { name = "mini_snippets" } }),
        mapping = cmp.mapping.preset.insert(), -- more opts...
      }
    end,
  },
}
```

</details>

## Options

The default options can be modified in the `sources` field of the `nvim-cmp` spec.

```lua
sources = cmp.config.sources({
  {
    name = "mini_snippets",
    option = {
      -- completion items are cached using default mini.snippets context:
      use_items_cache = false -- default: true
    }
  }
}),
```

## Remarks

See this [LazyVim PR] for a mini.snippets "extra"...
See this [nvim-cmp PR], providing a solution for outdated completion-items.

## Acknowledgments

- [cmp_luasnip] by @saadparwaiz1 (especially for function `get_documentation`)
- [nvim-cmp] and sources by @hrsh7th
- [mini.snippets] by @echasnovski

[mini.snippets]: https://github.com/echasnovski/mini.snippets
[nvim-cmp]: https://github.com/hrsh7th/nvim-cmp
[cmp_luasnip]: https://github.com/saadparwaiz1/cmp_luasnip
[beta]: https://github.com/echasnovski/mini.nvim/issues/1428
[LazyVim PR]: https://github.com/LazyVim/LazyVim/pull/5274
[nvim-cmp PR]: https://github.com/hrsh7th/nvim-cmp/pull/2126
