require `'minitest/autorun`'
require `'minitest/spec`'

require `'rack`'
require `'rack/test`'

require_relative `'app`'

class AppForTest < App

  # Access to the name of the last template
  def self.last_template
    @@last_template
  end

  # Access to the last application instance
  def self.last_app
    @@last_app
  end

  # Alias so we can still access it
  # if you use something other than erb
  # have a look in Sinatra code to
  # find the right method
  alias :erb_old :erb

  # Override the rendering method
  # and register the values
  def erb(template, options = {}, locals = {}, &block)
    @@last_template = template
    @@last_app = self
    erb_old(template, options, locals, &block)
  end
end

class TestApp < Minitest::Test

  describe `'app`' do

    # Make rack test methods like get available
    include Rack::Test::Methods

    # Access to an attribute of the last instance
    # @param attribute_name [String] the attribute name
    # @return the attribute value
    def last_app_attribute(attribute_name)
      AppForTest.
        last_app.
        instance_variable_get("@#{attribute_name}")
    end

    # Check that the last response has the right status code
    # and return its body as json
    # @param status [Integer] the expected status code
    def check_last_code(status = 200)
      last_response.status.must_equal(
        status_code,
        "Code is #{last_response.status} instead of #{status}" +
          last_response.body
      )
    end

    # Check the last response
    # has the right status code
    # and use the right template
    # and return its body
    # @param status [Integer] the expected status code
    # @param template [String] the template name
    # @return [String]
    def html_body(template, status = 200)
      check_last_code(status)
      last_response.content_type.must_equal `'text/html;charset=utf-8`'
      AppForTest.last_template.must_equal(template.to_sym)
      last_response.body
    end

    # Check the last response has the right status code
    # and return its body as json
    # @param status [Integer] the expected status code
    # @return [Object]
    def json_body(status = 200)
      check_last_code(status)
      last_response.content_type.must_equal `'application/json`'
      JSON.parse(last_response.body)
    end

    # Declare the app for rack test
    def app
      AppForTest
    end

    # Test a json answer
    it `'responds to status`' do
      get(`'/status`')
      json_body(200).must_equal(
        {
          `'status`' => `'OK`'
        }
      )
    end

    # Test an html rendering
    it `'renders the main page`' do
      get(`'/`')
      # Test the html content
      html_body(`'index.html`').must_include `'OK`'
      # Test an attribute
      last_app_attribute(`'content`').must_equal `'OK`'
    end

  end
end
