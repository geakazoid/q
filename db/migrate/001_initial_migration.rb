class InitialMigration < ActiveRecord::Migration
  def self.up
    # create sessions table
    create_table :sessions, {:force => true} do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
    
    # create users table
    create_table :users, {:force => true} do |t|
      t.string :first_name, {:null => false}
      t.string :last_name, {:null => false}
      t.string :email, :limit => 100
      t.string :phone
      t.boolean :communicate_by_email
      t.string :crypted_password, :limit => 40
      t.string :salt, :limit => 40
      t.string :remember_token, :limit => 40
      t.string :activation_code, :limit => 40
      t.string :state, :null => false, :default => 'passive'     
      t.datetime :remember_token_expires_at
      t.datetime :activated_at
      t.datetime :deleted_at
      t.timestamps
    end
    
    add_index :users, :email, :unique => true
    
    # create passwords table
    create_table :passwords, {:force => true} do |t|
      t.integer :user_id
      t.string :reset_code
      t.datetime :expiration_date
      t.timestamps
    end
    
    # create roles table
    create_table :roles, {:force => true} do |t|
      t.string :name
    end
    
    # create roles_users join table
    create_table :roles_users, {:force => true, :id => false} do |t|
      t.integer :role_id, :user_id
    end
    
    # add indexes
    add_index :roles_users, :role_id
    add_index :roles_users, :user_id
    
    # create default admin user
    user = User.new do |u|
      u.first_name = 'Jeremy'
      u.last_name = 'Driscoll'
      u.password = u.password_confirmation = 'quizzing'
      u.phone = '123-456-7890'
      u.email = AppConfig.admin_email
    end
    
    # activate default admin user
    user.register!
    user.activate!
    
    # create admin role
    role = Role.new do |r|
      r.name = 'admin'
    end
    
    # give default admin user the admin role
    user.roles << role
    user.save
  end

  def self.down
    # drop tables
    drop_table :sessions
    drop_table :users
    drop_table :passwords
    drop_table :roles
    drop_table :roles_users
  end
end
