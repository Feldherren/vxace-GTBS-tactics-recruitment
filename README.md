GTBS Clone Recruitment v1.0, by Feldherren

---------
Changelog
---------
  v1.0 - first released version of script
  v1.1 - user can now specify skills clone actor will start with. Also, general
         fixes and tweaks, such as removing test code.

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
Create at least one basic actor from which to make clones; this actor 
should be whatever class you want the resulting clones to be.
Set up an enemy as recruitable or capturable as normal in GTBS, and point it 
at the basic actor created above. Optionally also set its level, which will 
be used by the recruited actor.
  
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