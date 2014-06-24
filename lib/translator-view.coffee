{View} = require 'atom'
LanguageSelectorView = require './language-selector-view'

module.exports =
class TranslatorView extends View

  editor: null

  @content: (params)->
    @div class: 'translator tool-panel panel-bottom panel', =>
      @div class: 'btn-toolbar', =>
        @subview 'from', new LanguageSelectorView(languages: params.languages, lang: params.from)
        @button '<->', class: 'btn', click: 'switchLangs'
        @subview 'to', new LanguageSelectorView(languages: params.languages, lang: params.to)
        @button 'Translate', class: 'btn', click: 'requestTranslation'
      @div class: 'panel-body', =>
        @p ""

  initialize: (params) ->
    @prepend('<a class="close">&times;</a>')
    @find('a.close').on 'click', () => @trigger('close')
    @from.on 'langChanged', => @requestTranslation()
    @to.on 'langChanged', => @requestTranslation()
    @attachToEditor(params.editor)

  getInputTest: -> @editor.getText()

  switchLangs: ->
    fromLang = @from.getSelectedLanguage()
    @from.selectLanguage(@to.getSelectedLanguage(), false)
    @to.selectLanguage(fromLang, false)
    @requestTranslation()

  showTranslation: (text) ->
    @find('p').text(text)

  requestTranslation: ->
    @trigger 'translateRequested'

  attachToEditor: (editor) ->
    @editor = editor

  destroy: ->
    @detach()
