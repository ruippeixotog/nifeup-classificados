Then /^the request should succeed$/ do
  assert_equal 200, page.driver.status_code
end
