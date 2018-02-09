class CreateCustomers < ActiveRecord::Migration[5.1]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :location
      t.string :skills
      t.string :phonenumber

      t.timestamps
    end
  end
end
