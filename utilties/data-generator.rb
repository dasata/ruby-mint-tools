require 'date'
require 'getoptlong'
require 'json'

=begin
  input start and end month/year 
  input list of categoies
  input min and max limits per category
  generate a csv containing: 
    category
    month/year
    amount
=end

options = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--config', '-c', GetoptLong::REQUIRED_ARGUMENT],
  ['--output', '-o', GetoptLong::REQUIRED_ARGUMENT]
)


config_filepath = nil
output_filepath = nil
all_arguments_specified = false
start_date = nil
end_date = nil
categories = []

options.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
data-generator.rb -c filepath  -o filepath

--config filepath, -c filepath
  File path of the configuration file used as input for this script
  
  The file should be the in the format
    Start Date
    End Date
    Category, TransactionsPerMonth, Min, Max // 1 or more entries

--output_file filepath, -o filepath
  File path of where the output of the script should be written to
    EOF
    
    exit 0
    when '--config'
      config_filepath = arg
    when '--output'
      output_filepath = arg
  end
end

if config_filepath.nil? 
  puts 'Missing config filepath. Try the --help option for more details.'
elsif not File.exist?(config_filepath)
  puts 'Config file does not exist. Cannot generate data without it!'
elsif output_filepath.nil?
  puts 'Missing output filepath. Try the --help option for more details.'
else
  all_arguments_specified = true
end

if not all_arguments_specified
  exit 0
end

File.open(config_filepath) do |input_file|
  config = JSON.parse(input_file.readlines.join)
  start_date = Date.strptime(config['start_date'], '%m/%d/%Y')
  end_date = Date.strptime(config['end_date'], '%m/%d/%Y')
  #input_file.each_line do |line|
  config['categories'].each do |cat|
    #categories.push(line.split(',').each { |item| item.strip! }) 
    categories.push(cat)
  end
end

File.open(output_filepath, 'w') do |output_file|
  current_month = 0
  num_transactions = 1
  
  output_file.puts '"Date","Description","Amount","Transaction Type","Category"'

  categories.each do |cat|
    #monthly_limit = cat[1].to_i
    monthly_limit = cat['monthly_transactions']

    for d in (start_date..end_date)
      if d.month != current_month 
        current_month = d.month
        num_transactions = 1
      elsif num_transactions >= monthly_limit
        next
      else
        num_transactions += 1
      end 
      
      #amount = rand(cat[2].to_i..cat[3].to_i)
      amount = rand(cat['min_amount']..cat['max_amount'])
      type = amount >= 0 ? 'debit' : 'credit' 
      #output_file.puts sprintf('"%s","%s","%2g","%s","%s"', d.strftime('%m/%d/%Y'), cat[0], amount, type, cat[0]) 
      output_file.puts sprintf('"%s","%s","%2g","%s","%s"', d.strftime('%m/%d/%Y'), cat['category'], amount, type, cat['category']) 
    end
  end
end

