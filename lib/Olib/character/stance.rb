class Stance
  OFFENSIVE = "offensive"
  ADVANCE   = "advance"
  FORWARD   = "forward"
  NEUTRAL   = "neutral"
  GUARDED   = "guarded"
  DEFENSIVE = "defensive"

  ENUM = [OFFENSIVE, ADVANCE, FORWARD, NEUTRAL, GUARDED, DEFENSIVE]

  def self.change(stance)
    waitcastrt?
    waitrt?
    fput "stance #{stance}" unless checkstance == stance
    sleep 0.1
    self
  end

  ENUM.each do |stance|
    Stance.define_singleton_method((stance.to_s + "?").to_sym) do
      checkstance == str
    end

    Stance.define_singleton_method(stance.to_sym) do
      change stance
    end
  end
end