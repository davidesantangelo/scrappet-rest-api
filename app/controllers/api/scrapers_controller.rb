require 'open-uri'

class Api::ScrapersController < Api::BaseController
  skip_before_filter :verify_authenticity_token
  before_filter :check_params

  def scrape
    begin
      page = get_page(params[:url])
      doc = Nokogiri::HTML(open(page.url))
      render status: 200, json: { page: output(page, doc) }
    rescue Exception => e
       render status: 500, json: { message: e.message }
    end
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

  def output(page, doc)
    output = { 
      url: page.url,
      host: page.host,
      title: title(page, doc),
      description: description(page, doc),
      keywords: keywords(page, doc),
      links: links(page, doc),
      images:  images(page, doc),
      meta_tags: meta_tags(page, doc)
    }
  end

  def title(page, doc)
    return page.title.strip if page.title
    return doc.css('title').text
  end

  def description(page, doc)
    return page.description if page.description
    return meta(page.url, doc, 'description')
  end

  def keywords(page, doc)
    return page.meta['keywords'] if page.meta['keywords']
    return meta(page.url, doc, 'keywords')
  end

  def meta(url, doc, name)
    metatags = []
    return metatags if doc.at("meta[name='#{name}']").blank?

    doc.at("meta[name='#{name}']").each do |meta|
      metatags.push(meta[1]) if (meta and meta.include? "content")
    end
    return metatags
  end

  def links(page, doc)
    return page.links.all if not page.links.all.blank?
    links = []
    doc.css("a").each do |a|
      links.push((a[:href].to_s.start_with? page.url.to_s) ? a[:href] : URI.join(page.url, a[:href]).to_s) if (a and a[:href])
    end
    return links
  end

  def images(page, doc)
    url = page.url
    images = []
    doc.css("img").each do |img|
      images.push((img[:src].to_s.start_with? url.to_s) ? img[:src] : URI.join(url, img[:src]).to_s) if (img and img[:src])
    end
    return images
  end

  def meta_tags(page, doc)
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