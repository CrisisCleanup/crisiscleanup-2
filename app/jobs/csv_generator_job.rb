require 'aws-sdk'

class CsvGeneratorJob < ActiveJob::Base
  queue_as :default

  def perform(generator_type, file_prefix, download_file_name, bucket_name, *args)
    path = "/tmp/#{file_prefix}-#{self.job_id}.csv"
    file_basename = File.basename(path)
    begin
      File.open(path, "w+") do |f|
        case generator_type
          when "generate_sites"
            generate_sites_csv(args[0], args[1]).each {|element| f.puts(element)}
        end
      end
    rescue
      logger.error("Could not generate #{file_basename}")
    end

    begin
      S3Helper.new(bucket_name).upload_to_s3(file_basename, download_file_name, path)
    rescue
      logger.error("Could not upload #{file_basename} to S3!")
    ensure
      if File.file?(path)
        File.delete(path)
      end
    end

  end

  private

  def generate_sites_csv(legacy_event_id, org_id)
    Enumerator.new do |y|
      y << Legacy::LegacySite.csv_header.to_s

      Legacy::LegacySite.find_in_batches_claimed_reported(["legacy_event_id = ? AND (claimed_by = ? OR reported_by = ?)", legacy_event_id, org_id, org_id], 300) {
          |site| y << site.to_csv_row.to_s
      }

      Legacy::LegacySite.find_in_batches_claimed_reported(["(legacy_event_id = ?) AND ((NOT claimed_by = ?) OR (NOT reported_by = ?))", legacy_event_id, org_id, org_id], 300) {
          |site| y << site.redacted_to_csv_row.to_s
      }

    end
  end
end
