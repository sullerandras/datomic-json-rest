Feature: POST /schema
  As a user of the application
  I want to create new entity schemas in the database
  So that I can create new entities for my application

  Scenario: entity with only string attributes
    When I call "create_schema" with the following parameter:
        | JSON structure |
        | {"name": "admin", "attributes": [{"name": "name", "type": "string", "cardinality": "one"}, {"name": "phone", "type": "string", "cardinality": "many"}]} |
    Then I can see the new schema in "schemas_all"
