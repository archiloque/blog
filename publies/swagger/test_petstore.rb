# Patch the app to do the validation
class Petstore

  # This will validate the data against swagger
  set :swagger_validator, SwaggerValidator.new('swagger.json')

  # Patch get method to add swagger validation
  # Pseudo code, sinatra doesn't work this way
  def get(path, opts = {}, &block)
    result = super
    settings.swagger_validator.check_result(path, options, result)
    result
  end

class TestPetstore < Minitest::Test

  before do
    @swagger = read_swagger_configuration
  end

  it 'shoulen\'t have too long name' do
    get("/api/api/source/1/element?per_page=1")
    # you should get an error from the swagger validator
    # because the name is too long in the result
  end

end
