ActiveRecord::Schema.define :version => 0 do

  create_table :clients, :force => true do |t|
    t.string :name, :default => Client::DEFAULT_NAME
    t.string :description, :default => Client::DEFAULT_DESCRIPTION
    t.boolean :active, :default => false
  end

  create_table :projects, :force => true do |t|
    t.string :name, :default => Project::DEFAULT_NAME
    t.string :description, :default => Project::DEFAULT_DESCRIPTION
    t.boolean :active, :default => false
    t.float :rate
    t.integer :client_id
  end

  create_table :tasks, :force => true do |t|
    t.string :name
    t.date :date
    t.boolean :active, :default => false
    t.datetime :start_at
    t.datetime :end_at
    t.float :accumulated_spent_time, :default => 0
    t.float :rate, :default => 0
    t.integer :user_id
    t.integer :project_id
  end

  create_table :users, :force => true do |t|
    t.string :nickname
    t.string :first_name
    t.string :last_name
    t.string :company
    t.string :address
    t.string :city
    t.string :country
    t.string :email
    t.string :phone
    t.string :zip
    t.string :site
    t.boolean :active, :default => false
  end
end
