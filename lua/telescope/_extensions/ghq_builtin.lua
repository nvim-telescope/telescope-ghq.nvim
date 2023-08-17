local actions = require "telescope.actions"
local actions_set = require "telescope.actions.set"
local actions_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local entry_display = require "telescope.pickers.entry_display"
local finders = require "telescope.finders"
local from_entry = require "telescope.from_entry"
local pickers = require "telescope.pickers"
local previewers = require "telescope.previewers"
local utils = require "telescope.utils"
local Path = require "plenary.path"

local uv = vim.uv or vim.loop

local M = {}

local function search_readme(dir)
  for _, name in pairs {
    "README",
    "README.md",
    "README.markdown",
    "README.mkd",
  } do
    local file = dir / name
    if file:is_file() then
      return file
    end
  end
  return nil
end

local function search_doc(dir)
  local doc_path = Path:new(dir, "doc", "**", "*.txt")
  local maybe_doc = vim.split(vim.fn.glob(doc_path.filename), "\n")
  for _, filepath in pairs(maybe_doc) do
    local file = Path:new(filepath)
    if file:is_file() then
      return file
    end
  end
  return nil
end

local sep = Path.path.sep
local home = (function(h)
  return h .. (h:sub(-1) ~= sep and sep or "")
end)(assert(Path.path.home))
local basename_regex = (".*%s([^%s]+)"):format(sep, sep)

local function replace_home(path)
  local start, finish = path:find(home, 1, true)
  if start == 1 then
    path = "~" .. sep .. path:sub(finish + 1, -1)
  end
  return path
end

local function make_items(opts, path)
  if path == Path.path.root() then
    return { "", path }
  end
  local transformed = utils.transform_path(opts, path)
  local replaced = replace_home(transformed)
  local basename = replaced:match(basename_regex)
  if not basename then
    return { "", replaced }
  end
  local parent = replaced:sub(1, #replaced - #basename)
  return { { parent, "Directory" }, basename }
end

local displayer = entry_display.create {
  separator = "",
  items = { {}, {} },
}

local function gen_from_ghq(opts)
  return function(line)
    return {
      value = line,
      ordinal = line,
      path = line,
      display = function(entry)
        local items = make_items(opts, entry.path)
        return displayer(items)
      end,
    }
  end
end

M.list = function(opts)
  opts = opts or {}
  opts.bin = opts.bin and vim.fn.expand(opts.bin) --[[@as string]]
    or "ghq"
  opts.cwd = utils.get_lazy_default(opts.cwd, uv.cwd)
  opts.entry_maker = utils.get_lazy_default(opts.entry_maker, gen_from_ghq, opts)
  if opts.tail_path then
    opts.path_display = { "tail" }
  elseif opts.shorten_path then
    opts.path_display = { "shorten" }
  end

  local bin = vim.fn.expand(opts.bin)
  pickers
    .new(opts, {
      prompt_title = "Repositories managed by ghq",
      finder = finders.new_oneshot_job({ bin, "list", "--full-path" }, opts),
      previewer = previewers.new_termopen_previewer {
        get_command = function(entry)
          local dir = Path:new(from_entry.path(entry))
          local doc = search_readme(dir)
          local is_mardown
          if doc then
            is_mardown = true
          else
            -- TODO: doc may be previewed in a plain text. Can I use syntax highlight?
            doc = search_doc(dir)
          end
          if doc then
            if is_mardown and vim.fn.executable "glow" == 1 then
              return { "glow", doc.filename }
            elseif vim.fn.executable "bat" == 1 then
              return { "bat", "--style", "header,grid", doc.filename }
            end
            return { "cat", doc.filename }
          end
          return { "echo", "" }
        end,
      },
      sorter = conf.file_sorter(opts),
      attach_mappings = function(prompt_bufnr)
        actions_set.select:replace(function(_, type)
          local entry = actions_state.get_selected_entry()
          local dir = from_entry.path(entry)
          if type == "default" then
            require("telescope.builtin").git_files { cwd = dir }
            return
          end
          actions.close(prompt_bufnr)
          if type == "horizontal" then
            vim.cmd("cd " .. dir)
            print("chdir to " .. dir)
          elseif type == "vertical" then
            vim.cmd("lcd " .. dir)
            print("lchdir to " .. dir)
          elseif type == "tab" then
            vim.cmd("tcd " .. dir)
            print("tchdir to " .. dir)
          end
        end)
        return true
      end,
    })
    :find()
end

return M
