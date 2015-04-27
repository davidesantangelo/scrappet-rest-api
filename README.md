# scrappet-rest-api
rails app for web scraping purposes. It scrapes a given page (by the URL), and returns you all informations about that page. This API use the my own gem https://github.com/davidesantangelo/webinspector

# see in action
You can use scrappet-rest-api live at this url: https://scrappet.herokuapp.com

# getting started

 git clone https://github.com/davidesantangelo/scrappet-rest-api.git<br />
 cd scrappet-rest-api & bundle install<br />
 rails s 

# try it
curl -X GET http://127.0.0.1:3000/api/scrape?url=http://www.github.com<br>
return a json hash with title, description, keywords, links, images etc..
