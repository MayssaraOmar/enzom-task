class CreatePopulations < ActiveRecord::Migration[7.0]
  def up
    create_table :populations do |t|
      t.column "country_id", :integer, :null =>false
      t.column "year", :integer, :null => false
      t.column "count", :integer, :null => false
      t.column "sex", :string, :limit => 50
      t.column "reliabilty", :string, :limit => 50
      t.timestamps
    end
    add_index  :populations, :country_id

  end

  def down
    drop_table :populations
  end
end
