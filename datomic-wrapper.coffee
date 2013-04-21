request = require "request"
edn = require "edn"

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
			done edn.parse body

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
			done edn.parse body

	query: (query_edn, done)->
		req =
			url: @base_url()+'/api/query?q='+escape(query_edn)+'&args='+escape('[{:db/alias "'+@db_alias()+'"}]')
			method: 'GET'
			headers:
				Accept: 'application/edn'
		@log 'Querying the database:', 'req'
		request req, (error, response, body)=>
			@log 'Server response:', error, response.statusCode, body
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
			done entities

	schemas_all: (done)->
		@query '
			[:find ?e ?ident ?vt ?vt_ident ?card ?card_ident
			:in $
			:where
				[?e :db/ident ?ident]
				[?e :db/valueType ?vt]
				[?vt :db/ident ?vt_ident]
				[?e :db/cardinality ?card]
				[?card :db/ident ?card_ident]
			]', done

module.exports.Attribute = Attribute
module.exports.Entity = Entity
module.exports.DatomicWrapper = DatomicWrapper
