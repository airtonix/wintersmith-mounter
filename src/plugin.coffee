_ = require 'lodash'
fs = require 'fs'
path = require 'path'
diveSync = require 'diveSync'

module.exports = (env, done) ->

	defaults =
		options:
			allow: /(\.js|\.coffee|\.map)$/
		mounts:
			'/vendor/':
				src: './bower_components'

	options = _.merge defaults, env.config.bower or {}


	class MounterGenerator

		constructor: (contents, options, callback) ->
			tree = []
			for key, value in options.mounts
				config = _.merge defaults.options, value
				files = @discover config
				tree.push @mount files

			callback null, mounts: tree

		discover: (options) ->
			target = path.resolve env.workDir, options.src
			pattern = new RegExp options.allow
			output = []
			diveSync target, (err, file) =>
				throw err if err
				if pattern.test file
					output.push file
			output

		mount: (options, files) ->
			output = {}
			for file in files
				relative = file.replace env.workDir, '.'
				mounted = path.join options.mount, relative.replace options.root, ''
				full = path.resolve env.workDir, relative
				output[mounted] = new env.plugins.StaticFile
					relative: mounted
					full: full


	env.registerGenerator 'bower', (contents, callback) ->
		new BowerGenerator(contents, options, callback)

	done()