request = require 'request'
edn = require 'edn'
async = require 'async'
util = require './features/support/util'

class Attribute
	constructor: (@id, @name, @type, @cardinality)->

class Entity
	constructor: (@name)->
		@attributes = []

	addAttribute: (name)->
		@attributes.push name

class DatomicWrapper
	constructor: (@datomic_host, @datomic_port, @alias, @db_name)->

	log: ->
		# console.log.apply console, arguments

	base_url: ->
		'http://'+@datomic_host+':'+@datomic_port

	db_alias: ->
		@alias+'/'+@db_name

	create_database: (db_name, done)->
		req =
			url: @base_url()+'/data/'+@alias+'/'
			method: 'POST'
			headers:
				Accept: 'application/edn'
			form:
				'db-name': db_name
		@log 'Creating database: '+db_name
		request req, (error, response, body)=>
			@log 'Server response:', error, response.statusCode, body
			done null, edn.parse body

	transact: (data_edn, done)->
		req =
			url: @base_url()+'/data/'+@db_alias()+'/'
			method: 'POST'
			headers:
				Accept: 'application/edn'
			form:
				'tx-data': data_edn
		@log 'Transacting data: '+data_edn
		request req, (error, response, body)=>
			@log 'Server response:', error, response.statusCode, body
			done null, edn.parse body

	query: (query_edn, done)->
		req =
			url: @base_url()+'/api/query?q='+escape(query_edn)+'&args='+escape('[{:db/alias "'+@db_alias()+'"}]')
			method: 'GET'
			headers:
				Accept: 'application/edn'
		@log 'Querying the database:', 'req'
		request req, (error, response, body)=>
			@log 'Server response:', error, response.statusCode, body
			done error, response, body

	query_entity: (entity_id, done)->
		req =
			url: @base_url()+'/data/'+@db_alias()+'/-/entity?e='+entity_id
			method: 'GET'
			headers:
				Accept: 'application/edn'
		@log 'Querying entity:', req
		request req, (error, response, body)=>
			if error
				return done error, null
			try
				@log 'Server response:', error, response.statusCode, body
				data = edn.parse body
				entity = {}
				for key in data.keys
					entity[key.name] = util.edn_to_json data.get key
				# console.log entity
				done null, entity
			catch e
				done e, null

	query_schema: (query_edn, done)->
		@query query_edn, (error, response, body)->
			parsed = edn.parse(body)
			entities = []
			parsed.forEach (rec)->
				id = rec[0]
				entity_name = rec[1].namespace
				attr_name = rec[1].name
				attr_type = rec[3].name
				cardinality = rec[5].name
				e = null
				for ent in entities
					if ent.name == entity_name
						e = ent
						break
				if e == null
					e = new Entity entity_name
					entities.push e
				e.addAttribute new Attribute id, attr_name, attr_type, cardinality
			done null, entities

	schemas_all: (done)->
		@query_schema '
			[:find ?e ?ident ?vt ?vt_ident ?card ?card_ident
			:in $
			:where
				[?e :db/ident ?ident]
				[?e :db/valueType ?vt]
				[?vt :db/ident ?vt_ident]
				[?e :db/cardinality ?card]
				[?card :db/ident ?card_ident]
			]', done

	create_schema: (entity_schema, done)->
		# console.log entity_schema
		entity_name = entity_schema.name
		data = []
		for attr in entity_schema.attributes
			data.push edn.map [
				edn.keyword 'db/id'
				edn.generic 'db/id', [edn.keyword 'db.part/db']
				edn.keyword 'db/ident'
				edn.keyword entity_name + '/' + attr.name
				edn.keyword 'db/valueType'
				edn.keyword 'db.type/' + attr.type
				edn.keyword 'db/cardinality'
				edn.keyword 'db.cardinality/' + attr.cardinality
				edn.keyword 'db.install/_attribute'
				edn.keyword 'db.part/db'
			]

		@transact edn.stringify(data), (result)->
			done()

	get_schema: (entity_name, done)->
		@schemas_all (err, entities)->
			for ent in entities
				if ent.name == entity_name
					return done(null, ent)
			done new Error 'Entity with name "'+entity_name+'" not found'

	rest_index: (entity_name, done)->
		@get_schema entity_name, (err, entity_schema)=>
			query_ids_for_attribute = (attr, done)=>
				@query '[:find ?c :where [?c :'+entity_name+'/'+attr.name+']]', (error, response, body)->
					done error, edn.parse(body).map (row)->
						row[0]
			query_entity_with_id = (id, done)=>
				@query_entity id, (error, entity)->
					done error, entity
			async.map entity_schema.attributes, query_ids_for_attribute, (err, results)=>
				# console.log 'async map:', err, results
				ids = results.reduce((a,b)-> a.concat b).filter((el,i,a)->i==a.indexOf el)
				# console.log 'ids:', ids
				async.map ids, query_entity_with_id, (err, results)=>
					# console.log 'err:', err
					# console.log 'results:', results
					done err, results

module.exports.Attribute = Attribute
module.exports.Entity = Entity
module.exports.DatomicWrapper = DatomicWrapper
