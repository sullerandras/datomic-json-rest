util = require('../support/util')

module.exports = ->
	@World = require("../support/world").World # overwrite default World constructor

	@Given /^There are the following entity\-attributes in the database:$/, (table, callback) ->
		data = ''
		for row in table.hashes()
			data += row['edn attribute definition']
		@app.transact '['+data+']', ->
			callback()

	@When /^I call "([^"]*)"$/, (function_name, callback) ->
		@app[function_name] (result)=>
			@result = result
			callback()

	@Then /^I get back the following JSON structure:/, (table, callback) ->
		# console.log "table:", table.hashes()
		expected = JSON.parse table.hashes()[0]['JSON structure']
		# console.log 'expected:', expected
		# console.log 'result:', @result
		m = util.matchStruct(expected, @result, true)
		if m != true
			callback.fail(m)
		else
			callback()
