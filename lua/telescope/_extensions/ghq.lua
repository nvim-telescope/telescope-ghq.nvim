local ghq_builtin = require "telescope._extensions.ghq_builtin"

return require("telescope").register_extension {
  exports = {
    ghq = ghq_builtin.list,
    list = ghq_builtin.list,
  },
}
