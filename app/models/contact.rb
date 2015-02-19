  class Contact < ActiveRecord::Base
    self.table_name = 'contacts'
    
    if ActiveRecord::VERSION::STRING < '4.0.0' || defined?(ProtectedAttributes)
      attr_accessible   :addr,
                        :city,
                        :district_doc_type,
                        :email,
                        :enrollment,
                        :ext,
                        :first_name,
                        :full_name,
                        :grade,
                        :high_grade,
                        :honorific,
                        :last_name,
                        :low_grade,
                        :phone,
                        #:role,
                        :school_name,
                        :source_filename,
                        :state,
                        :title,
                        :school_type,
                        :school_classification,
                        :unused,
                        :website,
                        :zip,
                        :source,
                        :status,
                        :notes
    end
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    #devise :database_authenticatable, 
    devise    :recoverable, :rememberable, :trackable
  end