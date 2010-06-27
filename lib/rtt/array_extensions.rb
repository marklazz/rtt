class Array

  def same(array)
    temp_array = self.clone
    temp_array.length == array.length &&
      (temp_array-array).length == 0
  end
end
