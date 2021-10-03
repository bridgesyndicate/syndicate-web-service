require 'json'

def deep_to_h os
  os.each_pair.map do |key, value|
    [
      key,
      case value
      when OpenStruct then value.deep_to_h
      when Array then value.map {|el| el.class == OpenStruct ? deep_to_h(el) : el}
      else value
      end
    ]
  end.to_h
end

def test
json=<<HERE
{
  "string": "fooval",
  "string_array": [
    "arrayval"
  ],
  "int": 2,
  "hash_array": [
    {
      "string": "barval",
      "string2": "bazval"
    },
    {
      "string": "barval2",
      "string2": "bazval2"
    }
  ]
}
HERE

os = JSON.parse(json, object_class: OpenStruct)
puts JSON.pretty_generate os.to_h
puts JSON.pretty_generate deep_to_h(os)
end
