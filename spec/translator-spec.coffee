{WorkspaceView} = require 'atom'
q = require 'q'
Translator = require '../lib/translator'

describe "Translator", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('translator')

  describe "when the translator:translate event is triggered", ->
    it "tries to translate input text", ->
      expect(atom.workspaceView.find('.translator')).not.toExist()
