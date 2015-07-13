{View} = require 'atom-space-pen-views'

module.exports =
class LanguageSelectorView extends View

  @content: (params)->
    @div class: 'btn-group language-selector', =>
      @button outlet: 'langButton', class: 'btn btn-default'
      @button class: 'btn', click: 'onShowMenuClick', =>
        @span class: 'caret'
      @ul class: 'dropdown-menu', =>
        for lang in params.languages
          @li =>
            @a lang, lang: lang , click: 'onSelectLanguage'

  initialize: (params)->
    @langButton.text(params.lang)

  selectLanguage: (lang, triggerEvent) ->
    oldLang = @langButton.text()
    @langButton.text(lang)
    @removeClass('open')
    if triggerEvent and oldLang != lang
      @trigger 'langChanged'

  getSelectedLanguage: ->
    return @langButton.text()

  onSelectLanguage: (event, element) ->
    @selectLanguage(element.attr('lang'), true)

  onShowMenuClick: (event, element) ->
    @toggleClass('open')
