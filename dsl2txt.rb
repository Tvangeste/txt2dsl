# TODO:
# 1. check for key, value, desc validity
# 2. check for empty cards

require 'optparse'
require 'fileutils'

require File.expand_path('../lib/Dictionary', __FILE__)
require File.expand_path('../lib/Card', __FILE__)
require File.expand_path('../lib/TxtDictionary', __FILE__)

$IN = ""
$OUT = ""
$DOT = "*"
$DESC_DOT = "-"

$separotor = nil
opts = OptionParser.new
opts.on("-i FILE", "--in FILE", "input file to convert", String) {|val| $IN = val }
opts.on("-o DIR", "--out DIR", "directory to extract txt files", String) { |val|
  if ($OUT.empty?)
    $OUT = val
  else
    $stderr.puts "Error: output file can be defined only once!\n\n"
    $stderr.puts opts
    exit
  end
}
opts.on("-s", "start each line with a separator") { $separator = $DOT }
opts.on_tail("-h", "--help", "Show this message") do
  $stderr.puts opts
  exit
end
rest = opts.parse(ARGV)

if ($IN.size == 0 || $OUT.size == 0)
  $stderr.puts opts
  exit
end

# load the DSL dictionary
d = nil
File.open($IN, 'rb') { |f|
  d = Dictionary.load_from_dsl(f)
}

if File.exist?($OUT)
  $stderr.puts "ERROR: Output directory already exist: '#{$OUT}'"
  # TODO: must be enabled
  # exit
  
  # back = $OUT + ".bak"
  # FileUtils.copy($OUT, back)
  # $stderr.puts "Made backup copy: #{back}"
  # File.open($OUT, 'rb') { |f|
  #  d = Dictionary.load_from_dsl(f)
  #}
else
  $stderr.puts "Creating output directory: '#{$OUT}'"
  Dir.mkdir($OUT)
end

[].each { |file_name|
  desc = ""
  File.foreach(file_name) { |line|
    if line =~ /^(?:\xEF\xBB\xBF)?#\s*[Dd]escription\s*(.*)$/
      desc = $1.strip
    elsif line =~ /^\s*$/
      # ignore
    elsif line =~ /^(.*?):(.*)$/
      key, value = $1, $2
      d.add(key, value, desc)
    end
  }
}

d.get_txt_dicts.each { |dict|
  dict.print_out("CON")
  dict.extract_to_dir($OUT)
}

