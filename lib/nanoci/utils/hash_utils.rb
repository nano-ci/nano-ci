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
    transform_keys(&:to_sym).transform_values do |v|
      v.is_a?(Hash) ? v.symbolize_keys : v
    end
  end
end
