# Requires Fomar's Clone Actors script
# With this and the clone script added, invited actors are added to the party twice under certain circumstances - observed when inviting one slime and having it kill the others?

module Recruitment
  # Variable to store ID of new clone in whilst it's customised.
  NEW_ACTOR_VAR = 1
end

class Scene_Battle_TBS < Scene_Base
  alias add_remove_invited_old add_remove_invited
  def add_remove_invited(battler)
    if (battler.enemy? && !battler.death_state? && battler.team == Battler_Actor && 
                                  !battler.states.include?(GTBS::CHARM_ID))  
        
      id = GTBS.capture_to_actor(battler.enemy_id)
      return if id ==0
      #$game_party.add_actor(id)
      # NEW
      $game_variables[Recruitment::NEW_ACTOR_VAR]=$game_actors[id,true]
      $game_party.add_actor($game_variables[Recruitment::NEW_ACTOR_VAR])
      customise_clone(id, battler)
      # END NEW STUFF
    elsif (battler.actor? && !battler.death_state? && battler.team != Battler_Actor &&
                                !battler.states.include?(GTBS::CHARM_ID))
      $game_party.remove_actor(battler.id)
    elsif (battler.actor? && !battler.death_state? && battler.team == Battler_Actor && 
        !battler.states.include?(GTBS::CHARM_ID) && !$game_party.all_members.include?(battler) &&
        !$game_party.neutrals.include?(battler) && !battler.is_summoned?)
      $game_party.add_actor(battler.id)
    end
  end
  
  def customise_clone(id, battler)
    # get enemy name
    name = battler.name()
    puts name
    $game_actors[Recruitment::NEW_ACTOR_VAR].name = name
    # get enemy level
    # get weapon, armour tags from original enemy
    #$game_actors[id].change_equip_by_id(slot_id, item_id) # for changing equipment
  end
end