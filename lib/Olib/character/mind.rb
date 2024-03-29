require "ostruct"

class Mind
  @@states = OpenStruct.new(
    :saturated        => "saturated",
    :must_rest        => "must rest",
    :numbed           => "numbed",
    :becoming_numbed  => "becoming numbed",
    :muddled          => "muddled",
    :clear            => "clear",
    :fresh_and_clear  => "fresh and clear",
    :clear_as_a_bell  => "clear as a bell"
  )
  ##
  ## @brief      access the states
  ##
  ## @return     OpenStruct
  ##
  def Mind.states
    @@states
  end
  ##
  ## @brief      alias for Lich checkmind method
  ##
  ## @return     String
  ##  
  def Mind.state
    checkmind
  end
  ##
  ## @brief      returns the percentage of your character's mind
  ##
  ## @return     Fixnum
  ##
  def Mind.percent
    percentmind
  end
  ##
  ## dynamically defines all methods to check state
  ## 
  ## Example:
  ##  Mind.saturated?
  ##  Mind.must_rest? 
  ##
  Mind.states.each_pair { |name, str|
    Mind.define_singleton_method((name.to_s + "?").to_sym) do
      Mind.state.eql?(str)
    end

    Mind.define_singleton_method("while_#{name.to_s}".to_sym) do
      wait_while("waiting while mind / %s" % str) { 
        Mind.state.eql? str
      }
    end

    Mind.define_singleton_method("until_#{name.to_s}".to_sym) do
      wait_until("waiting until mind / %s" % str) { 
        Mind.state.eql?(str)
      }
    end
  }
end