minilog = require "minilog"
fs = require "fs"

minilog
  .pipe minilog.backends.nodeConsole.formatLearnboost
  .pipe minilog.backends.nodeConsole

create = (name) -> minilog name

module.exports = create: create
