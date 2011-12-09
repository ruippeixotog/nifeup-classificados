Feature: Show dashboard
  In order to be able to see the ads that interest me most
  As a user
  I want to see a dashboard that shows a number of ads ordered by relevance

  Scenario: Visiting dashboard
    Given the system has already some ads
    When I open the dashboard
    Then the request should succeed
      And I should see a list of ads
      And they should be ordered by relevance
