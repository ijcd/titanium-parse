describe "Parse.Object", ->

  # setup globals and fixtures
  GameScore = Parse.Object.extend("TestGameScore")
  Post = Parse.Object.extend("TestPost")
  Comment = Parse.Object.extend("TestComment")
  BigObject = Parse.Object.extend("TestBigObject")

  # fixtures
  myGameScore = null
  myPost = null
  myComment = null

  # setup fixtures
  beforeAll ->
    dropAllWhileWaiting(GameScore)
    dropAllWhileWaiting(Post)
    dropAllWhileWaiting(Comment)
    dropAllWhileWaiting(BigObject)

    runs ->
      gameScore = new GameScore()
      waitsForPromise ->
        gameScore.save
          score: 133799
          playerName: "Sean Plott Plapp"
          cheatMode: true
          foods: []
        ,
          success: (gs) ->
            myGameScore = gs

      # Create the post
      myPost = new Post()
      myPost.set "title", "I'm Hungry"
      myPost.set "content", "Where should we go for lunch?"

      # Create the comment
      myComment = new Comment()
      myComment.set "content", "Let's do Sushirrito."


  it "saves an object", ->
    gameScore = new GameScore()
    gameScore.set "score", 1337
    gameScore.set "playerName", "Sean Plott"
    gameScore.set "cheatMode", false
    expect(gameScore.id).toBeUndefined()

    waitsForPromise ->
      gameScore.save null

    runs ->
      expect(gameScore.id).not.toBeUndefined()
      expect(gameScore.dirty()).toEqual(false)
      expect(gameScore.existed()).toEqual(false)


  it "saves and object using a hash", ->
    gameScore = new GameScore()
    expect( gameScore.id ).toBeUndefined()

    waitsForPromise ->
      gameScore.save
        score: 1337
        playerName: "Sean Plott"
        cheatMode: false

    runs ->
      expect( gameScore.id ).not.toBeUndefined()
      expect( gameScore.dirty() ).toEqual(false)
      expect( gameScore.existed() ).toEqual(false)


  it "retrieves an object", ->
    query = new Parse.Query(GameScore)

    gameScore = null
    waitsForPromise ->
      query.get myGameScore.id,
        success: (gs) ->
          gameScore = gs

    runs ->
      expect( gameScore.id ).toEqual myGameScore.id
      expect( gameScore.get("score") ).toEqual 133799
      expect( gameScore.get("playerName") ).toEqual "Sean Plott Plapp"
      expect( gameScore.get("cheatMode") ).toEqual true


  it "refreshes an object", ->
    waitsForPromise ->
      myGameScore.fetch
        success: (gs) ->
          expect( gs.id ).toEqual myGameScore.id
        error: (error) -> @fail(Error('spec should not reach here: ' + error))



  it "updates an object", ->
    expect( myGameScore.get("skills") ).toBeUndefined()

    waitsForPromise ->
      myGameScore.set "skills", ["archery", "karate"]
      expect( myGameScore.get("skills") ).toEqual ["archery", "karate"]
      expect( myGameScore.dirty() ).toEqual true
      myGameScore.save()

    runs ->
      expect( myGameScore.dirty() ).toEqual false
      expect( myGameScore.get("skills") ).toEqual ["archery", "karate"]


  it "increments a counter", ->
    expect( myGameScore.get("score") ).toEqual 133799
    myGameScore.increment("score")
    expect( myGameScore.get("score") ).toEqual 133800


  it "adds to an array", ->
    expect( myGameScore.get("foods") ).toEqual([])
    myGameScore.add("foods", "apples")
    myGameScore.add("foods", "oranges")
    myGameScore.add("foods", "oranges")
    waitsForPromise ->
      myGameScore.save()
    runs ->
      expect( myGameScore.get("foods") ).toEqual ["apples", "oranges", "oranges"]


  it "adds to an array uniquely", ->
    expect( myGameScore.get("foods") ).toEqual ["apples", "oranges", "oranges"]
    myGameScore.addUnique("foods", "bananas")
    myGameScore.addUnique("foods", "bananas")
    waitsForPromise ->
      myGameScore.save()
    runs ->
      expect( myGameScore.get("foods") ).toEqual ["apples", "oranges", "oranges", "bananas"]


  it "removes from an array", ->
    expect( myGameScore.get("foods") ).toEqual ["apples", "oranges", "oranges", "bananas"]
    myGameScore.remove("foods", "oranges")
    expect( myGameScore.get("foods") ).toEqual ["apples", "bananas"]


  it "unsets a field", ->
    myGameScore.unset("foods")
    waitsForPromise ->
      myGameScore.save()
    runs ->
      expect( myGameScore.get("foods") ).toBeUndefined()


  it "destroys an object", ->
    query = new Parse.Query(GameScore)

    fix = null
    waitsForPromise ->
      query.get myGameScore.id,
        success: (gs) ->
          fix = gs

    runs ->
      waitsForPromise ->
        expect( fix.id ).toEqual( myGameScore.id )
        fix.destroy()

    fix2 = null
    runs ->
      waitsForPromise ->
        query.get myGameScore.id,
          success: (gs) ->
            fix2 = gs

    runs ->
      expect( fix2 ).toEqual( null )


  it "handles one-to-one relationships", ->

    # Add the post as a value in the comment
    myComment.set "parent", myPost

    # This will save both myPost and myComment
    waitsForPromise ->
      myComment.save
        error: (error) -> @fail(Error('spec should not reach here: ' + error))

    runs ->
      expect( myComment.get("parent") ).toBe myPost
      expect( myPost.id ).not.toBeUndefined()


  it "handles one-to-one relationships by linking ids", ->
    post = new Post();
    post.id = myPost.id
    myComment.set("parent2", post)
    waitsForPromise ->
      myComment.save
        error: (error) -> @fail(Error('spec should not reach here: ' + error))

    runs ->
      expect( myComment.get("parent2") ).toEqual post


  # TODO: doesn't seem to be working
  pending "handles many-to-many relationships", ->

    user = new GameScore();
    post1 = new Post();
    post2 = new Post();
    post3 = new Post();

    #waitsForPromise -> user.save()
    waitsForPromise -> post1.save()
    waitsForPromise -> post2.save()
    waitsForPromise -> post3.save()

    likes = user.relation("likes")
    runs -> likes.add( post1 )

    waitsForPromise ->
      user.save()

    user_likes = null
    runs ->
      user.relation("likes").query().find
        success: (list) ->
          user_likes = list
        error: (error) -> @fail(Error('spec should not reach here: ' + error))

    runs ->
      expect( user_likes ).toEqual [post1, post2, post3]


  it "saves all kinds of datatypes", ->
    number = 42
    string = "the number is " + number
    date = new Date()
    array = [string, number]
    object =
      number: number
      string: string

    bigObject = new BigObject()
    bigObject.set "myNumber", number
    bigObject.set "myString", string
    bigObject.set "myDate", date
    bigObject.set "myArray", array
    bigObject.set "myObject", object
    bigObject.set "myNull", null

    waitsForPromise -> bigObject.save()

    runs ->
      expect( bigObject.get("myNumber") ).toEqual number
      expect( bigObject.get("myString") ).toEqual string
      expect( bigObject.get("myDate") ).toEqual date
      expect( bigObject.get("myArray") ).toEqual array
      expect( bigObject.get("myObject") ).toEqual object
      expect( bigObject.get("myNull") ).toEqual null

