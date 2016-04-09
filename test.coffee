chai = require 'chai'
chai.use require "chai-as-promised"
chai.should()
{expect} = chai
{sleep} = require "promised-util"

evocatio = require './index'

describe 'evocatio', ->

    fns = evocatio()

    it "should dispatch synchronously", ->

        fns.register "add", (a,b)->
            a + b

        fns.dispatch("add", a: 1, b: 2).should.equal 3

    it "should return promise", ->

        fns.register "async",
            add: (a,b)->
                yield sleep 10
                a + b
            error: ->
                Promise.reject new Error "fail"

        fns.dispatch("async.add", a: 1, b: 2).should.eventually.equal 3
        fns.dispatch("async.error", {}).should.be.rejected

    it "should complain for missing params", ->

        expect(-> fns.dispatch "async.add", b: 2).to.throw /Parameter missing/

    it "should complain for unexpected params", ->

        expect(-> fns.dispatch "async.add", a:1, b:2, c:3).to.throw /Unexpected parameter/

    it "should complain for unexpected call", ->

        expect(-> fns.dispatch "unknow", {}).to.throw /Method not registered/

    it "should handle unregistered method", ->
        fns = evocatio (name, kwargs)-> "#{name} is not here"
        fns.dispatch("unknow", {}).should.equal "unknow is not here"

    it "should bind context", ->
        fns = evocatio()
        fns.register "ctx", (param)->
            [@session, param]
        fns.dispatch("ctx", {param: "bar"}, {session: "foo"}).should.deep.equal ["foo", "bar"]
