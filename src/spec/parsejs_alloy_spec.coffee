Ti.include('spec/spec_helper.js')
Ti.include('app.js')

describe "Alloy Models", ->

  # fixtures
  GameScore = Parse.Object.extend("TestGameScore")
  danScore = null

  beforeAll ->
    dropAllWhileWaiting(GameScore)

    makeScore = (opts) ->
      gs = new GameScore()
      gs.save opts

    runs ->
      waitsForPromise(makeScore(fields)) for fields in [
        playerName: "Joan Smith"
        playerAge: 13
      ,
        playerName: "Chris Delio"
        playerAge: 14
      ,
        playerName: "Dan Stemkoski"
        playerAge: 15
        score: 5
      ,
        playerName: "Linda Heckridge"
        playerAge: 21
      ,
        playerName: "James Thomas"
        playerAge: 23
        score: 3
        favoriteNumbers: [1, 2, 3]
      ,
        playerName: "Michael Yabuti"
        playerAge: 25
        favoriteNumbers: [3, 5, 24]
      ]

    runs ->
      query = new Parse.Query(GameScore)
      query.equalTo "playerName", "Dan Stemkoski"

      waitsForPromise ->
        query.find
          success: (results) ->
            danScore = results[0]


  it "fetches a single model", ->
    score = Alloy.createModel('game_score')
    score.id = danScore.id

    waitsWithPromiseCallbacks (cb) ->
      score.fetch(cb)

    runs ->
      expect( score.get('playerName') ).toEqual "Dan Stemkoski"
      expect( score.get('playerAge') ).toEqual 15
      expect( score.get('score') ).toEqual 5


  it "creates a model from set attributes", ->
    score = Alloy.createModel('game_score2')
    score.set("playerName", "Boofus Merriweather")
    score.set("playerAge", 24)
    score.set("score", 55)

    waitsWithPromiseCallbacks (cb) ->
      score.save(null, cb)

    runs ->
      newScore = Alloy.createModel('game_score2')
      newScore.id = score.id

      waitsWithPromiseCallbacks (cb) ->
        newScore.fetch(cb)

      runs ->
        expect( newScore.get('playerName') ).toEqual "Boofus Merriweather"
        expect( newScore.get('playerAge') ).toEqual 24
        expect( newScore.get('score') ).toEqual 55


  it "creates a model from direct attributes", ->
    score = Alloy.createModel('game_score2')

    waitsWithPromiseCallbacks (cb) ->
      score.save
        playerName: "Meowington Moses"
        playerAge: 23
        score: 22
      , cb

    runs ->
      newScore = Alloy.createModel('game_score2')
      newScore.id = score.id

      waitsWithPromiseCallbacks (cb) ->
        newScore.fetch(cb)

      runs ->
        expect( newScore.get('playerName') ).toEqual "Meowington Moses"
        expect( newScore.get('playerAge') ).toEqual 23
        expect( newScore.get('score') ).toEqual 22


  it "does not fail to save if createdAt and updatedAt are set", ->
    score = Alloy.createModel('game_score2')

    waitsWithPromiseCallbacks (cb) ->
      score.save
        playerName: "Meowington Moses"
        playerAge: 23
        score: 22
        createdAt: "2013-11-21T11:55:36.046Z"
        updatedAt: "2013-11-21T11:55:36.046Z"
      , cb

    runs ->
      newScore = Alloy.createModel('game_score2')
      newScore.id = score.id

      waitsWithPromiseCallbacks (cb) ->
        newScore.fetch(cb)

      runs ->
        expect( newScore.get('playerName') ).toEqual "Meowington Moses"
        expect( newScore.get('playerAge') ).toEqual 23
        expect( newScore.get('score') ).toEqual 22


  it "fetches a collection", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch(cb)

    runs ->
      expect( scores.length ).toEqual 6
      names = scores.pluck("playerName")
      expect( names ).toContain "Joan Smith"
      expect( names ).toContain "Chris Delio"
      expect( names ).toContain "Dan Stemkoski"
      expect( names ).toContain "Linda Heckridge"
      expect( names ).toContain "James Thomas"
      expect( names ).toContain "Michael Yabuti"


  it "creates a model through a collection", ->
    scores = Alloy.createCollection('game_score2')

    p = waitsWithPromiseCallbacks (cb) ->
      scores.create
        playerName: "Jesus Malone"
        playerAge: 29
        score: 44
      , cb

    p.then (score) ->
      newScore = Alloy.createModel('game_score2')
      newScore.id = score.id

      waitsWithPromiseCallbacks (cb) ->
        newScore.fetch(cb)

      runs ->
        expect( newScore.get('playerName') ).toEqual "Jesus Malone"
        expect( newScore.get('playerAge') ).toEqual 29
        expect( newScore.get('score') ).toEqual 44


  it "fetches a collection using a basic query", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            playerName: "Dan Stemkoski"

    runs ->
      expect( scores.length ).toEqual 1
      expect( scores.at(0).get("playerName") ).toEqual "Dan Stemkoski"


  it "fetches a collection using query constraints", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            playerName:
              $ne: "Michael Yabuti"
            playerAge:
              $gt: 18

    runs ->
      names = scores.pluck("playerName")
      expect( names.length ).toEqual 2
      expect( names ).toContain "Linda Heckridge"
      expect( names ).toContain "James Thomas"


  it "fetches a collection using a limit", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          limit: 2
          where:
            playerAge:
              $gt: 14

    runs ->
      names = scores.pluck("playerName")
      expect( names.length ).toEqual 2
      expect( names ).toContain "Dan Stemkoski"
      expect( names ).toContain "Linda Heckridge"


  it "fetches a collection using a skip", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          skip: 2
          where:
            playerAge:
              $gt: 14

    runs ->
      names = scores.pluck("playerName")
      expect( names.length ).toEqual 2
      expect( names ).toContain "James Thomas"
      expect( names ).toContain "Michael Yabuti"


  # Backbone sorts using a comparator, not the network result
  pending "fetches a collection with sorted scores", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          sort: "-playerAge"
          limit: 3

    runs ->
      names = scores.pluck("playerName")
      expect( names.length ).toEqual 3
      expect( names ).toContain "Linda Heckridge"
      expect( names ).toContain "James Thomas"
      expect( names ).toContain "Michael Yabuti"


  it "fetches a collection with scores contained in an array", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            playerName:
              $in: ["Joan Smith", "Dan Stemkoski", "James Thomas"]

    runs ->
      names = scores.pluck("playerName")
      expect( names.length ).toEqual 3
      expect( names ).toContain "Joan Smith"
      expect( names ).toContain "Dan Stemkoski"
      expect( names ).toContain "James Thomas"


  it "fetches a collection filtering for a given field", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            score:
              $exists: true

    runs ->
      names = scores.pluck("playerName")
      expect( names.length ).toEqual 2
      expect( names ).toContain "Dan Stemkoski"
      expect( names ).toContain "James Thomas"


  it "fetches a collection excluding for a given field", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            score:
              $exists: false

    runs ->
      names = scores.pluck("playerName")
      expect( names.length ).toEqual 4
      expect( names ).not.toContain "Dan Stemkoski"
      expect( names ).not.toContain "James Thomas"


  # TODO: testing using (doesNot)matchesKeyIn Query
  pending "fetches a collection using matchedKeyInQuery"


  it "fetches a collection returning only some fields", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          keys: "playerName,score"

    runs ->
      expect( scores.length ).toEqual 6
      scores.each (s) ->
        expect( s.get("playerName") ).toBeDefined()
        expect( s.get("playerAge") ).toBeUndefined()


  it "fetches the rest of an object after a partial query", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            score:
              $exists: true
          keys: "score"

    runs ->
      expect( scores.length ).toEqual 2
      score = scores.at(0)

      expect( score.get("playerName") ).toBeUndefined()
      expect( score.get("playerAge") ).toBeUndefined()
      expect( score.get("score") ).toBeDefined()

      p = new Parse.Promise();
      score.fetch
        success: (score) ->
          expect( score.get("playerName") ).toBeDefined()
          expect( score.get("playerAge") ).toBeDefined()
          expect( score.get("score") ).toBeDefined()
          p.resolve(score)

      waitsForPromise(p)


  it "fetches a collection using array member lookup", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            favoriteNumbers: 24

    runs ->
      expect( scores.length ).toEqual 1
      expect( scores.at(0).get("playerName") ).toEqual "Michael Yabuti"


  it "fetches a collection using full array lookup", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            favoriteNumbers:
              $all: [1, 2]

    runs ->
      expect( scores.length ).toEqual 1
      expect( scores.at(0).get("playerName") ).toEqual "James Thomas"


  it "fetches a collection using string values", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            playerName:
              $regex: "^\\QJ\\E"

    runs ->
      names = scores.pluck("playerName")
      expect( names.length ).toEqual 2
      expect( names ).toContain "Joan Smith"
      expect( names ).toContain "James Thomas"


  pending "fetches a collection with a given relation", ->

  pending "fetches a collection using matchesQuery", ->

  pending "fetches a collection using doesNotMatchQuery", ->

  pending "fetches a collection using a relational query by objectId", ->

  pending "fetches a collection including other scores", ->

  pending "fetches a collection including other scores using multi-level dot notation", ->

  # Not sure this one applies since Backbone wants the results, and
  # we'll get empty results as well as a count...
  pending "counts objects in a collection", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            playerName:
              $regex: "^\\QJ\\E"
          count: true
        success: (res) ->
          dump "count res", res

    runs ->
      expect( count ).toEqual 2


  it "fetches a collection using an ORing compount query", ->
    scores = Alloy.createCollection('game_score')
    waitsWithPromiseCallbacks (cb) ->
      scores.fetch _.extend cb,
        query:
          where:
            $or: [
                   playerAge:
                     $gte: 21
                 ,
                   playerAge: 13
                 ]

    runs ->
      names = scores.pluck("playerName")
      expect( names.length ).toEqual 4
      expect( names ).toContain "Joan Smith"
      expect( names ).toContain "Linda Heckridge"
      expect( names ).toContain "James Thomas"
      expect( names ).toContain "Michael Yabuti"
