require 'open-uri'
require 'open_uri_redirections'

class Api::ScrapersController < Api::BaseController
  skip_before_filter :verify_authenticity_token

  def scrape
    render status: 200, json: { page: output(@current_url, @current_page) }
  end

  def page_title
    render status: 200, json: { title:  title(@current_url, @current_page) }
  end

  def page_description
    render status: 200, json: { description:  description(@current_url, @current_page) }
  end

  def page_links
    render status: 200, json: { links:  links(@current_url, @current_page) }
  end

  def page_images
    render status: 200, json: { images:  images(@current_url, @current_page) }
  end
  
private
  def output(url, page)
    output = { 
      url: url,
      host: host(url).host,
      scheme: host(url).scheme,
      port: host(url).port,
      title: title(page),
      description: description(url, page),
      keywords: keywords(url, page),
      links: links(url, page),
      images:  images(url, page),
      meta_tags: meta_tags(page)
    }
  end

  def host(url)
    return URI.parse(url)
  end

  def title(page)
    return page.css('title').text.strip
  end

  def description(url, page)
    return meta(url, page, 'description')
  end

  def keywords(url, page)
    return meta(url, page, 'keywords')
  end

  def meta(url, page, name)
    metatags = []
    return metatags if page.at("meta[name='#{name}']").blank?

    page.at("meta[name='#{name}']").each do |meta|
      metatags.push(meta[1]) if (meta and meta.include? "content")
    end
    return metatags
  end

  def links(url, page)
    links = []
    page.css("a").each do |a|
      links.push((a[:href].to_s.start_with? url.to_s) ? a[:href] : URI.join(url, a[:href]).to_s) if (a and a[:href])
    end
    return links
  end

  def images(url, page)
    images = []
    page.css("img").each do |img|
      images.push((img[:src].to_s.start_with? url.to_s) ? img[:src] : URI.join(url, img[:src]).to_s) if (img and img[:src])
    end
    return images
  end

  def meta_tags(page)
    results = []
    hash = Hash.new
    page.search("meta").map { |meta| 
      hash[meta['name']] =  meta['content']
      results.push(hash)
      hash = Hash.new
    }
  end
end