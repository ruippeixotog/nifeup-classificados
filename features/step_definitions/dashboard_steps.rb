World(Rack::Test::Methods)

Given /^the system has already some ads$/ do
  3.times { |i| (Ad.new :title => i.to_s).save }
  assert !Ad.first.nil?
end

When /^I open the dashboard$/ do
  get "/"
end

Then /^the request should succeed$/ do
  assert_equal 200, last_response.status
end

Then /^I should see a list of ads$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^they should be ordered by relevance$/ do
  pending # express the regexp above with the code you wish you had
end
