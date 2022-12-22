class CreateCountries < ActiveRecord::Migration[7.0]
  def up
    create_table :countries do |t|
      t.column "name", :string, :limit => 300, :null =>false, :unique => true 
      t.column "code", :string, :limit => 50, :null => false 
      t.column "iso3", :string, :limit => 50, :null => false 

      t.timestamps
    end

    add_index("countries", ["name"])
  end

  def down
    drop_table :countries
  end
end
