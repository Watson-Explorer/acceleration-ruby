#the goal here is to provide an interface like this:
#
# i = Velocity::Instance.new
# i.set_opts { :endpoint => api_endpoint, :username => api_username, :password => api-password }
# if i.ping
#   puts "Working"
#   i.collections.each do |c|
#     c.status
#   end
# end
# c = i.find_collection("wiki") # => <#Velocity::API::Collection name=wiki>
# c.status # => an array of status items
#

# reference material:
# http://rdoc.info/github/archiloque/rest-client/master/file/README.rdoc
# http://code.vivisimo.com/gitweb/rails/velocity_gem.git/blob/master:/lib/velocity/api.rb
# https://bitbucket.org/colindean/challonge-api/src/daff627691c6/lib/challonge/api.rb
# http://nokogiri.org/Nokogiri.html
# http://zimonet.vivisimo.com/vivisimo/cgi-bin/query-meta?v%3asources=office&query=api%20documentation%20DOCUMENT_KEY%3a%22file%3a%2f%2f%3a80%2foffice%2fDocumentation%2f8.0-0%2fvelocity_api_developers_guide.pdf%2f%22&v%3aframe=cache&search-vfile=viv_mkzSm7&search-state=%28root%29%7croot&
#
module Velocity
  class Instance
    attr_accessor :v_app, :endpoint, :username, :password, :read_timeout, :open_timeout

    def initialize(args)
      @v_app = args[:v_app] || 'api-rest'
      @endpoint = args[:endpoint]
      @username = args[:username]
      @password = args[:password]
      @read_timeout = args[:read_timeout] || 120
      @open_timeout = args[:open_timeout] || 30
    end

    def call(function, args={})
      sanity_check
      puts "calling #{function} with args: #{args}"
      if args.class == Array and args.empty?
        args = {}
      elsif !args.empty? and args.first.class == Hash
        args = args.first
      end
      params = base_parameters.merge( {'v.function' => function}.merge(args))
      rest_call params
    end

    def rest_call params
      #RestClient.get(endpoint, :params => params) #this doesn't allow for
      #timeouts
      req = {:method => :get, :url => endpoint, :headers => {:params => params } } #restclient stupidly puts query params in the...headers?
      req[:timeout] = read_timeout if read_timeout
      req[:open_timeout] = open_timeout if open_timeout
      puts "hitting #{endpoint} with params: #{params}"
      RestClient::Request.execute(req) 
    end

    def base_parameters
      {'v.app' => v_app, 
       'v.username' => username,
       'v.password' => password }
    end

    def ping
      result = call "ping"
      n = Nokogiri::XML(result)
      return true if n.root.name == 'pong'
      return false
    end

    def collections
      result = call "search-collection-list-xml"
      n = Nokogiri::XML(result)
      raise Error if n.root.name != 'vse-collections' #TODO: make this error handling better
      n.xpath('/vse-collections/vse-collection').collect do |c|
        SearchCollection.new_from_xml(:xml => c, :instance => self) #initialize a new one, set its instance to me
      end
    end

    def sanity_check
      raise ArgumentError, "You must specify a v.app." if v_app.nil?
      raise ArgumentError, "You must specify a username." if username.nil?
      raise ArgumentError, "You must specify a password." if password.nil?
      raise ArgumentError, "You must specify an endpoint." if endpoint.nil?
    end


    class APIModel

      def initialize(instance)
        @instance = instance
      end

      def resolve(operation)
        [prefix, operation].join '-'
      end

      def dasherize(string)
        string.to_s.downcase.gsub(/_/,'-')
      end

      def prefix
        nil
      end
      def method_missing(function, *args, &block)
        @instance.call resolve(function), args
      end
    end

    class XMLResponse < Hash

    end

    class Query < APIModel
      def prefix
        "query"
      end

      def search args
        QueryResponse.new(@instance.call(resolve('search'), args))
      end

    end

    class QueryResponse
      attr_accessor :doc

      def initialize xml
        @doc = Nokogiri::XML xml
      end

      def results?
        documents.size > 0
      end

      def documents
        doc.xpath("/query-results/list/document").collect do |d|
          Document.new d
        end
      end
    end

    class Document
      attr_accessor :doc

      def initialize node
        @doc = node
      end

      def contents
        doc.xpath "content"
      end

      def content name
        doc.xpath "content[@name='#{name}']"
      end

      def attribute name
        doc.attribute name
      end
      def attributes
        doc.attributes
      end
      def xpath xpath
        doc.xpath xpath
      end
    end

    
    def query
      Query.new(self)
    end

    class SearchCollection < APIModel
      attr_accessor :name, :instance

      def prefix
        "search-collection"
      end

      def initialize(collection_name)
        @name = collection_name
      end

      #collection methods from API
     
      def status
        Status.from_xml instance.call resolve("status"), {:collection => name}
      end

      def self.new_from_xml(args)
        sc = SearchCollection.new(args[:xml].attributes['name'].to_s)
        sc.instance = args[:instance]
        return sc
      end

      class Status < XMLResponse
        #this is mostly just an easy interface to the status xml hash
        attr_writer :hash

        def initialize
          hash = {}
        end

        def from_xml xml
          super.from_xml(xml)["vse_status"]
        end

        def crawler
          self["crawler_status"]
        end

        def indexer
          self["vse_index_status"]
        end
      end
    end
  end
end
