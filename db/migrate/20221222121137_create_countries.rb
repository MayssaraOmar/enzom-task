class CreateCountries < ActiveRecord::Migration[7.0]
  def up
    create_table :countries do |t|
      t.column "name", :string, :limit => 50, :null =>false #make limit 300
      t.column "city_name", :string, :limit => 50, :null => false #make limit 300

      t.timestamps
    end

    add_index("countries", ["name"])
    add_index("countries", ["name", "city_name"])
  end

  def down
    drop_table :countries
  end
end
