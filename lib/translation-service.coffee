q = require 'q'
request = require 'request'
querystring = require 'querystring'

module.exports =
class TranslationService

  dataMarketAccessUrl: 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13'
  accessToken: null
  appSettings: null

  constructor: (appSettings) ->
    @appSettings = {
      scope: 'http://api.microsofttranslator.com',
      grant_type: 'client_credentials',
      client_id: appSettings.clientId,
      client_secret: appSettings.clientSecret
    }

  getAccessToken: () ->
    deferred = q.defer()
    if @accessToken == null
      request.post 'https://datamarket.accesscontrol.windows.net/v2/OAuth2-13', {
        form: @appSettings,
        json: true,
        encoding: 'utf8',
      }, (error, response, body) =>
        if !error and response.statusCode == 200
          @accessToken = body.access_token
          deferred.resolve(@accessToken)
        else
          deferred.reject(error)
    else
      deferred.resolve(@accessToken)
    return deferred.promise

  callTranslatorApi: (method, params, remainingAttempts, deferred) ->
    remainingAttempts = remainingAttempts ? 1
    deferred = deferred ? q.defer()
    @getAccessToken().then (token) =>
      params.appId = "Bearer #{token}"
      request {
        url : "http://api.microsofttranslator.com/V2/Ajax.svc/#{method}",
        json: true,
        encoding: 'utf8',
        qs: params
      }, (error, response, body) =>
        if !error and response.statusCode == 200
          # Check if API request failed.
          if /ArgumentException: .*: ID=.*V2_Json[.].*/.test(body)
            error = body
          else
            deferred.resolve response.body
        else
          error = error ? response.statusCode
        if error
          # Try to refresh token and execute request few more times
          if remainingAttempts > 0
            @accessToken = null
            @callTranslatorApi(method, params, --remainingAttempts, deferred)
          else
            deferred.reject error
    return deferred.promise

  translateTextLines: (lines, from, to) ->
    @callTranslatorApi 'Translate',
      from: from,
      to: to,
      text: lines.join('<br/>'),
      contentType : 'text/html'

  getLanguages: -> @callTranslatorApi 'GetLanguagesForTranslate', {}
