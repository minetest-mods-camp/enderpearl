local t = minetest.get_translator("enderpearl")

----------------------
-- ! Item Section ! -- 
----------------------


minetest.register_craftitem("enderpearl:ender_pearl", {
  description = "Enderpeal\n"..t("Left click to throw it@nIt will teleport you on the node it hits making you 2 damage@n(it won't work if you launch it to an unloaded world area)"),
  inventory_image = "enderpearl.png",
  stack_max = 16,
  on_use =
    function(_, player, pointed_thing)
      local ender_pearl = minetest.add_entity(vector.add({x=0, y=1.5, z=0}, player:get_pos()), "enderpearl:thrown_ender_pearl", player:get_player_name())
      local entity = ender_pearl:get_luaentity()
      local yaw = player:get_look_horizontal()
      local pitch = player:get_look_vertical()
      local dir = player:get_look_dir()

      ender_pearl:set_rotation({x = -pitch, y = yaw, z = 0})
      ender_pearl:set_velocity({
          x=(dir.x * entity.initial_properties.speed),
          y=(dir.y * entity.initial_properties.speed),
          z=(dir.z * entity.initial_properties.speed),
      })
      ender_pearl:set_acceleration({x=dir.x*-3, y=-entity.initial_properties.gravity, z=dir.z*-3})
      minetest.after(0, function() player:get_inventory():remove_item("main", "enderpearl:ender_pearl") end)
    end,
  
})



------------------------
-- ! Entity Section ! -- 
------------------------


-- entity declaration
local thrown_ender_pearl = {
  initial_properties = {
    hp_max = 1,
    physical = true,
    collide_with_objects = false,
    collisionbox = {-0.2, -0.2, -0.2, 0.2, 0.2, 0.2},
    visual = "wielditem",
    visual_size = {x = 0.4, y = 0.4},
    textures = {"enderpearl:ender_pearl"},
    spritediv = {x = 1, y = 1},
    initial_sprite_basepos = {x = 0, y = 0},
    pointable = false,
    speed = 56,
    gravity = 32,
    damage = 2,
    lifetime = 15
  },
  player_name = ""
}



function thrown_ender_pearl:on_step(dtime, moveresult)  
  local collided_with_node = moveresult.collisions[1] and moveresult.collisions[1].type == "node"

  -- if it's touching the ground or it collides with a node
  if moveresult.touching_ground == true or collided_with_node then
    local player = minetest.get_player_by_name(self.player_name)

    if player == nil then
      self.object:remove()
    end

    player:set_pos(vector.add(self.object:get_pos(), {x = 0, y = 1, z = 1}))
    player:set_hp(player:get_hp()-self.initial_properties.damage, "enderpearl")
    self.object:remove()
  end
end



function thrown_ender_pearl:on_activate(staticdata)
  if staticdata == nil or minetest.get_player_by_name(staticdata) == nil then
    self.object:remove()
  end

  self.player_name = staticdata
  minetest.after(self.initial_properties.lifetime, function() self.object:remove() end)
end



minetest.register_entity("enderpearl:thrown_ender_pearl", thrown_ender_pearl)