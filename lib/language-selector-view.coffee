{View} = require 'atom'

module.exports =
class LanguageSelectorView extends View

  @content: (params)->
    @div class: 'btn-group language-selector', =>
      @button outlet: 'langButton', class: 'btn btn-default'
      @button class: 'btn', click: 'showMenu', =>
        @span class: 'caret'
      @ul class: 'dropdown-menu', =>
        for lang in params.languages
          @li =>
            @a lang, lang: lang , click: 'selectLanguage'

  initialize: (params)->
    @langButton.text(params.lang)

  showMenu: (event, element) ->
    @toggleClass('open')

  selectLanguage: (event, element) ->
    @langButton.text(element.attr('lang'))
    @removeClass('open')
