class Dictionary
  attr_accessor :name, :index_lang, :content_lang
  def initialize
    self.name = name
    self.index_lang = index_lang
    self.content_lang = content_lang
    @cards = {}
  end
  def add(key, value, desc)
    key.strip!
    value.strip!
    desc.strip!
    if desc.empty?
      $stderr.puts "ERROR: empty/missing dictionary description"
      exit
    end
    (@cards[key] ||= Card.new(key)).add(value, desc)
  end
  def add_card(card)
    if @cards[card.headword]
      $stderr.puts "such card already exists: #{card.inspect}"
      exit
    else
      @cards[card.headword] = card
    end
  end
  def self.load_from_dsl(file)
    d = Dictionary.new
    if (file.gets =~ /^(?:\xEF\xBB\xBF)?#NAME\s*"(.*)"\s*$/)
      d.name = $1
    else
      $stderr.puts "\#NAME is not the first line in the DSL file"
      exit
    end

    if (file.gets =~ /^#INDEX_LANGUAGE\s*"(.*)"\s*$/)
      d.index_lang = $1
    else
      $stderr.puts "\#INDEX_LANGUAGE is not the second line in the DSL file"
      exit
    end

    if (file.gets =~ /^#CONTENTS_LANGUAGE\s*"(.*)"\s*$/)
      d.content_lang = $1
    else
      $stderr.puts "\#CONTENTS_LANGUAGE is not the third line in the DSL file"
      exit
    end

    card = nil
    while (line = file.gets)
      next if line.strip.empty?
      line.rstrip!
      if (line =~ /^(\S.*)$/) # headword
        card = Card.new($1)
        d.add_card(card)
      elsif (line =~ /^\s/) # card body
        card.parse_from_dsl(line)
      else
        $stderr.puts "Wrong line: #{line}"
        exit
      end
    end
    d
  end
  def check_valid
    if name && index_lang && content_lang
      # everything's fine
    else
      $stderr.puts "Required Dictionary Info is missing"
      exit
    end
  end
  def print_out(out_name)
    check_valid
    
    out = File.open(out_name, 'w')

    # Dictionary Header
    out.print "\xEF\xBB\xBF"
    out.puts "\#NAME \"#{name}\""
    out.puts "\#INDEX_LANGUAGE \"#{index_lang}\""
    out.puts "\#CONTENTS_LANGUAGE \"#{content_lang}\""
    
    @cards.values.sort.each { |card|
      card.print_out(out)
    }

    out.close
    $stderr.puts "File #{out_name} written...."
    $stderr.puts "Total number of headwords: #{@cards.size}"
  end
end
