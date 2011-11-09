module AdsHelper  
  
  def checked?(id)
    if params[":section_#{id}"]
      true
    else
      false
    end
  end
  
  def share_with_facebook_url(opts)
      url = "http://www.facebook.com/sharer.php?"

      parameters = []

      opts.each do |key,v|
        
        if v.is_a? Hash
          v.each do |sk, sv|
            parameters << "#{key}#{sk}=#{sv}"
          end
        else
          parameters << "#{key}=#{v}"
        end

      end

      url + parameters.join("&")
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
