@omniauth
Feature: Omniauth Login and Registration
  In order to login or sign up promptly
  As a user
  I want to login (or signup) using Social Providers

  @facebook @focus
  Scenario: Registering with Facebook
    Given I am not logged in
     When I sign in with provider "facebook"
     Then I should be on the home page
      And I should see notice with message: "authenticated from Facebook"
      And a confirmed user should exist with email: "testuser@facebook.com"
     When I go to the edit profile page
     Then I should see field "Name" prefilled with "Test Facebook User"
      And I should see field "Image" prefilled with "http://url.to/profile-image.jpg"
      And I should see link to "https://facebook.com/testuser"

  @facebook
  Scenario: Login with Facebook
    Given I have signed in with provider "facebook" before
     Then a confirmed user should exist with email: "testuser@facebook.com"
    Given I am not logged in
     When I sign in with provider "facebook"
     Then I should be on the home page
      And I should see notice with message: "Signed in via Facebook!"

  @facebook
  Scenario: Registering with Facebook without email permission
    Given I am not logged in
      And I do not want to expose my "email" via "facebook" provider
     When I sign in with provider "facebook"
     Then I should be on the registration page
      And I should see field "Name" prefilled with "Test Facebook User"
     When I sign up with email: "john@smith.com"
      And a user should exist with email: "john@smith.com"
      And the user should not be confirmed
      And 1 email should be delivered to the user
      And the email should contain "confirm"
     When I sign in with provider "facebook"
     Then I should see alert with message: "confirm your email address before"
     When I follow "Confirm my account" in the email
     Then I should see notice with message: "successfully confirmed"
     When I sign in with provider "facebook"
     Then I should be on the home page
      And I should see notice with message: "Signed in via Facebook!"

  @google
  Scenario: Registering with Google
    Given I am not logged in
     When I sign in with provider "google_plus"
     Then I should be on the home page
      And I should see notice with message: "authenticated from Google Plus"
      And a confirmed user should exist with email: "testuser@google_plus.com"
     When I go to the edit profile page
     Then I should see field "Name" prefilled with "Test Google User"
      And I should see field "Image" prefilled with "http://url.to/profile-image.jpg"
      And I should see link to "http://plus.google.com/some-profile-id"

  @google
  Scenario: Login with Google
    Given I have signed in with provider "google_plus" before
     Then a confirmed user should exist with email: "testuser@google_plus.com"
    Given I am not logged in
     When I sign in with provider "google_plus"
     Then I should be on the home page
      And I should see notice with message: "Signed in via Google Plus!"

  @twitter
  Scenario: Registering with Twitter
    Given I am not logged in
     When I sign in with provider "twitter"
     Then I should be on the registration page
      And I should see field "Name" prefilled with "Test Twitter User"
     When I sign up with email: "testuser2@twitter.com"
     Then a user should exist with email: "testuser2@twitter.com"
      And 1 email should be delivered to the user
      And the email should contain "confirm"
     When I sign in with provider "twitter"
     Then I should see alert with message: "confirm your email address before"
     When I follow "Confirm my account" in the email
     Then I should see notice with message: "successfully confirmed"
     When I sign in with provider "twitter"
     Then I should be on the home page
      And I should see notice with message: "Signed in via Twitter!"
     When I go to the edit profile page
     Then I should see field "Name" prefilled with "Test Twitter User"
      And I should see field "Image" prefilled with "http://url.to/profile-image.jpg"
      And I should see link to "https://twitter.com/testusername"

  @facebook
  Scenario: Confirming email address with Identity
    Given no user exists with email: "testuser@example.com"
     When I sign up with email: "testuser@facebook.com"
     Then a user should exist with email: "testuser@facebook.com"
      And the user should not be confirmed
      And 1 email should be delivered to the user
    Given I am not logged in
     When I sign in with provider "facebook"
     Then I should see notice with message: "Confirmed email: testuser@facebook.com!"
      And the user should be confirmed

  @google
  Scenario: Adding new identity when logged in
    Given I am logged in as user with email: "user@user.com"
     When I click to add provider "google_plus" in my profile
     Then I should see notice with message: "Successfully linked"
      And I should be on the edit profile page

  @twitter
  Scenario: Adding already attached identity when logged in
    Given I have signed in with provider "twitter" before
     Then a confirmed user should exist with email: "testuser@twitter.com"
     When I sign in as this user and password: "password"
      And I click to add provider "twitter" in my profile
     Then I should see notice with message: "already linked"
      And I should be on the edit profile page

  @facebook
  Scenario: Adding identity associated with another user when logged in
    Given I have signed in with provider "facebook" before
     Then a confirmed user should exist with email: "testuser@facebook.com"
    Given I am logged in as user with email: "someone@example.com"
     When I click to add provider "facebook" in my profile
     Then I should see alert with message: "already associated with another"
      And I should be on the edit profile page

  @facebook
  Scenario: Adding identity (when logged in) whose email is associated with another user
    Given a user exists with email: "testuser@facebook.com"
      And I am logged in as user with email: "user@user.com"
     When I click to add provider "facebook" in my profile
     Then I should be on the edit profile page
      And I should see notice with message: "Successfully linked"
      But I should not see "already associated"

  @google
  Scenario: Adding identity (when logged in) with user's current email address
    Given I am logged in as user with email: "testuser@google_plus.com"
     When I click to add provider "google_plus" in my profile
     Then I should be on the edit profile page
      And I should see notice with message: "Successfully linked"
      But I should not see "already linked"
