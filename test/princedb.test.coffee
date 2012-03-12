{PrinceDB} = require('../lib/princedb')
request = require('superagent')
testutil = require('testutil')
database = require('../lib/database')
S = require('string')

PORT = 30090

describe 'princedb', ->
  prince = null
  url = null
  dbName = 'princedb'
  colName = 'somecol'
  _db = null

  beforeEach (done) ->
    prince = PrinceDB.create(PORT)
    url = "http://localhost:#{PORT}/db/#{dbName}%5Ftest/col/#{colName}"
    database.connect name:"#{dbName}_test", (err,db) ->
      _db = db
      db.dropCollection colName, (err) ->
        prince.listen ->
          done()

  afterEach (done) ->
    prince.close()
    done()

  describe 'PUT /db/:database/col/:collection', ->
    it 'should store the object and return the document id', (done) ->
      #console.log url
      doc =
        firstName: 'JP'
        lastName: 'Richardson'
      data =
        document: doc
        key: '1'
      request.put(url).type('json').send(data).end (res) ->
        respData = res.body
        F respData.error?
        T S(respData.message).startsWith('Updated')
        docUrl = url += "/doc/#{data.key}/current"
        request.get(docUrl).end (res) -> 
          #console.log res.text
          respData = res.body
          doc = respData.document
          created_at = respData.created_at
          T doc.firstName is 'JP'
          T doc.lastName is 'Richardson'
          T parseInt(created_at, 10) > 0
          done()

  describe 'GET /db/:database/col/:collection/doc/:key/current', ->
    it 'should retrieve the document with the specified key', ->
      doc =
        firstName: 'JP'
        lastName: 'Richardson'
      data =
        current: doc
        key: '1'
      _db.collection colName, (err, col) ->
        col.insert data, {safe: true}, (err, doc) ->
          T err is null
          docUrl = url += "/doc/#{data.key}/current"
          request.get(docUrl).end (res) -> 
            respData = res.body
            doc = respData.document
            T doc.firstName is 'JP'
            T doc.lastName is 'Richardson'
            done()
      



