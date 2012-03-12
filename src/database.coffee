mongo = require('mongodb')
{Db} = mongo
{Connection} = mongo
{Server} = mongo

_cache = {}

database = module.exports

database.connect = (params = {}, callback) ->
  host = params.host or= '127.0.0.1'
  port = params.port or= 27017
  name = params.name or= 'princedb_' + process.env['NODE_ENV']

  cacheString = host + ':' + port + ':' + name
  if _cache[cacheString]?
    callback?(null, _cache[cacheString])
  else
    db = new Db(name, new Server(host, port, {}), {native_parser:false, strict:false})
    _cache[cacheString] = db
    db.open (err, db) ->
      callback?(err,db)