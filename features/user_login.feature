Feature: User Login and Registration
  In order to identify myself for certain actions
  As a user
  I want to login (and signup) with the site

  Scenario: Registration, and subsequent Login
    Given I am not logged in
    And   no user exist with email: "john@smith.com"
    When  I go to the registration page
    And   I fill in "Name" with "John Smith"
    And   I fill in "Email" with "john@smith.com"
    And   I fill in "Password (8 characters minimum)" with "password"
    And   I fill in "Password confirmation" with "password"
    And   I click on "Sign up" button
    Then  I should see notice with message: "activate your account"
    And   a user should exist with email: "john@smith.com"
    And   1 email should be delivered to the user
    When  I sign in as this user and password: "password"
    Then  I should see alert with message: "confirm your email address before"
    And   the email should contain "confirm"
    When  I follow "Confirm my account" in the email
    Then  I should see notice with message: "successfully confirmed"
    When  I sign in as this user and password: "password"
    Then  I should be on the home page
    And   I should see notice with message: "Signed in successfully"
    When  I go to the edit profile page
    Then  I should see field "Name" prefilled with "John Smith"

  Scenario: Login when not registered
    Given I am not logged in
    And   no user exist with email: "elisha@cuthbert.com"
    When  I go to the login page
    And   I fill in "Email" with "elisha@cuthbert.com"
    And   I fill in "Password" with "password"
    And   I click on "Log in" button
    Then  I should see alert with message: "Invalid email or password"

  Scenario: Login with invalid password
    Given I am not logged in
    And   confirmed user exists with email: "elisha@cuthbert.com"
    When  I go to the login page
    And   I fill in "Email" with "elisha@cuthbert.com"
    And   I fill in "Password" with "wrongpassword"
    And   I click on "Log in" button
    Then  I should see alert with message: "Invalid email or password"

  Scenario: Login with correct credentials
    Given I am not logged in
    And   confirmed user exists with email: "elisha@cuthbert.com"
    When  I go to the login page
    And   I fill in "Email" with "elisha@cuthbert.com"
    And   I fill in "Password" with "password"
    And   I click on "Log in" button
    Then  I should see notice with message: "Signed in successfully"
