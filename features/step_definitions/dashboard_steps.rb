Given /^the system has already some ads in section "([^"]+)"$/i do |section|
  3.times do |i|
    ad = Ad.new :title => i.to_s
    ad.section_id = Section.find_by_name(section).id
    ad.save
  end
end

When /^I open the dashboard$/i do
  visit "/"
end

When /^I select the section "([^"]+)"$/i do |section|
  section_id = Section.find_by_name(section).id
  find(Dashboard.section_tab_id(section_id)).click
  assert_equal section_id, find('#section_id').value.to_i
end

Then /^I should see a list of ads$/i do
  assert page.has_selector?(Dashboard.main_id), "The main ad container wasn't found."
  within(Dashboard.main_id) do
    assert has_selector?(Dashboard.ad_class), "There were no ads in the main container. Ads in database: " + Ad.all.to_s
  end
end

Then /^(the ads|they) should all be from the section "([^"]+)"$/i do |dummy, section|
  within(Dashboard.main_id) do
    all(Dashboard.ad_class).each do |elem|
      ad = Ad.find(Dashboard.ad_id(elem))
      assert_equal section, ad.section.name, 'The ad #{ad.id} isn\'t from section "#{section}"'
    end
  end
end

Then /^(the ads|they) should be ordered by relevance$/i do |dummy|
  within(Dashboard.main_id) do
    last_ad = nil
    all(Dashboard.ad_class).each do |elem|
      ad = Ad.find(Dashboard.ad_id(elem))
      if last_ad then
        assert ad.relevance <= last_ad.relevance
      end
      last_ad = ad
    end
  end
end
