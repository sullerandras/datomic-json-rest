Feature: GET /schema/entity
  As a user of the application
  I want to get entity schema by its name
  So that I can retrieve only the relevant schemas

  Scenario: default
    Given There are the following entity-attributes in the database:
        | edn attribute definition |
        | {:db/id #db/id[:db.part/db] :db/ident :user3/age :db/valueType :db.type/long :db/cardinality :db.cardinality/one :db.install/_attribute :db.part/db} |
        | {:db/id #db/id[:db.part/db] :db/ident :user3/female :db/valueType :db.type/boolean :db/cardinality :db.cardinality/one :db.install/_attribute :db.part/db} |
        | {:db/id #db/id[:db.part/db] :db/ident :address3/street :db/valueType :db.type/string :db/cardinality :db.cardinality/one :db.install/_attribute :db.part/db} |
    When I call "get_schema" with "user3"
    Then I get back the following JSON structure:
        | JSON structure |
        | {"name": "user3", "attributes": [{"name": "age", "type": "long"}, {"name": "female", "type": "boolean"}]} |
