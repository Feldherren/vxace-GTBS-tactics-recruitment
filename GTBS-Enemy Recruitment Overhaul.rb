# Requires Fomar's Clone Actors script
# With this and the clone script added, invited actors are added to the party twice under certain circumstances - observed when inviting one slime and having it kill the others?

module Recruitment
  # Variable to store ID of new clone in whilst it's customised.
  NEW_ACTOR_VAR = 1
  
  MATCH_EQUIP = /<recruit\s*equipment\s*:\s*(\d*),\s*(\d*)>/i
  MATCH_PARAMS = /^<recruit (MHP|MMP|ATK|DEF|MAT|MDF|AGI|LUK)\s*:\s*(\+|\-)\s*([\d]*)>/i
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
      customise_clone(id, battler)
      $game_party.add_actor($game_variables[Recruitment::NEW_ACTOR_VAR])
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
    # fix new actor's name
    $game_actors[$game_variables[Recruitment::NEW_ACTOR_VAR]].name = battler.name()
    # get enemy level
    targetLevel = battler.level
    currentLevel = $game_actors[$game_variables[Recruitment::NEW_ACTOR_VAR]].level
    while currentLevel < targetLevel  do
      $game_actors[$game_variables[Recruitment::NEW_ACTOR_VAR]].level_up()
      currentLevel +=1
    end
    
    $data_enemies[battler.enemy_id].note.split(/[\r\n]+/).each { |line|
      case line
      #---
        when (match = line.match(Recruitment::MATCH_EQUIP))
          puts match[1].to_s + ", " + match[2].to_s
          if match[1].to_i == 0
            # equipment is a weapon
            $game_party.gain_item($data_weapons[match[2].to_i], 1)
          else
            # equipment is something else
            $game_party.gain_item($data_armors[match[2].to_i], 1)
          end
          #$game_actors[id].change_equip_by_id(slot_id, item_id) # for changing equipment
          $game_actors[$game_variables[Recruitment::NEW_ACTOR_VAR]].change_equip_by_id(match[1].to_i, match[2].to_i)
        end
      #---
    } # self.note.split
    
    # get weapon, armour tags from original enemy
    
    # get stat tags from original enemy
  end
end