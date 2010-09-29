# Change api key for karma, so we can expect it.
KARMA_API_KEY = 'karmatestapikey'

# Stub out the actual karma server so it's talking to our fake data instead.
def stub_karma_server(json=nil)
  # A sample json response from the karma server.
  json ||= %{
    {
      "total":7,
      "user_path":"/users/bobexamplecom.json",
      "user":"bobexamplecom",
      "tags": {
        "add_annotation": {
          "total":4,
          "adjustments_path":"/users/bobexamplecom/tags/add_annotation/adjustments.json",
          "tag_path":"/tags/add_annotation.json"
         },
         "add_comment": {
           "total":3,
           "adjustments_path":"/users/bobexamplecom/tags/add_comment/adjustments.json",
           "tag_path":"/tags/add_comment.json"
         }
       }
     }
  }
  # A RestClient Resource that returns json in response to a get request, and
  # accepts a post request.
  resource = stub('resource', :get => json, :post => nil, :put => nil)
  # Stub the RestClient Resource to use our objects instead of querying the server.
  RestClient::Resource.stub!(:new => resource)
end
