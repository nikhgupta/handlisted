@omniauth
Feature: Omniauth Login and Registration
  In order to login or sign up promptly
  As a user
  I want to login (or signup) using Social Providers

  @facebook @focus
  Scenario: Registering with Facebook
    Given I am not logged in
    And   I have not signed in with provider "facebook" before
    Then  user with email "testuser@facebook.com" should not exist
    When  I sign in with provider "facebook"
    Then  I should be on the home page
    And   I should see "authenticated from Facebook"
    And   user with email "testuser@facebook.com" should be confirmed
    When  I go to the edit profile page
    Then  I should see field "Name" prefilled with "Test Facebook User"
    And   I should see field "Image" prefilled with "http://url.to/profile-image.jpg"
    And   I should see link to "https://facebook.com/testuser"

  @facebook
  Scenario: Login with Facebook
    Given I have signed in with provider "facebook" before
    Then  user with email "testuser@facebook.com" should exist
    Given I am not logged in
    When  I sign in with provider "facebook"
    Then  I should be on the home page
    And   I should see "Signed in via Facebook!"

  @facebook
  Scenario: Registering with Facebook without email permission
    Given I am not logged in
    And   I have not signed in with provider "facebook" before
    And   I do not want to expose my "email" via "facebook" provider
    When  I sign in with provider "facebook"
    Then  I should be on the new user registration page
    And   I should see field "Name" prefilled with "Test Facebook User"
    When  I signup with email "testuser2@facebook.com" and password "password2"
    Then  I should see "activate your account"
    And   "testuser2@facebook.com" should receive an email
    When  I sign in with provider "facebook"
    Then  I should see "confirm your email address before"
    When  I follow the confirmation link in the confirmation email
    Then  I should see "successfully confirmed"
    When  I sign in with provider "facebook"
    Then  I should be on the home page
    And   I should see "Signed in via Facebook!"

  @google
  Scenario: Registering with Google
    Given I am not logged in
    And   I have not signed in with provider "google_plus" before
    Then  user with email "testuser@google_plus.com" should not exist
    When  I sign in with provider "google_plus"
    Then  I should be on the home page
    And   I should see "authenticated from Google Plus"
    And   user with email "testuser@google_plus.com" should be confirmed
    When  I go to the edit profile page
    Then  I should see field "Name" prefilled with "Test Google User"
    And   I should see field "Image" prefilled with "http://url.to/profile-image.jpg"
    And   I should see link to "http://plus.google.com/some-profile-id"

  @google
  Scenario: Login with Google
    Given I have signed in with provider "google_plus" before
    Then  user with email "testuser@google_plus.com" should exist
    Given I am not logged in
    When  I sign in with provider "google_plus"
    Then  I should be on the home page
    And   I should see "Signed in via Google Plus!"

  @twitter
  Scenario: Registering with Twitter
    Given I am not logged in
    And   I have not signed in with provider "twitter" before
    When  I go to the login page
    And   I sign in with provider "twitter"
    Then  I should be on the new user registration page
    And   I should see field "Name" prefilled with "Test Twitter User"
    When  I signup with email "testuser2@twitter.com" and password "password2"
    Then  I should see "activate your account"
    And   "testuser2@twitter.com" should receive an email
    When  I sign in with provider "twitter"
    Then  I should see "confirm your email address before"
    When  I follow the confirmation link in the confirmation email
    Then  I should see "successfully confirmed"
    When  I sign in with provider "twitter"
    Then  I should be on the home page
    And   I should see "Signed in via Twitter!"
    When  I go to the edit profile page
    Then  I should see field "Name" prefilled with "Test Twitter User"
    And   I should see field "Image" prefilled with "http://url.to/profile-image.jpg"
    And   I should see link to "https://twitter.com/testusername"

  @facebook @focus
  Scenario: Confirming email address with Identity
    Given I signup with email "testuser@facebook.com" and password "password"
    Then  "testuser@facebook.com" should receive an email
    And   user with email "testuser@facebook.com" should not be confirmed
    Given I am not logged in
    When  I sign in with provider "facebook"
    Then  I should see "Signed in via Facebook! Confirmed email: testuser@facebook.com!"
    And   user with email "testuser@facebook.com" should be confirmed

  @google
  Scenario: Adding new identity when logged in
    Given I am logged in
    And   I have not signed in with provider "google_plus" before
    When  I click to add provider "google_plus" in my profile
    Then  I should see "Successfully linked"
    And   I should be on the edit profile page

  @twitter
  Scenario: Adding already attached identity when logged in
    Given I am logged in
    And   I have signed in with provider "twitter" before
    When  I click to add provider "twitter" in my profile
    Then  I should see "already linked"
    And   I should be on the edit profile page

  @twitter
  Scenario: Adding identity associated with another user when logged in
    Given I have signed in with provider "twitter" before
    Then  user with email "testuser@twitter.com" should be confirmed
    Given I login with email "someotheruser@twitter.com"
    When  I click to add provider "twitter" in my profile
    Then  I should see "already associated with another"
    And   I should be on the edit profile page

  @facebook
  Scenario: Adding identity (when logged in) whose email is associated with another user
    Given user with email address "testuser@facebook.com" exists
    And   anyone has not signed in with provider "facebook" before
    And   I am logged in
    When  I click to add provider "facebook" in my profile
    Then  I should see "Successfully linked"
    And   I should not see "already associated"
    And   I should be on the edit profile page

  @google
  Scenario: Adding identity (when logged in) with user's current email address
    Given I am logged in user with email "testuser@google_plus.com"
    When  I click to add provider "google_plus" in my profile
    Then  I should see "Successfully linked"
    And   I should not see "already linked"
    And   I should be on the edit profile page
