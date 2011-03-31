
class Cassandra
  # Inner methods for actually doing the Thrift calls
  module Protocol #:nodoc:
    private

    def _mutate(mutation_map, consistency_level)
      client.batch_mutate(mutation_map, consistency_level)
    end

    def _remove(key, column_path, timestamp, consistency_level)
      client.remove(key, column_path, timestamp, consistency_level)
    end

    def _add(column_family, key, column, sub_column, value, consistency)
      if is_super(column_family)
        column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family, :super_column => column)
        counter_column = CassandraThrift::CounterColumn.new(:name => sub_column, :value => value)
      else
        column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family)
        counter_column = CassandraThrift::CounterColumn.new(:name => column, :value => value)
      end
      client.add(key, column_parent, counter_column, consistency)
    end

    def _get_counter(column_family, key, column, sub_column, consistency)
      args = {:column_family => column_family}
      columns = is_super(column_family) ? {:super_column => column, :column => sub_column} : {:column => column}
      column_path = CassandraThrift::ColumnPath.new(args.merge(columns))

      begin
        result = client.get_counter(key, column_path, consistency)
        return result.column.value
      rescue CassandraThrift::NotFoundException
        return 0
      end
    end

    def _get_counter_slice(column_family, key, column, start, finish, consistency)
      if is_super(column_family)
        column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family, :super_column => column)
      else
        column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family)
      end

      slice_pred = CassandraThrift::SlicePredicate.new(:slice_range => CassandraThrift::SliceRange.new(:start => start, :finish => finish))
      client.get_counter_slice(key, column_parent, slice_pred, consistency)
    end

    def _count_columns(column_family, key, super_column, consistency)
      client.get_count(key,
        CassandraThrift::ColumnParent.new(:column_family => column_family, :super_column => super_column),
        CassandraThrift::SlicePredicate.new(:slice_range => CassandraThrift::SliceRange.new(:start => '', :finish => '')),
        consistency
      )
    end

    def _get_columns(column_family, key, columns, sub_columns, consistency)
      result = if is_super(column_family)
        if sub_columns
          columns_to_hash(column_family, client.get_slice(key,
            CassandraThrift::ColumnParent.new(:column_family => column_family, :super_column => columns),
            CassandraThrift::SlicePredicate.new(:column_names => sub_columns),
            consistency))
        else
          columns_to_hash(column_family, client.get_slice(key,
            CassandraThrift::ColumnParent.new(:column_family => column_family),
            CassandraThrift::SlicePredicate.new(:column_names => columns),
            consistency))
        end
      else
        columns_to_hash(column_family, client.get_slice(key,
          CassandraThrift::ColumnParent.new(:column_family => column_family),
          CassandraThrift::SlicePredicate.new(:column_names => columns),
          consistency))
      end

      klass = column_name_class(column_family)
      (sub_columns || columns).map { |name| result[klass.new(name)] }
    end

    def _multiget(column_family, keys, column, sub_column, count, start, finish, reversed, consistency)
      # Single values; count and range parameters have no effect
      if is_super(column_family) and sub_column
        predicate = CassandraThrift::SlicePredicate.new(:column_names => [sub_column])
        column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family, :super_column => column)
        multi_sub_columns_to_hash!(column_family, client.multiget_slice(keys, column_parent, predicate, consistency))

      elsif !is_super(column_family) and column
        predicate = CassandraThrift::SlicePredicate.new(:column_names => [column])
        column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family)
        multi_columns_to_hash!(column_family, client.multiget_slice(keys, column_parent, predicate, consistency))

      # Slices
      else
        predicate = CassandraThrift::SlicePredicate.new(:slice_range =>
          CassandraThrift::SliceRange.new(
            :reversed => reversed,
            :count => count,
            :start => start,
            :finish => finish))

        if is_super(column_family) and column
          column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family, :super_column => column)
          multi_sub_columns_to_hash!(column_family, client.multiget_slice(keys, column_parent, predicate, consistency))
        else
          column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family)
          multi_columns_to_hash!(column_family, client.multiget_slice(keys, column_parent, predicate, consistency))
        end
      end
    end

    def _get_range(column_family, start, finish, count, consistency)
      column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family)
      predicate = CassandraThrift::SlicePredicate.new(:slice_range => CassandraThrift::SliceRange.new(:start => '', :finish => ''))
      range = CassandraThrift::KeyRange.new(:start_key => start, :end_key => finish, :count => count)
      client.get_range_slices(column_parent, predicate, range, 1)
    end

    def _get_range_keys(column_family, start, finish, count, consistency)
      _get_range(column_family, start, finish, count, consistency).collect{|i| i.key }
    end

    # TODO: Supercolumn support
    def _get_indexed_slices(column_family, idx_clause, column, count, start, finish, reversed, consistency)
      column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family)
      if column
        predicate = CassandraThrift::SlicePredicate.new(:column_names => [column])
      else
        predicate = CassandraThrift::SlicePredicate.new(:slice_range =>
          CassandraThrift::SliceRange.new(
            :reversed => reversed,
            :count => count,
            :start => start,
            :finish => finish))
      end
      client.get_indexed_slices(column_parent, idx_clause, predicate, consistency)
    end

  def _each_key(column_family, batch_size = 2, options)
      batch_size = 2 if batch_size < 2
      column_parent = CassandraThrift::ColumnParent.new(:column_family => column_family.to_s)
      predicate = nil
      if not options[:start].nil? or not options[:finish].nil? or not options[:count].nil?
        slice_range = CassandraThrift::SliceRange.new(:start => options[:start], :finish => options[:finish], :count => options[:count])
        predicate = CassandraThrift::SlicePredicate.new(:slice_range => slice_range)
      end
      predicate = predicate || CassandraThrift::SlicePredicate.new(:column_names => []) #default predicate
      predicate
      position = ''
      begin
        range = CassandraThrift::KeyRange.new(:start_key => position, :end_key => '', :count => batch_size)
        results_returned = client.get_range_slices(column_parent, predicate, range, 1)
        results_returned = results_returned.drop(1) if position != '' # get_range slices with start key's is range inclusive, remove the first one here
        results_returned.each { |i| yield key_slice_to_hash(column_family, i) }
        position = results_returned.last.key unless results_returned.length == 0
      end while results_returned.length > 0
    end
  end
end
