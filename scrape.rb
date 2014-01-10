require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'  

base_url = "http://www.census.nationalarchives.ie/search/results.jsp?"

params = {
  "census_year" => "1901",
  "pageSize" => "100",
  "search" => "Search"
}
url_safe_params = URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))
url = "#{base_url}#{url_safe_params}"
puts url



doc = Nokogiri::HTML(open(url))  
doc.css(".results tbody tr").each do |elem|
  # puts elem.css("td").inspect
  person = {
    :surname => elem.children[0].text,
    :forename => elem.children[1].text,
    :townland => elem.children[3].text,
    :district => elem.children[4].text,
    :county => elem.children[5].text,
    :age => elem.children[6].text,
    :sex => elem.children[7].text,
    :birthplace => elem.children[8].text,
    :occupation => elem.children[9].text,
    :religion => elem.children[10].text,
    :literacy => elem.children[11].text,
    :language => elem.children[12].text,
    :relationship_to_head => elem.children[13].text
  }
  puts person.inspect
end