datomic_wrapper = require '../../datomic-wrapper'

World = (callback)->
	@app = new datomic_wrapper.DatomicWrapper('localhost', 8888, 'test_alias', 'test')
	@app.create_database 'test', ()=>
		callback(@) # tell Cucumber we're finished and to use 'this' as the world instance

exports.World = World