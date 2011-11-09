require 'test_helper'

class AdTest < ActiveSupport::TestCase
	setup do
		@a1 = ads(:a1)
	end

	test "favorites" do
		user1 = users(:uva)

		assert !@a1.favorite?(user1.id)

		@a1.mark_favorite! user1.id
		assert @a1.favorite?(user1.id)

		@a1.unmark_favorite! user1.id
		assert !@a1.favorite?(user1.id)
	end
	
	test "user_rating" do
		user1 = users(:uva)

		assert_nil @a1.user_rating(user1.id)

		@a1.rate! user1.id, 3
		assert_equal 3, @a1.user_rating(user1.id)
		
		@a1.rate! user1.id, 4
		assert_equal 4, @a1.user_rating(user1.id)

		assert_throws(ArgumentError) { @a1.rate! user1.id, 0 }
		assert_equal 4, @a1.user_rating(user1.id)
		
		assert_throws(ArgumentError) { @a1.rate! user1.id, -1 }
		assert_throws(ArgumentError) { @a1.rate! user1.id, 6 }
		assert_throws(ArgumentError) { @a1.rate! user1.id, nil }
	end
	
	test "ad_rating" do
	  @a1.rate! users(:uva), 3
	  assert_in_delta 3.0, @a1.avg_rating, 0.001
	  
	  @a1.rate! users(:ray).id, 4
	  assert_in_delta 3.5, @a1.avg_rating, 0.001
	  
	  @a1.rate! users(:grelhas).id, 1
	  assert_in_delta (8.0 / 3.0), @a1.avg_rating, 0.001
	  
	  @a1.rate! users(:ray).id, 5
	  assert_in_delta 3.0, @a1.avg_rating, 0.001
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

  # TODO change order of results when the relevance algorithm is defined
  test "search" do
  	arr = Ad.search_text "Porto"
    assert_equal [ads(:a3)], arr, "Search in tags from opened ads only failed"
    
  	arr = Ad.search_text "world"
    assert_equal [@a1], arr, "Search in a substring of a tag failed"
    
    arr = Ad.search_text "universitario"
    assert_equal [ads(:a3)], arr, "Case and accent insensivive search in title failed"
    
    arr = Ad.search_text "FeUp"
    assert_equal [ads(:a3), ads(:a2)], arr, "Search with multiple results, ordered by relevance, failed"
    
    arr = Ad.search_text "t2 primeiro"
    assert_equal [ads(:a3), @a1], arr, "Search with multiple keywords failed"
    
    arr = Ad.search_text "t2 primeiro", 1
    assert_equal [ads(:a3)], arr, "Search with limit number of results failed"
    
    arr = Ad.search_text "not_in_tags"
    assert arr.empty?, "Search with empty results failed"
    
    arr = Ad.search_text "a", 0
    assert arr.empty?, "Search with empty results failed"
    
    arr = Ad.search_text nil
    assert_nil arr, "Search with invalid inputs failed"
    
    arr = Ad.search_text "a", -1
    assert_nil arr, "Search with invalid inputs failed"
    
    arr = Ad.search_text "a", nil
    assert_nil arr, "Search with invalid inputs failed"
  end
  
  test "close" do
		assert @a1.open?
		
		@a1.close!
		assert !@a1.open?
		
		@a1.open!
		assert @a1.open?
		
		@a1.close_permanently!
		assert !@a1.open?
	
		assert_throws(CannotOpenAdError) { @a1.open! }
		assert !@a1.open?
  end
end
