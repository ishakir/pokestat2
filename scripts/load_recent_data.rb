require 'nokogiri'
require 'open-uri'

SMOGON_BASE_URL = "http://www.smogon.com/stats"

def grab_all_files
	files = Hash.new

	page = Nokogiri::HTML(open(SMOGON_BASE_URL))
	page.css('a').select {|link| link.text != "../"}.each do |link|
		files_for_year_month = Set.new
		page2 = Nokogiri::HTML(open("#{SMOGON_BASE_URL}/#{link.text}"))
		all_links = page2.css('a').select {|link| link.text.end_with?(".txt")}
		if all_links.size > 20
			all_links.each do |link2|
				files_for_year_month.add("#{link2.text}")
			end
			files[link.text] = files_for_year_month.sort
		end
	end

	Hash[files.sort]
end

def newest_generation(filenames)
	gens = SortedSet.new

	filenames.each do |filename|
		if /\Agen\d/ =~ filename
			gens.add(filename[3].to_i)
		end
	end

	gens.max + 1
end

def parse_filename(yearmonth, fname, default_gen)
	year, month = yearmonth.gsub("/", "").split("-").map { |num| num.to_i }

	if /\Agen\d/ =~ fname
		generation = fname[3].to_i
		remaining_filename = fname.slice(4, fname.length)
	else
		generation = default_gen
		remaining_filename = fname
	end

	tier, min_rank = remaining_filename.gsub(".txt", "").split("-")

	[year, month, generation, tier, min_rank.to_i]
end

# Cache the sources we currently have
Rails.logger.info("Fetching sources from the database")
sources = Set.new(Source.all.map do |source|
	source.filename
end)

# Grab the list of filenames from the smogon site
Rails.logger.info("Fetching data files from smogon")
files = grab_all_files()

# Calculate the newest generation for that yearmonth
latest_generation = files.map { |ym, filenames| [ym, newest_generation(filenames)]}.to_h

# Filter the files we have down to the ones we haven't loaded
filtered_to_filenames = files.map do |ym, filenames|
	unloaded_files = filenames.select { |filename| !sources.include?("#{ym}#{filename}") }
	[ym, unloaded_files]
end.to_h
filtered_yearmonth = filtered_to_filenames.select { |ym, filenames| !filenames.empty? }

Rails.logger.info("Found the following files to load")
filtered_yearmonth.each do |ym, filenames|
	filenames.each do |fname|
		Rails.logger.info("#{ym}#{fname}")
	end
end

filtered_yearmonth.each do |ym, filenames|
	Rails.logger.info("Inserting files for #{ym}")
	filenames.each do |fname|
		full_path = "#{ym}#{fname}"
		Rails.logger.info("Inserting #{full_path}")
		year, month, generation, tier, min_rank = parse_filename(ym, fname, latest_generation[ym])
		source = Source.new(filename: full_path, year: year, month: month, generation: generation, tier: tier, min_rank: min_rank)

		# Grab the data from the smogon site
		page = Nokogiri::HTML(open("#{SMOGON_BASE_URL}/#{full_path}"))
		data = page.text.split("\n")

		actual_lines = data[5..-2]

		if actual_lines.nil?
			Rails.logger.info("No data in #{full_path}")
		else
			usages = actual_lines.map do |line|
				split = line.split("|").map { |dp| dp.strip }

				pokemon = split[2]
				usage_pct = split[3].gsub("%", "").to_f
				raw = split[4].to_i
				raw_pct = split[5].gsub("%", "").to_f
				real = split[6].to_i
				real_pct = split[7].gsub("%", "").to_f

				Usage.new(source: source, pokemon: pokemon, usage_pct: usage_pct, raw: raw, raw_pct: raw_pct, real: real, real_pct: real_pct)
			end

			# And upload!
			ActiveRecord::Base.transaction do
			    source.save!
			    usages.each {|usage| usage.save!}
	  		end
	  	end
	end
end
# files_to_load.each do |fname|
# 	# Parse bits of info out of the filename
# 	year = 
# 	month = 
# 	generation = 
# 	tier = 
# 	min_rank = 

# 	# Create the source


# 	# Grab the file from the URL, should get back pipe separated or whatever
# 	# Use csv library to drop headers etc...
# 	csv_lines.map do |line|
# 		# Convert to activerecord object / sql statement
# 		line = 
# 	end

# 	# Create transaction and create source, followed by batch insert of all usages

# end	