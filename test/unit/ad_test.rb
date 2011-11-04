require 'test_helper'

class AdTest < ActiveSupport::TestCase
	# fixtures :users, :ads

	test "favorites" do
		ad1 = ads(:a1)
		user1 = users(:one)

		assert !(ad1.favorite? user1.id)

		ad1.mark_favorite user1.id
		assert ad1.favorite? user1.id

		ad1.unmark_favorite user1.id
		assert !(ad1.favorite? user1.id)
	end

	test "relevance" do
		ad1 = ads(:a1)
		ad2 = ads(:a2)

    ad1_rel = ad1.relevance
    assert ad1_rel > 0

    ad2_rel = ad2.relevance
    assert ad2_rel > 0

    # TODO to change when the relevance algorithm is defined
    assert ad2_rel > ad1_rel
  end

  # TODO to change when the relevance algorithm is defined
  test "get_most_relevant" do
    arr = Ad.get_most_relevant 3
    assert_equal arr [ads(:a3), ads(:a2), ads(:a1)]

    arr = Ad.get_most_relevant 5
    assert_equal arr [ads(:a3), ads(:a2), ads(:a1)]

    arr = Ad.get_most_relevant 1
    assert_equal arr [ads(:a3)]

    arr = Ad.get_most_relevant 0
    assert_equal arr []

    arr = Ad.get_most_relevant -1
    assert_nil arr

    arr = Ad.get_most_relevant nil
    assert_nil arr
  end

  test "search" do
  	# test search in tags
  	list = Ad.search "Porto"
    assert_equal list.length 1
    assert list.include?(ads(:a3))
    
  	# test search in a substring of a tag
  	list = Ad.search "world"
    assert_equal list.length 1
    assert list.include?(ads(:a1))
    
    # test search in title, case insensivity
    # and accentuation insensitivity
    list = Ad.search "universitario"
    assert_equal list.length 1
    assert list.include?(ads(:a3))
    
    # test multiple results
    list = Ad.search "FeUp"
    assert_equal list.length 2
    assert list.include?(ads(:a2))
    assert list.include?(ads(:a3))
    
    # limit number of results
    list = Ad.search "FeUp" 1
    assert_equal list.length 1
    # TODO to change when the relevance algorithm is defined
    assert list.include?(ads(:a3)) # by relevance
    
    # empty results and invalid inputs
    list = Ad.search "not in tags"
    assert list.empty?
    
    list = Ad.search nil
    assert_nil list
  end
end
