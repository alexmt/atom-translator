q = require 'q'
request = require 'request'
querystring = require('querystring')
TranslatorView = require './translator-view'

dataMarketAccessUrl = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'

azureAppSettings = {
  client_id: 'atom-translator',
  # Please don't abuse!
  client_secret: '8i5GjrCXS+Iab9TcaKn7gNkTcjIJn2hxPr7pLFsRhQA=',
  scope: 'http://api.microsofttranslator.com'
  grant_type: 'client_credentials'
}

accessToken = null

getAccessToken = () ->
  deferred = q.defer()
  if accessToken == null
    request.post 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13', {
      form: azureAppSettings,
      json: true,
      encoding: 'utf8',
    }, (error, response, body) ->
      if !error and response.statusCode == 200
        accessToken = body.access_token
        deferred.resolve(accessToken)
      else
        deferred.reject(error)
  else
    deferred.resolve(accessToken)
  return deferred.promise

callTranslatorApi = (method, params) ->
  deferred = q.defer()
  getAccessToken().then (token) ->
    params.appId = "Bearer #{token}"
    request {
      url : "http://api.microsofttranslator.com/V2/Ajax.svc/#{method}",
      json: true,
      encoding: 'utf8',
      qs: params
    }, (error, response, body) ->
      if !error and response.statusCode == 200
        deferred.resolve response.body
      else
        deferred.reject error
  return deferred.promise

translateText = (text, from, to) ->
  callTranslatorApi 'Translate', from: from, to: to, text: text

getLanguages = -> callTranslatorApi 'GetLanguagesForTranslate', {}

module.exports =

  translatorView: null,

  activate: (state) ->
    atom.workspaceView.command "translator:translate", => @translate()

  getTranslatorView: (editor, languages) ->
    if !@translatorView
      @translatorView = new TranslatorView(
        editor: editor,
        languages: languages,
        from: 'en',
        to: 'ru')
      @translatorView.on 'close', => @closeTranslatorView()
      @translatorView.on 'translateRequested', => @translate()
      atom.workspaceView.prependToBottom(@translatorView)
    else
      @translatorView.attachToEditor(editor)
    return @translatorView

  translate: ->
    editor = atom.workspace.getActiveEditor()
    if editor
      getLanguages().then (languages) =>
        view = @getTranslatorView(editor, languages)
        view.showTranslation '...'
        translateText(
          view.getInputTest(),
          view.from.getSelectedLanguage(),
          view.to.getSelectedLanguage()).then (result) => view.showTranslation result

  closeTranslatorView: ->
    if @translatorView
      @translatorView.destroy()
      @translatorView = null

  deactivate: ->

  serialize: -> {}
