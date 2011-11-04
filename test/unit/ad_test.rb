require 'test_helper'

class AdTest < ActiveSupport::TestCase
	setup do
		@a1 = ads(:a1)
	end

	test "favorites" do
		user1 = users(:uva)

		assert !(@a1.favorite? user1.id)

		@a1.mark_favorite user1.id
		assert (@a1.favorite? user1.id)

		@a1.unmark_favorite user1.id
		assert !(@a1.favorite? user1.id)
	end

	test "relevance" do
    ad1_rel = @a1.relevance
    assert ad1_rel > 0

    ad2_rel = ads(:a2).relevance
    assert ad2_rel > 0

    # TODO to change when the relevance algorithm is defined
    assert ad2_rel > ad1_rel
  end
  
  test "opened" do
    arr = Ad.all_opened
    assert_equal 3, arr.length
    arr.each do |a|
      assert a.open?
    end 
  end

  # TODO to change when the relevance algorithm is defined
  test "most relevant" do
    arr = Ad.most_relevant 3
    assert_equal [ads(:a3), ads(:a2), @a1], arr

    arr = Ad.most_relevant 5
    assert_equal [ads(:a3), ads(:a2), @a1], arr

    arr = Ad.most_relevant 1
    assert_equal [ads(:a3)], arr

    arr = Ad.most_relevant 0
    assert_equal [], arr

    arr = Ad.most_relevant -1
    assert_nil arr

    arr = Ad.most_relevant nil
    assert_nil arr
  end

  # TODO to change when the relevance algorithm is defined
  test "search" do
  	# test search in tags
  	arr = Ad.search "Porto"
    assert_equal [ads(:a3)], arr
    
  	# test search in a substring of a tag
  	arr = Ad.search "world"
    assert_equal [@a1], arr
    
    # test search in title, case insensivity
    # and accentuation insensitivity
    arr = Ad.search "universitario"
    assert_equal [ads(:a3)], arr
    
    # test multiple results, ordered by relevance
    arr = Ad.search "FeUp"
    assert_equal [ads(:a3), ads(:a2)], arr
    
    # test multiple keywords
    arr = Ad.search "t2 ola"
    assert_equal [ads(:a3), @a1], arr
    
    # limit number of results
    arr = Ad.search "t2 ola", 1
    assert_equal [ads(:a3)], arr
    
    # empty results and invalid inputs
    arr = Ad.search "not_in_tags"
    assert arr.empty?
    
    arr = Ad.search nil
    assert_nil arr
  end
end
