chai = require 'chai'
chai.should()

evocatio = require './index'

describe 'evocatio', ->

    it "should", ->

        fns = evocatio()
        fns.register "add", (a,b)->
            a + b

        fns.dispatch("add", a: 1, b: 2).should.equal 3
