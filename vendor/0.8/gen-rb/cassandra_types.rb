#
# Autogenerated by Thrift
#
# DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
#


module CassandraThrift
    module ConsistencyLevel
      ONE = 1
      QUORUM = 2
      LOCAL_QUORUM = 3
      EACH_QUORUM = 4
      ALL = 5
      ANY = 6
      TWO = 7
      THREE = 8
      VALUE_MAP = {1 => "ONE", 2 => "QUORUM", 3 => "LOCAL_QUORUM", 4 => "EACH_QUORUM", 5 => "ALL", 6 => "ANY", 7 => "TWO", 8 => "THREE"}
      VALID_VALUES = Set.new([ONE, QUORUM, LOCAL_QUORUM, EACH_QUORUM, ALL, ANY, TWO, THREE]).freeze
    end

    module IndexOperator
      EQ = 0
      GTE = 1
      GT = 2
      LTE = 3
      LT = 4
      VALUE_MAP = {0 => "EQ", 1 => "GTE", 2 => "GT", 3 => "LTE", 4 => "LT"}
      VALID_VALUES = Set.new([EQ, GTE, GT, LTE, LT]).freeze
    end

    module IndexType
      KEYS = 0
      VALUE_MAP = {0 => "KEYS"}
      VALID_VALUES = Set.new([KEYS]).freeze
    end

    module Compression
      GZIP = 1
      VALUE_MAP = {1 => "GZIP"}
      VALID_VALUES = Set.new([GZIP]).freeze
    end

    module CqlResultType
      ROWS = 1
      VOID = 2
      INT = 3
      VALUE_MAP = {1 => "ROWS", 2 => "VOID", 3 => "INT"}
      VALID_VALUES = Set.new([ROWS, VOID, INT]).freeze
    end

    # Basic unit of data within a ColumnFamily.
    # @param name, the name by which this column is set and retrieved.  Maximum 64KB long.
    # @param value. The data associated with the name.  Maximum 2GB long, but in practice you should limit it to small numbers of MB (since Thrift must read the full value into memory to operate on it).
    # @param timestamp. The timestamp is used for conflict detection/resolution when two columns with same name need to be compared.
    # @param ttl. An optional, positive delay (in seconds) after which the column will be automatically deleted.
    class Column
      include ::Thrift::Struct, ::Thrift::Struct_Union
      NAME = 1
      VALUE = 2
      TIMESTAMP = 3
      TTL = 4

      FIELDS = {
        NAME => {:type => ::Thrift::Types::STRING, :name => 'name', :binary => true},
        VALUE => {:type => ::Thrift::Types::STRING, :name => 'value', :binary => true},
        TIMESTAMP => {:type => ::Thrift::Types::I64, :name => 'timestamp'},
        TTL => {:type => ::Thrift::Types::I32, :name => 'ttl', :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field name is unset!') unless @name
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field value is unset!') unless @value
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field timestamp is unset!') unless @timestamp
      end

      ::Thrift::Struct.generate_accessors self
    end

    # A named list of columns.
    # @param name. see Column.name.
    # @param columns. A collection of standard Columns.  The columns within a super column are defined in an adhoc manner.
    #                 Columns within a super column do not have to have matching structures (similarly named child columns).
    class SuperColumn
      include ::Thrift::Struct, ::Thrift::Struct_Union
      NAME = 1
      COLUMNS = 2

      FIELDS = {
        NAME => {:type => ::Thrift::Types::STRING, :name => 'name', :binary => true},
        COLUMNS => {:type => ::Thrift::Types::LIST, :name => 'columns', :element => {:type => ::Thrift::Types::STRUCT, :class => CassandraThrift::Column}}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field name is unset!') unless @name
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field columns is unset!') unless @columns
      end

      ::Thrift::Struct.generate_accessors self
    end

    # Methods for fetching rows/records from Cassandra will return either a single instance of ColumnOrSuperColumn or a list
    # of ColumnOrSuperColumns (get_slice()). If you're looking up a SuperColumn (or list of SuperColumns) then the resulting
    # instances of ColumnOrSuperColumn will have the requested SuperColumn in the attribute super_column. For queries resulting
    # in Columns, those values will be in the attribute column. This change was made between 0.3 and 0.4 to standardize on
    # single query methods that may return either a SuperColumn or Column.
    # 
    # @param column. The Column returned by get() or get_slice().
    # @param super_column. The SuperColumn returned by get() or get_slice().
    class ColumnOrSuperColumn
      include ::Thrift::Struct, ::Thrift::Struct_Union
      COLUMN = 1
      SUPER_COLUMN = 2

      FIELDS = {
        COLUMN => {:type => ::Thrift::Types::STRUCT, :name => 'column', :class => CassandraThrift::Column, :optional => true},
        SUPER_COLUMN => {:type => ::Thrift::Types::STRUCT, :name => 'super_column', :class => CassandraThrift::SuperColumn, :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    # A specific column was requested that does not exist.
    class NotFoundException < ::Thrift::Exception
      include ::Thrift::Struct, ::Thrift::Struct_Union

      FIELDS = {

      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    # Invalid request could mean keyspace or column family does not exist, required parameters are missing, or a parameter is malformed.
    # why contains an associated error message.
    class InvalidRequestException < ::Thrift::Exception
      include ::Thrift::Struct, ::Thrift::Struct_Union
      def initialize(message=nil)
        super()
        self.why = message
      end

      def message; why end

      WHY = 1

      FIELDS = {
        WHY => {:type => ::Thrift::Types::STRING, :name => 'why'}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field why is unset!') unless @why
      end

      ::Thrift::Struct.generate_accessors self
    end

    # Not all the replicas required could be created and/or read.
    class UnavailableException < ::Thrift::Exception
      include ::Thrift::Struct, ::Thrift::Struct_Union

      FIELDS = {

      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    # RPC timeout was exceeded.  either a node failed mid-operation, or load was too high, or the requested op was too large.
    class TimedOutException < ::Thrift::Exception
      include ::Thrift::Struct, ::Thrift::Struct_Union

      FIELDS = {

      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    # invalid authentication request (invalid keyspace, user does not exist, or credentials invalid)
    class AuthenticationException < ::Thrift::Exception
      include ::Thrift::Struct, ::Thrift::Struct_Union
      def initialize(message=nil)
        super()
        self.why = message
      end

      def message; why end

      WHY = 1

      FIELDS = {
        WHY => {:type => ::Thrift::Types::STRING, :name => 'why'}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field why is unset!') unless @why
      end

      ::Thrift::Struct.generate_accessors self
    end

    # invalid authorization request (user does not have access to keyspace)
    class AuthorizationException < ::Thrift::Exception
      include ::Thrift::Struct, ::Thrift::Struct_Union
      def initialize(message=nil)
        super()
        self.why = message
      end

      def message; why end

      WHY = 1

      FIELDS = {
        WHY => {:type => ::Thrift::Types::STRING, :name => 'why'}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field why is unset!') unless @why
      end

      ::Thrift::Struct.generate_accessors self
    end

    # schemas are not in agreement across all nodes
    class SchemaDisagreementException < ::Thrift::Exception
      include ::Thrift::Struct, ::Thrift::Struct_Union

      FIELDS = {

      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    # ColumnParent is used when selecting groups of columns from the same ColumnFamily. In directory structure terms, imagine
    # ColumnParent as ColumnPath + '/../'.
    # 
    # See also <a href="cassandra.html#Struct_ColumnPath">ColumnPath</a>
    class ColumnParent
      include ::Thrift::Struct, ::Thrift::Struct_Union
      COLUMN_FAMILY = 3
      SUPER_COLUMN = 4

      FIELDS = {
        COLUMN_FAMILY => {:type => ::Thrift::Types::STRING, :name => 'column_family'},
        SUPER_COLUMN => {:type => ::Thrift::Types::STRING, :name => 'super_column', :binary => true, :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field column_family is unset!') unless @column_family
      end

      ::Thrift::Struct.generate_accessors self
    end

    # The ColumnPath is the path to a single column in Cassandra. It might make sense to think of ColumnPath and
    # ColumnParent in terms of a directory structure.
    # 
    # ColumnPath is used to looking up a single column.
    # 
    # @param column_family. The name of the CF of the column being looked up.
    # @param super_column. The super column name.
    # @param column. The column name.
    class ColumnPath
      include ::Thrift::Struct, ::Thrift::Struct_Union
      COLUMN_FAMILY = 3
      SUPER_COLUMN = 4
      COLUMN = 5

      FIELDS = {
        COLUMN_FAMILY => {:type => ::Thrift::Types::STRING, :name => 'column_family'},
        SUPER_COLUMN => {:type => ::Thrift::Types::STRING, :name => 'super_column', :binary => true, :optional => true},
        COLUMN => {:type => ::Thrift::Types::STRING, :name => 'column', :binary => true, :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field column_family is unset!') unless @column_family
      end

      ::Thrift::Struct.generate_accessors self
    end

    class CounterColumn
      include ::Thrift::Struct, ::Thrift::Struct_Union
      NAME = 1
      VALUE = 2

      FIELDS = {
        NAME => {:type => ::Thrift::Types::STRING, :name => 'name', :binary => true},
        VALUE => {:type => ::Thrift::Types::I64, :name => 'value'}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field name is unset!') unless @name
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field value is unset!') unless @value
      end

      ::Thrift::Struct.generate_accessors self
    end

    class CounterSuperColumn
      include ::Thrift::Struct, ::Thrift::Struct_Union
      NAME = 1
      COLUMNS = 2

      FIELDS = {
        NAME => {:type => ::Thrift::Types::STRING, :name => 'name', :binary => true},
        COLUMNS => {:type => ::Thrift::Types::LIST, :name => 'columns', :element => {:type => ::Thrift::Types::STRUCT, :class => CassandraThrift::CounterColumn}}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field name is unset!') unless @name
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field columns is unset!') unless @columns
      end

      ::Thrift::Struct.generate_accessors self
    end

    class Counter
      include ::Thrift::Struct, ::Thrift::Struct_Union
      COLUMN = 1
      SUPER_COLUMN = 2

      FIELDS = {
        COLUMN => {:type => ::Thrift::Types::STRUCT, :name => 'column', :class => CassandraThrift::CounterColumn, :optional => true},
        SUPER_COLUMN => {:type => ::Thrift::Types::STRUCT, :name => 'super_column', :class => CassandraThrift::CounterSuperColumn, :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    # A slice range is a structure that stores basic range, ordering and limit information for a query that will return
    # multiple columns. It could be thought of as Cassandra's version of LIMIT and ORDER BY
    # 
    # @param start. The column name to start the slice with. This attribute is not required, though there is no default value,
    #               and can be safely set to '', i.e., an empty byte array, to start with the first column name. Otherwise, it
    #               must a valid value under the rules of the Comparator defined for the given ColumnFamily.
    # @param finish. The column name to stop the slice at. This attribute is not required, though there is no default value,
    #                and can be safely set to an empty byte array to not stop until 'count' results are seen. Otherwise, it
    #                must also be a valid value to the ColumnFamily Comparator.
    # @param reversed. Whether the results should be ordered in reversed order. Similar to ORDER BY blah DESC in SQL.
    # @param count. How many columns to return. Similar to LIMIT in SQL. May be arbitrarily large, but Thrift will
    #               materialize the whole result into memory before returning it to the client, so be aware that you may
    #               be better served by iterating through slices by passing the last value of one call in as the 'start'
    #               of the next instead of increasing 'count' arbitrarily large.
    class SliceRange
      include ::Thrift::Struct, ::Thrift::Struct_Union
      START = 1
      FINISH = 2
      REVERSED = 3
      COUNT = 4

      FIELDS = {
        START => {:type => ::Thrift::Types::STRING, :name => 'start', :binary => true},
        FINISH => {:type => ::Thrift::Types::STRING, :name => 'finish', :binary => true},
        REVERSED => {:type => ::Thrift::Types::BOOL, :name => 'reversed', :default => false},
        COUNT => {:type => ::Thrift::Types::I32, :name => 'count', :default => 100}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field start is unset!') unless @start
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field finish is unset!') unless @finish
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field reversed is unset!') if @reversed.nil?
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field count is unset!') unless @count
      end

      ::Thrift::Struct.generate_accessors self
    end

    # A SlicePredicate is similar to a mathematic predicate (see http://en.wikipedia.org/wiki/Predicate_(mathematical_logic)),
    # which is described as "a property that the elements of a set have in common."
    # 
    # SlicePredicate's in Cassandra are described with either a list of column_names or a SliceRange.  If column_names is
    # specified, slice_range is ignored.
    # 
    # @param column_name. A list of column names to retrieve. This can be used similar to Memcached's "multi-get" feature
    #                     to fetch N known column names. For instance, if you know you wish to fetch columns 'Joe', 'Jack',
    #                     and 'Jim' you can pass those column names as a list to fetch all three at once.
    # @param slice_range. A SliceRange describing how to range, order, and/or limit the slice.
    class SlicePredicate
      include ::Thrift::Struct, ::Thrift::Struct_Union
      COLUMN_NAMES = 1
      SLICE_RANGE = 2

      FIELDS = {
        COLUMN_NAMES => {:type => ::Thrift::Types::LIST, :name => 'column_names', :element => {:type => ::Thrift::Types::STRING, :binary => true}, :optional => true},
        SLICE_RANGE => {:type => ::Thrift::Types::STRUCT, :name => 'slice_range', :class => CassandraThrift::SliceRange, :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class IndexExpression
      include ::Thrift::Struct, ::Thrift::Struct_Union
      COLUMN_NAME = 1
      OP = 2
      VALUE = 3

      FIELDS = {
        COLUMN_NAME => {:type => ::Thrift::Types::STRING, :name => 'column_name', :binary => true},
        OP => {:type => ::Thrift::Types::I32, :name => 'op', :enum_class => CassandraThrift::IndexOperator},
        VALUE => {:type => ::Thrift::Types::STRING, :name => 'value', :binary => true}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field column_name is unset!') unless @column_name
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field op is unset!') unless @op
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field value is unset!') unless @value
        unless @op.nil? || CassandraThrift::IndexOperator::VALID_VALUES.include?(@op)
          raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Invalid value of field op!')
        end
      end

      ::Thrift::Struct.generate_accessors self
    end

    class IndexClause
      include ::Thrift::Struct, ::Thrift::Struct_Union
      EXPRESSIONS = 1
      START_KEY = 2
      COUNT = 3

      FIELDS = {
        EXPRESSIONS => {:type => ::Thrift::Types::LIST, :name => 'expressions', :element => {:type => ::Thrift::Types::STRUCT, :class => CassandraThrift::IndexExpression}},
        START_KEY => {:type => ::Thrift::Types::STRING, :name => 'start_key', :binary => true},
        COUNT => {:type => ::Thrift::Types::I32, :name => 'count', :default => 100}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field expressions is unset!') unless @expressions
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field start_key is unset!') unless @start_key
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field count is unset!') unless @count
      end

      ::Thrift::Struct.generate_accessors self
    end

    # The semantics of start keys and tokens are slightly different.
    # Keys are start-inclusive; tokens are start-exclusive.  Token
    # ranges may also wrap -- that is, the end token may be less
    # than the start one.  Thus, a range from keyX to keyX is a
    # one-element range, but a range from tokenY to tokenY is the
    # full ring.
    class KeyRange
      include ::Thrift::Struct, ::Thrift::Struct_Union
      START_KEY = 1
      END_KEY = 2
      START_TOKEN = 3
      END_TOKEN = 4
      COUNT = 5

      FIELDS = {
        START_KEY => {:type => ::Thrift::Types::STRING, :name => 'start_key', :binary => true, :optional => true},
        END_KEY => {:type => ::Thrift::Types::STRING, :name => 'end_key', :binary => true, :optional => true},
        START_TOKEN => {:type => ::Thrift::Types::STRING, :name => 'start_token', :optional => true},
        END_TOKEN => {:type => ::Thrift::Types::STRING, :name => 'end_token', :optional => true},
        COUNT => {:type => ::Thrift::Types::I32, :name => 'count', :default => 100}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field count is unset!') unless @count
      end

      ::Thrift::Struct.generate_accessors self
    end

    # A KeySlice is key followed by the data it maps to. A collection of KeySlice is returned by the get_range_slice operation.
    # 
    # @param key. a row key
    # @param columns. List of data represented by the key. Typically, the list is pared down to only the columns specified by
    #                 a SlicePredicate.
    class KeySlice
      include ::Thrift::Struct, ::Thrift::Struct_Union
      KEY = 1
      COLUMNS = 2

      FIELDS = {
        KEY => {:type => ::Thrift::Types::STRING, :name => 'key', :binary => true},
        COLUMNS => {:type => ::Thrift::Types::LIST, :name => 'columns', :element => {:type => ::Thrift::Types::STRUCT, :class => CassandraThrift::ColumnOrSuperColumn}}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field key is unset!') unless @key
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field columns is unset!') unless @columns
      end

      ::Thrift::Struct.generate_accessors self
    end

    class KeyCount
      include ::Thrift::Struct, ::Thrift::Struct_Union
      KEY = 1
      COUNT = 2

      FIELDS = {
        KEY => {:type => ::Thrift::Types::STRING, :name => 'key', :binary => true},
        COUNT => {:type => ::Thrift::Types::I32, :name => 'count'}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field key is unset!') unless @key
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field count is unset!') unless @count
      end

      ::Thrift::Struct.generate_accessors self
    end

    class Deletion
      include ::Thrift::Struct, ::Thrift::Struct_Union
      TIMESTAMP = 1
      SUPER_COLUMN = 2
      PREDICATE = 3

      FIELDS = {
        TIMESTAMP => {:type => ::Thrift::Types::I64, :name => 'timestamp'},
        SUPER_COLUMN => {:type => ::Thrift::Types::STRING, :name => 'super_column', :binary => true, :optional => true},
        PREDICATE => {:type => ::Thrift::Types::STRUCT, :name => 'predicate', :class => CassandraThrift::SlicePredicate, :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field timestamp is unset!') unless @timestamp
      end

      ::Thrift::Struct.generate_accessors self
    end

    # A Mutation is either an insert, represented by filling column_or_supercolumn, or a deletion, represented by filling the deletion attribute.
    # @param column_or_supercolumn. An insert to a column or supercolumn
    # @param deletion. A deletion of a column or supercolumn
    class Mutation
      include ::Thrift::Struct, ::Thrift::Struct_Union
      COLUMN_OR_SUPERCOLUMN = 1
      DELETION = 2

      FIELDS = {
        COLUMN_OR_SUPERCOLUMN => {:type => ::Thrift::Types::STRUCT, :name => 'column_or_supercolumn', :class => CassandraThrift::ColumnOrSuperColumn, :optional => true},
        DELETION => {:type => ::Thrift::Types::STRUCT, :name => 'deletion', :class => CassandraThrift::Deletion, :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class CounterDeletion
      include ::Thrift::Struct, ::Thrift::Struct_Union
      SUPER_COLUMN = 1
      PREDICATE = 2

      FIELDS = {
        SUPER_COLUMN => {:type => ::Thrift::Types::STRING, :name => 'super_column', :binary => true, :optional => true},
        PREDICATE => {:type => ::Thrift::Types::STRUCT, :name => 'predicate', :class => CassandraThrift::SlicePredicate, :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    # A CounterMutation is either an insert, represented by filling counter, or a deletion, represented by filling the deletion attribute.
    # @param counter. An insert to a counter column or supercolumn
    # @param deletion. A deletion of a counter column or supercolumn
    class CounterMutation
      include ::Thrift::Struct, ::Thrift::Struct_Union
      COUNTER = 1
      DELETION = 2

      FIELDS = {
        COUNTER => {:type => ::Thrift::Types::STRUCT, :name => 'counter', :class => CassandraThrift::Counter, :optional => true},
        DELETION => {:type => ::Thrift::Types::STRUCT, :name => 'deletion', :class => CassandraThrift::CounterDeletion, :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
      end

      ::Thrift::Struct.generate_accessors self
    end

    class TokenRange
      include ::Thrift::Struct, ::Thrift::Struct_Union
      START_TOKEN = 1
      END_TOKEN = 2
      ENDPOINTS = 3

      FIELDS = {
        START_TOKEN => {:type => ::Thrift::Types::STRING, :name => 'start_token'},
        END_TOKEN => {:type => ::Thrift::Types::STRING, :name => 'end_token'},
        ENDPOINTS => {:type => ::Thrift::Types::LIST, :name => 'endpoints', :element => {:type => ::Thrift::Types::STRING}}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field start_token is unset!') unless @start_token
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field end_token is unset!') unless @end_token
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field endpoints is unset!') unless @endpoints
      end

      ::Thrift::Struct.generate_accessors self
    end

    # Authentication requests can contain any data, dependent on the IAuthenticator used
    class AuthenticationRequest
      include ::Thrift::Struct, ::Thrift::Struct_Union
      CREDENTIALS = 1

      FIELDS = {
        CREDENTIALS => {:type => ::Thrift::Types::MAP, :name => 'credentials', :key => {:type => ::Thrift::Types::STRING}, :value => {:type => ::Thrift::Types::STRING}}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field credentials is unset!') unless @credentials
      end

      ::Thrift::Struct.generate_accessors self
    end

    class ColumnDef
      include ::Thrift::Struct, ::Thrift::Struct_Union
      NAME = 1
      VALIDATION_CLASS = 2
      INDEX_TYPE = 3
      INDEX_NAME = 4

      FIELDS = {
        NAME => {:type => ::Thrift::Types::STRING, :name => 'name', :binary => true},
        VALIDATION_CLASS => {:type => ::Thrift::Types::STRING, :name => 'validation_class'},
        INDEX_TYPE => {:type => ::Thrift::Types::I32, :name => 'index_type', :optional => true, :enum_class => CassandraThrift::IndexType},
        INDEX_NAME => {:type => ::Thrift::Types::STRING, :name => 'index_name', :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field name is unset!') unless @name
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field validation_class is unset!') unless @validation_class
        unless @index_type.nil? || CassandraThrift::IndexType::VALID_VALUES.include?(@index_type)
          raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Invalid value of field index_type!')
        end
      end

      ::Thrift::Struct.generate_accessors self
    end

    class CfDef
      include ::Thrift::Struct, ::Thrift::Struct_Union
      KEYSPACE = 1
      NAME = 2
      COLUMN_TYPE = 3
      COMPARATOR_TYPE = 5
      SUBCOMPARATOR_TYPE = 6
      COMMENT = 8
      ROW_CACHE_SIZE = 9
      KEY_CACHE_SIZE = 11
      READ_REPAIR_CHANCE = 12
      COLUMN_METADATA = 13
      GC_GRACE_SECONDS = 14
      DEFAULT_VALIDATION_CLASS = 15
      ID = 16
      MIN_COMPACTION_THRESHOLD = 17
      MAX_COMPACTION_THRESHOLD = 18
      ROW_CACHE_SAVE_PERIOD_IN_SECONDS = 19
      KEY_CACHE_SAVE_PERIOD_IN_SECONDS = 20
      MEMTABLE_FLUSH_AFTER_MINS = 21
      MEMTABLE_THROUGHPUT_IN_MB = 22
      MEMTABLE_OPERATIONS_IN_MILLIONS = 23
      REPLICATE_ON_WRITE = 24
      MERGE_SHARDS_CHANCE = 25

      FIELDS = {
        KEYSPACE => {:type => ::Thrift::Types::STRING, :name => 'keyspace'},
        NAME => {:type => ::Thrift::Types::STRING, :name => 'name'},
        COLUMN_TYPE => {:type => ::Thrift::Types::STRING, :name => 'column_type', :default => %q"Standard", :optional => true},
        COMPARATOR_TYPE => {:type => ::Thrift::Types::STRING, :name => 'comparator_type', :default => %q"BytesType", :optional => true},
        SUBCOMPARATOR_TYPE => {:type => ::Thrift::Types::STRING, :name => 'subcomparator_type', :optional => true},
        COMMENT => {:type => ::Thrift::Types::STRING, :name => 'comment', :optional => true},
        ROW_CACHE_SIZE => {:type => ::Thrift::Types::DOUBLE, :name => 'row_cache_size', :default => 0, :optional => true},
        KEY_CACHE_SIZE => {:type => ::Thrift::Types::DOUBLE, :name => 'key_cache_size', :default => 200000, :optional => true},
        READ_REPAIR_CHANCE => {:type => ::Thrift::Types::DOUBLE, :name => 'read_repair_chance', :default => 1, :optional => true},
        COLUMN_METADATA => {:type => ::Thrift::Types::LIST, :name => 'column_metadata', :element => {:type => ::Thrift::Types::STRUCT, :class => CassandraThrift::ColumnDef}, :optional => true},
        GC_GRACE_SECONDS => {:type => ::Thrift::Types::I32, :name => 'gc_grace_seconds', :optional => true},
        DEFAULT_VALIDATION_CLASS => {:type => ::Thrift::Types::STRING, :name => 'default_validation_class', :optional => true},
        ID => {:type => ::Thrift::Types::I32, :name => 'id', :optional => true},
        MIN_COMPACTION_THRESHOLD => {:type => ::Thrift::Types::I32, :name => 'min_compaction_threshold', :optional => true},
        MAX_COMPACTION_THRESHOLD => {:type => ::Thrift::Types::I32, :name => 'max_compaction_threshold', :optional => true},
        ROW_CACHE_SAVE_PERIOD_IN_SECONDS => {:type => ::Thrift::Types::I32, :name => 'row_cache_save_period_in_seconds', :optional => true},
        KEY_CACHE_SAVE_PERIOD_IN_SECONDS => {:type => ::Thrift::Types::I32, :name => 'key_cache_save_period_in_seconds', :optional => true},
        MEMTABLE_FLUSH_AFTER_MINS => {:type => ::Thrift::Types::I32, :name => 'memtable_flush_after_mins', :optional => true},
        MEMTABLE_THROUGHPUT_IN_MB => {:type => ::Thrift::Types::I32, :name => 'memtable_throughput_in_mb', :optional => true},
        MEMTABLE_OPERATIONS_IN_MILLIONS => {:type => ::Thrift::Types::DOUBLE, :name => 'memtable_operations_in_millions', :optional => true},
        REPLICATE_ON_WRITE => {:type => ::Thrift::Types::BOOL, :name => 'replicate_on_write', :default => false, :optional => true},
        MERGE_SHARDS_CHANCE => {:type => ::Thrift::Types::DOUBLE, :name => 'merge_shards_chance', :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field keyspace is unset!') unless @keyspace
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field name is unset!') unless @name
      end

      ::Thrift::Struct.generate_accessors self
    end

    class KsDef
      include ::Thrift::Struct, ::Thrift::Struct_Union
      NAME = 1
      STRATEGY_CLASS = 2
      STRATEGY_OPTIONS = 3
      REPLICATION_FACTOR = 4
      CF_DEFS = 5

      FIELDS = {
        NAME => {:type => ::Thrift::Types::STRING, :name => 'name'},
        STRATEGY_CLASS => {:type => ::Thrift::Types::STRING, :name => 'strategy_class'},
        STRATEGY_OPTIONS => {:type => ::Thrift::Types::MAP, :name => 'strategy_options', :key => {:type => ::Thrift::Types::STRING}, :value => {:type => ::Thrift::Types::STRING}, :optional => true},
        REPLICATION_FACTOR => {:type => ::Thrift::Types::I32, :name => 'replication_factor'},
        CF_DEFS => {:type => ::Thrift::Types::LIST, :name => 'cf_defs', :element => {:type => ::Thrift::Types::STRUCT, :class => CassandraThrift::CfDef}}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field name is unset!') unless @name
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field strategy_class is unset!') unless @strategy_class
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field replication_factor is unset!') unless @replication_factor
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field cf_defs is unset!') unless @cf_defs
      end

      ::Thrift::Struct.generate_accessors self
    end

    # Row returned from a CQL query
    class CqlRow
      include ::Thrift::Struct, ::Thrift::Struct_Union
      KEY = 1
      COLUMNS = 2

      FIELDS = {
        KEY => {:type => ::Thrift::Types::STRING, :name => 'key', :binary => true},
        COLUMNS => {:type => ::Thrift::Types::LIST, :name => 'columns', :element => {:type => ::Thrift::Types::STRUCT, :class => CassandraThrift::Column}}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field key is unset!') unless @key
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field columns is unset!') unless @columns
      end

      ::Thrift::Struct.generate_accessors self
    end

    class CqlResult
      include ::Thrift::Struct, ::Thrift::Struct_Union
      TYPE = 1
      ROWS = 2
      NUM = 3

      FIELDS = {
        TYPE => {:type => ::Thrift::Types::I32, :name => 'type', :enum_class => CassandraThrift::CqlResultType},
        ROWS => {:type => ::Thrift::Types::LIST, :name => 'rows', :element => {:type => ::Thrift::Types::STRUCT, :class => CassandraThrift::CqlRow}, :optional => true},
        NUM => {:type => ::Thrift::Types::I32, :name => 'num', :optional => true}
      }

      def struct_fields; FIELDS; end

      def validate
        raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Required field type is unset!') unless @type
        unless @type.nil? || CassandraThrift::CqlResultType::VALID_VALUES.include?(@type)
          raise ::Thrift::ProtocolException.new(::Thrift::ProtocolException::UNKNOWN, 'Invalid value of field type!')
        end
      end

      ::Thrift::Struct.generate_accessors self
    end

  end
