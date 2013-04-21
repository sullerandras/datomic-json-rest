JSON REST api for Datomic REST
==============================

Install dependencies
--------------------

	npm install


Run JSON REST server
--------------------

	node_modules/.bin/coffee datomic-json-rest.coffee <options>

Use `--help` to know the possible options.


How to run the tests
--------------------

### Run unit tests

	node_modules/.bin/mocha --compilers coffee:coffee-script

### Run Cucumber tests

Since we test against a real Datomic REST server -- meaning, it is not mocked out in the tests --, we need to start an instance with in-memory database on port 8888. Port number is hard coded in `world.coffee` for now.
Since it takes 5-10 seconds to start the REST server, we do not boot up a new REST server every time we run the tests. However, that would be the ideal situation to avoid side effects.

	cd ~/projects/datomic-free-0.8.3862
	bin/rest -p 8888 test_alias datomic:mem://

Run the tests

	node_modules/.bin/cucumber.js


Instructions to start the JSON REST server
------------------------------------------

1. Download and install Datomic free (it should work with Pro as well, but is not tested)

	[http://downloads.datomic.com/free.html](http://downloads.datomic.com/free.html)

2. Open terminal and start transactor

		cd ~/projects/datomic-free-0.8.3862
		bin/transactor config/samples/free-transactor-template.properties

	It should display something like this:

		System started datomic:free://localhost:4334/<DB-NAME>, storing data in: data

3. Load the Seattle schema from datomic/sample directory. Here we'll create a "seattle" database in datomic.

		cd ~/projects/datomic-free-0.8.3862
		bin/shell

	In the datomic shell, run the following commands:

		uri = "datomic:free://localhost:4334/seattle";
		Peer.createDatabase(uri);
		conn = Peer.connect(uri);

		schema_rdr = new FileReader("samples/seattle/seattle-schema.dtm");
		schema_tx = Util.readAll(schema_rdr).get(0);
		txResult = conn.transact(schema_tx).get();

		data_rdr = new FileReader("samples/seattle/seattle-data0.dtm");
		data_tx = Util.readAll(data_rdr).get(0);
		txResult = conn.transact(data_tx).get();

4. Open an other terminal and start Datomic REST

		cd ~/projects/datomic-free-0.8.3862
		bin/rest -p 9000 testing datomic:free://localhost:4334/

	It should display something like this:

		REST API started on port: 9000
		   testing = datomic:free://localhost:4334/

5. Start JSON REST

		cd ~/projects/datomic-json-rest
		node_modules/.bin/coffee datomic-json-rest.coffee --alias=testing --db_name=seattle

	It should display something like this:

		Datomic JSON REST server listening on port 3000 in development mode,
		connecting to Datomic REST at http://localhost:9000, db alias is testing/seattle


How to use
----------

1. Use `/rest/<entity name>` as a normal JSON REST endpoint, like
	- `GET /rest/<entity name>` returns all entities
	- `POST /rest/<entity name>` creates a new entity with the posted data
	- `GET /rest/<entity name>/<id>` returns the entity with the specified ID
	- `PUT /rest/<entity name>/<id>` modifies the attributes of the entity
	- `DELETE /rest/<entity name>/<id>` deletes the entity
2. Additional API:
	- schema
		- `GET /schema` returns the schema of all entities
		- `POST /schema` creates a new entity schema
		- `GET /schema/<entity name>` returns the schema of the entity
		- `PUT /schema/<entity name>` modifies an existing entity schema
		- `DELETE /schema/<entity name>` deletes the entity schema and all entities in that schema
	- transaction?
	- query interface?
	- databases?
	- Every GET endpoint accepts a timestamp parameter to query the database at the specified time
