describe "Parse.Query", ->

  # fixtures
  GameScore = Parse.Object.extend("TestGameScore")

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


  it "performs a basic query", ->
    query = new Parse.Query(GameScore)
    query.equalTo "playerName", "Dan Stemkoski"

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          expect( results.length ).toEqual 1
          expect( results[0].get("playerName") ).toEqual "Dan Stemkoski"


  it "uses query constraints", ->
    query = new Parse.Query(GameScore)
    query.notEqualTo "playerName", "Michael Yabuti"
    query.greaterThan "playerAge", 18

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = _.map results, (p) -> p.get("playerName")
          expect( names.length ).toEqual 2
          expect( names ).toContain "Linda Heckridge"
          expect( names ).toContain "James Thomas"


  it "uses a limit", ->
    query = new Parse.Query(GameScore)
    query.greaterThan "playerAge", 14
    query.limit(2)

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = _.map results, (p) -> p.get("playerName")
          expect( names.length ).toEqual 2
          expect( names ).toContain "Dan Stemkoski"
          expect( names ).toContain "Linda Heckridge"


  it "uses a skip", ->
    query = new Parse.Query(GameScore)
    query.greaterThan "playerAge", 14
    query.skip(2)

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = _.map results, (p) -> p.get("playerName")
          expect( names.length ).toEqual 2
          expect( names ).toContain "James Thomas"
          expect( names ).toContain "Michael Yabuti"


  it "sorts the results", ->
    query = new Parse.Query(GameScore)
    query.descending("playerAge")
    query.limit(3)

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = _.map results, (p) -> p.get("playerName")
          expect( names.length ).toEqual 3
          expect( names ).toContain "Linda Heckridge"
          expect( names ).toContain "James Thomas"
          expect( names ).toContain "Michael Yabuti"


  it "finds results contained in an array", ->
    query = new Parse.Query(GameScore)
    query.containedIn "playerName", ["Joan Smith", "Dan Stemkoski", "James Thomas"]

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = _.map results, (p) -> p.get("playerName")
          expect( names.length ).toEqual 3
          expect( names ).toContain "Joan Smith"
          expect( names ).toContain "Dan Stemkoski"
          expect( names ).toContain "James Thomas"


  it "finds results with a given field", ->
    query = new Parse.Query(GameScore)
    query.exists("score")

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = _.map results, (p) -> p.get("playerName")
          expect( names.length ).toEqual 2
          expect( names ).toContain "Dan Stemkoski"
          expect( names ).toContain "James Thomas"


  it "finds results without a given field", ->
    query = new Parse.Query(GameScore)
    query.doesNotExist("score")

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = _.map results, (p) -> p.get("playerName")
          expect( names.length ).toEqual 4
          expect( names ).not.toContain "Dan Stemkoski"
          expect( names ).not.toContain "James Thomas"


  # TODO: testing using (doesNot)matchesKeyIn Query
  pending "finds results using matchedKeyInQuery"


  it "finds records using select for fields", ->
    query = new Parse.Query(GameScore)
    query.select("playerName", "score")

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          expect( results.length ).toEqual 6
          _.each results, (r) ->
            expect( r.get("playerName") ).toBeDefined()
            expect( r.get("playerAge") ).toBeUndefined()


  it "fetches the rest of an object after a parital query", ->
    query = new Parse.Query(GameScore)
    query.exists("score")
    query.select("score")

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          expect( results.length ).toEqual 2
          player = results[0]

          expect( player.get("playerName") ).toBeUndefined()
          expect( player.get("playerAge") ).toBeUndefined()
          expect( player.get("score") ).toBeDefined()

          waitsForPromise ->
            player.fetch
              success: (player) ->
                expect( player.get("playerName") ).toBeDefined()
                expect( player.get("playerAge") ).toBeDefined()
                expect( player.get("score") ).toBeDefined()


  it "finds records using array member lookup", ->
    query = new Parse.Query(GameScore)
    query.equalTo("favoriteNumbers", 24)

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          expect( results.length ).toEqual 1
          expect( results[0].get("playerName") ).toEqual "Michael Yabuti"


  it "finds records using full array lookup", ->
    query = new Parse.Query(GameScore)
    query.containsAll("favoriteNumbers", [1, 2])

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          expect( results.length ).toEqual 1
          expect( results[0].get("playerName") ).toEqual "James Thomas"


  it "finds records using string values", ->
    query = new Parse.Query(GameScore)
    query.startsWith("playerName", "J")

    waitsForPromise ->
      query.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = _.map results, (p) -> p.get("playerName")
          expect( names.length ).toEqual 2
          expect( names ).toContain "Joan Smith"
          expect( names ).toContain "James Thomas"


  pending "finds results with a given relation", ->
    query = new Parse.Query(Comment)
    query.equalTo "post", myPost

    waitsForPromise ->
      query.find
        success: (comments) ->
          expect( comments ).toContain "foo"


  pending "finds results using matchesQuery", ->
    innerQuery = new Parse.Query(Post)
    innerQuery.exists "image"
    query = new Parse.Query(Comment)
    query.matchesQuery "post", innerQuery

    waitsForPromise ->
      query.find
        success: (comments) ->
          expect( comments ).toContain "foo"


  pending "finds results using doesNotMatchQuery", ->
    innerQuery = new Parse.Query(Post)
    innerQuery.exists "image"
    query = new Parse.Query(Comment)
    query.doesNotMatchQuery "post", innerQuery

    waitsForPromise ->
      query.find
        success: (comments) ->
          expect( comments ).toContain "foo"


  pending "finds results using a relational query by objectId", ->
    post = new Post();
    post.id = "asdfasdf"
    query.equalTo("post", post)

    waitsForPromise ->
      query.find
        success: (comments) ->
          expect( comments ).toContain "foo"


  pending "finds results including other results", ->
    query = new Parse.Query(Comment)
    query.descending "createdAt"   # Retrieve the most recent ones
    query.limit 10                 # Only retrieve the last ten

    # Include the post data with each comment
    query.include "post"
    query.find success: (comments) ->

      # Comments now contains the last ten comments, and the "post" field
      # has been populated. For example:
      i = 0
      while i < comments.length
        # This does not require a network access.
        post = comments[i].get("post")
        i++


  pending "finds results including other results using multi-level dot notation", ->
    query.include(["posts.author"])


  it "counts objects in a query", ->
    query = new Parse.Query(GameScore)
    query.startsWith("playerName", "J")
    waitsForPromise ->
      query.count
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (count) ->
          expect( count ).toEqual 2


  it "finds results using an ORing compount query", ->
    canDrink = new Parse.Query(GameScore)
    canDrink.greaterThanOrEqualTo("playerAge", 21)

    is13 = new Parse.Query(GameScore)
    is13.equalTo("playerAge", 13)

    mainQuery = Parse.Query.or(canDrink, is13)
    waitsForPromise ->
      mainQuery.find
        error: (error) ->
          @fail(Error('spec should not reach here: ' + error))
        success: (results) ->
          names = _.map results, (p) -> p.get("playerName")
          expect( names.length ).toEqual 4
          expect( names ).toContain "Joan Smith"
          expect( names ).toContain "Linda Heckridge"
          expect( names ).toContain "James Thomas"
          expect( names ).toContain "Michael Yabuti"
