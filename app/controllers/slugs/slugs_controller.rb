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
    slugified = Slug.new(origin_url: params[:slug]).slugify
    render json: { slugified_slug: slugified }, status: 200
  end

  # create the slug
  def create
  end

  # update the slug
  def update
  end





  def api_status
    render json: { success: true }, status: 200
  end

  private

  def slug_params
    params.require(:slug).permit(:slugified_slug, :active)
  end

end