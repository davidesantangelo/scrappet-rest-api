# snippet-rest-api
rails app for web scraping purposes. It scrapes a given page (by the URL), and returns you all informations about that page.

# getting started

git clone https://github.com/davidesantangelo/snippet-rest-api.git<br />
cd snippet-rest-api & bundle install<br />
rails s 

# try it
url -X GET http://127.0.0.1:3000/api/scrape?url=http://www.github.com
