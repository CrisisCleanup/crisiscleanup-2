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
      Aws::S3::Resource.stub(:new)
      S3Helper.new('test_bucket')
    end
  end
  
  describe "#retrieve_s3_obj_url" do
    
    it "retrieve_s3_obj_url" do
      dbl = double('s3')
      s3_helper = S3Helper.new('test_bucket')
      bucket_dbl = double('bucket_dbl')
      obj_dbl = double('obj_dbl')
      allow(obj_dbl).to receive(:exists?).and_return(true)
      allow(obj_dbl).to receive(:presigned_url).and_return(true)
      allow(bucket_dbl).to receive(:object).and_return(obj_dbl)
      allow(dbl).to receive(:bucket).and_return(bucket_dbl)
      s3_helper.s3 = dbl
      s3_helper.retrieve_s3_obj_url('somefile')
    end
    
    it "upload_to_s3" do
      dbl = double('s3_dbl')
      s3_helper = S3Helper.new('test_bucket')
      bucket_dbl = double('bucket_dbl')
      obj_dbl = double('obj_dbl')
      allow(obj_dbl).to receive(:upload_file)
      allow(bucket_dbl).to receive(:object).and_return(obj_dbl)
      allow(dbl).to receive(:bucket).and_return(bucket_dbl)
      s3_helper.s3 = dbl
      s3_helper.upload_to_s3('filename.txt', 'downloadfilename.txt', 'path/to')
    end    
  end  
end
