--[[ Starbound Sign Placer for Silverfeelin's Generator.
 Made by Degranon. All rights reserved.
--]]

require "/scripts/vec2.lua"

-- Initialize the variables
function init()

  interface_path = "/interface/scripted/signplacer/signplacer.config"
  self.previous_mode = "none"

  --self.data = status.statusProperty("signPlacer", nil)

  self.data = {}
  self.signDimension = {4, 1}

  message.setHandler("signPlacerMessage", function (_, _, data) self.data = data end)
  sb.setLogMap("^cyan;Sign Folder Name^reset;", "Not Selected")

    -- sets the item between hands
  activeItem.setOutsideOfHand(false)
end

-- Update function, is called every tick
function update(dt, fireMode, shiftHeld)

  -- making sure we open only one interface windows
  if fireMode == "alt" and self.previous_mode ~= "alt" then
	player.interact("ScriptPane", root.assetJson(interface_path))
  end

  -- making sure we don't spawn one object onto another one
  if fireMode == "primary" and self.previous_mode ~= "primary" then
	PlaceSigns()
  end

  if self.data and self.data.name then
    world.sendEntityMessage(player.id(), "drawImagePreview", activeItem.ownerAimPosition(), self.data)
  end

  self.previous_mode = fireMode
  updateAim()
end


-- Place Sign function
function PlaceSigns()
  self.anchor = vec2.floor(activeItem.ownerAimPosition())

  if self.data and self.data.name then
    for i = 0, self.data.wNumber - 1 do
      for j = 0, self.data.hNumber - 1 do
        local position = vec2.add(self.anchor, vec2.mul(self.signDimension, {i ,j}))
	      sign = root.assetJson("/"..self.data.name.."/"..self.data.name.." ["..i..","..j.."].json")
		    -- the function recieves the position as the center of the future object, so we have to move it
        world.placeObject("customsign", vec2.add(position, {2, 0}), 1, sign.parameters)
      end
    end
  end

end

-- Util finction, rotates the item
function updateAim()
  animator.resetTransformationGroup("weapon")

  self.aimAngle, self.facingDirection = activeItem.aimAngleAndDirection(0, activeItem.ownerAimPosition())
  activeItem.setFacingDirection(self.facingDirection)
  activeItem.setArmAngle(self.aimAngle)
end
