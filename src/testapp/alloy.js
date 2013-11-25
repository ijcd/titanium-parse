// The contents of this file will be executed before any of
// your view controllers are ever executed, including the index.
// You have access to all functionality on the `Alloy` namespace.
//
// This is a great place to do any initialization for your app
// or create any global variables/functions that you'd like to
// make available throughout your app. You can easily make things
// accessible globally by attaching them to the `Alloy.Globals`
// object. For example:
//
// Alloy.Globals.someGlobalFunction = function(){};

var Parse, dump,
  __slice = [].slice;

Alloy.Globals.dump = dump = function() {
  var args;
  args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
  return Ti.API.debug(JSON.stringify(args, void 0, 2));
};

Parse = require("ti-parse")({
  applicationId: Alloy.CFG.parse_appid,
  javaScriptKey: Alloy.CFG.parse_jskey
});
