Given /^I have surrendered my web page as a lackie$/ do
  browse_example_app
end

When /^I tell the lackie to log "([^\"]*)"$/ do |message|
  @response = remote_control.log(message)
end

When /^I tell the lackie to execute "([^\"]*)"$/ do |script|
  begin
    @response = remote_control.exec(script)
  rescue => e
    @error = e
  end
end

Then /^I should see a result with the value "([^\"]*)"$/ do |value|
  @response.to_s.should == value
end

Then /^I should see an error with the message "([^\"]*)"$/ do |message|
  @error.message.should == message
end
