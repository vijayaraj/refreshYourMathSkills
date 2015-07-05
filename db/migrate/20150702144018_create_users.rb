class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string 'name'
      t.string 'email'
      t.string 'passcode'

      t.integer 'score'
      t.integer 'total_questions'
      t.string 'prev_question'

      t.timestamps
    end
    add_index :users, [ :email ], :unique => true
    add_index :users, [ :passcode ], :unique => true
  end
end
