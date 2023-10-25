class Petstore < Sinatra::Base

  type `'PetInput`', {
    :required => [:name],
    :properties => {
      :name => {
        :type => String,
        :example => `'doggie`',
        :description => `'The pet name`',
        :maxLength => 2048,
      }
    }
  }


  # Patch post method to add swagger validation
  # Pseudo code, sinatra doesn`'t work this way
  def post(path, opts = {}, &block)
    settings.swagger_validator.check_params(path, options)
    super
  end

  endpoint_summary `'Create a pet`'
  endpoint_response 200, `'Pet`', `'Standard response`'
  endpoint_parameter :pet, `'The pet`', :body, true, `'PetInput`'
  post `'/pet/`' do |id|
    content_type :json
    # we don`'t need to validate that the pet name`'s length is < 2048
    # since it`'s already specified in the swagger file
    ...
  end
end
