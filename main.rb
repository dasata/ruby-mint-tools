require_relative 'category'
require 'csv'
require 'getoptlong'

categories = Hash.new
x = 0
amount = 0.0
input_filepath = nil
output_filepath = nil
output = nil

options = GetoptLong.new(
  ['--help', '-h', GetoptLong::NO_ARGUMENT],
  ['--input', '-i', GetoptLong::REQUIRED_ARGUMENT],
  ['--output', '-o', GetoptLong::OPTIONAL_ARGUMENT] 
)

options.each do |opt, arg|
  case opt
    when '--help'
      puts <<-EOF
main.rb -i filepath  [-o filepath]

--input filepath, -i filepath
  File path of the file containing transactions for use as input for this script
  
  The file should be the in the format
    Date
    Description
    Amount
    Transaction Type
    Category

--output_file filepath, -o filepath
  File path of where the output of the script should be written to
    EOF
    
    exit 0
    when '--input'
      input_filepath = arg
    when '--output'
      output_filepath = arg
  end
end

if input_filepath.nil? 
  puts 'Missing input filepath. Try the --help option for more details.'
elsif not File.exist?(input_filepath)
  puts 'Input file does not exist. Cannot generate a report without it!'
else
  all_arguments_specified = true
end

if not all_arguments_specified
  exit 0
end

CSV.foreach(input_filepath, {:headers=>true}) do |row|
  amount = row['Amount'].to_f.round(2)
  name = row['Category']
  date = Date.strptime(row['Date'], '%m/%d/%Y')
  c = nil

  if row['Transation Type'] == 'credit'
    amount *= -1
  end
  
  if categories.has_key?(name)
    c = categories[name]
  else
    c = Category.new(name)
    categories[name] = c;
  end

  c.add_amount(date.year, date.month, amount)
end

unless output_filepath
  output = $stdout
else
  output = File.open(output_filepath, 'w')
end

output.printf("%20s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\t%10s\n", "category", "min", "max", "mean", "median", "stdev", "25pctl", "75pctl")
20.times { |i| output.print '-' }
output.print "\t"
7.times do |i|
  10.times do |j|
    output.print '-'
  end
  output.print "\t" 
end
output.print "\n"

categories.sort_by { |key, value| key}.each do |key, value|
  ar = value.summary_array

  output.printf("%20.20s\t", key)
  ar.each do |el|
    output.printf("%10.2f\t", el)
  end

  output.print "\n"
end

unless output.tty?
  output.close
end
