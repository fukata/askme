class CreateAskme < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :username, null: false
      t.string :twitter_account_id
      t.datetime :last_logined_at
      t.datetime :deleted_at
      t.timestamps
    end

    create_table :questions do |t|
      t.string :comment, null: false, limit: 1024
      t.datetime :deleted_at
      t.timestamps
    end
  end
end
