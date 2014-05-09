_ = require 'lodash'
fs = require 'fs'
path = require 'path'
diveSync = require 'diveSync'

module.exports = (env, done) ->

	defaults =
		options:
			allow: /(\.js|\.coffee|\.map)$/
		mounts: {}

	options = _.merge defaults, env.config.mounter or {}


	class MounterGenerator

		constructor: (contents, callback) ->
			tree = []

			_.forEach options.mounts, (value, mount) =>
				config = _.merge defaults.options, value
				files = @discover config
				mountedTree = @mount mount, files,  config
				tree = tree.concat mountedTree

			callback null, mounts: tree

		discover: (config) ->
			target = path.resolve env.workDir, config.src
			pattern = new RegExp config.allow
			output = []
			diveSync target, (err, file) =>
				throw err if err
				if pattern.test file
					output.push file
			output

		mount: (mount, files, config) ->
			output = {}
			for file in files
				relative = file.replace env.workDir, '.'
				mounted = path.join mount, relative.replace config.src, ''
				full = path.resolve env.workDir, relative
				output[mounted] = new env.plugins.StaticFile
					relative: mounted
					full: full


	env.registerGenerator 'mounter', (contents, callback) -> new MounterGenerator(contents, callback)

	done()