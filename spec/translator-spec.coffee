q = require 'q'
Translator = require '../lib/translator'

describe 'Translator package', ->

  getLanguagesDeferred = null
  translateTextLinesDeferred = null
  translationService = null

  beforeEach ->
    getLanguagesDeferred = q.defer()
    translateTextLinesDeferred = q.defer()

    spyOn(atom.workspace, 'addBottomPanel')
    waitsForPromise ->
      atom.workspace.open 'new.txt'

    Translator.activate()
    Translator.languages = ['en', 'ru']
    Translator.translatorView = null
    translationService = jasmine.createSpyObj('translationService',
      ['getLanguages', 'translateTextLines'])
    translationService.getLanguages.andReturn(getLanguagesDeferred.promise)
    translationService.translateTextLines.andReturn(translateTextLinesDeferred.promise)

    Translator.translationService = translationService

  it 'reloads list of available languages', ->
    Translator.languages = null

    atom.commands.dispatch atom.views.getView(atom.workspace), 'translator:translate'

    expect(translationService.getLanguages).toHaveBeenCalled()

  it 'translates input text of active editor', ->
    atom.workspace.getActiveTextEditor().setText('Hello world')

    atom.commands.dispatch atom.views.getView(atom.workspace), 'translator:translate'

    waitsFor ->
      translationService.translateTextLines.callCount > 0
    runs ->
      expect(translationService.translateTextLines).toHaveBeenCalledWith(
        ['Hello world'], 'en', 'ru')

  it 'creates view and sets translation result', ->

    atom.commands.dispatch atom.views.getView(atom.workspace), 'translator:translate'

    waitsFor ->
      translationService.translateTextLines.callCount > 0 and
      atom.workspace.addBottomPanel.callCount > 0

    runs ->
      view = atom.workspace.addBottomPanel.mostRecentCall.args[0]
      expect(view.item.find('textarea').text()).toEqual('...')

      translateTextLinesDeferred.resolve 'Translation result'

      waitsForPromise ->
        translateTextLinesDeferred.promise

      runs ->
        expect(view.item.find('textarea').text()).toEqual('Translation result')
