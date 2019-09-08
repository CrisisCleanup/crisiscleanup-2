require 'rails_helper'
require 'spec_helper'

RSpec.describe Form, type: :model do
  
    describe "associations" do
      it { should belong_to :legacy_event }
    end
    
    describe "stuff" do
      
      it "default_html" do
        allow_any_instance_of(File).to receive(:open)
        Form.default_html
      end
      
      it "default_form_html" do
        allow_any_instance_of(File).to receive(:open)
        f = Form.new
        f.default_form_html
      end
      
    end

end