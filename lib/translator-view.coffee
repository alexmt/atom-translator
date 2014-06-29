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
      @div class: 'translator-content-view', =>
        @div class: 'btn-toolbar', =>
          @subview 'from', new LanguageSelectorView(languages: params.languages, lang: params.from)
          @button '<->', class: 'btn', click: 'switchLangs'
          @subview 'to', new LanguageSelectorView(languages: params.languages, lang: params.to)
          @button 'Translate', class: 'btn', click: 'requestTranslation'
          @button 'Settings', class: 'btn', role: 'show-settings', click: 'showSettings'
        @div class: 'panel-body', =>
          @p ""
      @div class: 'translator-settings-view', =>
        @form role: 'form', =>
          @div class: 'form-group', =>
            @label 'Client ID', for: 'client-id'
            @input outlet: 'clientIdInput', type: 'text', class: 'form-control',id: 'client-id'
          @div class: 'form-group', =>
            @label 'Client Secret', for: 'client-secret'
            @input outlet: 'clientSecretInput', type: 'text', class: 'form-control', id: 'client-secret'
        @div class: 'btn-toolbar', =>
          @button 'Save', class: 'btn', role: 'save', click: 'saveSettingsChanges'
          @button 'Cancel', class: 'btn', role: 'cancel', click: 'cancelSettingsChanges'
          @button 'Set Default', class: 'btn', role: 'save', click: 'cancelSettingsChanges'

  initialize: (params) ->
    @prepend('<a class="close">&times;</a>')
    @find('a.close').on 'click', () => @trigger('close')
    @from.on 'langChanged', => @requestTranslation()
    @to.on 'langChanged', => @requestTranslation()
    @attachToEditor(params.editor)
    @on 'mousedown', '.resizer', @resizeStarted
    @height(params.viewHeight ? MIN_HEIGHT)
    @setSettings params.azureAppSettings

  setSettings: (settings) =>
    @clientId = settings.client_id
    @clientSecret = settings.client_secret
    @clientIdInput.val(@clientId)
    @clientSecretInput.val(@clientSecret)

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

  showSettings: =>
    @addClass('translator-settings-view')

  saveSettingsChanges: =>
    @clientSecret = @clientSecretInput.val()
    @clientId = @clientIdInput.val()
    @trigger('settingsChanged')
    @removeClass('translator-settings-view')

  cancelSettingsChanges: =>
    @clientSecretInput.val(@clientSecret)
    @clientIdInput.val(@clientId)
    @removeClass('translator-settings-view')

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
      @requestTranslation()), @translationWaitTimeoutMilliseconds

  destroy: =>
    @detachFromEditor()
    @detach()
