Feature: Search ads (US2)
  In order to find a specific ad suited to me
  As a user
  I want to be able to search the ads in a given section by a text expression or keyword

  Scenario: Search ads page
    When I submit a search
    Then the request should succeed
    
  Scenario: Search by a keyword
    Given the system has already some ads with the keyword "feup" in section "Troco"
      And the system has already some ads with the keyword "puef" in section "Troco"
    When I open the dashboard
      And I select the section "Troco"
      And I type "feup" in the search area
      And I submit the search
    Then I should see a list of ads
      And they should all have the keyword "feup" or a keyword with that prefix

  @javascript
  Scenario: Show search results while introducing text (instant search)
    Given the system has already some ads with the keyword "fe" in section "Troco"
      And the system has already some ads with the keyword "fu" in section "Troco"
      And the system has already some ads with the keyword "ef" in section "Troco"
    When I open the dashboard
      And I select the section "Troco"
      And I type "f" in the search area
    Then I should see a list of ads
      And they should all have the keyword "f" or a keyword with that prefix
    When I type "e" in the search area
    Then the ads should all have the keyword "f" or a keyword with that prefix
