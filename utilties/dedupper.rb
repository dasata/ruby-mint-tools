class Dedupper
  def initialize
    @keys = Hash.new
  end

  def has_key?(key)
    return @keys.has_key?(key)
  end

  def add_key(key, record_count)
    @keys[key] = { "record_count" => record_count, "num_seen" => 0 }
  end

  def increment_record_count(key)
    @keys[key]['record_count'] += 1
  end

  def increment_seen(key)
    @keys[key]['num_seen'] += 1
  end

  def should_add_record?(key)
    counters = @keys[key]
    return counters['record_count'] < counters['num_seen']
  end
end
