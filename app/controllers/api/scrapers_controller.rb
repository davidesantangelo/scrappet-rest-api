require 'open-uri'

class Api::ScrapersController < Api::BaseController
  skip_before_filter :verify_authenticity_token
  before_filter :set_headers 

  def scrape
    if params[:url].blank?
      render status: 404, json: { message:  'missing params: url' }
      return
    end

    page = MetaInspector.new(
      params[:url],
      :warn_level => :store,
      :connection_timeout => 5, 
      :read_timeout => 5,
      :headers => { 'User-Agent' => user_agent, 'Accept-Encoding' => 'identity' }
    )

    render status: 200, json: { page:  output(page) }
  end

  def title
  end
  
  def options
    set_headers
    # this will send an empty request to the clien with 200 status code (OK, can proceed)
    render :text => '', :content_type => 'text/plain'
  end

private
  def set_headers
    headers["Access-Control-Allow-Origin"] = '*'
    headers['Access-Control-Expose-Headers'] = 'Etag'
    headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, PATCH, OPTIONS, HEAD'
    headers['Access-Control-Allow-Headers'] = '*, x-requested-with, Content-Type, If-Modified-Since, If-None-Match'
    headers['Access-Control-Max-Age'] = '86400'
  end

  def output(page)
    output = { 
      url: page.url,
      host: page.host,
      title: title(page),
      description: description(page),
      keywords: keywords(page),
      links: links(page),
      images:  images(page.url),
      meta_tags: meta_tags(page.url)
    }
  end

  def title(page)
    return page.title.strip if page.title

    doc = Nokogiri::HTML(open(page.url))
    return doc.css('title').text
  end

  def description(page)
    return page.description if page.description
    return meta(page.url, 'description')
  end

  def keywords(page)
    return page.meta['keywords'] if page.meta['keywords']
    return meta(page.url, 'keywords')
  end

  def meta(url, name)
    doc = Nokogiri::HTML(open(url))
    metatags = []
    
    if doc.at("meta[name='#{name}']").blank?
      return metatags
    end
    
    doc.at("meta[name='#{name}']").each do |meta|
      metatags.push(meta['content']) if meta
    end
  end

  def links(page)
    return page.links.all if page.links
    doc = Nokogiri::HTML(open(page.url))
    links = []
    doc.css("a").each do |a|
      if not (a and a[:href])
        next
      end
      url = (a[:href].to_s.start_with? url.to_s) ? a[:href] : URI.join(url, a[:href]).to_s
      links.push(url)
    end
    return links
  end

  def images(url)
    doc = Nokogiri::HTML(open(url))
    images = []
    doc.css("img").each do |img|
      if not (img and img[:src])
        next
      end
      image = (img[:src].to_s.start_with? url.to_s) ? img[:src] : URI.join(url, img[:src]).to_s
      puts image
      images.push(image)
    end
    return images
  end

  def meta_tags(url)
    doc = Nokogiri::HTML(open(url))
    results = []
    hash = Hash.new
    doc.search("meta").map { |meta| 
      hash[meta['name']] =  meta['content']
      results.push(hash)
      hash = Hash.new
    }
  end

  def user_agent
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.111 Safari/537.36"
  end
end