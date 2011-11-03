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

=begin
	test "relevance" do
		ad1 = ads(:one).find
		ad1 = ads(:two).find
		user1 = users(:one).find

		assert !ad1.favorite? user1.id

		ad1.mark_favorite user1.id
		assert ad1.favorite? user1.id

		ad1.unmark_favorite user1.id
		assert !ad1.favorite? user1.id
	end
=end
end
