coffee = require 'coffee-script'
path = require 'path'
async = require 'async'
wrench = require 'wrench'
fs = require 'fs'
child_process = require 'child_process'
_ = require 'underscore'
logger = require './logger'
coffeescript = path.join __dirname, '..', 'node_modules', '.bin', 'coffee'
log = logger.create 'dark-roast'
file_ext = /\..*$/

handle_err = (cb) ->
  (err, args...) ->
    if err
      log.error err
      process.exit 1
    else
      cb.apply cb, args

copy_file = (cs_path, file_path, cb) ->
  full_path = path.join process.cwd(), cs_path, file_path
  coffee_path = full_path.replace file_ext, '.coffee'

  coffee_file = fs.createWriteStream coffee_path
  write = fs.createReadStream full_path
  write.pipe coffee_file
  write.on 'end', cb

compile_cs = (cs_path, cs_opts, files) ->
  _.each files, (file) ->
    log.info "compiling #{cs_path}/#{file}"

  child_process.exec "#{coffeescript} #{cs_opts} #{cs_path}",
    handle_err (stdout, stderr) ->
      process.stdout.write stdout
      process.stderr.write stderr

      async.each files,
        (file_path, cb) ->
          full_path = path.join process.cwd(), cs_path, file_path
          coffee_path = full_path.replace file_ext, '.coffee'
          fs.unlink coffee_path, handle_err(cb)
        handle_err

compile = (cs_path, cs_opts, opts) ->
  abs_path = path.join(process.cwd(), cs_path)
  custom_file_ext = new RegExp "#{opts.blend}$"

  wrench.readdirRecursive abs_path,
    handle_err (files) ->
      return if not files

      files = _.reject files, (file) ->
        fs.statSync(path.join abs_path, file).isDirectory() or
          !file.match custom_file_ext

      # HACK: don't just lazily copy files
      async.each files,
        copy_file.bind(null, cs_path),
        handle_err compile_cs.bind(null, cs_path, cs_opts, files)

module.exports =
  compile: compile
