class AddShippingToSales < ActiveRecord::Migration
  def change
    add_column :sales, :name, :string
    add_column :sales, :phone, :string
    add_column :sales, :line1, :string
    add_column :sales, :line2, :string
    add_column :sales, :city, :string
    add_column :sales, :region, :string
    add_column :sales, :postal_code, :string
    add_column :sales, :country, :string
  end
end
