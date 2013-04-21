Feature: GET /schema
  As a user of the application
  I want to know what entities are there in the database
  So that I can access the entities thru the REST API

  Scenario: single entity with string attributes
    Given There are the following entity-attributes in the database:
        | edn attribute definition |
        | {:db/id #db/id[:db.part/db] :db/ident :user/name :db/valueType :db.type/string :db/cardinality :db.cardinality/one :db.install/_attribute :db.part/db} |
        | {:db/id #db/id[:db.part/db] :db/ident :user/phone :db/valueType :db.type/string :db/cardinality :db.cardinality/many :db.install/_attribute :db.part/db} |
    When I call "schemas_all"
    Then I get back the following JSON structure:
        | JSON structure |
        | [ {"name": "user", "attributes": [{"name": "name", "type": "string", "cardinality": "one"}, {"name": "phone", "type": "string", "cardinality": "many"}]} ] |

  Scenario: single entity with all types
    Given There are the following entity-attributes in the database:
        | edn attribute definition |
        | {:db/id #db/id[:db.part/db] :db/ident :user/age :db/valueType :db.type/long :db/cardinality :db.cardinality/one :db.install/_attribute :db.part/db} |
        | {:db/id #db/id[:db.part/db] :db/ident :user/female :db/valueType :db.type/boolean :db/cardinality :db.cardinality/one :db.install/_attribute :db.part/db} |
    When I call "schemas_all"
    Then I get back the following JSON structure:
        | JSON structure |
        | [ {"name": "user", "attributes": [{"name": "age", "type": "long", "cardinality": "one"}, {"name": "female", "type": "boolean", "cardinality": "one"}]} ] |

  Scenario: multiple entities
    Given There are the following entity-attributes in the database:
        | edn attribute definition |
        | {:db/id #db/id[:db.part/db] :db/ident :user/age :db/valueType :db.type/long :db/cardinality :db.cardinality/one :db.install/_attribute :db.part/db} |
        | {:db/id #db/id[:db.part/db] :db/ident :user/female :db/valueType :db.type/boolean :db/cardinality :db.cardinality/one :db.install/_attribute :db.part/db} |
        | {:db/id #db/id[:db.part/db] :db/ident :address/street :db/valueType :db.type/string :db/cardinality :db.cardinality/one :db.install/_attribute :db.part/db} |
    When I call "schemas_all"
    Then I get back the following JSON structure:
        | JSON structure |
        | [ {"name": "user", "attributes": [{"name": "age", "type": "long"}, {"name": "female", "type": "boolean"}]}, {"name": "address", "attributes": [{"name": "street", "type": "string"}]} ] |
