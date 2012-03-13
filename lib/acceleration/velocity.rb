##
# :main:Acceleration
# = Acceleration
# 
# by Colin Dean <cdean@vivisimo.com>
# 
# (c) 2012 Vivisimo, Inc.
#
# For services and training around this library, please contact Vivisimo
# Professional Services.
#
# == Introduction
#
# *Acceleration* exists to provide a simple, object-oriented interface to
# a Vivisimo Velocity search platform instance in an interface familiar to
# Rubyists. It communicates with the instance via REST and parses the responses
# using Nokogiri, a very fast and well-tested XML library.
# 
# Acceleration is derived from Velocity ;-)
#
# == Interface
#
# Acceleration makes an effort to provide an ActiveRecord-style interface while
# still allowing the end user to access directly the XML returned from the
# Velocity API. Acceleration wraps most of the responses in a convenient object
# which provides a series a methods to accelerate development using the
# Velocity API.
#
#    i = Velocity::Instance.new :endpoint => api_endpoint, :username => api_username, :password => api-password
#    if i.ping
#      puts "Working"
#      i.collections.each do |c|
#       puts c.status.crawler.elapsed_time
#     end
#    end
#    c = i.collection("wiki") # => <#Velocity::API::Collection name=wiki>
#
#    c.status.crawler.n_docs if c.status.has_data? # => get the number of docs
#
# == Reference material:
# * http://rdoc.info/github/archiloque/rest-client/master/file/README.rdoc
# * http://code.vivisimo.com/gitweb/rails/velocity_gem.git/blob/master:/lib/velocity/api.rb
# * https://bitbucket.org/colindean/challonge-api/src/daff627691c6/lib/challonge/api.rb
# * http://nokogiri.org/Nokogiri.html
# * http://zimonet.vivisimo.com/vivisimo/cgi-bin/query-meta?v%3asources=office&query=api%20documentation%20DOCUMENT_KEY%3a%22file%3a%2f%2f%3a80%2foffice%2fDocumentation%2f8.0-0%2fvelocity_api_developers_guide.pdf%2f%22&v%3aframe=cache&search-vfile=viv_mkzSm7&search-state=%28root%29%7croot&
#
module Velocity
  class Instance
    attr_accessor :v_app, :endpoint, :username, :password, :read_timeout, :open_timeout
    attr_reader :error

    def initialize(args)
      @v_app = args[:v_app] || 'api-rest'
      @endpoint = args[:endpoint]
      @username = args[:username]
      @password = args[:password]
      @read_timeout = args[:read_timeout] || 120
      @open_timeout = args[:open_timeout] || 30
    end

    ##
    # Prepare and eventually execute a Velocity API function call.
    #
    # This function is generally meant to be called from within
    # APIModel#method_missing, but a method can call it directly if something
    # special must be done with the returned Nokogiri::XML object. The classes
    # that do that generally wrap around the object to provide convenience
    # methods.
    #
    def call(function, args={})
      sanity_check
      puts "calling #{function} with args: #{args}"
      if args.class == Array and args.empty?
        args = {}
      elsif !args.empty? and args.first.class == Hash
        args = args.first
      end
      params = base_parameters.merge( {'v.function' => function}.merge(args))
      result = Nokogiri::XML(rest_call params)
      unless VelocityException.exception? result
        @error = nil
        return result
      else
        raise VelocityException, result
      end
    end

    ##
    # Perform the actual REST action
    #
    def rest_call params
      req = {:method => :get, :url => endpoint, :headers => {:params => params } } #restclient stupidly puts query params in the...headers?
      req[:timeout] = read_timeout if read_timeout
      req[:open_timeout] = open_timeout if open_timeout
      puts "hitting #{endpoint} with params: #{params}"
      RestClient::Request.execute(req) 
    end

    ##
    # Assemble a hash with the basic parameters for the instance. 
    #
    def base_parameters
      {'v.app' => v_app, 
       'v.username' => username,
       'v.password' => password }
    end

    ##
    # Perform a simple ping against the instance using the API function
    # appropriately named "ping".
    #
    # If Instance#ping returns false, check Instance#error for the exception
    # that was thrown. Instance#ping should always have a boolean return. 
    #
    def ping
      begin
        n = call "ping"
        return true if n.root.name == 'pong'
      rescue Exception => e
        @error = e
      end
      return false
    end

    ##
    # List all collections available on the instance.
    #
    def collections
      n = call "search-collection-list-xml"
      n.xpath('/vse-collections/vse-collection').collect do |c|
        SearchCollection.new_from_xml(:xml => c, :instance => self) #initialize a new one, set its instance to me
      end
    end

    ##
    # Get just one collection
    #
    def collection name
      c = SearchCollection.new(name)
      c.instance = self
      return c
    end

    ##
    # List all dictionaries available on the instance.
    #
    def dictionaries
      n = call "dictionary-list-xml"
      n.xpath('/dictionaries/dictionary').collect do |d|
        Dictionary.new_from_xml(:xml => d, :instance => self)
      end
    end

    ##
    # Ensure that all instance variables necessary to communicate with the API
    # are set.
    #
    def sanity_check
      raise ArgumentError, "You must specify a v.app." if v_app.nil?
      raise ArgumentError, "You must specify a username." if username.nil?
      raise ArgumentError, "You must specify a password." if password.nil?
      raise ArgumentError, "You must specify an endpoint." if endpoint.nil?
    end

    ##
    # The APIModel is a very simple interface for building more complex API
    # function models.
    #
    # TODO: refactor some of this method into something includable
    # TODO: move #dasherize to a monkeypatch of string and symbol
    # TODO: implement #dedasherize
    #
    class APIModel

      def initialize(instance)
        @instance = instance
      end

      ##
      # Build the API function name based off the prefix and the desired
      # operation.
      #
      def resolve(operation)
        [prefix, operation].join '-'
      end

      ##
      # Convenience function for converting Ruby method names to Velocity API
      # method names by replacing underscores with dashes.
      #
      def dasherize(string)
        string.to_s.downcase.gsub(/_/,'-')
      end
      ##
      # Get the hardcoded prefix for this model.
      #
      # All classes extending APIModel should implement this method.
      #
      def prefix
        nil
      end
      private :prefix

      ##
      # This magical method enables a direct pass-through of methods if no
      # special logic is required to handle the response.
      def method_missing(function, *args, &block)
        @instance.call resolve(function), args
      end
    end

    ##
    # Query models a query executed through the API. There are a very large
    # number of arguments that can be passed to Query#search and similar
    # methods. See the API documentation for a complete list.
    #
    # Acquire a Query by executing Velocity::Instance#query; do not instantiate
    # one yourself.
    #
    class Query < APIModel
      def prefix
        "query"
      end
      
      ##
      # Execute a standard search using a source the instance.
      #
      # You'll want to supply at least a +:sources+ option and likely
      # a +:query+ option.
      def search args
        QueryResponse.new(@instance.call(resolve('search'), args))
      end

      ##
      # Execute a browse query, having already executed a regular Query#search 
      # and passing the +:browse+ option set to true. 
      #
      # You must supply a +:file+ corresponding to the file that was returned
      # from the original query. This is not checked here, so _caveat_
      # _implementor_.
      #
      def browse args
        QueryResponse.new(@instance.call(resolve('browse'), args))
      end

      ##
      # Execute a similar documents query.
      #
      # You must supply a +:document+ containing something that will resolve to
      # an XML nodeset containing document nodes. This is not checked here, so
      # _caveat_ _implementor_.
      #
      def similar_documents args
        QueryResponse.new(@instance.call(resolve('similar-documents'), args))
      end

    end

    ##
    # QueryResponse wraps the XML output from a Query#search in an object which
    # provides several convenience methods in addition to exposing the
    # underlying XML document comprising the response.
    #
    class QueryResponse
      attr_accessor :doc

      def initialize node
        @doc = node
      end

      ##
      # Indicates if a query response actually contains documents
      #
      def results?
        documents.size > 0
      end

      ##
      # Retrieve all documents from the query response
      #
      def documents
        doc.xpath("/query-results/list/document").collect do |d|
          Document.new d
        end
      end

      ##
      # Retrieve the file name of the browse file, a.k.a. +v:file+.
      #
      # Pass this as the +:file+ option to Query#browse in order for that
      # method to work properly.
      def file
        doc.xpath('/query-results/@file').first.value
      end
    end
    
    ##
    # Document wraps the XML for an individual Velocity document in order to
    # provide several convenience methods.
    #
    class Document
      attr_accessor :doc

      def initialize node
        @doc = node
      end

      ##
      # Retrieve all contents
      #
      def contents
        doc.xpath "content"
      end

      ##
      # Retrieve a single content.
      #
      # _Warning:_ This will actually return an array and that array may
      # contain multiple elements if there are multiple contents with the same
      # name attribute.
      #
      #    document.content 'author'
      #    document.content("title").first
      #
      def content name
        doc.xpath "content[@name='#{name}']"
      end

      ##
      # Retrieve a single attribute from the document.
      #
      #     document.attribute "url"
      #
      def attribute name
        doc.attribute name
      end

      ##
      # Retrieve all document attributes
      #
      def attributes
        doc.attributes
      end

      ##
      # Direct passthrough of the xpath in order to execute more complex XPath
      # queries on the source document XML.
      #
      def xpath xpath
        doc.xpath xpath
      end
    end

    ## 
    # Create a new query
    #
    def query
      Query.new(self)
    end

    ##
    # SearchCollection models a Velocity search collection and provides a set
    # of convenience methods for accessing its status, controlling its
    # activity, and even enqueuing documents and URLs.
    #
    class SearchCollection < APIModel
      attr_accessor :name, :instance

      def prefix
        "search-collection"
      end

      def initialize(collection_name)
        @name = collection_name
      end
      
      ##
      # Factory method used by Instance#collections
      #
      def self.new_from_xml(args)
        sc = SearchCollection.new(args[:xml].attributes['name'].to_s)
        sc.instance = args[:instance]
        return sc
      end

      ##
      # Get a handle on the crawler service
      #
      def crawler
        Crawler.new self
      end

      ##
      # Get a handle on the indexer service
      #
      def indexer
        Indexer.new self
      end

      ##
      # Retrieve the status of the collection
      #
      def status
        Status.new instance.call resolve("status"), {:collection => name}
      end


      class Status
        # The raw document describing the status
        attr_accessor :doc

        def initialize doc
          @doc = doc
        end

        ##
        # Get the crawler status node
        #
        def crawler
          CrawlerStatus.new doc.xpath("/vse-status/crawler-status").first
        end

        ##
        # Get the indexer status node
        #
        def indexer
          IndexerStatus.new doc.xpath("/vse-status/vse-index-status").first
        end

        ##
        # Check to see if the collection actually has a status.
        #
        # If false, then the collection isn't running and has no data.
        # if true, then the collection _may_ be running but certainly has data.
        def has_data?
          doc.xpath("__CONTAINER__").empty?
        end

        class ServiceStatus
          # The raw document describing the status
          attr_accessor :doc

          def initialize doc
            @doc = doc
          end

          ##
          # Return a hash of all attributes
          #
          # This method resolves the value of all of the Nokogiri attributes so
          # that you don't have to.
          #
          def attributes
            attrs = {}
            doc.attributes.each do |key,nattr|
              attrs[key] = nattr.value
            end
            return attrs
          end

          ##
          # Get a single attribute
          #
          def attribute attr
            doc.attribute(attr).value
          end

          ##
          # Capture attributes accessed as instance variables
          #
          # def method_missing (function, *args, &block)
          #   if doc.attributes.member? function.to_s
          #     attribute function.to_s
          #   else if doc.attributes.member? "n-" + function.to_s
          #     attribute function.to_s
          #   else
          #     super(function, args, block)
          #   end
          # end
        end

        ##
        # Wrapper for the crawler status object
        #
        class CrawlerStatus < ServiceStatus
          ##
          # Get the total number of time spent converting
          #
          def converter_timings_total_ms
            doc.xpath('converter-timings/@total-ms').first.value.to_i
          end
          
          ##
          # Get an array of hashes containing the timings for all converters
          # that have run so far while crawling.
          #
          def converter_timings
            doc.xpath('converter-timings/converter-timing').collect do |ct|
              attrs = {}
              ct.attributes.each do |key,nattr|
                attrs[key] = nattr.value
              end
              attrs
            end
          end

          ##
          # Retrieve the number of documents output at each hop
          #
          def crawl_hops_output
            crawl_hops :output
          end

          ##
          # Retrieve the number of documents input at each hop
          #
          def crawl_hops_input
            crawl_hops :input
          end

          ##
          # Private method unifying how crawl-hop elements are presented
          #
          def crawl_hops which
            doc.xpath('crawl-hops-' + which.to_s + '/crawl-hop').collect do |ch|
              attrs = {}
              ch.attributes.each do |key, nattr|
                attrs[key] = nattr.value
              end
              attrs
            end
          end
          private :crawl_hops

          #TODO: crawl-remote-all-status/crawl-remote-{server,client,all}-status

        end

        ##
        # Wrapper for the index status object
        #
        class IndexerStatus < ServiceStatus
          #TODO: implement convenience methods
        end


      end

      ##
      # A model for the collections' services
      #
      class CollectionService < APIModel
        attr_accessor :collection
        def initialize collection
          @collection = collection
        end

        ##
        # Start the service.
        #
        # Valid option for either service is:
        #
        # * :subcollection => 'live' (default) or 'staging'
        #
        # Valid option only for crawler service:
        #
        # * :type => 'resume' 'resume-and-idle' 'refresh-inplace' 'refresh-new'
        #             'new' 'apply-changes'
        #
        def start options={}
          act 'start', options
        end

        ##
        # Stop the service
        #
        # Valid options for either service are:
        #
        # * :subcollection => 'live' (default) or 'staging'
        # * :kill => true or false
        #
        def stop options={}
          act 'stop', options
        end

        ##
        # Restart the service
        #
        # Valid options for either service are:
        #
        # * :subcollection => 'live' (default) or 'staging'
        #
        def restart options={}
          act 'restart', options
        end

        private
          ## 
          # Refactored interface for all collection services
          # 
          def act action, options={}
            collection.instance.call resolve(action), options.merge({:collection => collection.name})
          end
      end

      ##
      # The Crawler service of the collection
      #
      class Crawler < CollectionService
        #implied by method_missing:
        #start, stop, restart
        def prefix
          collection.prefix + "-crawler"
        end
      end

      ##
      # The Indexer service of the collection
      #
      class Indexer < CollectionService
        #implied by method_missing:
        #start, stop, restart, full-merge
        def prefix
          collection.prefix + "-indexer"
        end

        ##
        # Executes a full merge on the index. This reduces the number of files
        # across which the index is spread and also removes deleted data.
        #
        # * :subcollection => 'live' (default) or 'staging'
        def full_merge options={}
          act 'full-merge', options
        end
      end

    end

    ## 
    # Interact with a dictionary on the Velocity instance
    #
    # Note that +dictionary-list-xml+ is implemented as
    # Velocity::Instance#dictionaries.
    #
    class Dictionary < APIModel
      attr_accessor :name, :instance
      def prefix
        'dictionary'
      end
      private :prefix
      ##
      # Factory method used by Instance#collections
      #
      def self.new_from_xml(args)
        d = Dictionary.new(args[:xml].attributes['name'].to_s)
        d.instance = args[:instance]
        return d
      end

      def initialize name
        @name = name
      end

      ##
      # Get the dictionary's status object
      #
      # TODO: wrap the XML returned
      def status
        act 'status-xml'
      end

      ##
      # Begin a build of the dictionary
      #
      def build
        act __method__
      end
      ##
      # Create the dictionary
      #
      # Can optionally pass +:based_on+ String to use another dictionary as a template
      #
      def create args={}
        act __method__
      end
      ##
      # Stop the dictionary build process
      #
      # Can optionally pass +:kill+ boolean if it should be killed immediately
      #
      def stop args={}
        act __method__, {}
      end
      ##
      # Delete the dictionary
      #
      def delete
        act __method__
      end
      
      def act action, args={}
        return instance.call resolve(action), args.merge({:dictionary => name})
      end
      private :act



    end
  end

  ##
  # Generic Velocity API exception thrown when Velocity doesn't like the
  # arguments supplied in a call or the credentials are incorrect.
  # 
  # Don't ever raise this yourself; it should be raised only by
  # Velocity::Instance#call
  #
  class VelocityException < Exception
    ##
    # Determines if a response from the API is an exception response
    #
    def self.exception? node
      node.root.name == 'exception'
    end
    ##
    # Wrap this exception around the XML returned by Velocity
    #
    def initialize node
      @node = node
      super(api_message)
    end
    ##
    # Get the string describing the thrown exception
    #
    def api_message
      @node.xpath('/exception//text()').to_a.join.strip
    end
    ##
    # Convert this exception to a string
    #
    def to_s
      api_message
    end
  end
end
