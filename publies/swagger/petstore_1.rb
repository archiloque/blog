class Petstore < Sinatra::Base

  type `'Pet`', {
    :required => [:id, :name],
    :properties => {
      :id => {
        :type => Integer,
        :format => `'int64`',
      },
      :name => {
        :type => String,
        :example => `'doggie`',
        :description => `'The pet name`',
        :maxLength => 2048,
      }
    }
  }

  endpoint_summary `'Finds a pet by its id`'
  endpoint_response 200, `'Pet`', `'Standard response`'
  endpoint_response 404, `'Error`', `'Pet not found`'
  endpoint_parameter :id, `'The pet id`', :path, true, Integer, { example => 1234, }
  endpoint_path `'/pet/{id}`'
  get %r{/pet/(\d+)} do |id|
    content_type :json
    # The name is too long compared to the swagger declaration
    {:id => 1, :name => (`'A`' * 2049)}
  end
end
