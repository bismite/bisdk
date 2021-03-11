
class Bi::Compile
  attr_reader :included_files, :line_count, :index, :code

  def initialize(mainfile,load_path=[])
    @mainfile = File.basename(mainfile)
    @load_path = [ File.dirname(mainfile) ] + load_path
    STDERR.puts "load path: #{@load_path.inspect}"
    @included_files = {}
    @index = []
    @line_count = 0
    @code = ""
  end

  def run
    read @mainfile
    @header = "begin\n"
    @code = @header + @code
    @code +=<<EOS
rescue => e
  _FILE_INDEX_ = #{@index.to_s}
  table = []
  _FILE_INDEX_.reverse_each{|i|
    filename = i[0]
    start_line = i[1]
    end_line = i[2]
    table.fill filename, (start_line..end_line)
  }

  STDERR.puts "\#{e.class}: \#{e.message}"
  #STDERR.puts e.backtrace.join("\\n")
  e.backtrace.each{|b|
    m = b.chomp.split(":")
    if m.size < 2
      puts b
    else
      line = m[1].to_i - #{@header.lines.size} -1
      message = m[2..-1].join(":")
      original_filename = table[line]
      original_line = table[0..line].count original_filename
      STDERR.puts "\#{original_filename}:\#{original_line}:\#{message}"
    end
  }
end
EOS

    if ENV['BI_COMPILE_DEBUG_OUTPUT_FILE']
      File.open(ENV['BI_COMPILE_DEBUG_OUTPUT_FILE'],"wb").write(@code)
    end
  end

  def write(line)
    @code << line + "\n"
    @line_count += 1
  end

  def memory(file)
    path = File.expand_path file
    return false if @included_files[path]
    @included_files[path] = true
  end

  def read(filename)
    filename = filename+".rb" unless filename.end_with? ".rb"

    filepath = nil
    @load_path.find{|l|
      f = File.join(l,filename)
      if File.exists? f
        filepath = f
        break
      end
    }

    if filepath
      # STDERR.puts "read #{filepath}"
    else
      STDERR.puts "#{filename} not found"
      return
    end

    unless memory filepath
      STDERR.puts "#{filepath} already included."
      return
    end

    source = File.read(filepath)

    syntax_error = Bi.check_syntax filepath,source
    if syntax_error
      STDERR.puts "check_syntax failed: #{filepath} #{syntax_error}"
      raise SyntaxError
    end

    s = source.split "\n"
    s << "# #{filepath}"
    start_line = @line_count
    s.each{|l|
      if l.start_with? "$LOAD_PATH"
        write "# #{l}"
      elsif l.start_with? "require"
        next_file = l.chomp
        next_file.slice! "require"
        next_file.gsub! '"', ''
        next_file.gsub! "'", ''
        next_file.gsub! ' ', ''
        write "# #{l}"
        self.read next_file
      else
        write l
      end
    }

    @index << [filename,start_line,@line_count-1]
  end

  def handle_error_log(error_log)
    p error_log
    table = []
    @index.reverse_each{|i|
      filename = i[0]
      start_line = i[1]
      end_line = i[2]
      table.fill filename, (start_line..end_line)
    }

    error_log.each_line{|l|
      m = l.chomp.split(":")
      if m.size < 2
        puts l
      else
        line = m[1].to_i - @header.lines.size - 1
        message = m[2..-1].join(":")
        original_filename = table[line]
        if original_filename
          original_line = table[0..line].count original_filename
          puts "#{original_filename}:#{original_line}:#{message}"
        else
          puts l
        end
      end
    }
  end
end

class Restorer
  def initialize
    tmp = []

    fileline = {}
    @index = tmp.each.with_index.map{|filename,i|
      fileline[filename] = fileline[filename].to_i + 1
      "#{filename}:#{fileline[filename]}"
    }
  end

  def restore(message)
    m = message.chomp.split(":")
    if m.size < 2
      print "#{message}"
    else
      line = m[1].to_i + 1
      text = m[2..-1].join(":")
      puts "#{@index[line]}:#{text}"
    end
  end
end


def run
  if ARGV == ["-h"] or ARGV == ["--help"] or ARGV.size < 1
    puts "Usage: birun [switches] source.rb [arguments]"
    puts "switches: -I/load/path"
    exit 1
  end
  index = ARGV.index{|a| ! a.start_with?("-") }
  args = ARGV[index..-1]
  switches = ARGV[0...index]
  load_path = switches.map{|s| s.start_with?("-I") ? s[2..-1] : nil }.compact

  infile = args.first
  compile = Bi::Compile.new infile, load_path
  begin
    compile.run
  rescue SyntaxError => e
    exit 1
  end

  result = Bi.run infile, compile.code, args
  if result
    STDERR.puts result
  end
end

def compile
  if ARGV == ["-h"] or ARGV == ["--help"] or ARGV.size < 2
    puts "Usage: bicompile [switches] source.rb out.mrb"
    puts "switches: -I/load/path"
    exit 1
  end
  index = ARGV.index{|a| ! a.start_with?("-") }
  args = ARGV[index..-1]
  switches = ARGV[0...index]
  load_path = switches.map{|s| s.start_with?("-I") ? s[2..-1] : nil }.compact

  infile = args.first
  outfile = args.last

  if not infile.end_with? ".rb" or not outfile.end_with? ".mrb"
    puts "Usage: bicompile [switches] source.rb out.mrb"
    exit 1
  end

  compile = Bi::Compile.new infile, load_path

  begin
    compile.run
  rescue SyntaxError => e
    exit 1
  end

  dir = File.dirname outfile
  dirs = dir.split File::SEPARATOR
  dirs.inject(""){|sum,d|
    new_dir = sum.empty? ? d : File.join(sum,d)
    Dir.mkdir new_dir unless Dir.exist? new_dir
    new_dir
  }

  error_message = Bi.compile( infile, compile.code, outfile )
  if error_message
    STDERR.puts "compile failed..."
    STDERR.puts error_message
    exit 1
  end

end
