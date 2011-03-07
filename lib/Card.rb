class Card
  attr_accessor :headword, :entries
  def initialize(headword)
    @headword = headword
    @entries = {}
  end
  def <=> (other)
    @headword <=> other.headword
  end
  def parse_from_dsl(line)
    trn = /\[trn\](.*?)\[\/trn\]/.match(line)[1]
    line.scan(/\{\{desc\}\}(.*?)\{\{\/desc\}\}/) { |desc|
      add(trn, desc[0])
    }
  end
  def add(value, desc)
    descs = (@entries[value] ||= [])
    descs << desc unless descs.include?(desc)
  end
  def print_out(out)
    out.puts @headword
    @entries.keys.sort.each { |k|
      out.print "\t[m1]"
      if ($separator && @entries.size > 1)
        out.print "#{$separator} "
      end
      initial_descr_dot = if (@entries[k] && @entries[k].size > 1)
        "[m2]#{$DESC_DOT}"
      else
        "[m2]"
      end
      
      out.puts "[trn]#{k}[/trn] [c darkgray]#{initial_descr_dot} #{@entries[k].uniq.sort.collect{|e| '{{desc}}' + e.to_s + '{{/desc}}'}.join(' [m2]' + $DESC_DOT + ' ')}[/c][/m]"
    }
  end
end
