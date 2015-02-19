class ContactsController < ApplicationController

#     def view
#     
#     end
#     
#     def render
#     
#     end
#     

    #DISABLE CSRF FOR ALL REQUESTS
    def verified_request?
        true
    end

    def getContactByEmail
        begin
            contact = Contact.where("email = ?", params[:email])[0]
            if not contact
                raise "No contact with that email found"
            end
            render :json => {:contact => contact}
        rescue => e
            render json: {:message => e.to_s}, status: 500
        end
    end
    
    def updateContactByEmail
        begin
            new_obj = JSON.parse params[:updated_json]
        

        
            contact = Contact.where("email = ?", params[:email])[0]
            if not contact
                raise "No contact with that email found"
            end
            
            new_obj.each_key{
                |key|
                contact[key] = new_obj[key]
            }
            
            contact.save
            
            render json: {:message => "Saved changes."}
        rescue => e
            render json: {:message => e.to_s}, status: 500
        end
    end
    
    @@insertable_colnames = [
        'email',
        'status',
        #'id',
        'addr',
        'city',
        'district_doc_type',
        'email',
        'enrollment',
        'ext',
        'first_name',
        'last_name',
        'full_name',
        'grade',
        'low_grade',
        'high_grade',
        'honorific',
        'phone',
        'school_name',
        #'source_filename',
        'state',
        'title',
        'school_type',
        'school_classification',
        'unused',
        'website',
        'zip',
        'source',
        'notes'
    ]
    
    def insertContactsWithCSV
        
        @final_result = "No result info given"
        begin
            begin
                datafile = params[:upload]['datafile']
    
                @filename = datafile.original_filename
    
                @contents = datafile.read
            rescue => e
                raise "Error getting the uploaded file:\n#{e}"
            end
            row_i=0
            @csv_heads=nil
        
            new_objects=[]
        
            row_errs=[]
        
            CSV.parse(@contents) do |row|
                # use row here...
        
                if row_i == 0
                    #header row
                    row.pop until row.last #REMOVE TRAILING NILS
                    @csv_heads=row.map{|col| col.downcase}
                    bad_cols = @csv_heads.select{|col| not @@insertable_colnames.include? col}
                    if bad_cols.length > 0
                        raise "Cols are not insertable: "+bad_cols.to_s
                    end
                    if @csv_heads.uniq.length != @csv_heads.length
                        raise "There are some duplicate column names..."
                    end
                    if not @csv_heads.include? "email"
                        raise "There needs to be a column called email."
                    end
                else
                    #content row
                    new_obj = {}
                    row.each_with_index do |val,i|
                        head = @csv_heads[i]
                        if val != nil
                            val = val.strip
                            if head == "email"
                                val = val.downcase
                            end
                            if val.length > 0
                                if not head
                                    row_errs.push "Row #{row_i+1}, col #{i+1} has a value '#{val}' but no header"
                                end
                                new_obj[head] = val
                            end
                        end
                        if head == "email" and not new_obj["email"]
                            row_errs.push "Row #{row_i+1} has no email"
                        end
                    end
                    new_obj['src_row'] = row_i+1
                    new_obj['source_filename'] = @filename
                    new_objects.push new_obj
                end
        
                row_i += 1
            end
    
            new_emails = new_objects.map{|obj| obj["email"]}
    
            dupe_emails = new_emails.select{ |e| new_emails.count(e) > 1 }.uniq
    
            if dupe_emails.length > 0
                dupe_emails.each do |email|
                    rows = new_objects.select{|obj| obj['email'] == email}.map{|obj| obj['src_row']}
                    row_errs.push "Email addr '#{email}' appears more than once, on rows #{rows}. "
                end
            end
    
            dupe_mode = params[:dupe_mode]
    
            if not ['keep_new', 'throw_error'].include? dupe_mode
                raise "Bad dupe mode selected"
            end
    
            if dupe_mode == 'throw_error'
    
                already_present_emails = new_emails.select{|email| Contact.where("email = ?",email)[0] != nil }.uniq
    
                if already_present_emails.length > 0
                    already_present_emails.each do |email|
                        rows = new_objects.select{|obj| obj['email'] == email}.map{|obj| obj['src_row']}
                        row_errs.push "Email addr '#{email}' on row #{rows[0]} is already in the database. "
                    end
                end
            end
    
            if row_errs.length > 0
                err_str = row_errs.join "\n"
                @final_result = "The database was not updated.\nRow errors: \n#{err_str}"
                return
            end
        
        rescue => e
            @final_result = "The database was not updated.\nError preparing data to insert: \n#{e}"
            return
        end
        
        n_saved = 0
        begin
            Contact.transaction do
                new_objects.each do |obj|
            
                    contact = nil
                    if dupe_mode == 'keep_new'
                        contact = Contact.where("email = ?",obj['email'])[0]
                    end
                    if contact == nil
                        contact = Contact.new
                    end
                    obj.each_key do |key|
                        if key != 'src_row'
                            contact[key] = obj[key]
                        end
                    end
                
                    contact.save!
                    n_saved += 1
                end
            
                #raise ActiveRecord::Rollback
            end
                @final_result = "The database was updated: #{n_saved} rows were added/replaced. "
        rescue => e
            n_saved = 0
            @final_result = "The database was not updated.\nError updating the DB: #{e}"
        end
        
    end
    
end
