Given /^the system has already some ads with the keyword "([^"]*)" in section "([^"]+)"$/ do |keyword, section|
  assert Section.exists?(1), Section.all.to_s
  3.times do |i|
    ad = Ad.new :title => keyword + " " + i.to_s
    ad.section_id = Section.find_by_name(section).id
    ad.save
  end
  
  3.times do |i|
    ad = Ad.new :title => i.to_s
    ad.section_id = Section.find_by_name(section).id
    ad.save

    tag = AdTag.new :ad_id => ad.id, :tag => keyword
    tag.save
  end
end

When /^I submit a search$/ do
  visit "/ads/dashboard?search_terms=&section_id=1&commit=Go"
end

When /^I submit the search$/ do
  find('#search_button').click
end

Then /^(the ads|they) should all have the keyword "([^"]*)" or a keyword with that prefix$/ do |dummy, keyword|
  pending # express the regexp above with the code you wish you had
end

When /^I type "([^"]*)" in the search area$/ do |text|
  old_text = find('#search_text_field').value || ""
  fill_in 'search_text_field', :with => old_text + text
end

