util = require '../support/util'

matchStruct = (expected, result, callback)->
	try
		util.matchStruct expected, result
		callback()
	catch e
		callback.fail e

module.exports = ->
	@World = require("../support/world").World # overwrite default World constructor

	@Given /^There are the following entity\-attributes in the database:$/, (table, callback) ->
		data = ''
		for row in table.hashes()
			data += row['edn attribute definition']
		@app.transact '['+data+']', (err, result)->
			if err then callback.fail(err) else callback()

	@When /^I call "([^"]*)"$/, (function_name, callback) ->
		@app[function_name] (err, result)=>
			@result = result
			if err then callback.fail(err) else callback()

	@Then /^I get back the following JSON structure:/, (table, callback) ->
		# console.log "table:", table.hashes()
		expected = JSON.parse table.hashes()[0]['JSON structure']
		# console.log 'expected:', expected
		# console.log 'result:', @result
		matchStruct expected, @result, callback

	@When /^I call "([^"]*)" with the following parameter:$/, (function_name, table, callback)->
		# console.log "table:", table.hashes()
		@new_entity_schema = JSON.parse table.hashes()[0]['JSON structure']
		@app[function_name] @new_entity_schema, (err, result)->
			if err then callback.fail(err) else callback()

	@Then /^I can see the new schema in "([^"]*)"$/, (function_name, callback)->
		@app[function_name] (err, result)=>
			matchStruct [@new_entity_schema], result, callback

	@When /^I call "([^"]*)" with "([^"]*)"$/, (function_name, entity_name, callback)->
		@app[function_name] entity_name, (err, result)=>
			@result = result
			if err then callback.fail(err) else callback()

	@Given /^There are the following facts in the database:$/, (table, callback)->
		data = ''
		for row in table.hashes()
			data += row['edn facts']
		# console.log data
		@app.transact '['+data+']', (err, result)->
			if err then callback.fail(err) else callback()

	@When /^I call "rest_get" with "user" and the first object's id$/, (callback)->
		@app.rest_get "user", @result[0].id, (err, result)=>
			@result_entity = result
			if err then callback.fail(err) else callback()

	@Then /^I get back the first object$/, (callback)->
		matchStruct @result[0], @result_entity, callback

	@When /^I create a new user entity with the following parameter:$/, (table, callback)->
		@new_entity = JSON.parse table.hashes()[0]['JSON structure']
		@app.create_entity 'user', @new_entity, (err, result)=>
			@result = result
			@new_entity_id = @result.id
			if err then callback.fail(err) else callback()

	@Then /^the result is the entity with a newly assigned ID$/, (callback)->
		new_entity = util.extend {}, @new_entity
		new_entity.id = '/[0-9]+/'
		matchStruct new_entity, @result, callback

	@Then /^I can see the new entity in "rest_index" with the same ID$/, (callback)->
		@app.rest_index "user", (err, result)=>
			matchStruct [@result], result, callback

	@When /^I modify this user entity with the following:$/, (table, callback)->
		@modified_entity = JSON.parse table.hashes()[0]['JSON structure']
		@app.update_entity 'user', @new_entity_id, @modified_entity, (err, result)=>
			@result = result
			if err then callback.fail(err) else callback()

	@Then /^I get back the updated attributes with "rest_get"$/, (callback)->
		@app.rest_get 'user', @new_entity_id, (err, result)=>
			matchStruct @modified_entity, result, callback

	@Then /^I get back the updated attributes with "rest_get", with the original ID$/, (callback)->
		modified_entity = util.extend {}, @modified_entity
		modified_entity.id = @new_entity_id
		@app.rest_get 'user', @new_entity_id, (err, result)=>
			matchStruct modified_entity, result, callback
