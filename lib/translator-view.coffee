{$, View} = require 'atom'
LanguageSelectorView = require './language-selector-view'

# Min translate panel height
MIN_HEIGHT = 100

module.exports =
class TranslatorView extends View

  editor: null
  textFinalizedTimer: null
  translationWaitTimeoutMilliseconds: 1000,
  clientId: null,
  clientSecret: null,

  @content: (params)->
    @div class: 'translator tool-panel panel-bottom panel', =>
      @div class: 'resizer'
      @div class: 'btn-toolbar', =>
        @subview 'from', new LanguageSelectorView(languages: params.languages, lang: params.from)
        @button '<->', class: 'btn', click: 'switchLangs'
        @subview 'to', new LanguageSelectorView(languages: params.languages, lang: params.to)
        @button 'Translate', class: 'btn', click: 'requestTranslation'
      @div class: 'panel-body', =>
        @textarea class : 'native-key-bindings'

  initialize: (params) ->
    @prepend('<a class="close">&times;</a>')
    @find('a.close').on 'click', () => @trigger('close')
    @from.on 'langChanged', => @requestTranslation()
    @to.on 'langChanged', => @requestTranslation()
    @attachToEditor(params.editor)
    @on 'mousedown', '.resizer', @resizeStarted
    @height(params.viewHeight ? MIN_HEIGHT)

  resizeStarted: (e) =>
    $(document).on 'mousemove', @resizeView
    $(document).on 'mouseup', @resizeStopped

  resizeView: (e) =>
    height = @height()
    @height(Math.max(height + @position().top - e.pageY, MIN_HEIGHT))

  resizeStopped: (e) =>
    $(document).off 'mousemove', @resizeView
    $(document).off 'mouseup', @resizeStopped
    @viewHeight = @height()
    @trigger 'heightChanged'

  getInputTextLines: -> @editor.buffer.lines

  switchLangs: ->
    fromLang = @from.getSelectedLanguage()
    @from.selectLanguage(@to.getSelectedLanguage(), false)
    @to.selectLanguage(fromLang, false)
    @requestTranslation()

  showTranslation: (text) ->
    @find('textarea').text(text)

  showError: (text) ->
    @find('textarea').text(text)

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
      @requestTranslation()), @translationWaitTimeoutMilliseconds

  destroy: =>
    @detachFromEditor()
    @detach()
