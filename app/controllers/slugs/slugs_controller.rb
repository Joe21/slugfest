class Slugs::SlugsController < ApplicationController

  # Find by slugified_slug and if active?
  def origin_url
    @slug = Slug.find_by(slugified_slug: slug_params['slugified_slug'])
    if @slug.present? && !!@slug&.active?
      render json: { origin_url: @slug.origin_url }, status: 200
    else 
      render json: { error: 'Slug not found' }, status: 400
    end
  end

  # slugify the string http://localhost:3000/slugs/slugify?url=abc
  def slugify
    slugified = Slug.new.slugify(params[:url])
    render json: { slugified_slug: slugified }, status: 200
  end

  def create
    return request_error(NoMethodError.new('Missing origin_url')) unless params[:slug].try(:[], :origin_url).present?

    origin_url = params[:slug][:origin_url]
    slugified_slug = params[:slug].try(:[], :slugified_slug)

    new_slug = Slug.new(origin_url: origin_url, slugified_slug: slugified_slug)
    new_slug.save
    render json: { slug: new_slug }, status: 200
  end

  def update
    begin
      slugified_slug = slug_params[:slugified_slug]
      slug = Slug.find_by(slugified_slug: slugified_slug)
      slug.update(slug_params)
    rescue StandardError => e
      return request_error(e)
    end

    render json: { slug: slug }, status: 200
  end

  def api_status
    render json: { success: true }, status: 200
  end

  private

  def request_error(e)
    render json: { error: e.message }, status: 400
  end

  def slug_params
    params.require(:slug).permit(:slugified_slug, :active)
  end

end