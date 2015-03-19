require 'minitest/autorun'
require_relative '../shift_register'

class Pin
  # def initialize
  #   @on = false
  # end

  def on
    @on = true
  end

  def off
    @on = false
  end

  def on?
    @on
  end

  def off?
    @on
  end

end

describe ShiftRegister, "Demonstration of ShiftRegister" do

  # Runs codes before each expectation
  before do
    @data_pin = Pin.new
    @latch_pin = Pin.new
    @clock_pin = Pin.new
    @blank_pin = Pin.new
    @clear_pin = Pin.new

    @sh = ShiftRegister.new({data: @data_pin, latch: @latch_pin, clock: @clock_pin, blank: @blank_pin, clear: @clear_pin})
  end

  # Runs code after each expectation
  after do
    # @data_pin.destroy!
    # @latch_pin.destroy!
    # @clock_pin.destroy!
    # @blank_pin.destroy!
    # @clear_pin.destroy!
    # @sh.destroy!
  end


  describe "#initalize" do

    it "assigs the pins" do
      @sh.data_pin.must_equal @data_pin
      @sh.clock_pin.must_equal @clock_pin
      @sh.latch_pin.must_equal @latch_pin
      @sh.clear_pin.must_equal @clear_pin
      @sh.blank_pin.must_equal @blank_pin
    end

    it "sets clear_pin on" do
      @sh.clear_pin.on?.must_equal true
    end

    it "sets clock_pin off" do
      @sh.clear_pin.off?.must_equal true
    end

  end


end
