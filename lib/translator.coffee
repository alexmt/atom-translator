TranslationService = require './translation-service'
TranslatorView = require './translator-view'
RETRIEVE_LANGUAGES_ERROR = 'Cannot retrieve supported languages'
TRANSLATION_FAILED = 'Translation failed'

module.exports =

  translatorView: null,
  languages: null,
  state: null,
  translationService: null,
  configDefaults: {
    clientId: 'atom-translator',
    # Please don't abuse!
    clientSecret: '8i5GjrCXS+Iab9TcaKn7gNkTcjIJn2hxPr7pLFsRhQA=',
  },

  activate: (state) ->
    @state = state ? {}
    @translationService = new TranslationService(@configDefaults)
    atom.workspaceView.command "translator:translate", => @translate()

  getTranslatorView: (editor, languages) ->
    if !@translatorView
      @translatorView = new TranslatorView(
        editor: editor,
        languages: languages,
        from: @state.from ? 'en',
        to: @state.to ? 'ru',
        viewHeight: @state.viewHeight,
        azureAppSettings: {})
      @translatorView.on 'close', => @closeTranslatorView()
      @translatorView.on 'translateRequested', => @refreshViewTranslation(@translatorView)
      @translatorView.on 'heightChanged', => @state.viewHeight = @translatorView.height()
      atom.workspaceView.prependToBottom(@translatorView)
    else
      @translatorView.attachToEditor(editor)
    return @translatorView

  refreshViewTranslation: (view) ->
    @state.from = view.from.getSelectedLanguage()
    @state.to = view.to.getSelectedLanguage()
    view.showTranslation '...'
    promise =@translationService.translateTextLines(
      view.getInputTest(),
      view.from.getSelectedLanguage(),
      view.to.getSelectedLanguage())
    promise.then(
      ((result) -> view.showTranslation(result)),
      ((error) -> view.showError(TRANSLATION_FAILED + ':\n' + error)) )

  translate: (view) ->
    editor = atom.workspace.getActiveEditor()
    if editor
      if !@languages
        @translationService.getLanguages()
          .then (languages) =>
            @languages = languages
            @refreshViewTranslation @getTranslatorView(editor, @languages)
          .catch (error) =>
            @getTranslatorView(editor, []).showError RETRIEVE_LANGUAGES_ERROR +
              ':\n' + error
      else
        @refreshViewTranslation @getTranslatorView(editor, @languages)

  closeTranslatorView: ->
    if @translatorView
      @translatorView.destroy()
      @translatorView = null

  deactivate: ->
    @closeTranslatorView()

  serialize: =>
    return @state
