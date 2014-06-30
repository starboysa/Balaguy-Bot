require 'nokogiri'
require 'open-uri'
require 'net/smtp'
require 'bitly'
Bitly.use_api_version_3

f = File.open("#{File.dirname(__FILE__)}/quiz_amount_before", 'r')
f.each_line do |line|
	@quiz_amount_before = line.to_i
end
f.close

doc = Nokogiri::HTML(open('http://math.sierracollege.edu/Staff/dbalaguy/Math%2029/Summer,%202014/Take%20Home%20Quiz%20Page.htm'))

quiz_count = 0
doc.css('tr').each do |link|
	quiz_count += 1
end

File.open("#{File.dirname(__FILE__)}/quiz_amount_before", 'w') {|line| line.write(quiz_count.to_s)}

if quiz_count > @quiz_amount_before
	doc.css('tr')[quiz_count-1].css('td')[1].css('a').map {|link| @quiz_link = link['href']}
	@quiz_link = "http://math.sierracollege.edu/Staff/dbalaguy/Math%2029/Summer,%202014/#{@quiz_link}"

	bitly = Bitly.new('starboysa', 'R_a3ed6d26f75541eead1b40e9863dbd37')
	text_link = bitly.shorten(@quiz_link, :history => 1)

	new_quiz = doc.css('tr')[quiz_count-1].css('td')[1].text.strip.tr("\r\n", "")

	email_msg = "Content-type: text/html\nSubject: Balaguy Bot, New Take Home Quiz!\n\n<a href='#{@quiz_link}'>#{new_quiz}</a>"
	text_msg = "\n\nNew Take Home quiz from Balaguy! #{text_link.short_url}"
	smtp = Net::SMTP.new 'smtp.gmail.com', 587
	smtp.enable_starttls
	smtp.start('gmail.com', 'mcpeakemailbot', '*No Password For You!*', :login) do
		smtp.send_message(email_msg, 'jacob.mcpeak@gmail.com', 'jacob.mcpeak@gmail.com')		
		smtp.send_message(text_msg, 'jacob.mcpeak@gmail.com', '9167052597@txt.att.net')
	end
end
