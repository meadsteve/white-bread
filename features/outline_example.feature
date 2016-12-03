@outline
Feature: Scenario outlines
  As a user
  I can write scenario outlines
  So I can try a scenario with several sets of data

  Scenario Outline: Basic outline
    Given the string "one and two"
    Then the string should contain "<substring>"

    Examples:
      | substring |
      | one       |
      | two       |

  Scenario Outline: Load starting state
    Given a scenario outline
    Then it should load the scenario starting state

    Examples:
      | dummy |
      | null  |
