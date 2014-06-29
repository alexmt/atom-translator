TranslationService = require './translation-service'
TranslatorView = require './translator-view'

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
        from: 'en',
        to: 'ru',
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
    view.showTranslationHtml '...'
    @translationService.translateTextLines(
      view.getInputTest(),
      view.from.getSelectedLanguage(),
      view.to.getSelectedLanguage()).then (result) => view.showTranslationHtml result

  translate: (view) ->
    editor = atom.workspace.getActiveEditor()
    if editor
      if !@languages
        @translationService.getLanguages().then (languages) =>
          @languages = languages
          @refreshViewTranslation @getTranslatorView(editor, @languages)
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
