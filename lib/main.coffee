path = require 'path'
fs = require 'fs-plus'
{File} = require 'pathwatcher'
{Emitter} = require 'atom'

module.exports =
class XpmEditor
  atom.deserializers.add(this)
  @deserialize: ({filePath}) ->
    if fs.isFileSync(filePath)
      new XpmEditor(filePath)
    else
      console.warn "Could not deserialize image editor for path '#{filePath}' because that file no longer exists"

  @activate: ->
    atom.workspace.addOpener (filePath='') ->
      # Check that the file path exists before opening in case something like
      # an http: URI is being opened.
      if /\.xpm$/i.test(filePath) and fs.isFileSync(filePath)
        new XpmEditor(filePath)

  serialize: ->
    {filePath: @getPath(), deserializer: @constructor.name}

  constructor: (filePath) ->
    @file = new File(filePath)
    @emitter = new Emitter()

  destroy: ->
    @emitter.emit 'did-destroy'

  onDidDestroy: (callback) ->
    @emitter.on 'did-destroy', callback

  getViewClass: -> require './xpm-view'

  getTitle: ->
    if @getPath()?
      path.basename(@getPath())
    else
      'untitled'

  getURI: -> @getPath()

  # Retrieves the absolute path to the image.
  #
  # Returns a {String} path.
  getPath: -> @file.getPath()

  # Compares two {ImageEditor}s to determine equality.
  #
  # Equality is based on the condition that the two URIs are the same.
  #
  # Returns a {Boolean}.
  isEqual: (other) ->
    other instanceof XpmEditor and @getURI() is other.getURI()
