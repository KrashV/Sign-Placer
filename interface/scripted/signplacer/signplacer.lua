-- GUI handler for Sign Placer.

function init()
  self.signFolder = "PUT_SIGNS_HERE/"
end

-- Searches the folder with generated signs given by name
function search(name)
  
  if pcall(function() root.assetJson("/"..self.signFolder..name.."/"..name.."[0,0].json") end) then
    widget.setText("lblWarning", "^#00ff00;All Good")
    return 0
  elseif pcall(function() root.assetJson("/"..self.signFolder..name.."/"..name.."[1,1].json") end) then
    widget.setText("lblWarning", "^#00ff00;All Good")
    return 1
	else
    widget.setText("lblWarning", "^#ff0000;Folder Not Found")
    return false
  end

end

-- Sets the dimension settings visible
function autoDimension()
  local is_not_checked = not widget.getChecked("cbAutoDim")
  
  widget.setVisible("lblX", is_not_checked)
  widget.setVisible("txbX", is_not_checked)
  widget.setVisible("lblY", is_not_checked)
  widget.setVisible("txbY", is_not_checked)
  
  if not is_not_checked then
	widget.setText("txbX", "")
	widget.setText("txbY", "")
  end
end

-- Determines the dimensions of the original image (in signs :P)
function findDimension(name, startIndex)
  local i = startIndex
  local j = startIndex
  
  while true do
    if not pcall(function() root.assetJson("/"..self.signFolder..name.."/"..name.."["..i.."," .. startIndex .. "].json") end) then
      break
    else
      i = i + 1
    end
  end
  
   while true do
    if not pcall(function() root.assetJson("/"..self.signFolder..name.."/"..name.."[" .. startIndex .. ","..j.."].json") end) then
      break
    else
      j = j + 1
    end
  end
  
  return i - startIndex, j - startIndex
end

-- Final function
function accept()
  local name = widget.getText("txbName")
  
  -- if not found, return with an error
  local startIndex = search(name)
  if not startIndex then
    widget.setText("lblWarning", "^#ff0000;Folder Not Found")
    return
  end
  
  -- if the dimensions are wrong, return with an error
  if tonumber(widget.getText("txbX")) and tonumber(widget.getText("txbX")) <= 0 or tonumber(widget.getText("txbY")) and tonumber(widget.getText("txbY")) <= 0 then
    widget.setText("lblWarning", "^#ff0000;Numbers must be positive")
	return
  end
  
  wNumber, hNumber = findDimension(name, startIndex)
  
  -- if the dimensions are wrong, return with an error
  if not widget.getChecked("cbAutoDim") then
    if not tonumber(widget.getText("txbX")) or tonumber(widget.getText("txbX")) > wNumber
      or not tonumber(widget.getText("txbY")) or tonumber(widget.getText("txbY")) > hNumber then
        widget.setText("lblWarning", "^#ff0000;Incorrect custom dimensions")
        return
    else
      wNumber = tonumber(widget.getText("txbX"))
      hNumber = tonumber(widget.getText("txbY"))
    end
  end
  
  --status.setStatusProperty("signPlacer", { 	name = widget.getText("txbName"), 	wNumber = wNumber, 	hNumber = hNumber   })
  
  widget.setText("txbX", wNumber)
  widget.setText("txbY", hNumber)
  
  -- settings are confirmed and being transfered to the item itself
  world.sendEntityMessage(player.id(), "signPlacerMessage", { 	
    name = name, 	
    wNumber = wNumber, 	
    hNumber = hNumber,
    startIndex = startIndex
	})

end