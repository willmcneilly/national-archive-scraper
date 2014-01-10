require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'  

@per_page = 100
@max_pages = 2



def url_for_page(options={})
  base_url = "http://www.census.nationalarchives.ie/search/results.jsp?"

  params = {
    "census_year" => "1901",
    "pageSize" => @per_page,
    "search" => "Search",
  }

  params.merge("offset" => options[:offset]) if options.has_key?(:offset)

  url_safe_params = URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))
  url = "#{base_url}#{url_safe_params}"
  puts url
  return url
end

# <span class="short">Displaying results 1 - 100 of 4429866</span>

def open_page(url)
  people = []
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
    people << person
  end
  return doc, people
end

@people = []

url = url_for_page()
doc, people = open_page(url)
@people.concat(people)

summary = doc.at_css("h1 .short").text
total = (summary.match(/of ([\d]*)/)[1]).to_i
puts "#{total} people"
pages = total/@per_page
puts "#{pages} pages"
offset = 0
page = 1


pages.times do |page|
  break unless page <= @max_pages
  url = url_for_page(:offset => page*@per_page)
  doc, people = open_page(url)
  @people.concat people
end

puts @people.size
puts @people.inspect
