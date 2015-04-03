require 'open-uri'

class Api::ScrapersController < Api::BaseController
  skip_before_filter :verify_authenticity_token
  before_filter :check_params

  def scrape
    page = get_page(params[:url])
    render status: 200, json: { page:  output(page) }
  end

  def page_title
    page = get_page(params[:url])
    render status: 200, json: { title:  title(page) }
  end

  def page_description
    page = get_page(params[:url])
    render status: 200, json: { description:  description(page) }
  end
  
private
  def get_page(url)
    page = MetaInspector.new(
      params[:url],
      :warn_level => :store,
      :connection_timeout => 5, 
      :read_timeout => 5,
      :headers => { 'User-Agent' => user_agent, 'Accept-Encoding' => 'identity' }
    )
    return page
  end

  def check_params
    if params[:url].blank?
      render status: 403, json: { message: 'Missing required url parameters' }
      return
    end
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

    return metatags if doc.at("meta[name='#{name}']").blank?
    doc.at("meta[name='#{name}']").each do |meta|
      metatags.push(meta[1]) if (meta and meta.include? "content")
    end
    return metatags
  end

  def links(page)
    return page.links.all if page.links
    doc = Nokogiri::HTML(open(page.url))
    links = []
    doc.css("a").each do |a|
      links.push((a[:href].to_s.start_with? url.to_s) ? a[:href] : URI.join(url, a[:href]).to_s) if (a and a[:href])
    end
    return links
  end

  def images(url)
    doc = Nokogiri::HTML(open(url))
    images = []
    doc.css("img").each do |img|
      images.push((img[:src].to_s.start_with? url.to_s) ? img[:src] : URI.join(url, img[:src]).to_s) if (img and img[:src])
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