class Cassandra

  def self.DEFAULT_TRANSPORT_WRAPPER
    Thrift::FramedTransport
  end

  def login!(username, password)
    @auth_request = CassandraThrift::AuthenticationRequest.new
    @auth_request.credentials = {'username' => username, 'password' => password}
    client.login(@auth_request)
  end

  def inspect
    "#<Cassandra:#{object_id}, @keyspace=#{keyspace.inspect}, @schema={#{
      Array(schema(false).cf_defs).map {|cfdef| ":#{cfdef.name} => #{cfdef.column_type}"}.join(', ')
    }}, @servers=#{servers.inspect}>"
  end

  def keyspace=(ks)
    client.set_keyspace(ks)
    @schema = nil; @keyspace = ks
  end

  def keyspaces
    client.describe_keyspaces.to_a.collect {|ksdef| ksdef.name }
  end

  def schema(load=true)
    if !load && !@schema
      Cassandra::Keyspace.new
    else
      @schema ||= client.describe_keyspace(@keyspace)
    end
  end

  def schema_agreement?
    client.describe_schema_versions().length == 1
  end

  def version
    client.describe_version()
  end

  def cluster_name
    @cluster_name ||= client.describe_cluster_name()
  end

  def ring
    client.describe_ring(@keyspace)
  end

  def partitioner
    client.describe_partitioner()
  end

  ## Delete
  # This is only included as its mentioned in the spec/mock files and used in the test
  def clear_column_family!(column_family, options = {})
    self.truncate!(column_family)
  end

  # Remove all rows in the column family you request.
  def truncate!(column_family)
    #each_key(column_family) do |key|
    #  remove(column_family, key, options)
    #end
    client.truncate(column_family.to_s)
  end

  # Remove all rows in the keyspace.
  def clear_keyspace!
    schema.cf_defs.each { |cfdef| truncate!(cfdef.name) }
  end

### Read

  def add_column_family(cf_def)
    begin
      res = client.system_add_column_family(cf_def)
    rescue CassandraThrift::TimedOutException => te
      puts "Timed out: #{te.inspect}"
    end
    @schema = nil
    res
  end

  def drop_column_family(cf_name)
    begin
      res = client.system_drop_column_family(cf_name)
    rescue CassandraThrift::TimedOutException => te
      puts "Timed out: #{te.inspect}"
    end
    @schema = nil
    res
  end

  def rename_column_family(old_name, new_name)
    begin
      res = client.system_rename_column_family(old_name, new_name)
    rescue CassandraThrift::TimedOutException => te
      puts "Timed out: #{te.inspect}"
    end
    @schema = nil
    res
  end

  def update_column_family(cf_def)
    begin
      res = client.system_update_column_family(cf_def)
    rescue CassandraThrift::TimedOutException => te
      puts "Timed out: #{te.inspect}"
    end
    @schema = nil
    res
  end

  def add_keyspace(ks_def)
    begin
      res = client.system_add_keyspace(ks_def)
    rescue CassandraThrift::TimedOutException => toe
      puts "Timed out: #{toe.inspect}"
    rescue Thrift::TransportException => te
      puts "Timed out: #{te.inspect}"
    end
    @keyspaces = nil
    res
  end

  def drop_keyspace(ks_name)
    begin
      res = client.system_drop_keyspace(ks_name)
    rescue CassandraThrift::TimedOutException => toe
      puts "Timed out: #{toe.inspect}"
    rescue Thrift::TransportException => te
      puts "Timed out: #{te.inspect}"
    end
    keyspace = "system" if ks_name.eql?(@keyspace)
    @keyspaces = nil
    res
  end

  def rename_keyspace(old_name, new_name)
    begin
      res = client.system_rename_keyspace(old_name, new_name)
    rescue CassandraThrift::TimedOutException => toe
      puts "Timed out: #{toe.inspect}"
    rescue Thrift::TransportException => te
      puts "Timed out: #{te.inspect}"
    end
    keyspace = new_name if old_name.eql?(@keyspace)
    @keyspaces = nil
    res
  end

  def update_keyspace(ks_def)
    begin
      res = client.system_update_keyspace(ks_def)
    rescue CassandraThrift::TimedOutException => toe
      puts "Timed out: #{toe.inspect}"
    rescue Thrift::TransportException => te
      puts "Timed out: #{te.inspect}"
    end
    @keyspaces = nil
    res
  end

  # Open a batch operation and yield self. Inserts and deletes will be queued
  # until the block closes, and then sent atomically to the server.  Supports
  # the <tt>:consistency</tt> option, which overrides the consistency set in
  # the individual commands.
  def batch(options = {})
    _, _, _, options =
      extract_and_validate_params(schema.cf_defs.first.name, "", [options], WRITE_DEFAULTS)

    @batch = []
    yield(self)
    compact_mutations!

    @batch.each do |mutation|
      case mutation.first
      when :remove
        _remove(*mutation[1])
      else
        _mutate(*mutation)
      end
    end
  ensure
    @batch = nil
  end

### 2ary Indexing

  def create_index(ks_name, cf_name, c_name, v_class)
    cf_def = client.describe_keyspace(ks_name).cf_defs.find{|x| x.name == cf_name}
    if !cf_def.nil? and !cf_def.column_metadata.find{|x| x.name == c_name}
      c_def  = CassandraThrift::ColumnDef.new do |cd|
        cd.name             = c_name
        cd.validation_class = "org.apache.cassandra.db.marshal."+v_class
        cd.index_type       = CassandraThrift::IndexType::KEYS
      end
      cf_def.column_metadata.push(c_def)
      update_column_family(cf_def)
    end
  end

  def drop_index(ks_name, cf_name, c_name)
    cf_def = client.describe_keyspace(ks_name).cf_defs.find{|x| x.name == cf_name}
    if !cf_def.nil? and cf_def.column_metadata.find{|x| x.name == c_name}
      cf_def.column_metadata.delete_if{|x| x.name == c_name}
      update_column_family(cf_def)
    end
  end

  def create_idx_expr(c_name, value, op)
    CassandraThrift::IndexExpression.new(
      :column_name => c_name,
      :value => value,
      :op => (case op
                when nil, "EQ", "eq", "=="
                  CassandraThrift::IndexOperator::EQ
                when "GTE", "gte", ">="
                  CassandraThrift::IndexOperator::GTE
                when "GT", "gt", ">"
                  CassandraThrift::IndexOperator::GT
                when "LTE", "lte", "<="
                  CassandraThrift::IndexOperator::LTE
                when "LT", "lt", "<"
                  CassandraThrift::IndexOperator::LT
              end ))
  end

  def create_idx_clause(idx_expressions, start = "")
    CassandraThrift::IndexClause.new(
      :start_key => start,
      :expressions => idx_expressions)
  end

  # Atomic counters
  # Add a value to the counter in cf:key:super column:column
  def add(column_family, key, value, *columns_and_options)
    column_family, column, sub_column, options = extract_and_validate_params(column_family, key, columns_and_options, WRITE_DEFAULTS)
    _add(column_family, key, column, sub_column, value, options[:consistency])
  end

	# Get the value stored in a counter
  def get_counter(column_family, key, *columns_and_options)
    column_family, columns, sub_columns, options =
    extract_and_validate_params(column_family, key, columns_and_options, READ_DEFAULTS)
    columns = [columns] if sub_columns.nil?
    sub_columns = [sub_columns] unless sub_columns.nil?
    _get_counter_columns(column_family, key, columns, sub_columns, options[:consistency])[0]
  end

  def get_counter_columns(column_family, key, *columns_and_options)
    column_family, columns, sub_columns, options =
    extract_and_validate_params(column_family, key, columns_and_options, READ_DEFAULTS)
    _get_counter_columns(column_family, key, columns, sub_columns, options[:consistency])
  end

  def get_counter_slice(column_family, key, *columns_and_options)
    column_family, column, sub_column, options = extract_and_validate_params(column_family, key, columns_and_options, READ_DEFAULTS)
    results = {}
    _get_counter_slice(column_family, key, column, options[:start], options[:finish], options[:consistency]).map do |counter|
      c = counter.super_column || counter.column || counter.counter_column
      results[c.name] = c.value
    end
    results
  end

  # TODO: Supercolumn support.
  def get_indexed_slices(column_family, idx_clause, *columns_and_options)
    column_family, columns, _, options =
      extract_and_validate_params(column_family, [], columns_and_options, READ_DEFAULTS)
    _get_indexed_slices(column_family, idx_clause, columns, options[:count], options[:start],
      options[:finish], options[:reversed], options[:consistency])
  end


   def each_key(column_family, batch_size = 10, *columns_and_options, &block)
     column_family, _, _, options = extract_and_validate_params(column_family, [], columns_and_options, READ_DEFAULTS)
      _each_key(column_family, batch_size, options, &block)

   end

  protected

  def client
    if @client.nil? || @client.current_server.nil?
      reconnect!
      @client.set_keyspace(@keyspace)
    end
    @client
  end

  def reconnect!
    @servers = all_nodes
    @client = new_client
  end

  def all_nodes
    if @auto_discover_nodes && !@keyspace.eql?("system")
      temp_client = new_client
      begin
        ips = (temp_client.describe_ring(@keyspace).map {|range| range.endpoints}).flatten.uniq
        port = @servers.first.split(':').last
        ips.map{|ip| "#{ip}:#{port}" }
      ensure
        temp_client.disconnect!
      end
    else
      @servers
    end
  end

end
