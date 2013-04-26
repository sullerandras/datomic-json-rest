Feature: GET /rest/entity
  As a user of the application
  I want to know what entities are there in the database
  So that I can access them thru the REST API

  Scenario: single entity with string attributes
    Given There are the following entity-attributes in the database:
        | edn attribute definition |
        | {:db/id #db/id[:db.part/db] :db/ident :user/name :db/valueType :db.type/string :db/cardinality :db.cardinality/one :db.install/_attribute :db.part/db} |
        | {:db/id #db/id[:db.part/db] :db/ident :user/phone :db/valueType :db.type/string :db/cardinality :db.cardinality/many :db.install/_attribute :db.part/db} |
    And There are the following facts in the database:
        | edn facts |
        | {:db/id #db/id[:db.part/user -1] :user/name "John"} |
        | {:db/id #db/id[:db.part/user -1] :user/phone "12345"} |
        | {:db/id #db/id[:db.part/user -2] :user/name "Garfield"} |
        | {:db/id #db/id[:db.part/user -2] :user/phone "555-4455"} |
    When I call "rest_index" with "user"
    Then I get back the following JSON structure:
        | JSON structure |
        | [ { "id": "/[0-9]+/", "name": "John", "phone": ["12345"] }, { "id": "/[0-9]+/", "name": "Garfield", "phone": ["555-4455"] } ] |
