require 'statsample'

class Category
  @name
  @amounts
  @min_key
  @max_key
  
  def initialize(name)
   @name = name
   @amounts = Hash.new
   @min_key = nil
   @max_key = nil
  end

  def name
    return @name
  end

  def min
    return @amounts[@min_key]
  end
  
  def max
    return @amounts[@max_key]
  end

  def add_amount(year, month, amount)
    key = _build_key(year, month)

    if @amounts.has_key?(key)
      new_amount = @amounts[key] += amount
    else
      new_amount = @amounts[key] = amount
    end

    _determine_minmax()
  end

  def get_amount(year, month)
    key = _build_key(year, month)

    if @amounts.has_key?(key)
      return @amounts[key]
    else 
      return nil
    end
  end

  def to_s
    puts @name
    @amounts.sort_by {|key, value| key}.each do |key, value|
      puts "  #{key}: #{value.round(2)}"
    end
  end

  def print_min
    Kernel.sprintf("min of $%.2f at #{@min_key}", min)
  end
 
  def print_max
    Kernel.sprintf("max of $%.2f at #{@max_key}", max)
  end

  def print_stats
    v = @amounts.values.to_scale()
    puts "mean: #{v.mean}"
    puts "median: #{v.median}"
    puts "stdev: #{v.sdp}"
    puts "25pct: #{v.percentil(25)}"
    puts "75pct: #{v.percentil(75)}"
  end

  def summary_array
    v = @amounts.values.to_scale()
    return [v.min, v.max, v.mean, v.median, v.sdp, v.percentil(25), v.percentil(75)]
  end
  
  # start the private stuff here
  private 

  def _build_key(year, month)
    return "#{year}-#{sprintf('%02d', month)}"
  end

  def _determine_minmax()
    minmax = @amounts.minmax_by { |key, value| value }
    @min_key = minmax[0][0]
    @max_key = minmax[1][0]
  end
end
