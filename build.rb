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
    Travis::Pro.access_token = ENV['TRAVIS_ACCCESS_TOKEN']
    @running = false
    @shift_register = ShiftRegister.new({ data: 17, latch: 18, clock: 27, blank: 22, clear: 23 }, 3)
  end

  def build_started(e)
    map = REPOSITORY_PIN_MAP[e.repository.slug]
    return unless map
    shift_map[map + 16] = 0 #build
    shift_map[map + 8]  = 1 #pass
    shift_map[map] = 1      #fail
    shift_register.shift_out!
  end

  def build_finished(e)
    map = REPOSITORY_PIN_MAP[e.repository.slug]
    return unless map

    shift_map[map + 16] = 1 #build
    if e.payload['state'] == 'passed'
      shift_map[map + 8] = 0 #pass
    else
      shift_map[map] = 0 #fail
    end

    shift_out
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
