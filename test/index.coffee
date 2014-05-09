#!/usr/bin/env coffee

vows = require 'vows'
assert = require 'assert'
wintersmith = require 'wintersmith'

vows
  .describe 'Plugin'
  .addBatch
    'wintersmith environment':
      topic: -> wintersmith './example/config.json'

      'loaded ok': (env) ->
        assert.instanceOf env, wintersmith.Environment

      'contents':
        topic: (env) -> env.load @callback

        'loaded ok': (result) ->
          assert.instanceOf result.contents, wintersmith.ContentTree

        'has plugin instances': (result) ->
          assert.instanceOf result.contents['index.md'], wintersmith.ContentPlugin
          assert.isArray result.contents._.pages
          assert.lengthOf result.contents._.pages, 1

        'contains the right text': (result) ->
          for item in result.contents._.pages
            assert.isObject item.metadata
            assert.isString item.metadata.template
            assert.match item.metadata.template, /^index.jade/

            assert.isString item.markdown
            assert.match item.markdown, /^\n\nWintersmith Mounter Plugin/

  .export module
