
module Olib
  module Char
    @@routines = {}

    def Char.hide
      while not hiding?
        waitrt?
        if @@routines[:hiding]
          @@routines[:hiding].call
        else
          fput 'hide'
        end
      end
      Char
    end

    def Char.visible?
      hiding? || invisible?
    end
    
    def Char.hiding_routine(procedure)
      @@routines[:hiding] = procedure
      Char
    end

    def Char.left
      GameObj.left_hand.nil? ? nil : Item.new(GameObj.left_hand)
    end

    def Char.right
      GameObj.right_hand.nil? ? nil : Item.new(GameObj.right_hand)
    end

  end

  # chainable
  def Olib.Char
    Olib::Char
  end

end