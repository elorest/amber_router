require "radix"
require "./route_set"
require "benchmark"

ROUTE_LIBRARY = {
  "/get/"                                                                               => :root,
  "/get/users/:id"                                                                      => :users,
  "/get/users/:id/books"                                                                => :users_books,
  "/get/books/:id"                                                                      => :books,
  "/get/books/:id/chapters"                                                             => :book_chapters,
  "/get/books/:id/authors"                                                              => :book_authors,
  "/get/books/:id/pictures"                                                             => :book_pictures,
  "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z"                            => :alphabet,
  "/get/var/:b/:c/:d/:e/:f/:g/:h/:i/:j/:k/:l/:m/:n/:o/:p/:q/:r/:s/:t/:u/:v/:w/:x/:y/:z" => :variable_alphabet,
  "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/:id"                           => :foobar_bat,
  "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbom/:id"                           => :foobar_bom,
}

module Jewel
  class Result
    # property params : Hash(String, String)
    property payload : Symbol? = nil
    setter params : Regex::MatchData?

    def initialize(@payload, @params)
    end

    def found?
      !@payload.nil?
    end

    def params
      if @params
        Hash(String, String).new.tap do |h| 
          params.to_h.each{|k, v| h[k.to_s] = v.to_s unless k.is_a?(Int32)}
        end
      else
        Hash(String, String).new
      end
    end
  end

  ROUTES = {} of Nil => Nil 

  macro routes(path, body)
    {% ROUTES[path.gsub(/\*/, "~")] = body %}
  end 

  macro finished
    class Routes
      def find(path)
        case path
          {% for path in ROUTES.keys %}
            {% if path.includes?(':') %}  
            when /^{{path.split("/").map{|p|p.starts_with?(':') ? "(?<" + p.gsub(/\:/, "") + ">[^$\\/]+)" : p}.join("\\/").id}}$/
              return Result.new({{ROUTES[path]}}, $~)
            {% else %}
              {% if path.includes?('~') %}
              when /^{{(path.gsub(/\//, "\\/").split("~").first + "[^$]").id}}$/
                return Result.new({{ROUTES[path]}}, nil)
              {% else %}
              when {{path}}
                return Result.new({{ROUTES[path]}}, nil)
              {% end %}
            {% end %}
          {% end %}
        else
          Result.new(nil, nil)
        end 
      end 
    end 
  end 
end

{% for path, body in ROUTE_LIBRARY %}
  Jewel.routes({{path}}, {{body}})
{% end %}


# router = Jewel::Routes.new
# puts router.find("/get/books/23/chapters").inspect
class Benchmarker
  getter route_library
  getter route_checks
  getter amber_router
  getter radix_router
  getter jewel_router

  def initialize
    @route_library = ROUTE_LIBRARY 

    @amber_router = Amber::Router::RouteSet(Symbol).new
    @radix_router = Radix::Tree(Symbol).new
    @jewel_router = Jewel::Routes.new

    route_library.each do |k, v|
      radix_router.add(k, v)
      amber_router.add(k, v)
    end
  end

  def run_check(router, check, expected_result)
    result = router.find(check)

    if expected_result.nil?
      raise "returned a result when it shouldn't've" unless result.found? == false
      return
    end

    actual_result = result.payload

    if actual_result != expected_result
      raise "#{actual_result} did not match #{expected_result}"
    end
  end

  def compare(name : String, route : String, result : Symbol?)
    puts route

    Benchmark.ips do |x|
      x.report("router: #{name}") { run_check(amber_router, route, result) }
      x.report("radix: #{name}") { run_check(radix_router, route, result) }
      x.report("jewel: #{name}") { run_check(jewel_router, route, result) }
    end

    puts
    puts
  end

  def go
    compare "root", "/get/", :root
    compare "deep", "/get/books/23/chapters", :book_chapters
    compare "wrong", "/get/books/23/pages", nil
    compare "many segments", "/get/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z", :alphabet
    compare "many variables", "/get/var/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6/7/8/9/0/1/2/3/4/5/6", :variable_alphabet
    compare "long_segments", "/get/foobarbizfoobarbizfoobarbizfoobarbizfoobarbizbat/3", :foobar_bat
  end
end

Benchmarker.new.go
