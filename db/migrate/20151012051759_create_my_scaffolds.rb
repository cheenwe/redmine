class CreateMyScaffolds < ActiveRecord::Migration
  def change
    create_table :my_scaffolds do |t|
      t.string :name
      t.text :contact
      t.text :result

      t.timestamps null: false
    end unless table_exists? :my_scaffolds
  end
end
