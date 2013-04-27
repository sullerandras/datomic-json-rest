Feature: PUT /rest/entity/id
  As a user of the application
  I want to modify existing entities in the database
  So that I can work with them later

  Scenario: default
    Given I call "create_schema" with the following parameter:
        | JSON structure |
        | {"name": "user", "attributes": [{"name": "name", "type": "string", "cardinality": "one"}, {"name": "phone", "type": "string", "cardinality": "many"}]} |
    And I create a new user entity with the following parameter:
        | JSON structure |
        | {"name": "admin", "phone": ["555-123", "555-234"]} |
    And the result is the entity with a newly assigned ID
    When I modify this user entity with the following:
        | JSON structure |
        | {"name": "modified name", "phone": ["555-555"]} |
    Then I get back the updated attributes with "rest_get"

  Scenario: ignores the id attribute, since it is in the URL
    Given I call "create_schema" with the following parameter:
        | JSON structure |
        | {"name": "user", "attributes": [{"name": "name", "type": "string", "cardinality": "one"}, {"name": "phone", "type": "string", "cardinality": "many"}]} |
    And I create a new user entity with the following parameter:
        | JSON structure |
        | {"name": "admin", "phone": ["555-123", "555-234"]} |
    And the result is the entity with a newly assigned ID
    When I modify this user entity with the following:
        | JSON structure |
        | {"id": 123, "name": "modified name", "phone": ["555-555"]} |
    Then I get back the updated attributes with "rest_get", with the original ID
