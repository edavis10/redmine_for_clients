class AddFailoverHostToAuthSourceForLdap < ActiveRecord::Migration
  def self.up
    add_column :auth_sources, :failover_host, :string
  end

  def self.down
    remove_column :auth_sources, :failover_host
  end
end
