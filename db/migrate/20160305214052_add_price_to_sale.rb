class AddPriceToSale < ActiveRecord::Migration
  def change
    add_column :sales, :amount, :integer
  end
end
