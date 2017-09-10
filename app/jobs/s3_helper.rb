require 'aws-sdk'

class S3Helper

  def initialize(bucket_name)
    if !defined?(bucket_name)
      raise "S3 Bucket name ENV variable does not exist!"
    end
    @bucket_name = ENV[bucket_name]

    @s3 = Aws::S3::Resource.new(
        region: 'us-east-1',
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY']
    )
  end

  def upload_to_s3(filename, download_file_name, path_to_file)
    obj = @s3.bucket(@bucket_name).object(filename)
    options = {
      :content_type => "text/csv",
      :content_disposition => "attachment; filename=\"#{download_file_name}\""
    }
    obj.upload_file(path_to_file, options)
  end

  def retrieve_s3_obj_url(obj_name)
    obj = @s3.bucket(@bucket_name).object(obj_name)
    if obj.exists?
      return obj.presigned_url(:get, :expires_in => 60 * 3)
    end
    return nil
  end

end
