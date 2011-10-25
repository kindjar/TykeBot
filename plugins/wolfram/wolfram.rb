# allow access to the worlfram alpha api
require 'net/http'
require 'cgi'
require 'rexml/document'
class WolframApi

#  API_KEY='FILLMEIN'
  DEFAULT_KEY='FILLMEIN'
  API_KEY = $bot.config[:wolframkey] || DEFAULT_KEY
  QUERY_URL="http://api.wolframalpha.com/v2/query?appid=#{API_KEY}&input=%s&format=plaintext"

  # returns array of [title, text] pairs
  def query(s)
    if "#{API_KEY}" == "#{DEFAULT_KEY}"
      [['ERROR',"Wolfram Alpha key has not been configured.  Please add a wolframkey config option"]]
    else
      parse(do_query(s))
    end
  end

  def parse(xml)
    doc = REXML::Document.new(xml) 
    results = []
    doc.elements.each('queryresult/pod') do |pod|
      title = pod.attributes['title']
      pod.elements.each('subpod/plaintext') do |txt|
        results << [title,txt.text]
      end
    end
    results
  end
  
private

  def do_query(s)
    get(QUERY_URL % CGI.escape(s)).body
  end

  def get(uri_str, limit = 10)
    raise ArgumentError, 'HTTP redirect too deep' if limit == 0

    url = URI.parse(uri_str)
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Get.new(url.path + "?" + url.query)
    response = http.start {|http| http.request(request) }

    case response
    when Net::HTTPSuccess     then response
    when Net::HTTPRedirection then fetch(response['location'], limit - 1)
    else
      response.error!
    end
  end

end