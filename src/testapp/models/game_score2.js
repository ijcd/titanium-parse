exports.definition = {
  config : {
    adapter: {
      type: "parse"
    }
    // table schema and adapter information
  },

  extendModel: function(Model) {              
    _.extend(Model.prototype, {
      // Extend, override or implement Backbone.Model 
      _parse_class_name: "TestGameScore2"
    });
    
    return Model;
  },

  extendCollection: function(Collection) {            
    _.extend(Collection.prototype, {
      // Extend, override or implement Backbone.Collection 
      _parse_class_name: "TestGameScore2"
    });
    
    return Collection;
  }
}
