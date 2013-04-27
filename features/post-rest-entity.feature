Feature: POST /rest/entity
  As a user of the application
  I want to create new entities in the database
  So that I can work with them later

  Scenario: default
    Given I call "create_schema" with the following parameter:
        | JSON structure |
        | {"name": "user", "attributes": [{"name": "name", "type": "string", "cardinality": "one"}, {"name": "phone", "type": "string", "cardinality": "many"}]} |
    When I create a new user entity with the following parameter:
        | JSON structure |
        | {"name": "admin", "phone": ["555-123", "555-234"]} |
    Then the result is the entity with a newly assigned ID
    And I can see the new entity in "rest_index" with the same ID
