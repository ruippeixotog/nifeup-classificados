prawn_document(:filename=> "#{@ad.title}.pdf",:page_size => "A4") do |pdf|
  pdf.text_box "Classificado #{@ad.title}", :size => 30, :style => :bold
  pdf.move_down(35)

  pdf.image open("http:/#{Rails.root}#{@ad.thumbnail.url}")
 
  pdf.move_down(5)

  if @ad.average_rate != nil
  	pdf.text "Average Rate: #{@ad.average_rate}", :size => 12
	pdf.move_down(5)
  end
  pdf.text "Author: #{@ad.user.username}", :size => 12
  pdf.move_down(5)
  if @ad.description != nil
  	pdf.text "Description", :size => 12
	pdf.move_down(2)
	pdf.text "#{@ad.description}", :align=>:left
  end
end


