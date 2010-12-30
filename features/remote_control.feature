Feature: Remote Control
  In order to automate remote applications with HTTP client capabilities 
  As a client
  I want to surrender applications as javascript lackies
  
  Scenario: Remote Execution
    Given I have surrendered my web page as a lackie
    When  I tell the lackie to execute "1 + 1"
    Then  I should see a result with the value "2"
    
  Scenario: Remote Execution Error
    Given I have surrendered my web page as a lackie
    When  I tell the lackie to execute "(function() { throw 'whoopsie'; })()"
    Then  I should see an error with the message "whoopsie"

  Scenario: Remote Log
    Given I have surrendered my web page as a lackie
    When  I tell the lackie to log "yipee"
    Then  I should see a result with the value "yipee"