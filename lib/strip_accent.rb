class StripAccent < String
  
  #@keywords is array of string
  #@return is copy array of accent stripped strings
  def self.strip_accents keywords
    return nil if keywords == nil
    stripped = []
    keywords.each do |k|
       stripped += k.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').to_s.split
    end
    return stripped
  end
  
end