class TxtDictionary
  def initialize(desc)
    @desc = desc
    @data = []
  end

  def add(key, trn)
    @data << [key, trn]
  end

  def extract_to_dir(dir_name)
    file = dir_name + "/" + desc_to_filename + ".txt"
    if (File.exist?(file))
      $stderr.puts "WARNING: file already exists (will overwrite): '#{file}'"
      # exit
    end
    print_out(file)
  end

  def print_out(out_name)
    $stderr.puts "Creating file: #{out_name}"
    out = File.open(out_name, 'w')
    out.puts "#description #{@desc}"
    out.puts ""
    @data.each { |line|
      out.puts "#{line[0]}:#{line[1]}"
    }
  end

  def desc_to_filename
    Russian::Transliteration.transliterate(@desc.gsub('"', '').gsub(/[\s\\\/\*\?"\|<>#:]+/, '_'))
  end
end
