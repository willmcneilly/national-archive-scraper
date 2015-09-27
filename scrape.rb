require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require 'open-uri'
require 'json'  

@per_page = 100
@max_pages = 1
@surname = 'rice'
@census_year = "1901"



def url_for_page(options={})
  puts options
  base_url = "http://www.census.nationalarchives.ie/search/results.jsp?"

  params = {
    "census_year" => @census_year,
    "pageSize" => @per_page,
    "search" => "Search",
    "surname" => @surname,
    "pager.offset" => options["pager.offset"]
  }

 # pageOffset = {}

 # params.merge(pageOffset)

  puts params

  url_safe_params = URI.escape(params.collect{|k,v| "#{k}=#{v}"}.join('&'))
  url = "#{base_url}#{url_safe_params}"
  return url
end

# <span class="short">Displaying results 1 - 100 of 4429866</span>

def open_page(url)
  people = []
  #doc = Nokogiri::HTML(open(url, :proxy => 'http://91.108.131.222:80'))
  doc = Nokogiri::HTML(open(url))
  doc.css(".results tbody tr").each do |elem|
    # puts elem.css("td").inspect
    person = {
      :surname => elem.children[0].text,
      :forename => elem.children[1].text,
      :townland => elem.children[2].text,
      :district => elem.children[3].text,
      :county => elem.children[4].text,
      :age => elem.children[5].text,
      :sex => elem.children[6].text,
      :birthplace => elem.children[7].text,
      :occupation => elem.children[8].text,
      :religion => elem.children[9].text,
      :literacy => elem.children[10].text,
      :language => elem.children[11].text,
      :relationship_to_head => elem.children[12].text
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
pages = (total/@per_page) + 1
puts "#{pages} pages"
offset = 0
page = 1


pages.times do |page|
  #break unless page <= @max_pages
  puts page * @per_page
  url = url_for_page({"pager.offset" => page*@per_page})
  puts url
  doc, people = open_page(url)
  @people.concat people
end


fname = "#{@census_year}-census-#{@surname}.json"
somefile = File.open(fname, "w")
people_json = @people.to_json
somefile.puts people_json
somefile.close

#puts @people.size
puts @people.inspect
