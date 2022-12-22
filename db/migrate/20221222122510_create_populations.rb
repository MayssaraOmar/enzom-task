class CreatePopulations < ActiveRecord::Migration[7.0]
  def up
    create_table :populations do |t|
      t.column "country_id", :integer, :null =>false
      t.column "year", :integer, :null => false, :unique => true
      t.column "count", :bigint, :null => false
     
      t.timestamps
    end
    add_index  :populations, :country_id
    add_index  :populations, :year

  end

  def down
    drop_table :populations
  end
end
