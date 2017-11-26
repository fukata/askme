class AddReplyColumn < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :reply_comment, :string, limit: 1024, null: false, default: "", after: :comment
  end
end
