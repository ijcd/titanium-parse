var TiParse = function(options) {

  // Stub out Facebook
  FB = {
    init: function() {
      Ti.API.info("called FB.init()");
    },
    login: function() {
      Ti.API.info("called FB.login()");
    },
    logout: function() {
      Ti.API.info("called FB.logout()");
    }
  };

  // Parse will pick this up and use it
  XMLHttpRequest = function() {
    return Ti.Network.createHTTPClient();
  }

  Ti.include("parse-1.2.11.js");

  Parse.localStorage = {
    getItem : function(key) {
      return Ti.App.Properties.getObject(Parse.localStorage.fixKey(key));
    },

    setItem : function(key, value) {
      return Ti.App.Properties.setObject(Parse.localStorage.fixKey(key), value);
    },

    removeItem : function(key, value) {
      return Ti.App.Properties.removeProperty(Parse.localStorage.fixKey(key));
    },

    // Titanium Android doesn't like slashes, which Parse uses
    fixKey : function(key) {
      return key.split("/").join("");
    }
  };  

  Parse.initialize(options.applicationId, options.javaScriptKey);
  Parse.FacebookUtils.init();

  return Parse;
}
 
module.exports = TiParse;
