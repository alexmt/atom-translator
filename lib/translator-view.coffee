{View} = require 'atom'
LanguageSelectorView = require './language-selector-view'

module.exports =
class TranslatorView extends View

  editor: null
  textFinalizedTimer: null
  translationWaitTimeoutMilliseconds: 1000

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

  getInputTest: -> @editor.buffer.lines

  switchLangs: ->
    fromLang = @from.getSelectedLanguage()
    @from.selectLanguage(@to.getSelectedLanguage(), false)
    @to.selectLanguage(fromLang, false)
    @requestTranslation()

  showTranslationHtml: (text) ->
    @find('p').html(text)

  requestTranslation: =>
    @trigger 'translateRequested'

  detachFromEditor: ->
    if @textFinalizedTimer
      clearTimeout @textFinalizedTimer
      @textFinalizedTimer = null
    if @editor
      @editor.buffer.off 'changed', @onTextChanged

  attachToEditor: (editor) ->
    @detachFromEditor()
    @editor = editor
    @editor.buffer.on 'changed', @onTextChanged

  onTextChanged: =>
    if @textFinalizedTimer
      clearTimeout @textFinalizedTimer
      @textFinalizedTimer = null
    @textFinalizedTimer = setTimeout (=>
      @textFinalizedTimer = null
      @requestTranslation() ), @translationWaitTimeoutMilliseconds

  destroy: =>
    @detachFromEditor()
    @detach()
