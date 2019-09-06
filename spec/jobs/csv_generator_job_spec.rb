require 'rails_helper'

RSpec.describe CsvGeneratorJob, type: :job do
  
  describe "CSV generator - perform" do
    it "enqueues a job" do
      ActiveJob::Base.queue_adapter = :test
      expect {
        CsvGeneratorJob.perform_later('generate_sites', 'TEST', 'somefile', 'test-bucket')
      }.to have_enqueued_job
    end
    
    let(:csv_doc) { IO.read(Rails.root.join("spec", "fixtures", "test.csv")) }
    it "performs basic execution with params" do
      allow_any_instance_of(CsvGeneratorJob).to receive(:generate_sites_csv).and_return(nil)
      allow_any_instance_of(CsvGeneratorJob).to receive(:job_id).and_return('632b7c50')
      expected_file_basename = 'TEST-632b7c50.csv'
      expected_path = '/tmp/TEST-632b7c50.csv'
      allow_any_instance_of(S3Helper).to(
        receive(:upload_to_s3).with(expected_file_basename, 'somefile.txt', expected_path).and_return(nil)
      )
      CsvGeneratorJob.perform_now('generate_sites', 'TEST', 'somefile.txt', 'test-bucket')
    end
    
    it "will catch S3Helper exception" do
      allow_any_instance_of(CsvGeneratorJob).to receive(:generate_sites_csv).and_return(nil)
      allow_any_instance_of(CsvGeneratorJob).to receive(:job_id).and_return('632b7c50')
      expected_file_basename = 'TEST-632b7c50.csv'
      expected_path = '/tmp/TEST-632b7c50.csv'
      allow_any_instance_of(S3Helper).to(
        receive(:upload_to_s3).with(expected_file_basename, 'somefile.txt', expected_path).and_raise('No S3 upload')
      )
      CsvGeneratorJob.perform_now('generate_sites', 'TEST', 'somefile.txt', 'test-bucket')
    end   
  end
  
  describe "generate_sites_csv" do
    before do |example|
      FactoryGirl.create :legacy_event 
    end
    
    it "basic" do
      ActiveJob::Base.queue_adapter = :test
      event = Legacy::LegacyEvent.first
	 		org = FactoryGirl.create :legacy_organization 
		 	site1 = FactoryGirl.create :legacy_site, reported_by: org.id, name: 'John Doe'
		 	
	    site1.claimed_by = org.id
      cgj = CsvGeneratorJob.new
      
      csv_store = []
      cgj.generate_sites_csv(event.id, org.id).each { |element| csv_store << element }
    end
  end
end
