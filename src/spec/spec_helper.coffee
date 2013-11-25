
# quick beforeAll (place at front of suite)
beforeAll = (fn) ->
  it('[beforeAll]', fn)

# quick afterAll (place at end of suite)
afterAll = (fn) ->
  it('[afterAll]', fn)

# mark a test as pending
pending = (message, fn) ->
  it "[PENDING]: " + message, ->
    #@fail(Error('PENDING'))

# takes a Parse.Promise or a function that returns a promise
waitsForPromise = (p) ->
  unless Parse.Promise.is(p)
    p = p()
  waitsFor ->
    p._resolved || p._rejected

# destroys object, resolving a given promise
destroyWithPromise = (p, obj) ->
  obj.destroy
    success: ->
      p.resolve("destroyed: " + obj)
    error: (error) ->
      p.reject("destroy error: " + error)

# drop and wait for all of a Parse.Object class
dropAllWhileWaiting = (klass) ->
  klasses = _.flatten klasses
  promises = null
  query = new Parse.Query(klass)

  waitsForPromise ->
    query.find
      success: (gss) ->
        promises = _.map gss, -> (new Parse.Promise())
        destroyWithPromise(p, gs) for [p, gs] in _.zip(promises, gss)

  # should start after we wait on the query.find() promise
  runs ->
    waitsForPromise(p) for p in promises
