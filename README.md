# titanium-parse

This project wraps the Parse javascript and REST APIs for use in Appcelerator Titanium and Alloy projects.

## Installing

1) Copy ti-parse.js and the parse library to your lib directory.

2) Copy the sync adapter in src/lib/alloy/sync/parse.js to app/lib/alloy/sync/parse.js

3) Setup your Parse credentials in config.json

```json
    {
        "global": {
            "parse_appid": "your-appid-here",
            "parse_jskey": "your-jskey-here",
            "parse_restkey": "your-restkey-here"
        }, 
        "env:development": {}, 
        "env:test": {}, 
        "env:production": {}, 
        "os:android": {},
        "os:blackberry": {},
        "os:ios": {},
        "os:mobileweb": {},
        "dependencies": {}
    }
```

4) Require ti-parse in your app (maybe alloy.js)
```
    Parse = require("ti-parse")(
        applicationId: Alloy.CFG.parse_appid
        javaScriptKey: Alloy.CFG.parse_jskey
    )
```

## Using Parse directly



## Using Parse through Alloy models and collections



## Contributing

This project makes use of rvm, guard, rake, coffeescript, and tishadow for building and testing.

Make the testapp:

```
    rake wipe testapp appify
```

The project is partially spec'd. Please add more tests in src/spec

````
    bundle install
    bundle exec guard  # will build the files (TODO: move this to Rake) - watches for edits in testing as well
    rake testapp       # will build a test app
    rake appify        # will create a stand-alone tishadow server for use in testing
    rake clean         # start over
    tishadow spec      # run the tests
```
