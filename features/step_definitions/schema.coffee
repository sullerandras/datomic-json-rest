util = require '../support/util'

module.exports = ->
	@World = require("../support/world").World # overwrite default World constructor

	@Given /^There are the following entity\-attributes in the database:$/, (table, callback) ->
		data = ''
		for row in table.hashes()
			data += row['edn attribute definition']
		@app.transact '['+data+']', ->
			callback()

	@When /^I call "([^"]*)"$/, (function_name, callback) ->
		@app[function_name] (err, result)=>
			@result = result
			callback()

	@Then /^I get back the following JSON structure:/, (table, callback) ->
		# console.log "table:", table.hashes()
		expected = JSON.parse table.hashes()[0]['JSON structure']
		# console.log 'expected:', expected
		# console.log 'result:', @result
		util.matchStruct expected, @result
		callback()

	@When /^I call "([^"]*)" with the following parameter:$/, (function_name, table, callback)->
		# console.log "table:", table.hashes()
		@new_entity_schema = JSON.parse table.hashes()[0]['JSON structure']
		@app[function_name] @new_entity_schema, ->
			callback()

	@Then /^I can see the new schema in "([^"]*)"$/, (function_name, callback)->
		@app[function_name] (err, result)=>
			util.matchStruct [@new_entity_schema], result
			callback()

	@When /^I call "([^"]*)" with "([^"]*)"$/, (function_name, entity_name, callback)->
		@app[function_name] entity_name, (err, result)=>
			@result = result
			callback()

	@Given /^There are the following facts in the database:$/, (table, callback)->
		data = ''
		for row in table.hashes()
			data += row['edn facts']
		# console.log data
		@app.transact '['+data+']', ->
			callback()
