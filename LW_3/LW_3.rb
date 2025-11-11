# frozen_string_literal: true

require 'find'
require 'digest'
require 'json'

class DuplicateScanner
  def initialize(root_dir)
    @root_dir = root_dir
    @files_by_size = {}
    @duplicates = {
      scanned_files: 0,
      groups: []
    }
  end

  def scan
    collect_files
    find_duplicates
    generate_report
  end

  private

  def collect_files
    Find.find(@root_dir) do |path|
      next if File.directory?(path)

      @duplicates[:scanned_files] += 1
      size = File.size(path)

      (@files_by_size[size] ||= []) << path
    end
  end

  def find_duplicates
    @files_by_size.each do |size, files|
      next if files.length < 2

      files_by_hash = {}
      files.each do |file_path|
        hash = calculate_hash(file_path)
        (files_by_hash[hash] ||= []) << file_path
      end

      files_by_hash.each do |_, dup_files|
        next if dup_files.length < 2

        @duplicates[:groups] << {
          size_bytes: size,
          saved_if_dedup_bytes: size * (dup_files.length - 1),
          files: dup_files
        }
      end
    end
  end

  def calculate_hash(file_path)
    Digest::SHA256.file(file_path).hexdigest
  rescue StandardError => e
    puts "Could not calculate hash for #{file_path}: #{e.message}"
    nil
  end

  def generate_report
    File.write('duplicates.json', JSON.pretty_generate(@duplicates))
    puts "Scan complete. Found #{@duplicates[:groups].length} duplicate groups."
    puts "Report saved to duplicates.json"
  end
end

if ARGV.empty?
  puts "Usage: ruby LW_3.rb <directory_to_scan>"
  exit
end

target_directory = ARGV[0]

unless File.directory?(target_directory)
  puts "Error: '#{target_directory}' is not a valid directory."
  exit
end

puts "Starting scan in '#{target_directory}'..."
scanner = DuplicateScanner.new(target_directory)
scanner.scan
