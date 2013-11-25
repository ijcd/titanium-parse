describe "Parse.Collection", ->

  # fixtures
  GameScore = Parse.Object.extend("TestGameScore")

  PlayersCollection = Parse.Collection.extend
    model: GameScore

  ScorersCollection = Parse.Collection.extend
    model: GameScore
    query: (new Parse.Query(GameScore)).exists("score")

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


  it "retrieves a collection", ->
    collection = new PlayersCollection()
    waitsForPromise ->
      collection.fetch
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = results.pluck("playerName")
          expect( names.length ).toEqual 6
          expect( names ).toContain "Joan Smith"
          expect( names ).toContain "Chris Delio"
          expect( names ).toContain "Dan Stemkoski"
          expect( names ).toContain "Linda Heckridge"
          expect( names ).toContain "James Thomas"
          expect( names ).toContain "Michael Yabuti"


  it "retrieves a collection with a query", ->
    collection = new ScorersCollection()
    waitsForPromise ->
      collection.fetch
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = results.pluck("playerName")
          expect( names.length ).toEqual 2
          expect( names ).toContain "Dan Stemkoski"
          expect( names ).toContain "James Thomas"


  # TODO: doesn't seem to be working
  pending "creates a collection from a query", ->
    query = new Parse.Query(GameScore)
    query.greaterThan("playerAge", 20)

    waitsForPromise ->
      query.collection().fetch()
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = results.pluck("playerName")
          expect( names.length ).toEqual 3
          expect( names ).toContain "Linda Heckridge"
          expect( names ).toContain "James Thomas"
          expect( names ).toContain "Michael Yabuti"


  it "sorts a collection", ->
    collection = new PlayersCollection()
    collection.comparator = (p) ->
      p.get "playerName"

    waitsForPromise ->
      collection.fetch
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = results.pluck("playerName")
          expect( names ).toEqual ["Chris Delio", "Dan Stemkoski", "James Thomas", "Joan Smith", "Linda Heckridge", "Michael Yabuti"]


  it "modifies a collection", ->
    collection = new PlayersCollection()
    collection.add [
      playerName: "Bo Phillips"
      playerAge: 33
    ,
      playerName: "Jimmy Sussex"
      playerAge: 29
    ]

    expect( collection.length ).toEqual 2

    # get first player
    player = collection.at(0)
    expect( player.get("playerName") ).toEqual "Bo Phillips"
    expect( player.get("playerAge") ).toEqual 33

    # # get him again by id
    # playerAgain = collection.get( player.id )
    # expect( playerAgain.get("playerName") ).toEqual "Bo Phillips"
    # expect( playerName.get("playerAge") ).toEqual 33

    # remove the first player
    collection.remove( player )
    lastPlayer = collection.at(0)
    expect( collection.length ).toEqual 1
    expect( lastPlayer.get("playerName") ).toEqual "Jimmy Sussex"
    expect( lastPlayer.get("playerAge") ).toEqual 29

    # reset the collection
    collection.reset [
      playerName: "Mary Dithers"
      playerAge: 24
    ,
      playerName: "Lyndon Crew"
      playerAge: 25
    ]

    # get first player
    newPlayer = collection.at(0)
    expect( collection.length ).toEqual 2
    expect( newPlayer.get("playerName") ).toEqual "Mary Dithers"
    expect( newPlayer.get("playerAge") ).toEqual 24
