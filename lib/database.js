(function() {
  var Connection, Db, Server, database, mongo, _cache;

  mongo = require('mongodb');

  Db = mongo.Db;

  Connection = mongo.Connection;

  Server = mongo.Server;

  _cache = {};

  database = module.exports;

  database.connect = function(params, callback) {
    var cacheString, db, host, name, port;
    if (params == null) params = {};
    host = params.host || (params.host = '127.0.0.1');
    port = params.port || (params.port = 27017);
    name = params.name || (params.name = 'princedb_' + process.env['NODE_ENV']);
    cacheString = host + ':' + port + ':' + name;
    if (_cache[cacheString] != null) {
      return typeof callback === "function" ? callback(null, _cache[cacheString]) : void 0;
    } else {
      db = new Db(name, new Server(host, port, {}), {
        native_parser: false,
        strict: false
      });
      _cache[cacheString] = db;
      return db.open(function(err, db) {
        return typeof callback === "function" ? callback(err, db) : void 0;
      });
    }
  };

}).call(this);
