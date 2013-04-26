Feature: GET /rest/entity/id
  As a user of the application
  I want get an entity with id
  So that I can edit and save it back to the server

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
    And I call "rest_index" with "user"
    When I call "rest_get" with "user" and the first object's id
    Then I get back the first object
