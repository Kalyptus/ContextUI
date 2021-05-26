---
--- @author Dylan MALANDAIN, Kalyptus
--- @version 1.0.0
--- File created at [26/05/2021 10:28]
---

--EntityType 1 = Ped
--EntityType 2 = Vehicle
--EntityType 3 = Object

local main = ContextUI:CreateMenu(1)
local submenu = ContextUI:CreateSubMenu(main)

ContextUI:IsVisible(main, function(Entity)
    for i=1, 10 do
        ContextUI:Button("Button #"..i, function(onSelected)
            if (onSelected) then
                print("onSelected #"..i)
            end
        end, submenu)
    end
end)

ContextUI:IsVisible(submenu, function(Entity)
    for k, v in pairs(Entity) do
        ContextUI:Button(k, function(onSelected)
            if onSelected then
                print(v)
            end
        end)
    end
end)

Keys.Register("X", "X", "Enable / disable focus mode.", function()
    ContextUI.Focus = not ContextUI.Focus;
end)