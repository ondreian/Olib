load "stubs.rb"
load "lib/Olib/combat/creature.rb"
load "lib/Olib/bounty.rb"

RSpec.describe Bounty do
  it "handles no task" do
    Stubs.bounty = "You are not currently assigned a task."
    expect(Bounty.type).to be :none
  end

  context "needs to talk to NPC" do
    it "handles success => guild" do
      Stubs.bounty = "You have succeeded in your task and can return to the Adventurer's Guild"
      expect(Bounty.type).to be :succeeded
    end

    it "handles success => guard" do
      Stubs.bounty = "You succeeded in your task and should report back to"
      expect(Bounty.type).to be :report_to_guard
    end

    it "can tell we were assigned a cull task" do
      Stubs.bounty ="It appears they have a creature problem they'd like you to solve"
    end

    it "can tell we were assigned an heirloom task" do
      Stubs.bounty ="It appears they need your help in tracking down some kind of lost heirloom"
      expect(Bounty.type).to be :get_heirloom
    end

    it "can tell we were assigned a skins task" do
      Stubs.bounty ="The local furrier Furrier has an order to fill and wants our help"
      expect(Bounty.type).to be :get_skin_bounty
    end

    it "can tell we were assigned a gem task" do
      Stubs.bounty ="The local gem dealer, GemTrader, has an order to fill and wants our help"
      expect(Bounty.type).to be :get_gem_bounty
    end


    it "can tell we were assigned a herb task" do
      Stubs.bounty ="Hmm, I've got a task here from the town of Ta'Illistim.  The local herbalist's assistant, Jhiseth, has asked for our aid.  Head over there and see what you can do.  Be sure to ASK about BOUNTIES."
      expect(Bounty.type).to be :get_herb_bounty
    end

    it "can tell we were assigned a herb task" do
      Stubs.bounty ="The healer in Wehnimer's Landing, Surtey Akrash, is working on a concoction that requires some pennyroyal stem found near Darkstone Castle near Wehnimer's Landing.  These samples must be in pristine condition.  You have been tasked to retrieve 9 samples."
      expect(Bounty.type).to be :herb
    end

    it "can tell we were assigned a rescue task" do
      Stubs.bounty ="It appears that a local resident urgently needs our help in some matter"
      expect(Bounty.type).to be :get_rescue
    end

    it "can tell we were assigned get a bandit task" do
      Stubs.bounty ="The taskmaster told you:  \"Hmm, I've got a task here from the town of Ta'Illistim.  It appears they have a bandit problem they'd like you to solve.  Go report to one of the guardsmen just inside the Ta'Illistim City Gate to find out more.  Be sure to ASK about BOUNTIES.\""
      expect(Bounty.type).to be :get_bandits
    end

    it "can tell we have a culling task" do
      Stubs.bounty = "You have been tasked to suppress nedum vereri activity in the Abbey near Icemule Trace.  You need to kill 21 of them to complete your task."
      expect(Bounty.type).to be :cull
    end

    it "can tell we have an undead task" do
      Stubs.bounty = "You have been tasked to hunt down and kill a particularly dangerous crazed zombie that has established a territory in the Lunule Weald near Ta'Vaalor.  You can get its attention by killing other creatures of the same type in its territory."
      expect(Bounty.type).to be :dangerous
      expect(Bounty.tags.include?(:undead)).to be true
    end

    it "can tell we have a bandit task" do
      tasks = [
        "You have been tasked to suppress bandit activity on the old Logging Road near Kharam-Dzu.  You need to kill 19 of them to complete your task.",
      ]

      tasks.each do |task|
        Stubs.bounty = task
        expect(Bounty.type).to be :bandits
      end
    end

  end
end