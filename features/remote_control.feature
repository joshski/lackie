Feature: Remote Control
  In order to automate remote applications with HTTP client capabilities 
  As a client
  I want to surrender applications as javascript lackies
  
  Background:
    Given I have surrendered my web page as a lackie
  
  Scenario Outline: Remote Execution
    When  I tell the lackie to execute "<command>"
    Then  I should see a result with the value "<result>"
      
      Examples:
      | command        | result             |
      | 1 + 1          | 2                  |
      | 2 + 2          | 4                  |
      | 'foo'          | foo                |
      | document.title | Lackie Example App |
    
  Scenario: Remote Execution Error
    When  I tell the lackie to execute "(function() { throw 'whoopsie'; })()"
    Then  I should see an error with the message "whoopsie"

  Scenario: Remote Log
    When  I tell the lackie to log "yipee"
    Then  I should see a result with the value "yipee"
    
  Scenario: Send Command Without Expecting A Result
    When  I tell the lackie to send the command "window.foo = '123'"
    Then  I should see a result with the value "OK"
    When  I tell the lackie to execute "window.foo = 99"
    Then  I should see a result with the value "99"

  Scenario: Await Result
    When  I tell the lackie to execute "setTimeout(function() { window.foo = 666 }, 500)"
    And   I await the result of "window.foo" to equal "666"
    Then  I should not see an error
    
  Scenario: Await Result Timeout
    When  I tell the lackie to execute "window.bar = 123"
    When  I await the result of "window.bar" to equal "456"
    Then  I should see an error with a message including "123" 