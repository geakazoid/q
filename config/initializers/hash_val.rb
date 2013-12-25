class Hash
  # Fetch a nested hash value
  def hash_val(*attrs)
    attr_count = attrs.size
    current_val = self
    for i in 0..(attr_count-1)
      attr_name = attrs[i]
      return current_val[attr_name] if i == (attr_count-1)
      return nil if current_val[attr_name].nil?
      current_val = current_val[attr_name]
    end
    return nil
  end
end