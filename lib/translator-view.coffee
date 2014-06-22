{View} = require 'atom'

module.exports =
class TranslatorView extends View

  editor: null

  @content: ->
    @div class: 'translator', =>
      @p ""

  getInputTest: -> @editor.getText()

  showTranslation: (text) ->
    @find('p').text(text)

  initialize: (editor) ->
    @editor = editor

  serialize: -> {}

  destroy: ->
    @detach()
