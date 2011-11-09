module AdsHelper  
  
  def checked?(id)
    if params[":section_#{id}"]
      true
    else
      false
    end
  end  
  def date_format(value)
		return value.to_i if value.class == String
		return value if !value.acts_like_time?

		if value.to_date == Date.today
			return value.strftime "%H:%M"
		elsif value.year == Date.today.year
			return value.strftime "%d %B"
		else
			return value.strftime "%d %B %Y"
		end
	end
end
