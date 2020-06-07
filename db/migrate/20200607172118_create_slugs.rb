class CreateSlugs < ActiveRecord::Migration[6.0]
  def change
    create_table :slugs do |t|
      t.string :origin_url
      t.string :slugified_slug
      t.boolean :active, default: true
      t.index ["origin_url"], name: "index_origin_url_on_slug", unique: true
    end
  end
end
