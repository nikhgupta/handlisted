Feature: User Profile Editing
  In order to keep my profile information concurrent
  As a user
  I want to update information in my profile

  Scenario: Unauthenticated user tries to edit his profile
    Given I am not logged in
     When I go to the edit profile page
     Then I should be on the login page
      And I should see alert with message: "need to sign in"

  Scenario: Authenticated user edits his profile information without password
    Given I am logged in as user with email: "john@smith.com", name: "Some User"
     When I go to the edit profile page
     Then I should see field "Name" prefilled with "Some User"
     When I fill in "Name" with "John Smith"
      And I click on "Update User" button
     Then I should see notice with message: "successfully updated"
      And I should see field "Name" prefilled with "John Smith"

  Scenario: Authenticated user edits his profile information along with password
    Given I am logged in as user with email: "john@smith.com", name: "Some User"
     When I go to the edit profile page
     Then I should see field "Name" prefilled with "Some User"
     When I fill in "Name" with "John Smith"
     When I fill in "Password" with "newpassword"
     When I fill in "Password confirmation" with "newpassword"
      And I click on "Update User" button
     Then I should see notice with message: "successfully updated"
      And I should be on the home page
     When I sign in as user with email: "john@smith.com" and password: "newpassword"
     Then I should see notice with message: "Signed in successfully"
     When I go to the edit profile page
     Then I should see field "Name" prefilled with "John Smith"
     Then I should see empty field "Password"
      And I should see empty field "Password confirmation"

  Scenario: Authenticated user edits his profile information with wrong password confirmation
    Given I am logged in as user with email: "john@smith.com", name: "Some User"
     When I go to the edit profile page
     Then I should see field "Name" prefilled with "Some User"
     When I fill in "Name" with "John Smith"
     When I fill in "Password" with "newpassword"
     When I fill in "Password confirmation" with "newpasswordwrong"
      And I click on "Update User" button
     Then I should see alert with message: "Password confirmation doesn't match Password"
      And I should be on the edit profile page
