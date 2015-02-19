ActiveAdmin.register Contact do
  permit_params :email

  index do
    selectable_column
    #column :id
    column :email
    #column :addr
    column :first_name
    column :last_name
    column :school_name
    column :phone
    column :city
    column :state

    #column :district_doc_type
    #column :enrollment
    #column :ext
    #column :full_name
    #column :grade
    #column :high_grade
    #column :honorific
    #column :low_grade
    #column :role
    #column :source_filename
    #column :title
    #column :school_type
    #column :school_classification
    #column :unused
    #column :website
    #column :zip
    actions
  end

  filter :email
  filter :id
  filter :status

  #filter :addr
  filter :first_name
  filter :last_name  
  filter :full_name
  filter :city
  #filter :district_doc_type
  #filter :enrollment
  #filter :ext  
  #filter :grade
  #filter :high_grade
  #filter :honorific
  #filter :low_grade
  filter :phone
  #filter :role
  filter :school_name
  filter :source_filename
  filter :state
  filter :title
  filter :school_type
  filter :school_classification
  #filter :unused
  #filter :website
  filter :zip
  filter :source
  #filter :notes
        
  viewable_cols = [
    :email,
    :status,
    :id,
    :addr,
    :city,
    :district_doc_type,
    :email,
    :enrollment,
    :ext,
    :first_name,
    :last_name,
    :full_name,
    :grade,
    :low_grade,
    :high_grade,
    :honorific,
    :phone,
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
    :notes

  ]
  
  editable_cols = viewable_cols.dup
        
  form do |f|
    f.inputs "Contact Details" do
        editable_cols.each{ |col|
            f.input col
        }
        f.actions         # adds the 'Submit' and 'Cancel' buttons
    end
  end
  
  show do
    attributes_table do
        viewable_cols.each{ |col|
            row col
        }

    end
    active_admin_comments
  end

end
