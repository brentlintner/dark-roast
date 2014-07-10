app = require 'commander'
dark_roast = require './dark_roast'
pkg = require './../package'

validate = (path_to_coffee, opts) ->
  if !app.blend
    msg = 'I need a --blend extension (ex: .co).'
  else if !path_to_coffee
    msg = 'I need a path to coffee files.'

  if msg
    console.error msg
    process.exit 1

cs_opts = (args) ->
  args.slice(args.indexOf('--') + 1).join(' ')

interpret = ->
  app
    .version pkg.version
    .usage '[options] path/to/script.coffee -- [coffee-script-options]'
    .option '--blend [file_extension]', 'File extension to use.'
    .parse process.argv

  path_to_cs = app.args[0]

  validate path_to_cs, app

  dark_roast.compile path_to_cs,
                     cs_opts(process.argv),
                     app

module.exports =
  interpret: interpret
