class CreateJourneys < ActiveRecord::Migration[4.2]
  def change
    create_table :journeys do |t|
      t.references :user, index: true

      t.timestamps null: false
    end
    add_foreign_key :journeys, :users
  end
end
