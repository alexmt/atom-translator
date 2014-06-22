q = require 'q'
request = require 'request'
querystring = require('querystring')
TranslatorView = require './translator-view'

dataMarketAccessUrl = 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'

azureAppSettings = {
  client_id: 'your client id here',
  client_secret: 'your client secret here',
  scope: 'http://api.microsofttranslator.com'
  grant_type: 'client_credentials'
}

accessToken = null

getAccessToken = () ->
  deferred = q.defer()
  if accessToken == null
    request.post 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13', {
      form: azureAppSettings
    }, (error, response, body) ->
      if !error and response.statusCode == 200
        accessToken = JSON.parse(body).access_token
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
      qs: params
    }, (error, response, body) ->
      if !error and response.statusCode == 200
        deferred.resolve response.body
      else
        deferred.reject error
  return deferred.promise

translateText = (text, from, to) ->
  callTranslatorApi 'Translate', { from: 'en', to: 'ru', text: text }

module.exports =

  activate: (state) ->
    atom.workspaceView.command "translator:translate", => @translate()

  translate: ->
    editor = atom.workspaceView.find('.editor.is-focused')
    if editor.length == 1
      translator = editor.find('.translator')
      if translator.length == 0
        view = new TranslatorView(atom.workspace.getActiveEditor())
        editor.append(view)
      else
        view = translator.view()
      translateText(view.getInputTest(), 'en', 'ru').then (result) ->
        view.showTranslation result

  deactivate: ->

  serialize: -> {}
