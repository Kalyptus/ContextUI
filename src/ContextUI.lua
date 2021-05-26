---
--- @author Dylan MALANDAIN, Kalyptus
--- @version 1.0.0
--- File created at [26/05/2021 10:22]
---

local Settings = {
    Button = {
        Width = 220,
        Height = 32,
        Background = {
            { 0, 0, 0, 200 },
            { 255, 255, 255, 200 }
        }
    },
    Text = {
        Colors = {
            { 255, 255, 255, 255 },
            { 10, 10, 10, 255 }
        },
        X = 8.0,
        Y = 4.5,
        Scale = 0.26,
        Font = 0,
        Center = false,
        Outline = false,
        DropShadow = false,
    },
}

ContextUI = {
    Entity = {
        ID = nil,
        Type = nil,
        Model = nil,
        NetID = nil,
    },
    Menus = {},
    Focus = false,
    Open = false,
    Position = vector2(0.0, 0.0),
    Offset = vector2(0.0, 0.0),
    Options = 0,
    Category = "main",
    CategoryID = 0,
}

function ContextUI:OnClosed()
    ResetEntityAlpha(self.Entity.ID)
    self.Entity.ID = nil
    self.Open = false
    self.Focus = false
    self.Category = "main"
    self.Options = 0
end

function ContextUI:Button(Label, Actions, Submenu)
    local PosX, PosY = self.Position.x, self.Position.y
    PosY = PosY + (self.Options * Settings.Button.Height)
    local onHovered = Graphics.IsMouseInBounds(PosX, PosY, Settings.Button.Width, Settings.Button.Height)

    if (onHovered) then
        local Selected = false;
        SetMouseCursorSprite(5)
        if IsControlJustPressed(0, 24) then
            Selected = true
            if (Submenu) then
                self.Category = Submenu.Category
            end
            local audioName = Label == "← Retour" and "BACK" or "SELECT"
            Audio.PlaySound("HUD_FRONTEND_DEFAULT_SOUNDSET", audioName, false)
        end
        if (Actions) then
            Actions(Selected)
        end
    end

    local Index = (not onHovered) and 1 or 2
    Graphics.Rectangle(PosX, PosY, Settings.Button.Width, Settings.Button.Height, Settings.Button.Background[Index][1], Settings.Button.Background[Index][2], Settings.Button.Background[Index][3], Settings.Button.Background[Index][4])
    Graphics.Text(Label, PosX + Settings.Text.X, PosY + Settings.Text.Y, Settings.Text.Font, Settings.Text.Scale, Settings.Text.Colors[Index][1], Settings.Text.Colors[Index][2], Settings.Text.Colors[Index][3], Settings.Text.Colors[Index][4], Settings.Text.Center, Settings.Text.Outline, Settings.Text.DropShadow)
    self.Options = self.Options + 1
    self.Offset = vector2(PosX, PosY)
end

function ContextUI:Visible()
    SetMouseCursorSprite(1)
    self.Menus[self.Entity.Type .. self.Category]()
    local X, Y = 1920, 1080
    local lastX, lastY = self.Offset.x, self.Offset.y
    if (lastY + Settings.Button.Height) >= Y then
        self.Position = vector2(self.Position.x, self.Position.y - 10.0)
    end
    if (lastX + Settings.Button.Width) >= X then
        self.Position = vector2(self.Position.x - 10.0, self.Position.y)
    end
    self.Options = 0
end

function ContextUI:CreateMenu(EntityType)
    return { EntityType = EntityType, Category = "main", Parent = nil, }
end

function ContextUI:CreateSubMenu(Parent)
    local category = self.CategoryID + 1
    self.CategoryID = category;
    return { EntityType = Parent.EntityType, Category = category, Parent = Parent }
end

function ContextUI:IsVisible(Menu, Callback)
    self.Menus[Menu.EntityType .. Menu.Category] = function()
        Callback(self.Entity)
        if Menu.Parent then
            self:Button("← Retour", nil, Menu.Parent)
        end
    end
end

Citizen.CreateThread(function()
    local controls_actions = { 239, 240, 24, 25 }
    while true do
        local Timer = 250;
        if (ContextUI.Focus) then
            DisableAllControlActions(2)
            SetMouseCursorActiveThisFrame()
            for _, control in ipairs(controls_actions) do
                EnableControlAction(0, control, true)
            end
            if (not ContextUI.Open) then
                local isFound, entityCoords, surfaceNormal, entityHit, entityType, cameraDirection, mouse = Graphics.ScreenToWorld(35.0, 31)
                if (entityType ~= 0) then
                    SetMouseCursorSprite(5)
                    if ContextUI.Entity.ID ~= entityHit then
                        ResetEntityAlpha(ContextUI.Entity.ID)
                        ContextUI.Entity.ID = entityHit
                        SetEntityAlpha(ContextUI.Entity.ID, 200, false)
                    end
                    if IsControlJustPressed(0, 24) or IsDisabledControlPressed(0, 24) then
                        if (ContextUI.Menus[entityType .. ContextUI.Category] ~= nil) then
                            local posX, posY = Graphics.ConvertToPixel(mouse.x, mouse.y)
                            ContextUI.Position = vector2(posX, posY)
                            ContextUI.Entity = {
                                ID = entityHit,
                                Type = entityType,
                                Model = GetEntityModel(entityHit) or 0,
                                NetID = NetworkGetNetworkIdFromEntity(entityHit)
                            }
                            ContextUI.Open = true
                            Audio.PlaySound("HUD_FRONTEND_DEFAULT_SOUNDSET", "SELECT", false)
                        end
                    end
                else
                    if (ContextUI.Entity.ID ~= nil) then
                        ResetEntityAlpha(ContextUI.Entity.ID)
                        ContextUI.Entity.ID = nil
                    end
                    SetMouseCursorSprite(1)
                end
            else
                ContextUI:Visible()
            end
            DisablePlayerFiring(PlayerPedId(), true)
            Timer = 1;
        elseif (ContextUI.Entity.ID ~= nil) then
            ContextUI:OnClosed()
        end
        Citizen.Wait(Timer)
    end
end)
