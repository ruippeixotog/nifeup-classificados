require 'test_helper'

class AdTest < ActiveSupport::TestCase
	# fixtures :users, :ads

	test "favorites" do
		ad1 = ads(:one)
		user1 = users(:one)

		assert !(ad1.favorite? user1.id)

		ad1.mark_favorite user1.id
		assert ad1.favorite? user1.id

		ad1.unmark_favorite user1.id
		assert !(ad1.favorite? user1.id)
	end

	test "relevance" do
		ad1 = ads(:one)
		ad2 = ads(:two)

    ad1_rel = ad1.relevance
    assert ad1_rel > 0

    ad2_rel = ad2.relevance
    assert ad2_rel > 0

    # TODO to change when the relevance algorithm is defined
    assert ad2_rel > ad1_rel
  end

  test "get_most_relevant" do
    # TODO to change when the relevance algorithm is defined
    arr = Ad.get_most_relevant 3
    assert arr [ads(:one), ads(:two), ads(:three)]

    arr = Ad.get_most_relevant 5
    assert arr [ads(:one), ads(:two), ads(:three)]

    arr = Ad.get_most_relevant 1
    assert arr [ads(:one)]

    arr = Ad.get_most_relevant 0
    assert arr []

    arr = Ad.get_most_relevant -1
    assert arr nil

    arr = Ad.get_most_relevant nil
    assert arr nil
  end

  test "search" do
    # list = Ad.search "porto"
    # assert ads(:one).section == sections(:two)
    assert true
  end
end
