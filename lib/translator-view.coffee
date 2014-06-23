{View} = require 'atom'
LanguageSelectorView = require './language-selector-view'

module.exports =
class TranslatorView extends View

  editor: null

  @content: (params)->
    @div class: 'translator tool-panel panel-bottom panel', =>
      @div class: 'btn-toolbar', =>
        @subview 'from', new LanguageSelectorView(languages: params.languages, lang: params.from)
        @button '<->', class: 'btn'
        @subview 'to', new LanguageSelectorView(languages: params.languages, lang: params.to)
        @button 'Translate', class: 'btn'
      @div class: 'panel-body', =>
        @p ""

  initialize: (params) ->
    @prepend('<a class="close">&times;</a>')
    @find('a.close').on 'click', () => @trigger('close')
    @attachToEditor(params.editor)

  getInputTest: -> @editor.getText()

  showTranslation: (text) ->
    @find('p').text(text)

  attachToEditor: (editor) ->
    @editor = editor

  destroy: ->
    @detach()
