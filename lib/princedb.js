(function() {
  var PrinceDB, database, express, mongodb;

  express = require('express');

  mongodb = require('mongodb');

  database = require('./database');

  PrinceDB = (function() {

    function PrinceDB(port) {
      var _this = this;
      this.port = port;
      this.app = express.createServer();
      this.app.configure(function() {
        _this.app.use(express.bodyParser());
        _this.app.use(express.methodOverride());
        return _this.app.use(_this.app.router);
      });
      this.app.configure('development', function() {
        return _this.app.use(express.errorHandler({
          dumpExceptions: true,
          showStack: true
        }));
      });
      this.app.configure('testing', function() {
        return _this.app.use(express.errorHandler({
          dumpExceptions: true,
          showStack: true
        }));
      });
      this.app.get('/db/:database/col/:collection/doc/:key/current', function(req, res) {
        var colName, dbName, key;
        dbName = req.params.database;
        colName = req.params.collection;
        key = req.params.key;
        return database.connect({
          name: dbName
        }, function(err, db) {
          return db.collection(colName, function(err, col) {
            if (err != null) {
              res.send({
                error: {
                  code: 1,
                  message: err.message
                }
              });
              return;
            }
            return col.find({
              key: key
            }).toArray(function(err, docs) {
              if (err != null) {
                res.send({
                  error: {
                    code: 1,
                    message: err.message
                  }
                });
              } else {
                if (docs.length > 0) {
                  return res.send({
                    document: docs[0].current,
                    created_at: docs[0].created_at
                  });
                } else {
                  return res.send({
                    document: {}
                  });
                }
              }
            });
          });
        });
      });
      this.app.put('/db/:database/col/:collection', function(req, res) {
        var colName, created_at, dbName, doc, key, newDoc;
        dbName = req.params.database;
        colName = req.params.collection;
        key = req.body.key;
        doc = req.body.document;
        created_at = Date.now();
        newDoc = {
          key: key,
          created_at: created_at,
          current: doc,
          revisions: {
            created_at: doc
          }
        };
        res.contentType('application/json');
        return database.connect({
          name: dbName
        }, function(err, db) {
          return db.collection(colName, function(err, col) {
            if (err != null) {
              res.send({
                error: {
                  code: 1,
                  message: err.message
                }
              });
              return;
            }
            return col.insert(newDoc, {
              safe: true
            }, function(err, docs) {
              if (err != null) {
                return res.send({
                  error: {
                    code: 1,
                    message: err.message
                  }
                });
              } else {
                return res.send({
                  message: 'Updated.'
                });
              }
            });
          });
        });
      });
    }

    PrinceDB.prototype.listen = function(callback) {
      return this.app.listen(this.port, callback);
    };

    PrinceDB.prototype.close = function() {
      return this.app.close();
    };

    PrinceDB.create = function(port) {
      return new PrinceDB(port);
    };

    return PrinceDB;

  })();

  module.exports.PrinceDB = PrinceDB;

}).call(this);
