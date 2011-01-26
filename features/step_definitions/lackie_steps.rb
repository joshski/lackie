Given /^I have surrendered my web page as a lackie$/ do
  browse_example_app
end

When /^I tell the lackie to log "([^\"]*)"$/ do |message|
  @response = remote_control.log(message)
end

When /^I tell the lackie to execute "([^\"]*)"$/ do |script|
  @error = nil
  begin
    @response = remote_control.exec(script)
  rescue => e
    @error = e
  end
end

When /^I tell the lackie to send the command "([^"]*)"$/ do |script|
  @response = remote_control.send_command(script)
end

When /^I await the result of "([^"]*)" to equal "([^"]*)"$/ do |script, value|
  @error = nil
  begin
    @response = remote_control.await(script, :timeout_seconds => 1) do |current_value|
      current_value.to_s == value
    end
  rescue Lackie::AwaitError => e
    @error = e
  end
end

Then /^I should see a result with the value "([^\"]*)"$/ do |value|
  @error.should == nil
  @response.to_s.should == value
end

Then /^I should see an error with the message "([^\"]*)"$/ do |message|
  @error.message.should == message
end

Then /^I should not see an error$/ do
  raise @error unless @error.nil?
end

Then /^I should see an error with a message including "([^"]*)"$/ do |string|
  @error.should_not be_nil
  @error.message.should =~ Regexp.new(string)
end
