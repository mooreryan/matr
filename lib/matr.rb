require "matr/version"

module Matr
  def self.default_opt opts, key, default
    opts.has_key?(key) ? opts[key] : default
  end

  def self.main opts

    infile             = opts[:infile]
    self_score         = self.default_opt opts, :self_score, 100
    missing_score      = self.default_opt opts, :missing_score, 0
    output_style       = self.default_opt opts, :output_style, "wide"
    ensure_symmetry    = true # self.default_opt opts, :ensure_symmetry, true
    ensure_self_scores = self.default_opt opts, :ensure_self_scores, true

    unless File.exist? infile
      raise StandardError, "FATAL -- infile '#{infile}' does not exist"
    end

    unless output_style == "wide" || output_style == "long"
      raise StandardError, "FATAL -- output style must be either wide or long"
    end

    graph    = Hash.new { |ht, k| ht[k] = Hash.new }
    all_keys = Set.new
    header   = nil

    File.open(infile, "rt").each_line.with_index do |line, idx|
      line.chomp!

      if idx.zero?
        header = line
      else
        source, target, score = line.split "\t"

        all_keys << source << target

        # Fix self score if the option is there.
        if source == target && ensure_self_scores
          score = self_score
        end

        # If you have duplicates with different scores, that's an error: a
        # => b = 10 and a => b = 20
        if graph[source].has_key?(target) && graph[source][target] != score
          raise StandardError, "FATAL -- source--target (#{source}--#{target}) was repeated with a different score"
        end

        graph[source][target] = score

        if ensure_symmetry
          # Since you might have a files that specifies a => b = 10, and b
          # => a = 10, that would be okay.  But if you have a => b = 10, and
          # b => a = 5, then that would be an error.
          if graph[target].has_key?(source) && graph[target][source] != score
            raise StandardError, "FATAL -- target--source (#{target}--#{source}) is specified seperately from source--target (#{source}--#{target}), BUT their scores do not match.  This means your matrix is NOT symmetric.  Did you really mean to pass the --ensure-symmetry flag?"
          end

          graph[target][source] = score
        end

        # Makes sure these weren't already specified earlier.
        unless graph[target].has_key? target
          graph[target][target] = self_score
        end

        unless graph[source].has_key? source
          graph[source][source] = self_score
        end
      end
    end

    if output_style == "long"
      puts header

      all_keys.each do |source|
        all_keys.each do |target|
          puts [source, target, graph[source][target] || missing_score].join "\t"
        end
      end
    else
      all_keys = all_keys.sort

      puts ["", all_keys].join "\t"

      all_keys.each do |source|
        row = all_keys.map do |target|
          graph[source][target] || missing_score
        end

        puts [source, row].join "\t"
      end
    end
  end
end
