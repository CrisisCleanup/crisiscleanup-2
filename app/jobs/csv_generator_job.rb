require 'aws-sdk'

class CsvGeneratorJob < ApplicationJob
  queue_as :default

  def perform(generator_type, file_prefix, download_file_name, bucket_name, *args)
    path = "/tmp/#{file_prefix}-#{self.job_id}.csv"
    file_basename = File.basename(path)
    begin
      File.open(path, "w+") do |f|
        case generator_type
          when "generate_sites"
            generate_sites_csv(args[0]).each {|element| f.puts(element)}
        end
      end
    rescue Exception => e
      logger.error("Could not generate #{file_basename}")
      Sidekiq::Logging.logger.error("Could not generate #{file_basename}")
      Sidekiq::Logging.logger.error(e.message)
    end

    begin
      S3Helper.new(bucket_name).upload_to_s3(file_basename, download_file_name, path)
    rescue
      logger.error("Could not upload #{file_basename} to S3!")
      Sidekiq::Logging.logger.error("Could not upload #{file_basename} to S3!")
    ensure
      if File.file?(path)
        File.delete(path)
      end
    end

  end

  private

  def generate_sites_csv(legacy_event_id)
    Enumerator.new do |y|
      y << Legacy::LegacySite.csv_header.to_s

      Legacy::LegacySite.find_in_batches({legacy_event_id: legacy_event_id}, 300) {|site| y << site.to_csv_row.to_s}
    end
  end
end
