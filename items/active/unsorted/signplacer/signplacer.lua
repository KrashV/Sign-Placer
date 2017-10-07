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
  self.anchor = {0, 0}
  self.tempPosition = {}
  
  self.goodPlaceColor = {0, 255, 0}
  self.badPlaceColor = {255, 0, 0}
  
  message.setHandler("signPlacerMessage", function (_, _, data) self.data = data end)
  sb.setLogMap("^cyan;Sign Folder Name^reset;", "Not Selected")
  
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
    self.anchor = activeItem.ownerAimPosition()
	self.anchor[1] = math.floor(self.anchor[1])
	self.anchor[2] = math.floor(self.anchor[2])
	
	sb.setLogMap("^cyan;Sign Folder Name^reset;", self.data.name)
	for i = 0, self.data.wNumber - 1 do
	  for j = 0, self.data.hNumber - 1 do
	    self.tempPosition[i * self.data.hNumber + j] = vec2.add(self.anchor, vec2.mul(self.signDimension, {i ,j}))
		color = SetColor(self.tempPosition[i * self.data.hNumber + j])
	    world.debugPoly({self.tempPosition[i * self.data.hNumber + j], vec2.add(self.tempPosition[i * self.data.hNumber + j], {self.signDimension[1], 0}), vec2.add(self.tempPosition[i * self.data.hNumber + j], self.signDimension), vec2.add(self.tempPosition[i * self.data.hNumber + j], {0, self.signDimension[2]})}, color)
	  end
	end
  end
  
  self.previous_mode = fireMode
  updateAim()
end

-- Determines the color: if a sign can be placed at the position, it will be colored green, red otherwise
function SetColor(position)
  local temp = position
  
  -- we need to check 4 blocks for every sign
  for i = 0, self.signDimension[1] do
    temp = vec2.add(position, {i, 0})
	-- is there a tile on the background and if it's occupied by other objects / tiles already
    if not world.tileIsOccupied(temp, false) or world.tileIsOccupied(temp, true) then
      return self.badPlaceColor
    end
  end
  
  return self.goodPlaceColor
end

-- Place Sign function
function PlaceSigns()

  if self.data and self.data.name then
    for i = 0, self.data.wNumber - 1 do
      for j = 0, self.data.hNumber - 1 do
	    sign = root.assetJson("/"..self.data.name.."/"..self.data.name.." ["..i..","..j.."].json")
		-- the function recieves the position as the center of the future object, so we have to move it 
        world.placeObject("customsign", vec2.add(self.tempPosition[i * self.data.hNumber + j], {2, 0}), 1, sign.parameters)
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
  -- sets the item between hands
  activeItem.setOutsideOfHand(false)
end