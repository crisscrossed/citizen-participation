class AddQuarterToInitiatives < ActiveRecord::Migration
  def change
    add_column :initiatives, :quarter_id, :integer

    Initiative.reset_column_information
    Initiative.find_each do |initiative|
      initiative.update_quarter_id
      initiative.save(validate: false)
    end
  end
end
