require 'pi_piper'
require 'travis/pro'
require_relative 'shift_register'

class TravisMonitor
  REPOSITORY_PIN_MAP = {
    'americanhonors/quad-styles' => 0,
    'americanhonors/quad-advisor' => 1
  }

  attr_reader :shift_register

  def initialize
    p ENV['TRAVIS_ACCESS_TOKEN']
    Travis::Pro.access_token = ENV['TRAVIS_ACCESS_TOKEN']
    @running = false
    @shift_register = ShiftRegister.new({ data: 17, latch: 18, clock: 27, blank: 22, clear: 23 }, 3)
    @shift_register.invert = true
    @shift_register.clear(true)
    start_listeners
  end

  def build_started(e)
    map = REPOSITORY_PIN_MAP[e.repository.slug]
    return unless map
    shift_register.memory[map + 16] = :on #build
    shift_register.memory[map + 8]  = :off #pass
    shift_register.memory[map] = :off      #fail
    shift_register.shift_out!
  end

  def build_finished(e)
    map = REPOSITORY_PIN_MAP[e.repository.slug]
    return unless map

    shift_register.memory[map + 16] = :off #build
    if e.payload['state'] == 'passed'
      shift_register.memory[map + 8] = :on #pass
    else
      shift_register.memory[map] = :on #fail
    end

    shift_register.shift_out!
  end


  def start_listeners

    Travis::Pro.listen do |listener|

      listener.on('job:started') do |e|
        p e.inspect
        build_started(e)
      end

      listener.on('job:finished')  do |e|
        p e.inspect
        build_finished(e)
      end

    end

  end

end

TravisMonitor.new
