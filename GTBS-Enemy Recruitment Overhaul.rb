=begin
GTBS Clone Recruitment v1.0, by Feldherren

---------
Changelog
---------
  v1.0 - first released version of script
  v1.1 - user can now specify skills clone actor will start with. Also, general
         fixes and tweaks, such as removing test code.
  v1.2 - user can now specify class clone actor will start with and level as.
         Also removed a useless thing that was never really used in the first
         place.

-------
General
-------

Requires: GTBS (GubiD), Clone Actors (Fomar)

Overhauls enemy capture and invite in GTBS to create clone actors, using Fomar's
Clone Actor script instead of the standard add_actors method, allowing for the 
recruitment of unlimited generics.
Recruited units retain their name (so the base actor can be called something 
purely descriptive, as it'll be given the enemy name on cloning) and level. They
can be given initial equipment via notebox tags, and can start with modified 
parameters.

-----
Usage
-----
Set up GTBS, and the Clone Actors script
Place GTBS Clone Recruitment script below GTBS scripts, and above Main.
Create at least one basic actor from which to make clones.
Set up an enemy as recruitable or capturable as normal in GTBS, and point it 
at the basic actor created above. Optionally also set its level, which will 
be used by the recruited actor.
  
Class:
  Add the following tag to the enemy notebox: <recruit class: [id]>
  Replace [id] with the ID of the class.
  When recruited, the resulting clone actor will have the specified class, and 
  will be levelled as if from level 1 in that class (if you're using Yanfly's 
  Parameter Bonus Growth script or something similar).
Equipment:
  Add the following tag to the enemy notebox: <recruit equipment: [slot], [id]>
  Replace [slot] with equipment slot and [id] with the ID of the weapon or 
  armour
  When recruited, the resulting clone actor will have the specified equipment 
  in the specified slot, if capable of equipping it.
Parameters:
  Add the following tag to the enemy's notebox: <recruit [param]: [amount]>
  Valid values for [param] are: MHP, MMP, ATK, DEF, MAT, MDF, AGI, LUK
  [amount] can be either positive or negative.
  When recruited, the resulting clone actor will have the specified bonus or 
  penalty to their stats.
Skills
  Add the following tag to the enemy's notebox: <recruit skill: [id]>
  Valid values for [id] are skill IDs.
  When recruited, the resulting clone actor will be able to use the specified 
  skill.
=end

module Recruitment
  MATCH_CLASS = /<recruit class:\s*(\d*)>/i
  MATCH_EQUIPS = /(<recruit equipment:\s*\d*,\s*\d*>),?+/i
  MATCH_PARAMS = /(<recruit \w\w\w:\s*[\+\-]\s*\d*>)/i
  MATCH_SKILLS = /<recruit skill:\s*(\d*)>/i # note: may only match once per enemy? look into this
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
      $new_clone = 0
      $new_clone=$game_actors[id,true]
      customise_clone(id, battler)
      $game_party.add_actor($new_clone)
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
    # Name
    $game_actors[$new_clone].name = battler.name()
	# Class
	$game_actors[$new_clone].change_class($data_enemies[battler.enemy_id].note.scan(Recruitment::MATCH_CLASS)[0][0].to_i)
    # Level
    targetLevel = battler.level
    currentLevel = $game_actors[$new_clone].level
    while currentLevel < targetLevel  do
      $game_actors[$new_clone].level_up()
      currentLevel +=1
    end
    
    # Equipment
    if (equip_tags = $data_enemies[battler.enemy_id].note.scan(Recruitment::MATCH_EQUIPS))
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
        $game_actors[$new_clone].change_equip_by_id(match[0].to_i, match[1].to_i)
        $i += 1
      end
    end
    
    # Parameters
    if (param_tags = $data_enemies[battler.enemy_id].note.scan(Recruitment::MATCH_PARAMS))
      $i = 0
      while $i < param_tags.length do
        if (match = param_tags[$i].to_s.match( /<recruit (MHP|MMP|ATK|DEF|MAT|MDF|AGI|LUK)\s*:\s*(\+|\-)\s*(\d*)>/i ))
          
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
            $game_actors[$new_clone].add_param($paramchange, $paramvalue)
          end
        end
        $i += 1
      end
    end
    
    # Skills
    if (skill_tags = $data_enemies[battler.enemy_id].note.scan(Recruitment::MATCH_SKILLS))
      $i = 0
      while $i < skill_tags.length do
        $game_actors[$new_clone].learn_skill(skill_tags[$i][0].to_i)
        $i += 1
      end
    end
  end
end