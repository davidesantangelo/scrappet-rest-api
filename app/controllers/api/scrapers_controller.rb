class Api::ScrapersController < Api::BaseController
  skip_before_filter :verify_authenticity_token

  def scrape
    render status: 200, json: { page: output(@current_page) }
  end

  def page_title
    render status: 200, json: { title:  @current_page.title }
  end

  def page_description
    render status: 200, json: { description:  @current_page.description }
  end

  def page_metatags
    render status: 200, json: { meta_tags:  @current_page.meta }
  end

  def page_links
    render status: 200, json: { links:  @current_page.links }
  end

  def page_images
    render status: 200, json: { images:  @current_page.images }
  end
  
private
  def output(page)
    output = { 
      url: page.url,
      host: page.host,
      scheme: page.scheme,
      port: page.port,
      title: page.title,
      description: page.description,
      keywords: page.meta['keywords'],
      links: page.links,
      images:  page.images,
      meta_tags: page.meta
    }
  end
end
