class AddOptionsToAuthSources < ActiveRecord::Migration
  def self.up
    add_column :auth_sources, :options, :text
  end

  def self.down
    remove_column :auth_sources, :options
  end
end
