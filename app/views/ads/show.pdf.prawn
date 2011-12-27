prawn_document(:filename=> "#{@ad.title}.pdf", :page_layout => :landscape) do |pdf|
  pdf.text "Classificado #{@ad.title}", :size => 30, :style => :bold
  pdf.move_down(20)

  if @ad.average_rate != nil
  	pdf.text "Average Rate #{@ad.average_rate}", :size => 12
  end
  pdf.text "Author #{@ad.user.username}", :size => 12
  if @ad.description != nil
  	pdf.text "Description #{@ad.description}", :size => 12
  end
end
