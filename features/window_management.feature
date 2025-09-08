Feature: Window Management
  As a Lubuntu user
  I want to manage windows programmatically
  So that I can automate my desktop workflow

  Background:
    Given I am running on a Lubuntu system

  Scenario: List open windows
    Given there are open windows on the desktop
    When I request a list of windows
    Then I should receive an array of window information

  Scenario: Focus a window
    Given there is a window with ID "0x123"
    When I focus the window
    Then the window should become active

  Scenario: Move a window
    Given there is a window with ID "0x123"
    When I move the window to coordinates 100, 200
    Then the window should be positioned at 100, 200

  Scenario: Resize a window
    Given there is a window with ID "0x123"
    When I resize the window to 800x600
    Then the window should have dimensions 800x600

  Scenario: Close a window
    Given there is a window with ID "0x123"
    When I close the window
    Then the window should be closed

  Scenario: Switch virtual desktop
    Given there are multiple virtual desktops
    When I switch to desktop 2
    Then the active desktop should be 2

