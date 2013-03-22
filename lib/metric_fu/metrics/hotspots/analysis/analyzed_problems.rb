module MetricFu
  class HotspotAnalyzedProblems


    def initialize(hotspot_rankings)
      @hotspot_rankings = hotspot_rankings
    end
    def worst_items
      num = nil
      worst_items = {}
      worst_items[:files] =
        @hotspot_rankings.worst_files(num).inject([]) do |array, worst_file|
        array <<
          {:location => self.location(:file, worst_file),
          :details => self.problems_with(:file, worst_file)}
        array
      end
      worst_items[:classes] = @hotspot_rankings.worst_classes(num).inject([]) do |array, class_name|
        location = self.location(:class, class_name)
        array <<
          {:location => location,
          :details => self.problems_with(:class, class_name)}
        array
      end
      worst_items[:methods] = @analyzed_rankings.worst_methods(num).inject([]) do |array, method_name|
        location = self.location(:method, method_name)
        array <<
          {:location => location,
          :details => self.problems_with(:method, method_name)}
        array
      end
    end
    private
    #todo redo as item,value, options = {}
    # Note that the other option for 'details' is :detailed (this isn't
    # at all clear from this method itself
    def problems_with(item, value, details = :summary, exclude_details = [])
      sub_table = get_sub_table(item, value)
      #grouping = Ruport::Data::Grouping.new(sub_table, :by => 'metric')
      grouping = get_grouping(sub_table, :by => 'metric')
      MetricFu::HotspotProblems.new(grouping, details, exclude_details).problems
    end
    def location(item, value)
      sub_table = get_sub_table(item, value)
      if(sub_table.length==0)
        raise MetricFu::AnalysisError, "The #{item.to_s} '#{value.to_s}' does not have any rows in the analysis table"
      else
        first_row = sub_table[0]
        case item
        when :class
          MetricFu::Location.get(first_row.file_path, first_row.class_name, nil)
        when :method
          MetricFu::Location.get(first_row.file_path, first_row.class_name, first_row.method_name)
        when :file
          MetricFu::Location.get(first_row.file_path, nil, nil)
        else
          raise ArgumentError, "Item must be :class, :method, or :file"
        end
      end
    end
    def get_sub_table(item, value)
      @hotspot_rankings.tables.fetch(item) do
        raise ArgumentError, "Item must be :class, :method, or :file"
      end
      tables[value]
    end
    def get_grouping(table, opts)
      MetricFu::HotspotGroupings.new(table, opts)
    end
  end
end
