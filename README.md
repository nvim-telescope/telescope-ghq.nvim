# telescope-ghq.nvim

`telescope-ghq` is an extension for [telescope.nvim][] that provides its users with operating [x-motemen/ghq][].

[telescope.nvim]: https://github.com/nvim-telescope/telescope.nvim
[x-motemen/ghq]: https://github.com/x-motemen/ghq

## Installation

```lua
use{
  "nvim-telescope/telescope.nvim",
  requires = {
    "nvim-telescope/telescope-ghq.nvim",
  },
  config = function()
    require("telescope").load_extension "ghq"
  end,
}
```

## Usage

Now supports `ghq list` only.

TODO: others

### list

`:Telescope ghq`

Running `ghq list` and list repositories' paths. In default, it does actions below when you input keys.

| key              | action               |
|------------------|----------------------|
| `<CR>` (edit)    | `builtin.git_files`  |
| `<C-x>` (split)  | `:chdir` to the dir  |
| `<C-v>` (vsplit) | `:lchdir` to the dir |
| `<C-t>` (tabnew) | `:tchdir` to the dir |

#### options

#### `bin`

Filepath for the binary `ghq`.

```vim
" path can be expanded
:Telescope ghq bin=~/ghq
```

#### `cwd`

Transform the result paths into relative ones with this value as the base dir.

Default value: `vim.uv.cwd()`

#### `tail_path` (deprecated)

***This is deprecated. Use `path_display` (`:h telescope.defaults.path_display`).***

Show only basename of the path.

Default value: `false`

#### `shorten_path` (deprecated)

***This is deprecated. Use `path_display` (`:h telescope.defaults.path_display`).***

Call `pathshorten()` for each path.

Default value: `false`
