def Olib
  class Wand < Gameobj_Extender
    def wave(target)
      fput "wave #{@id} at #{target}"
      waitcastrt?
      waitrt?
    end
  end
end