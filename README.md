# cmp_mini_snippets

[mini.snippets] completion source for [nvim-cmp]
Mini.snippets is a plugin to manage and expand snippets.

Currently, the plugin is in [beta].

## Installation

### mini.deps

```lua
local add, later = MiniDeps.add, MiniDeps.later

later(function()
  -- Do read the installation section in the readme of mini.snippets!
  add({
    source = "echasnovski/mini.snippets",
    depends = { "rafamadriz/friendly-snippets" }
  })
  require("mini.snippets").setup({
    mappings = { expand = ''} -- expand is handled by the cmp source
    -- add your config table, needs `snippets` field present, :h MiniSnippets-examples
  })

  -- Do read the installation section in the readme of nvim-cmp!
  add({
    source = "hrsh7th/nvim-cmp",
    depends = { "abeldekat/cmp-mini-snippets" }, -- add path, buffer and more...
  })
  require'cmp'.setup {
    sources = { { name = 'mini_snippets' } },
    snippet = {
      expand = function(args) -- mini.snippets expands snippets from lsp...
        ---@diagnostic disable-next-line: undefined-global
        local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
        insert({ body = args.body }) -- Insert at cursor
      end,
    }
    -- more opts
  }
end)
```

### lazy.nvim

```lua
return {
  -- Do read the installation section in mini.snippets readme!
  {
    "echasnovski/mini.snippets",
    dependencies = "rafamadriz/friendly-snippets",
    opts = {
      mappings = { expand = ''} -- expand is handled by the cmp source
      -- add your config table, needs `snippets` field present, :h MiniSnippets-examples
    }
  },

  -- Do read the installation section in nvim-cmp readme!
  {
    "hrsh7th/nvim-cmp"
    dependencies = { "abeldekat/cmp-mini-snippets" }, -- more sources...
    event = "InsertEnter",
    opts = {
      sources = { { name = 'mini_snippets' } },
      snippet = {
        expand = function(args) -- mini.snippets expands snippets from lsp...
          ---@diagnostic disable-next-line: undefined-global
          local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
          insert({ body = args.body }) -- Insert at cursor
        end,
      }
      -- more opts
    }
  }
}
```

## LazyVim

There is a [LazyVim-PR] implementing an extra for mini.snippets..

## Acknowledgments

- [cmp_luasnip] by @saadparwaiz1 (especially for function `get_documentation`)
- [nvim-cmp] and sources by @hrsh7th
- [mini.snippets] by @echasnovski

[mini.snippets]: https://github.com/echasnovski/mini.snippets
[nvim-cmp]: https://github.com/hrsh7th/nvim-cmp
[cmp_luasnip]: https://github.com/saadparwaiz1/cmp_luasnip
[LazyVim-PR]: https://github.com/LazyVim/LazyVim/pull/5274
[beta]: https://github.com/echasnovski/mini.nvim/issues/1428
