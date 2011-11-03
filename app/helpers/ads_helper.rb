module AdsHelper
  
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
  
end
