express = require('express')
mongodb = require('mongodb')
database = require('./database')

class PrinceDB
  constructor: (@port) ->
    @app = express.createServer()
    @app.configure =>
      @app.use(express.bodyParser())
      @app.use(express.methodOverride())
      @app.use(@app.router)
    @app.configure 'development', => @app.use(express.errorHandler(dumpExceptions: true, showStack: true))
    @app.configure 'testing', => @app.use(express.errorHandler(dumpExceptions: true, showStack: true))

    @app.get '/db/:database/col/:collection/doc/:key/current', (req, res) =>
      dbName = req.params.database
      colName = req.params.collection
      key = req.params.key
      database.connect name: dbName, (err,db) =>
        db.collection colName, (err, col) =>
          if err?
            res.send(error: {code: 1, message: err.message})
            return

          col.find(key: key).toArray (err, docs) =>
            if err?
              res.send(error: {code: 1, message: err.message})
              return
            else
              if docs.length > 0
                res.send(document: docs[0].current, created_at: docs[0].created_at)
              else
                res.send(document: {})


    @app.put '/db/:database/col/:collection', (req, res) =>
      dbName = req.params.database
      colName = req.params.collection
      key = req.body.key
      doc = req.body.document
      #console.log dbName + ':' + colName + ':' + key
      created_at = Date.now()
      newDoc = {key: key, created_at: created_at, current: doc, revisions: {created_at: doc}}
      res.contentType('application/json')

      database.connect name: dbName, (err, db) =>
        db.collection colName, (err, col) => 
          if err?
            res.send(error: {code: 1, message: err.message})
            return

          col.insert newDoc, {safe: true}, (err, docs) =>
            if err? 
              res.send(error: {code: 1, message: err.message})
            else
              res.send(message: 'Updated.')
 

  listen: (callback) ->
    @app.listen(@port, callback)

  close: ->
    @app.close()

  @create: (port) ->
    new PrinceDB(port)

module.exports.PrinceDB = PrinceDB


