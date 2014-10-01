require 'pi_piper'

class ShiftRegister
  attr_reader :data_pin, :clock_pin, :latch_pin, :blank_pin, :clear_pin, :memory
  attr_accessor :invert

  def initialize(pins, register_count = 1, register_size = 8)
    assign_pins(pins)

    @memory = Array.new((register_count * register_size), :off)
    invert = false

    clear_pin.on
    blank_pin.off
  end

  def register(*data)
    @memory = new_buffer(data)
    shift_out!
  end

  def shift_out!
    memory.reverse.each_with_index do |v, i|
      set_data(v)
    end
    latch
  end

  def clear(write = false)
    memory.map!{ :off }

    shift_out! if write
  end

  def off
    blank_pin.on
  end

  def on
    blank_pin.off
  end

  def set_memory(memory_hash)
    memory_hash.each { |k, v| memory[k] = v }
  end

  private

  def latch
    latch_pin.on
    latch_pin.off
  end

  def new_buffer(data)
    Array.new(memory.length) { |i| data[i] || :off }
  end

  def set_data(state = :on)
    state = invert_state(state) if invert
    data_pin.send(state)
    clock_in
    data_pin.off
  end

  def invert_state(state)
    if state == :on
      state = :off
    else
      state = :on
    end
  end

  def clock_in
    clock_pin.on
    clock_pin.off
  end

  def assign_pins(pins)
    @data_pin = assign_pin(pins.fetch(:data))
    @clock_pin = assign_pin(pins.fetch(:clock))
    @latch_pin = assign_pin(pins.fetch(:latch))
    @clear_pin = assign_pin(pins.fetch(:clear))
    @blank_pin = assign_pin(pins.fetch(:blank))
  end

  def assign_pin(pin)
    PiPiper::Pin.new(:pin => pin, :direction => :out)
  end
end
