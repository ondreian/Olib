load "lib/Olib/bounty.rb"

$bounty = nil

def checkbounty
  $bounty
end

RSpec.describe Bounty do
  it "handles no task" do
    $bounty = "You are not currently assigned a task."
    expect(Bounty.type).to be :none
  end

  it "handles success => guild" do
    $bounty = "You have succeeded in your task and can return to the Adventurer's Guild"
    expect(Bounty.type).to be :succeeded
  end

  it "handles success => guard" do
    $bounty = "You succeeded in your task and should report back to"
    expect(Bounty.type).to be :report_to_guard
  end

  context "needs to talk to NPC" do
    it "can tell we were assigned a cull task" do
      $bounty ="It appears they have a creature problem they'd like you to solve"
    end

    it "can tell we were assigned an heirloom task" do
      $bounty ="It appears they need your help in tracking down some kind of lost heirloom"
      expect(Bounty.type).to be :get_heirloom
    end

    it "can tell we were assigned a skins task" do
      $bounty ="The local furrier Furrier has an order to fill and wants our help"
      expect(Bounty.type).to be :get_skin_bounty
    end

    it "can tell we were assigned a gem task" do
      $bounty ="The local gem dealer, GemTrader, has an order to fill and wants our help"
      expect(Bounty.type).to be :get_gem_bounty
    end


    it "can tell we were assigned a herb task" do
      $bounty ="Hmm, I've got a task here from the town of Ta'Illistim.  The local herbalist's assistant, Jhiseth, has asked for our aid.  Head over there and see what you can do.  Be sure to ASK about BOUNTIES."
      expect(Bounty.type).to be :get_herb_bounty
    end

    it "can tell we were assigned a rescue task" do
      $bounty ="It appears that a local resident urgently needs our help in some matter"
      expect(Bounty.type).to be :get_rescue
    end

    it "can tell we were assigned a bandit task" do
      $bounty ="The taskmaster told you:  \"Hmm, I've got a task here from the town of Ta'Illistim.  It appears they have a bandit problem they'd like you to solve.  Go report to one of the guardsmen just inside the Ta'Illistim City Gate to find out more.  Be sure to ASK about BOUNTIES.\""
      expect(Bounty.type).to be :get_bandits
    end
  end
end