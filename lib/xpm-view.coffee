path = require 'path'
PixmapReader = require 'xpixmap'
{ScrollView} = require 'atom-space-pen-views'
{CompositeDisposable} = require 'atom'

# View that renders the image of an {ImageEditor}.
module.exports =
class XpmView extends ScrollView
  @content: ->
    @div class: "xpm-view", =>
      @div outlet: 'errorMessage', class: 'padded icon icon-alert text-error'
      @div class: 'xpm-container', =>
        @div class: 'xpm-container-cell', =>
          @canvas outlet: 'canvas',

  initialize: (editor) ->
    commandDisposable = super()
    commandDisposable.dispose()
    @setModel(editor)

  refresh: ->
    @errorMessage.hide()
    originalPath = @path
    pix = new PixmapReader(originalPath,{format:"RGBA"})
    @canvas.prop({
                    width: pix.width,
                    height: pix.height
                })
    context = @canvas[0].getContext('2d')
    image = context.createImageData(pix.width, pix.height)
    offset = 0
    for d,i in pix.data
      image.data[i] = d
    context.putImageData(image, 0, 0)
    #@errorMessage.show().text(e.stack)

  setPath: (path) ->
    if path and @path isnt path
      @path = path
      @refresh()

  setModel: (editor) ->
    @editorSubscriptions?.dispose()
    @editorSubscriptions = null

    if editor?
      @editorSubscriptions = new CompositeDisposable()
      @editor = editor
      @setPath(editor.getPath())
      @editorSubscriptions.add editor.file.onDidChange =>
        @refresh()
      @editorSubscriptions.add editor.file.onDidDelete =>
        atom.workspace.paneForItem(@editor)?.destroyItem(@editor)
      @editorSubscriptions.add editor.onDidDestroy =>
        @editorSubscriptions?.dispose()
        @editorSubscriptions = null
