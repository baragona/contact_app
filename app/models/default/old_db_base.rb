module Default
  class OldDbBase < ActiveRecord::Base
    establish_connection :adapter => "mysql2", :host => "localhost", :database => "contactdb", :username => "root"
    self.table_name = 'contacts'
  end
end