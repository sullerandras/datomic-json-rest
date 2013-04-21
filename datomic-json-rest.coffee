#!/usr/local/bin/coffee
express = require 'express'
coffee = require 'coffee-script'
DatomicWrapper = require('./datomic-wrapper').DatomicWrapper
optimist = require('optimist')
	.usage('Starts the JSON REST wrapper for the specified Datomic REST server and database.\n'+
		'Usage: $0 <options>\n'+
		'\n'+
		'If you started the REST server with this command:\n'+
		'  bin/rest -p 9000 test datomic:free://localhost:4334/\n'+
		'then "datomic-port" is 9000, and "alias" is "test".'
		)
	.default('datomic-host': 'localhost', 'datomic-port': 9000, 'port': 3000)
	.alias('p', 'port')
	.alias('h', 'help')
	.demand('alias')
	.demand('db_name')
	.describe('port', 'This JSON REST server will listen on this port.')
	.describe('help', 'Prints this help message.')
	.describe('datomic-host', 'The hostname of the Datomic REST server.')
	.describe('datomic-port', 'The port number of the Datomic REST server.')
	.describe('alias', 'The alias of the Datomic REST server.')
	.describe('db_name', 'The DB name what you want to handle with the JSON REST server.')
argv = optimist.argv

app = module.exports = express()

public_dir = __dirname + '/public'
app.configure ->
	app.use express.bodyParser()
	app.use express.methodOverride()
	app.use app.router
	app.use express.static public_dir

app.configure 'development', ->
	app.use express.errorHandler dumpExceptions: true, showStack: true

app.configure 'production', -> app.use express.errorHandler()

datomic = new DatomicWrapper(argv['datomic-host'], argv['datomic-port'], argv['alias'], argv['db_name'])
schemas =
	list_all: (req, res) ->
		datomic.schemas_all (result)->
			res.send result

app.get '/', (req, res) -> res.render 'index', layout: false
app.get '/schema', (req, res) ->
	schemas.list_all req, res

if argv.help
	console.log optimist.help()
else
	app.listen argv.port
	console.log "Datomic JSON REST server listening on port %d in %s mode,\nconnecting to Datomic REST at %s, db alias is %s",
		argv.port,
		app.settings.env,
		datomic.base_url(),
		datomic.db_alias()
