var PrinceDB = require('./lib/princedb').PrinceDB;

var PORT = 38455;
var prince = PrinceDB.create(PORT);

prince.listen(function(){
  console.log("PrinceDB is listening on %d...", PORT);
});