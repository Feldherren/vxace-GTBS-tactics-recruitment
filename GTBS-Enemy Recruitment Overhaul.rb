# Overhauls enemy capture and invite in GTBS to create clone actors, using Fomar's Clone Actor script, instead, hence allowing the recruitment of unlimited generics.
# Recruited units retain their name (so the base actor can have something purely descriptive), level and can be given initial equipment via notebox tags.

module Recruitment
  # Variable to store ID of new clone in whilst it's customised.
  NEW_ACTOR_VAR = 1
  
  MATCH_EQUIP = /(<recruit equipment:\s*\d*,\s*\d*>),?+/i
  MATCH_PARAMS = /(<recruit \w\w\w:\s*[\+\-]\s*\d*>)/i
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
    
    # get weapon, armour tags from original enemy
    if (equip_tags = $data_enemies[battler.enemy_id].note.scan(Recruitment::MATCH_EQUIP))
      $i = 0
      while $i < equip_tags.length do
        match = equip_tags[$i].to_s.match( /<recruit\s*equipment\s*:\s*(\d*),\s*(\d*)>/i )
        if match[0].to_i == 0
          # equipment is a weapon
          $game_party.gain_item($data_weapons[match[1].to_i], 1)
        else
          # equipment is something else
          $game_party.gain_item($data_armors[match[1].to_i], 1)
        end
        #$game_actors[id].change_equip_by_id(slot_id, item_id) # for changing equipment
        $game_actors[$game_variables[Recruitment::NEW_ACTOR_VAR]].change_equip_by_id(match[0].to_i, match[1].to_i)
        $i += 1
      end
    end
    if (param_tags = $data_enemies[battler.enemy_id].note.scan(Recruitment::MATCH_PARAMS))
      $i = 0
      while $i < param_tags.length do
        if (match = param_tags[$i].to_s.match( /<recruit (MHP|MMP|ATK|DEF|MAT|MDF|AGI|LUK)\s*:\s*(\+|\-)\s*(\d*)>/i ))
          #puts "Param: " + match[1] + " " + match[2] + match[3]
          
          $paramvalue = match[3].to_i
          
          $paramchange = -1
          if match[1].downcase == "mhp"
            $paramchange = 0
          elsif match[1] == "mmp"
            $paramchange = 1
          elsif match[1] == "atk"
            $paramchange = 2
          elsif match[1] == "def"
            $paramchange = 3
          elsif match[1] == "mat"
            $paramchange = 4
          elsif match[1] == "mdf"
            $paramchange = 5
          elsif match[1] == "agi"
            $paramchange = 6
          elsif match[1] == "luk"
            $paramchange = 7
          end
          
          if match[2] == "-"
            $paramvalue = $paramvalue * -1
          end
          
          if $paramchange != -1
            $game_actors[$game_variables[Recruitment::NEW_ACTOR_VAR]].add_param($paramchange, $paramvalue)
          end
        end
        $i += 1
      end
    end
  end
end