When /^I open the details page for ad "([0-9]+)"$/ do |id|
  assert Ad.exists?(id.to_i), Ad.all.to_s
  visit "/ads/#{id}"
end

Then /^I should see (?:the ad's|its) title$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see a related photo$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see (?:the ad's|its) author, creation date and keywords$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see (?:the ad's|its) description$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should see (?:the ad's|its) comments$/ do
  pending # express the regexp above with the code you wish you had
end

