RSpec.shared_examples 'lambda function' do
  it 'returns a well-formed response for Lambda' do
    expect(lambda_result.class).to eq Hash
  end

  it 'has 3 keys' do
    expect(lambda_result.keys.size).to eq 3
  end

  it 'body is a string' do
    expect(lambda_result[:body].class).to eq String
  end

  it 'body is a JSON string' do
    expect(JSON.parse(lambda_result[:body]).class).to eq Hash
  end
end
