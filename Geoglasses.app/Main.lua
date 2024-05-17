local GUI = require("GUI")
local system = require("System")
local com=require("component")

local localization = system.getCurrentScriptLocalization()

if not component.isAvailable("glasses") or not component.isAvailable("geolyzer") then
  GUI.alert(localization.notSigma)
  return
end

local glass = com.glasses
glass.removeAll()
local geo = com.geolyzer

local size=16
local pl=3
local minpl = 2
local maxpl = 5
 
local maxY
maxY=size 

-- Add a new window to MineOS workspace
local workspace, window, menu = system.addWindow(GUI.filledWindow(1, 1, 60, 20, 0xE1E1E1))



-- Add single cell layout to window
local layout = window:addChild(GUI.layout(1, 1, window.width, window.height, 1, 1))


local function tocolor(pl)
  local color = (pl-minpl)/maxpl
  if color<0 then
    return {1,1,1}
  elseif color>1 then
    return {1,0,1}
  else
    return {color,1-color,0}
  end
end
 
local function create(x,y,z,p)
  if glass.addDot3D then
    -- OpenGlasses 1
    local a = glass.addDot3D()
    a.set3DPos(x + 0.5, y + 0.5, z + 0.5)
    a.setColor(table.unpack(tocolor(p)))
  else
    -- OpenGlasses 2
    local widget = glass.addCube3D()
    widget.addTranslation(x + 0.125, y + 0.125, z + 0.125)
    widget.addScale(0.75, 0.75, 0.75)
    widget.setVisibleThroughObjects(true)
 
    local color = tocolor(p)
    color[4] = 1
 
    widget.addColor(table.unpack(color))
  end
end

local removeGovno = window:addChild(GUI.button(16, 8, 30, 3, 0xFFFFFF, 0x555555, 0x4B4B4B, 0xFFFFFF, localization.removeGomno))
removeGovno.onTouch = function()
  glass.removeAll()
end
local regularButton = window:addChild(GUI.button(16, 4, 30, 3, 0xFFFFFF, 0x555555, 0x4B4B4B, 0xFFFFFF, localization.scan))
regularButton.onTouch = function()
  for x=-size,size do
    for z=-size,size do
      tile=geo.scan(x,z)
      --os.sleep(0)
      for Y=-math.min(size,18),math.min(maxY,18) do
        local y=Y+32
        if tile[y]>pl then create(x,Y,z,tile[y]) end
      end
    end
  end
  GUI.alert(localization.found .. (glass.getObjectCount or glass.getWidgetCount)())
end
-- Create callback function with resizing rules when window changes its' size
window.onResize = function(newWidth, newHeight)
  window.backgroundPanel.width, window.backgroundPanel.height = newWidth, newHeight
  layout.width, layout.height = newWidth, newHeight
end

---------------------------------------------------------------------------------

-- Draw changes on screen after customizing your window
workspace:draw()
