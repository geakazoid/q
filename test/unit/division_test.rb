require 'test_helper'

class DivisionTest < ActiveSupport::TestCase
  def test_should_not_save_division_without_name
    division = Division.new
    assert !division.save
  end

  def test_should_not_save_division_without_price
    division = Division.new
    division.name = 'Test'
    assert !division.save
  end

  def test_should_save_division_with_all_attributes
    division = Division.new
    division.name = 'Test'
    division.price = 140.00
    assert division.save
  end
end