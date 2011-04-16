require 'optparse'
require 'fileutils'

require File.expand_path('../lib/Dictionary', __FILE__)
require File.expand_path('../lib/Card', __FILE__)
require File.expand_path('../lib/TxtDictionary', __FILE__)

$IN = ""
$OUT = ""

$separotor = nil
opts = OptionParser.new
opts.on("-i FILE", "--in FILE", "input DSL file to convert", String) {|val| $IN = val }
opts.on("-o DIR", "--out DIR", "directory to extract txt files", String) { |val|
  if ($OUT.empty?)
    $OUT = val
  else
    $stderr.puts "Error: output directory can be defined only once!\n\n"
    $stderr.puts opts
    exit
  end
}
opts.on_tail("-h", "--help", "Show this message") do
  $stderr.puts opts
  exit
end
rest = opts.parse(ARGV)

if ($IN.size == 0 || $OUT.size == 0)
  $stderr.puts opts
  exit
end

if File.exist?($OUT)
  $stderr.puts "WARNING: Output directory already exists: '#{$OUT}'"
  # exit
else
  $stderr.puts "Creating output directory: '#{$OUT}'"
  Dir.mkdir($OUT)
end

# load the DSL dictionary
d = nil
File.open($IN, 'rb') { |f|
  d = Dictionary.load_from_dsl(f)
}

d.get_txt_dicts.each { |dict|
  # dict.print_out("CON")
  dict.extract_to_dir($OUT)
}
