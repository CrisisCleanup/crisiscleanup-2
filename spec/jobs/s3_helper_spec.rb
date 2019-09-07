require 'rails_helper'

RSpec.describe CsvGeneratorJob do
  
  describe "#upload_to_s3" do
    it "no bucket name" do
      Aws::S3::Resource.stub(:new)
      expect {
        S3Helper.new(nil)
      }.to raise_error
    end    
    
    it "initializes" do
      # allow_any_instance_of().to receive(:new).and_return(nil)
      Aws::S3::Resource.stub(:new)
      S3Helper.new('test_bucket')
    end
  end
  
  describe "#retrieve_s3_obj_url" do
    
    it "retrieve_s3_obj_url" do
      # allow_any_instance_of().to receive(:new).and_return(nil)
      dbl = double('s3')
      s3_helper = S3Helper.new('test_bucket')
      bucket_dbl = double('bucket_double')
      allow(bucket_dbl).to receive(:object).and_return(double('obj_double'))
      allow(dbl).to receive(:bucket).and_return(bucket_double)
      s3_helper.s3 = dbl
      s3_helper.retrieve_s3_obj_url('somefile')
    end
  end  
end
