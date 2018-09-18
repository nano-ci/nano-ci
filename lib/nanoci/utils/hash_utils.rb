# frozen_string_literal: true

class Hash
  # convert string keys to symbols
  def symbolize_keys
    map do |k, v|
      [
        k.is_a?(String) ? k.to_sym : k,
        symbolize_value(v)
      ]
    end.to_h
  end

  private

  def symbolize_value(value)
    case value
    when Hash then value.symbolize_keys
    when Array then value.map(&->(x) { symbolize_value(x) })
    else value
    end
  end
end
