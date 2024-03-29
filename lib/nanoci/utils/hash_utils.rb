# frozen_string_literal: true

# Hash utils methods
class Hash
  # flattens hash
  # @param hash [Hash] source hash
  # @param prefix [String] optional prefix for keys
  def flatten_hash_value(prefix = nil)
    flat_hash = flat_map do |k, v|
      k = "#{prefix}.#{k}" unless prefix.nil?
      if v.is_a? Hash
        v.flatten_hash_value(k)
      else
        { k => v }
      end
    end
    flat_hash.reduce(:merge).symbolize_keys
  end

  # convert string keys to symbols
  # @return [Hash<Symbol, String|Hash|Array>]
  def symbolize_keys
    transform_keys { |k| k.is_a?(String) ? k.to_sym : k }.transform_values do |v|
      symbolize_value(v)
    end
  end

  private

  def symbolize_value(value)
    case value
    when Hash then value.symbolize_keys
    when Array then value.map { |i| i.is_a?(Hash) ? i.symbolize_keys : i }
    else value
    end
  end
end
