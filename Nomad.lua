-- Haven UI | Version 1.0.0

local gg = {}
gg.__index = gg

-- serviceVars
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- defaultThemes
gg.Themes = {
    Dark = {
        Background = Color3.fromRGB(20, 20, 25),
        Primary = Color3.fromRGB(45, 45, 55),
        Secondary = Color3.fromRGB(35, 35, 45),
        Accent = Color3.fromRGB(65, 105, 225),
        Text = Color3.fromRGB(220, 220, 230),
        TextSecondary = Color3.fromRGB(160, 160, 170),
        Border = Color3.fromRGB(60, 60, 70),
        Success = Color3.fromRGB(40, 167, 69),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(220, 53, 69),
        ToggleOn = Color3.fromRGB(65, 105, 225),
        ToggleOff = Color3.fromRGB(80, 80, 90)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 250),
        Primary = Color3.fromRGB(235, 235, 245),
        Secondary = Color3.fromRGB(225, 225, 235),
        Accent = Color3.fromRGB(65, 105, 225),
        Text = Color3.fromRGB(40, 40, 50),
        TextSecondary = Color3.fromRGB(100, 100, 110),
        Border = Color3.fromRGB(200, 200, 210),
        Success = Color3.fromRGB(40, 167, 69),
        Warning = Color3.fromRGB(255, 193, 7),
        Error = Color3.fromRGB(220, 53, 69),
        ToggleOn = Color3.fromRGB(65, 105, 225),
        ToggleOff = Color3.fromRGB(180, 180, 190)
    }
}

-- currentTheme
gg.CurrentTheme = gg.Themes.Dark

-- utilityFuncs
local function createInstance(class, properties)
    local instance = Instance.new(class)
    for prop, value in pairs(properties) do
        instance[prop] = value
    end
    return instance
end

local function round(num, numDecimalPlaces)
    local mult = 10 ^ (numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

-- main ui constructor
function gg.new(options)
    options = options or {}
    
    local self = setmetatable({}, gg)
    
    -- create the actual gui duh
    self.ScreenGui = createInstance("ScreenGui", {
        Name = "gg_UILibrary",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = CoreGui
    })
    
    -- this is your main window
    self.MainFrame = createInstance("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = gg.CurrentTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Size = UDim2.new(0, 600, 0, 400),
        Parent = self.ScreenGui
    })
    
    -- this is the topbar where youll put the name of your paste
    self.TopBar = createInstance("Frame", {
        Name = "TopBar",
        BackgroundColor3 = gg.CurrentTheme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = self.MainFrame
    })
    
    -- the title, self explanatory
    self.Title = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "gg/robloxuis version 2.0",
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TopBar
    })
    
    -- a status, very nice
    self.Status = createInstance("TextLabel", {
        Name = "Status",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Status: working", 
        TextColor3 = gg.CurrentTheme.TextSecondary,
        TextSize = 12,
        Position = UDim2.new(1, -100, 0, 0),
        Size = UDim2.new(0, 90, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = self.TopBar
    })
    
    -- basically a card but you can put things inside
    self.Content = createInstance("Frame", {
        Name = "Content",
        BackgroundColor3 = gg.CurrentTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 1, -30),
        Parent = self.MainFrame
    })
    
    -- your sidebar, tabs go here
    self.LeftSidebar = createInstance("ScrollingFrame", {
        Name = "LeftSidebar",
        BackgroundColor3 = gg.CurrentTheme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 150, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = gg.CurrentTheme.Border,
        Parent = self.Content
    })
    
    -- main content area, self explanatory if youre not lobotomised
    self.MainContent = createInstance("ScrollingFrame", {
        Name = "MainContent",
        BackgroundColor3 = gg.CurrentTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 150, 0, 0),
        Size = UDim2.new(1, -150, 1, 0),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = gg.CurrentTheme.Border,
        Parent = self.Content
    })
    
    -- tab sys
    self.Tabs = {}
    self.CurrentTab = nil
    
    -- component storage
    self.Components = {}
    
    -- notifications
    self.Notifications = {}
    
    -- esp sys
    self.ESP = {}
    
    -- this makes the ui draggable
    self:MakeDraggable(self.MainFrame, self.TopBar)
    
    -- tab init
    self:InitializeTabs()
    
    return self
end

-- make esp elements draggable
function gg:MakeDraggable(element, handle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = element.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            element.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

-- init the tabs once again
function gg:InitializeTabs()
    local tabLayout = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = self.LeftSidebar
    })
    
    local padding = createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = self.LeftSidebar
    })
end

-- make a tab lol
function gg:CreateTab(name)
    local tabButton = createInstance("TextButton", {
        Name = name .. "Tab",
        BackgroundColor3 = gg.CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = name,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = self.LeftSidebar
    })
    
    local tabContent = createInstance("ScrollingFrame", {
        Name = name .. "Content",
        BackgroundColor3 = gg.CurrentTheme.Background,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        Visible = false,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = gg.CurrentTheme.Border,
        Parent = self.MainContent
    })
    
    local tabLayout = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabContent
    })
    
    local padding = createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = tabContent
    })
    
    -- Tab functionality
    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(name)
    end)
    
    tabButton.MouseEnter:Connect(function()
        TweenService:Create(
            tabButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Accent}
        ):Play()
    end)
    
    tabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= name then
            TweenService:Create(
                tabButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = gg.CurrentTheme.Secondary}
            ):Play()
        end
    end)
    
    -- Store tab
    self.Tabs[name] = {
        Button = tabButton,
        Content = tabContent
    }
    
    -- Select first tab by default
    if not self.CurrentTab then
        self:SelectTab(name)
    end
    
    return {
        Name = name,
        Content = tabContent
    }
end

-- Select a tab
function gg:SelectTab(name)
    if not self.Tabs[name] then return end
    
    -- Hide current tab
    if self.CurrentTab and self.Tabs[self.CurrentTab] then
        self.Tabs[self.CurrentTab].Content.Visible = false
        TweenService:Create(
            self.Tabs[self.CurrentTab].Button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Secondary}
        ):Play()
    end
    
    -- Show new tab
    self.CurrentTab = name
    self.Tabs[name].Content.Visible = true
    TweenService:Create(
        self.Tabs[name].Button,
        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {BackgroundColor3 = gg.CurrentTheme.Accent}
    ):Play()
end

-- Create a section
function gg:CreateSection(tab, title)
    local section = createInstance("Frame", {
        Name = title .. "Section",
        BackgroundColor3 = gg.CurrentTheme.Primary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = tab.Content
    })
    
    local sectionTitle = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = section
    })
    
    local sectionLayout = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = section
    })
    
    local sectionPadding = createInstance("UIPadding", {
        PaddingTop = UDim.new(0, 25),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = section
    })
    
    -- Update section size based on content
    sectionLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.Size = UDim2.new(1, 0, 0, sectionLayout.AbsoluteContentSize.Y + 25)
    end)
    
    return {
        Container = section,
        AddComponent = function(component)
            component.Parent = section
        end
    }
end

-- Create a toggle component
function gg:CreateToggle(tab, title, default, callback)
    default = default or false
    callback = callback or function() end
    
    local toggle = createInstance("Frame", {
        Name = title .. "Toggle",
        BackgroundColor3 = gg.CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = tab.Content
    })
    
    local toggleTitle = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = title,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggle
    })
    
    local toggleButton = createInstance("TextButton", {
        Name = "Button",
        BackgroundColor3 = default and gg.CurrentTheme.ToggleOn or gg.CurrentTheme.ToggleOff,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        Parent = toggle
    })
    
    local toggleIndicator = createInstance("Frame", {
        Name = "Indicator",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Size = UDim2.new(0, 16, 0, 16),
        Position = default and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2),
        Parent = toggleButton
    })
    
    -- Round corners
    local toggleCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 10),
        Parent = toggleButton
    })
    
    local indicatorCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = toggleIndicator
    })
    
    local state = default
    
    -- Toggle functionality
    toggleButton.MouseButton1Click:Connect(function()
        state = not state
        
        -- Animate toggle
        TweenService:Create(
            toggleButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = state and gg.CurrentTheme.ToggleOn or gg.CurrentTheme.ToggleOff}
        ):Play()
        
        TweenService:Create(
            toggleIndicator,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = state and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)}
        ):Play()
        
        callback(state)
    end)
    
    -- Hover effect
    toggleButton.MouseEnter:Connect(function()
        TweenService:Create(
            toggleButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = state and gg.CurrentTheme.Accent or gg.CurrentTheme.Border}
        ):Play()
    end)
    
    toggleButton.MouseLeave:Connect(function()
        TweenService:Create(
            toggleButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = state and gg.CurrentTheme.ToggleOn or gg.CurrentTheme.ToggleOff}
        ):Play()
    end)
    
    -- Store component
    local componentId = #self.Components + 1
    self.Components[componentId] = {
        Type = "Toggle",
        Instance = toggle,
        State = state,
        SetState = function(newState)
            state = newState
            TweenService:Create(
                toggleButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = state and gg.CurrentTheme.ToggleOn or gg.CurrentTheme.ToggleOff}
            ):Play()
            
            TweenService:Create(
                toggleIndicator,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = state and UDim2.new(0, 22, 0, 2) or UDim2.new(0, 2, 0, 2)}
            ):Play()
            
            callback(state)
        end,
        GetState = function()
            return state
        end
    }
    
    return self.Components[componentId]
end

-- Create a slider component
function gg:CreateSlider(tab, title, min, max, default, callback)
    min = min or 0
    max = max or 100
    default = default or min
    callback = callback or function() end
    
    local slider = createInstance("Frame", {
        Name = title .. "Slider",
        BackgroundColor3 = gg.CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 50),
        Parent = tab.Content
    })
    
    local sliderTitle = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = title,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 5),
        Size = UDim2.new(0.7, -10, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = slider
    })
    
    local sliderValue = createInstance("TextLabel", {
        Name = "Value",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(default),
        TextColor3 = gg.CurrentTheme.TextSecondary,
        TextSize = 14,
        Position = UDim2.new(1, -50, 0, 5),
        Size = UDim2.new(0, 40, 0, 20),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = slider
    })
    
    local sliderBar = createInstance("Frame", {
        Name = "Bar",
        BackgroundColor3 = gg.CurrentTheme.Border,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 4),
        Position = UDim2.new(0, 10, 0, 30),
        Parent = slider
    })
    
    local sliderFill = createInstance("Frame", {
        Name = "Fill",
        BackgroundColor3 = gg.CurrentTheme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = sliderBar
    })
    
    local sliderButton = createInstance("TextButton", {
        Name = "Button",
        BackgroundColor3 = gg.CurrentTheme.Text,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6),
        Parent = sliderBar
    })
    
    -- Round corners
    local barCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = sliderBar
    })
    
    local fillCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 2),
        Parent = sliderFill
    })
    
    local buttonCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = sliderButton
    })
    
    local value = default
    local dragging = false
    
    -- Slider functionality
    sliderButton.MouseButton1Down:Connect(function()
        dragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
            local newValue = min + (max - min) * relativeX
            
            -- Update value
            value = round(newValue, 2)
            sliderValue.Text = tostring(value)
            
            -- Update visuals
            TweenService:Create(
                sliderFill,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(relativeX, 0, 1, 0)}
            ):Play()
            
            TweenService:Create(
                sliderButton,
                TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(relativeX, -6, 0.5, -6)}
            ):Play()
            
            callback(value)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Store component
    local componentId = #self.Components + 1
    self.Components[componentId] = {
        Type = "Slider",
        Instance = slider,
        Value = value,
        SetValue = function(newValue)
            value = math.clamp(newValue, min, max)
            sliderValue.Text = tostring(value)
            
            local relativeX = (value - min) / (max - min)
            
            TweenService:Create(
                sliderFill,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Size = UDim2.new(relativeX, 0, 1, 0)}
            ):Play()
            
            TweenService:Create(
                sliderButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(relativeX, -6, 0.5, -6)}
            ):Play()
            
            callback(value)
        end,
        GetValue = function()
            return value
        end
    }
    
    return self.Components[componentId]
end

-- Create a dropdown component
function gg:CreateDropdown(tab, title, options, default, callback)
    options = options or {}
    default = default or (options[1] or "")
    callback = callback or function() end
    
    local dropdown = createInstance("Frame", {
        Name = title .. "Dropdown",
        BackgroundColor3 = gg.CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = tab.Content
    })
    
    local dropdownTitle = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = title,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdown
    })
    
    local dropdownButton = createInstance("TextButton", {
        Name = "Button",
        BackgroundColor3 = gg.CurrentTheme.Border,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = default,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Size = UDim2.new(0, 120, 0, 20),
        Position = UDim2.new(1, -130, 0.5, -10),
        Parent = dropdown
    })
    
    local dropdownArrow = createInstance("ImageLabel", {
        Name = "Arrow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://6031090990",
        ImageColor3 = gg.CurrentTheme.Text,
        Size = UDim2.new(0, 12, 0, 8),
        Position = UDim2.new(1, -18, 0.5, -4),
        Parent = dropdownButton
    })
    
    -- Dropdown options container
    local optionsContainer = createInstance("ScrollingFrame", {
        Name = "OptionsContainer",
        BackgroundColor3 = gg.CurrentTheme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -130, 1, 5),
        Size = UDim2.new(0, 120, 0, 0),
        Visible = false,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = gg.CurrentTheme.Border,
        ZIndex = 10,
        Parent = dropdown
    })
    
    local optionsLayout = createInstance("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionsContainer
    })
    
    -- Round corners
    local buttonCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = dropdownButton
    })
    
    local optionsCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = optionsContainer
    })
    
    local selected = default
    local isOpen = false
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionButton = createInstance("TextButton", {
            Name = option,
            BackgroundColor3 = gg.CurrentTheme.Secondary,
            BorderSizePixel = 0,
            Font = Enum.Font.Gotham,
            Text = option,
            TextColor3 = gg.CurrentTheme.Text,
            TextSize = 14,
            Size = UDim2.new(1, 0, 0, 25),
            ZIndex = 10,
            Parent = optionsContainer
        })
        
        local optionCorner = createInstance("UICorner", {
            CornerRadius = UDim.new(0, 4),
            Parent = optionButton
        })
        
        optionButton.MouseButton1Click:Connect(function()
            selected = option
            dropdownButton.Text = option
            isOpen = false
            optionsContainer.Visible = false
            
            -- Rotate arrow back
            TweenService:Create(
                dropdownArrow,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Rotation = 0}
            ):Play()
            
            callback(option)
        end)
        
        optionButton.MouseEnter:Connect(function()
            TweenService:Create(
                optionButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = gg.CurrentTheme.Accent}
            ):Play()
        end)
        
        optionButton.MouseLeave:Connect(function()
            TweenService:Create(
                optionButton,
                TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundColor3 = gg.CurrentTheme.Secondary}
            ):Play()
        end)
    end
    
    -- Update options container size
    optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        optionsContainer.Size = UDim2.new(0, 120, 0, math.min(optionsLayout.AbsoluteContentSize.Y, 150))
    end)
    
    -- Dropdown functionality
    dropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        optionsContainer.Visible = isOpen
        
        -- Rotate arrow
        TweenService:Create(
            dropdownArrow,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Rotation = isOpen and 180 or 0}
        ):Play()
    end)
    
    dropdownButton.MouseEnter:Connect(function()
        TweenService:Create(
            dropdownButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Accent}
        ):Play()
    end)
    
    dropdownButton.MouseLeave:Connect(function()
        TweenService:Create(
            dropdownButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Border}
        ):Play()
    end)
    
    -- Store component
    local componentId = #self.Components + 1
    self.Components[componentId] = {
        Type = "Dropdown",
        Instance = dropdown,
        Selected = selected,
        SetSelected = function(option)
            if table.find(options, option) then
                selected = option
                dropdownButton.Text = option
                callback(option)
            end
        end,
        GetSelected = function()
            return selected
        end,
        RefreshOptions = function(newOptions)
            options = newOptions or {}
            
            -- Clear existing options
            for _, child in pairs(optionsContainer:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            -- Create new option buttons
            for i, option in ipairs(options) do
                local optionButton = createInstance("TextButton", {
                    Name = option,
                    BackgroundColor3 = gg.CurrentTheme.Secondary,
                    BorderSizePixel = 0,
                    Font = Enum.Font.Gotham,
                    Text = option,
                    TextColor3 = gg.CurrentTheme.Text,
                    TextSize = 14,
                    Size = UDim2.new(1, 0, 0, 25),
                    ZIndex = 10,
                    Parent = optionsContainer
                })
                
                local optionCorner = createInstance("UICorner", {
                    CornerRadius = UDim.new(0, 4),
                    Parent = optionButton
                })
                
                optionButton.MouseButton1Click:Connect(function()
                    selected = option
                    dropdownButton.Text = option
                    isOpen = false
                    optionsContainer.Visible = false
                    
                    -- Rotate arrow back
                    TweenService:Create(
                        dropdownArrow,
                        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Rotation = 0}
                    ):Play()
                    
                    callback(option)
                end)
                
                optionButton.MouseEnter:Connect(function()
                    TweenService:Create(
                        optionButton,
                        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {BackgroundColor3 = gg.CurrentTheme.Accent}
                    ):Play()
                end)
                
                optionButton.MouseLeave:Connect(function()
                    TweenService:Create(
                        optionButton,
                        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {BackgroundColor3 = gg.CurrentTheme.Secondary}
                    ):Play()
                end)
            end
            
            -- Update options container size
            optionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                optionsContainer.Size = UDim2.new(0, 120, 0, math.min(optionsLayout.AbsoluteContentSize.Y, 150))
            end)
            
            -- Reset selection if it's not in the new options
            if not table.find(options, selected) then
                selected = options[1] or ""
                dropdownButton.Text = selected
            end
        end
    }
    
    return self.Components[componentId]
end

-- Create a button component
function gg:CreateButton(tab, title, callback)
    callback = callback or function() end
    
    local button = createInstance("TextButton", {
        Name = title .. "Button",
        BackgroundColor3 = gg.CurrentTheme.Accent,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = tab.Content
    })
    
    -- Round corners
    local buttonCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = button
    })
    
    -- Button functionality
    button.MouseButton1Click:Connect(function()
        -- Click animation
        TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Border}
        ):Play()
        
        wait(0.1)
        
        TweenService:Create(
            button,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Accent}
        ):Play()
        
        callback()
    end)
    
    button.MouseEnter:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Border}
        ):Play()
    end)
    
    button.MouseLeave:Connect(function()
        TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Accent}
        ):Play()
    end)
    
    -- Store component
    local componentId = #self.Components + 1
    self.Components[componentId] = {
        Type = "Button",
        Instance = button,
        SetText = function(text)
            button.Text = text
        end,
        GetText = function()
            return button.Text
        end
    }
    
    return self.Components[componentId]
end

-- Create a color picker component
function gg:CreateColorPicker(tab, title, default, callback)
    default = default or Color3.fromRGB(255, 255, 255)
    callback = callback or function() end
    
    local colorPicker = createInstance("Frame", {
        Name = title .. "ColorPicker",
        BackgroundColor3 = gg.CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = tab.Content
    })
    
    local pickerTitle = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = title,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = colorPicker
    })
    
    local pickerButton = createInstance("TextButton", {
        Name = "Button",
        BackgroundColor3 = default,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "",
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, -50, 0.5, -10),
        Parent = colorPicker
    })
    
    -- Round corners
    local buttonCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = pickerButton
    })
    
    local selectedColor = default
    
    -- Color picker window
    local pickerWindow = createInstance("Frame", {
        Name = "ColorPickerWindow",
        BackgroundColor3 = gg.CurrentTheme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(0.5, -150, 0.5, -100),
        Size = UDim2.new(0, 300, 0, 200),
        Visible = false,
        ZIndex = 100,
        Parent = self.ScreenGui
    })
    
    local pickerTopBar = createInstance("Frame", {
        Name = "TopBar",
        BackgroundColor3 = gg.CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        ZIndex = 101,
        Parent = pickerWindow
    })
    
    local pickerTitleLabel = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Color Picker",
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102,
        Parent = pickerTopBar
    })
    
    local pickerCloseButton = createInstance("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "×",
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 18,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 25, 1, 0),
        ZIndex = 102,
        Parent = pickerTopBar
    })
    
    local colorDisplay = createInstance("Frame", {
        Name = "ColorDisplay",
        BackgroundColor3 = selectedColor,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 40),
        Size = UDim2.new(0, 60, 0, 60),
        ZIndex = 101,
        Parent = pickerWindow
    })
    
    local colorHex = createInstance("TextBox", {
        Name = "ColorHex",
        BackgroundColor3 = gg.CurrentTheme.Border,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "#" .. selectedColor:ToHex(),
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 80, 0, 40),
        Size = UDim2.new(0, 100, 0, 30),
        ZIndex = 101,
        Parent = pickerWindow
    })
    
    local colorR = createInstance("Frame", {
        Name = "ColorR",
        BackgroundColor3 = gg.CurrentTheme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 110),
        Size = UDim2.new(0, 280, 0, 20),
        ZIndex = 101,
        Parent = pickerWindow
    })
    
    local colorRFill = createInstance("Frame", {
        Name = "Fill",
        BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, 0, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(selectedColor.R, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 102,
        Parent = colorR
    })
    
    local colorRButton = createInstance("TextButton", {
        Name = "Button",
        BackgroundColor3 = gg.CurrentTheme.Text,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(selectedColor.R, -6, 0.5, -6),
        ZIndex = 103,
        Parent = colorR
    })
    
    local colorRLabel = createInstance("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "R: " .. math.floor(selectedColor.R * 255),
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 12,
        Position = UDim2.new(0, -30, 0, 0),
        Size = UDim2.new(0, 25, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 102,
        Parent = colorR
    })
    
    local colorG = createInstance("Frame", {
        Name = "ColorG",
        BackgroundColor3 = gg.CurrentTheme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 135),
        Size = UDim2.new(0, 280, 0, 20),
        ZIndex = 101,
        Parent = pickerWindow
    })
    
    local colorGFill = createInstance("Frame", {
        Name = "Fill",
        BackgroundColor3 = Color3.fromRGB(0, selectedColor.G * 255, 0),
        BorderSizePixel = 0,
        Size = UDim2.new(selectedColor.G, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 102,
        Parent = colorG
    })
    
    local colorGButton = createInstance("TextButton", {
        Name = "Button",
        BackgroundColor3 = gg.CurrentTheme.Text,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(selectedColor.G, -6, 0.5, -6),
        ZIndex = 103,
        Parent = colorG
    })
    
    local colorGLabel = createInstance("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "G: " .. math.floor(selectedColor.G * 255),
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 12,
        Position = UDim2.new(0, -30, 0, 0),
        Size = UDim2.new(0, 25, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 102,
        Parent = colorG
    })
    
    local colorB = createInstance("Frame", {
        Name = "ColorB",
        BackgroundColor3 = gg.CurrentTheme.Border,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 10, 0, 160),
        Size = UDim2.new(0, 280, 0, 20),
        ZIndex = 101,
        Parent = pickerWindow
    })
    
    local colorBFill = createInstance("Frame", {
        Name = "Fill",
        BackgroundColor3 = Color3.fromRGB(0, 0, selectedColor.B * 255),
        BorderSizePixel = 0,
        Size = UDim2.new(selectedColor.B, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ZIndex = 102,
        Parent = colorB
    })
    
    local colorBButton = createInstance("TextButton", {
        Name = "Button",
        BackgroundColor3 = gg.CurrentTheme.Text,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "",
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(selectedColor.B, -6, 0.5, -6),
        ZIndex = 103,
        Parent = colorB
    })
    
    local colorBLabel = createInstance("TextLabel", {
        Name = "Label",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "B: " .. math.floor(selectedColor.B * 255),
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 12,
        Position = UDim2.new(0, -30, 0, 0),
        Size = UDim2.new(0, 25, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 102,
        Parent = colorB
    })
    
    local applyButton = createInstance("TextButton", {
        Name = "ApplyButton",
        BackgroundColor3 = gg.CurrentTheme.Accent,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = "Apply",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Position = UDim2.new(1, -80, 1, -35),
        Size = UDim2.new(0, 70, 0, 25),
        ZIndex = 101,
        Parent = pickerWindow
    })
    
    -- Round corners
    local windowCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = pickerWindow
    })
    
    local topBarCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = pickerTopBar
    })
    
    local displayCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = colorDisplay
    })
    
    local hexCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = colorHex
    })
    
    local rCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = colorR
    })
    
    local gCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = colorG
    })
    
    local bCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = colorB
    })
    
    local rButtonCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = colorRButton
    })
    
    local gButtonCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = colorGButton
    })
    
    local bButtonCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = colorBButton
    })
    
    local applyCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = applyButton
    })
    
    -- Make picker window draggable
    self:MakeDraggable(pickerWindow, pickerTopBar)
    
    -- Color picker functionality
    pickerButton.MouseButton1Click:Connect(function()
        pickerWindow.Visible = true
    end)
    
    pickerCloseButton.MouseButton1Click:Connect(function()
        pickerWindow.Visible = false
    end)
    
    -- RGB sliders functionality
    local rDragging = false
    local gDragging = false
    local bDragging = false
    
    colorRButton.MouseButton1Down:Connect(function()
        rDragging = true
    end)
    
    colorGButton.MouseButton1Down:Connect(function()
        gDragging = true
    end)
    
    colorBButton.MouseButton1Down:Connect(function()
        bDragging = true
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if rDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - colorR.AbsolutePosition.X) / colorR.AbsoluteSize.X, 0, 1)
            
            -- Update color
            selectedColor = Color3.fromRGB(relativeX, selectedColor.G, selectedColor.B)
            
            -- Update visuals
            colorDisplay.BackgroundColor3 = selectedColor
            colorHex.Text = "#" .. selectedColor:ToHex()
            colorRFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, 0, 0)
            colorRFill.Size = UDim2.new(selectedColor.R, 0, 1, 0)
            colorRButton.Position = UDim2.new(selectedColor.R, -6, 0.5, -6)
            colorRLabel.Text = "R: " .. math.floor(selectedColor.R * 255)
            
            -- Update G and B fills with new R value
            colorGFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, selectedColor.G * 255, 0)
            colorBFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, 0, selectedColor.B * 255)
        end
        
        if gDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - colorG.AbsolutePosition.X) / colorG.AbsoluteSize.X, 0, 1)
            
            -- Update color
            selectedColor = Color3.fromRGB(selectedColor.R, relativeX, selectedColor.B)
            
            -- Update visuals
            colorDisplay.BackgroundColor3 = selectedColor
            colorHex.Text = "#" .. selectedColor:ToHex()
            colorGFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, selectedColor.G * 255, 0)
            colorGFill.Size = UDim2.new(selectedColor.G, 0, 1, 0)
            colorGButton.Position = UDim2.new(selectedColor.G, -6, 0.5, -6)
            colorGLabel.Text = "G: " .. math.floor(selectedColor.G * 255)
            
            -- Update R and B fills with new G value
            colorRFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, selectedColor.G * 255, 0)
            colorBFill.BackgroundColor3 = Color3.fromRGB(0, selectedColor.G * 255, selectedColor.B * 255)
        end
        
        if bDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp((input.Position.X - colorB.AbsolutePosition.X) / colorB.AbsoluteSize.X, 0, 1)
            
            -- Update color
            selectedColor = Color3.fromRGB(selectedColor.R, selectedColor.G, relativeX)
            
            -- Update visuals
            colorDisplay.BackgroundColor3 = selectedColor
            colorHex.Text = "#" .. selectedColor:ToHex()
            colorBFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, 0, selectedColor.B * 255)
            colorBFill.Size = UDim2.new(selectedColor.B, 0, 1, 0)
            colorBButton.Position = UDim2.new(selectedColor.B, -6, 0.5, -6)
            colorBLabel.Text = "B: " .. math.floor(selectedColor.B * 255)
            
            -- Update R and G fills with new B value
            colorRFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, 0, selectedColor.B * 255)
            colorGFill.BackgroundColor3 = Color3.fromRGB(0, selectedColor.G * 255, selectedColor.B * 255)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            rDragging = false
            gDragging = false
            bDragging = false
        end
    end)
    
    -- Hex input functionality
    colorHex.FocusLost:Connect(function()
        local hex = colorHex.Text:gsub("#", "")
        if #hex == 6 then
            local r = tonumber("0x" .. hex:sub(1, 2)) / 255
            local g = tonumber("0x" .. hex:sub(3, 4)) / 255
            local b = tonumber("0x" .. hex:sub(5, 6)) / 255
            
            if r and g and b then
                selectedColor = Color3.fromRGB(r, g, b)
                
                -- Update visuals
                colorDisplay.BackgroundColor3 = selectedColor
                colorRFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, 0, 0)
                colorRFill.Size = UDim2.new(selectedColor.R, 0, 1, 0)
                colorRButton.Position = UDim2.new(selectedColor.R, -6, 0.5, -6)
                colorRLabel.Text = "R: " .. math.floor(selectedColor.R * 255)
                
                colorGFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, selectedColor.G * 255, 0)
                colorGFill.Size = UDim2.new(selectedColor.G, 0, 1, 0)
                colorGButton.Position = UDim2.new(selectedColor.G, -6, 0.5, -6)
                colorGLabel.Text = "G: " .. math.floor(selectedColor.G * 255)
                
                colorBFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, 0, selectedColor.B * 255)
                colorBFill.Size = UDim2.new(selectedColor.B, 0, 1, 0)
                colorBButton.Position = UDim2.new(selectedColor.B, -6, 0.5, -6)
                colorBLabel.Text = "B: " .. math.floor(selectedColor.B * 255)
            else
                colorHex.Text = "#" .. selectedColor:ToHex()
            end
        else
            colorHex.Text = "#" .. selectedColor:ToHex()
        end
    end)
    
    -- Apply button functionality
    applyButton.MouseButton1Click:Connect(function()
        pickerButton.BackgroundColor3 = selectedColor
        pickerWindow.Visible = false
        callback(selectedColor)
    end)
    
    -- Store component
    local componentId = #self.Components + 1
    self.Components[componentId] = {
        Type = "ColorPicker",
        Instance = colorPicker,
        Color = selectedColor,
        SetColor = function(color)
            selectedColor = color
            
            -- Update visuals
            pickerButton.BackgroundColor3 = selectedColor
            colorDisplay.BackgroundColor3 = selectedColor
            colorHex.Text = "#" .. selectedColor:ToHex()
            colorRFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, 0, 0)
            colorRFill.Size = UDim2.new(selectedColor.R, 0, 1, 0)
            colorRButton.Position = UDim2.new(selectedColor.R, -6, 0.5, -6)
            colorRLabel.Text = "R: " .. math.floor(selectedColor.R * 255)
            
            colorGFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, selectedColor.G * 255, 0)
            colorGFill.Size = UDim2.new(selectedColor.G, 0, 1, 0)
            colorGButton.Position = UDim2.new(selectedColor.G, -6, 0.5, -6)
            colorGLabel.Text = "G: " .. math.floor(selectedColor.G * 255)
            
            colorBFill.BackgroundColor3 = Color3.fromRGB(selectedColor.R * 255, 0, selectedColor.B * 255)
            colorBFill.Size = UDim2.new(selectedColor.B, 0, 1, 0)
            colorBButton.Position = UDim2.new(selectedColor.B, -6, 0.5, -6)
            colorBLabel.Text = "B: " .. math.floor(selectedColor.B * 255)
            
            callback(selectedColor)
        end,
        GetColor = function()
            return selectedColor
        end
    }
    
    return self.Components[componentId]
end

-- Create a label component
function gg:CreateLabel(tab, title)
    local label = createInstance("TextLabel", {
        Name = title .. "Label",
        BackgroundColor3 = gg.CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = title,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = tab.Content
    })
    
    -- Round corners
    local labelCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = label
    })
    
    -- Store component
    local componentId = #self.Components + 1
    self.Components[componentId] = {
        Type = "Label",
        Instance = label,
        SetText = function(text)
            label.Text = text
        end,
        GetText = function()
            return label.Text
        end
    }
    
    return self.Components[componentId]
end

-- Create a textbox component
function gg:CreateTextbox(tab, title, default, callback)
    default = default or ""
    callback = callback or function() end
    
    local textbox = createInstance("Frame", {
        Name = title .. "Textbox",
        BackgroundColor3 = gg.CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = tab.Content
    })
    
    local textboxTitle = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = title,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textbox
    })
    
    local textboxInput = createInstance("TextBox", {
        Name = "Input",
        BackgroundColor3 = gg.CurrentTheme.Border,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = default,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Size = UDim2.new(0, 120, 0, 20),
        Position = UDim2.new(1, -130, 0.5, -10),
        Parent = textbox
    })
    
    -- Round corners
    local inputCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = textboxInput
    })
    
    local value = default
    
    -- Textbox functionality
    textboxInput.FocusLost:Connect(function()
        value = textboxInput.Text
        callback(value)
    end)
    
    textboxInput.MouseEnter:Connect(function()
        TweenService:Create(
            textboxInput,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Accent}
        ):Play()
    end)
    
    textboxInput.MouseLeave:Connect(function()
        TweenService:Create(
            textboxInput,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Border}
        ):Play()
    end)
    
    -- Store component
    local componentId = #self.Components + 1
    self.Components[componentId] = {
        Type = "Textbox",
        Instance = textbox,
        Value = value,
        SetValue = function(newValue)
            value = newValue
            textboxInput.Text = newValue
            callback(newValue)
        end,
        GetValue = function()
            return value
        end
    }
    
    return self.Components[componentId]
end

-- Create a keybind component
function gg:CreateKeybind(tab, title, default, callback)
    default = default or "None"
    callback = callback or function() end
    
    local keybind = createInstance("Frame", {
        Name = title .. "Keybind",
        BackgroundColor3 = gg.CurrentTheme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = tab.Content
    })
    
    local keybindTitle = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = title,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.7, -10, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybind
    })
    
    local keybindButton = createInstance("TextButton", {
        Name = "Button",
        BackgroundColor3 = gg.CurrentTheme.Border,
        BorderSizePixel = 0,
        Font = Enum.Font.Gotham,
        Text = default,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Size = UDim2.new(0, 120, 0, 20),
        Position = UDim2.new(1, -130, 0.5, -10),
        Parent = keybind
    })
    
    -- Round corners
    local buttonCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 4),
        Parent = keybindButton
    })
    
    local selectedKey = default
    local isBinding = false
    
    -- Keybind functionality
    keybindButton.MouseButton1Click:Connect(function()
        isBinding = true
        keybindButton.Text = "[...]"
    end)
    
    UserInputService.InputBegan:Connect(function(input)
        if isBinding then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                selectedKey = input.KeyCode.Name
                keybindButton.Text = selectedKey
                isBinding = false
                callback(selectedKey)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                selectedKey = "MouseButton1"
                keybindButton.Text = selectedKey
                isBinding = false
                callback(selectedKey)
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                selectedKey = "MouseButton2"
                keybindButton.Text = selectedKey
                isBinding = false
                callback(selectedKey)
            end
        elseif input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode.Name == selectedKey then
            callback(selectedKey)
        elseif input.UserInputType == Enum.UserInputType.MouseButton1 and selectedKey == "MouseButton1" then
            callback(selectedKey)
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 and selectedKey == "MouseButton2" then
            callback(selectedKey)
        end
    end)
    
    keybindButton.MouseEnter:Connect(function()
        TweenService:Create(
            keybindButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Accent}
        ):Play()
    end)
    
    keybindButton.MouseLeave:Connect(function()
        TweenService:Create(
            keybindButton,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = gg.CurrentTheme.Border}
        ):Play()
    end)
    
    -- Store component
    local componentId = #self.Components + 1
    self.Components[componentId] = {
        Type = "Keybind",
        Instance = keybind,
        Key = selectedKey,
        SetKey = function(newKey)
            selectedKey = newKey
            keybindButton.Text = newKey
            callback(newKey)
        end,
        GetKey = function()
            return selectedKey
        end
    }
    
    return self.Components[componentId]
end

-- Create a notification
function gg:CreateNotification(title, text, type, duration)
    type = type or "info"
    duration = duration or 5
    
    local notification = createInstance("Frame", {
        Name = "Notification",
        BackgroundColor3 = gg.CurrentTheme.Primary,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -320, 1, 50),
        Size = UDim2.new(0, 300, 0, 80),
        Parent = self.ScreenGui
    })
    
    local notificationTopBar = createInstance("Frame", {
        Name = "TopBar",
        BackgroundColor3 = type == "success" and gg.CurrentTheme.Success or 
                         type == "warning" and gg.CurrentTheme.Warning or 
                         type == "error" and gg.CurrentTheme.Error or 
                         gg.CurrentTheme.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 25),
        Parent = notification
    })
    
    local notificationTitle = createInstance("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(1, -40, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notificationTopBar
    })
    
    local notificationClose = createInstance("TextButton", {
        Name = "Close",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "×",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 18,
        Position = UDim2.new(1, -25, 0, 0),
        Size = UDim2.new(0, 25, 1, 0),
        Parent = notificationTopBar
    })
    
    local notificationText = createInstance("TextLabel", {
        Name = "Text",
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = gg.CurrentTheme.Text,
        TextSize = 14,
        Position = UDim2.new(0, 10, 0, 30),
        Size = UDim2.new(1, -20, 0, 40),
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = notification
    })
    
    -- Round corners
    local notificationCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notification
    })
    
    local topBarCorner = createInstance("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = notificationTopBar
    })
    
    -- Add to notifications table
    local notificationId = #self.Notifications + 1
    self.Notifications[notificationId] = notification
    
    -- Adjust position based on existing notifications
    for i, notif in pairs(self.Notifications) do
        if i ~= notificationId then
            TweenService:Create(
                notif,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(1, -320, 1, 50 + (i * 90))}
            ):Play()
        end
    end
    
    -- Animate in
    TweenService:Create(
        notification,
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(1, -320, 1, 50 + (notificationId * 90))}
    ):Play()
    
    -- Close functionality
    local function closeNotification()
        TweenService:Create(
            notification,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(1, 320, 1, 50 + (notificationId * 90))}
        ):Play()
        
        wait(0.3)
        notification:Destroy()
        self.Notifications[notificationId] = nil
        
        -- Adjust positions of remaining notifications
        for i, notif in pairs(self.Notifications) do
            TweenService:Create(
                notif,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {Position = UDim2.new(1, -320, 1, 50 + (i * 90))}
            ):Play()
        end
    end
    
    notificationClose.MouseButton1Click:Connect(closeNotification)
    
    -- Auto-close after duration
    if duration > 0 then
        task.spawn(function()
            wait(duration)
            if notification and notification.Parent then
                closeNotification()
            end
        end)
    end
    
    return {
        Close = closeNotification,
        UpdateText = function(newText)
            notificationText.Text = newText
        end,
        UpdateTitle = function(newTitle)
            notificationTitle.Text = newTitle
        end
    }
end

-- Create ESP system
function gg:CreateESP()
    local esp = {}
    
    -- ESP GUI
    esp.GUI = createInstance("Folder", {
        Name = "ESP",
        Parent = workspace.CurrentCamera
    })
    
    -- ESP settings
    esp.Settings = {
        Enabled = false,
        TeamCheck = false,
        ShowName = true,
        ShowDistance = true,
        ShowHealth = true,
        ShowBox = true,
        BoxColor = Color3.fromRGB(255, 0, 0),
        NameColor = Color3.fromRGB(255, 255, 255),
        HealthColor = Color3.fromRGB(0, 255, 0),
        MaxDistance = 1000,
        Transparency = 0.7
    }
    
    -- ESP objects storage
    esp.Objects = {}
    
    -- Create ESP for a player
    function esp:AddPlayer(player)
        if player == player or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
            return
        end
        
        -- Create ESP objects
        local espObjects = {}
        
        -- Box
        espObjects.Box = createInstance("Frame", {
            Name = player.Name .. "_Box",
            BackgroundTransparency = 1,
            BorderColor3 = esp.Settings.BoxColor,
            BorderSizePixel = 1,
            Parent = esp.GUI
        })
        
        espObjects.TopLeft = createInstance("Frame", {
            Name = "TopLeft",
            BackgroundColor3 = esp.Settings.BoxColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 2, 0, 2),
            Parent = espObjects.Box
        })
        
        espObjects.TopRight = createInstance("Frame", {
            Name = "TopRight",
            BackgroundColor3 = esp.Settings.BoxColor,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -2, 0, 0),
            Size = UDim2.new(0, 2, 0, 2),
            Parent = espObjects.Box
        })
        
        espObjects.BottomLeft = createInstance("Frame", {
            Name = "BottomLeft",
            BackgroundColor3 = esp.Settings.BoxColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, -2),
            Size = UDim2.new(0, 2, 0, 2),
            Parent = espObjects.Box
        })
        
        espObjects.BottomRight = createInstance("Frame", {
            Name = "BottomRight",
            BackgroundColor3 = esp.Settings.BoxColor,
            BorderSizePixel = 0,
            Position = UDim2.new(1, -2, 1, -2),
            Size = UDim2.new(0, 2, 0, 2),
            Parent = espObjects.Box
        })
        
        -- Name
        espObjects.Name = createInstance("TextLabel", {
            Name = player.Name .. "_Name",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = player.Name,
            TextColor3 = esp.Settings.NameColor,
            TextSize = 14,
            TextStrokeTransparency = 0.5,
            Parent = esp.GUI
        })
        
        -- Distance
        espObjects.Distance = createInstance("TextLabel", {
            Name = player.Name .. "_Distance",
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = "0",
            TextColor3 = esp.Settings.NameColor,
            TextSize = 12,
            TextStrokeTransparency = 0.5,
            Parent = esp.GUI
        })
        
        -- Health
        espObjects.Health = createInstance("Frame", {
            Name = player.Name .. "_Health",
            BackgroundColor3 = Color3.fromRGB(50, 50, 50),
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0, 100, 0, 5),
            Parent = esp.GUI
        })
        
        espObjects.HealthFill = createInstance("Frame", {
            Name = "Fill",
            BackgroundColor3 = esp.Settings.HealthColor,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(1, 0, 1, 0),
            Parent = espObjects.Health
        })
        
        -- Store ESP objects
        esp.Objects[player] = espObjects
        
        -- Update ESP
        esp:UpdatePlayer(player)
    end
    
    -- Remove ESP for a player
    function esp:RemovePlayer(player)
        if esp.Objects[player] then
            for _, obj in pairs(esp.Objects[player]) do
                if obj and obj.Parent then
                    obj:Destroy()
                end
            end
            esp.Objects[player] = nil
        end
    end
    
    -- Update ESP for a player
    function esp:UpdatePlayer(player)
        if not esp.Settings.Enabled or not esp.Objects[player] then
            return
        end
        
        local espObjects = esp.Objects[player]
        local character = player.Character
        local humanoidRootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChild("Humanoid")
        
        if not humanoidRootPart or not humanoid then
            return
        end
        
        -- Team check
        if esp.Settings.TeamCheck and player.Team == player.Team then
            for _, obj in pairs(espObjects) do
                if obj and obj.Parent then
                    obj.Visible = false
                end
            end
            return
        end
        
        -- Calculate distance
        local distance = (player.Character.HumanoidRootPart.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
        
        -- Distance check
        if distance > esp.Settings.MaxDistance then
            for _, obj in pairs(espObjects) do
                if obj and obj.Parent then
                    obj.Visible = false
                end
            end
            return
        end
        
        -- Calculate box size and position
        local pos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position)
        local headPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position + Vector3.new(0, humanoid.HipHeight + (humanoid.HipHeight / 2), 0))
        local legPos = workspace.CurrentCamera:WorldToViewportPoint(humanoidRootPart.Position - Vector3.new(0, humanoid.HipHeight, 0))
        
        if onScreen then
            local boxHeight = math.abs(headPos.Y - legPos.Y)
            local boxWidth = boxHeight / 2
            
            -- Update box
            if esp.Settings.ShowBox then
                espObjects.Box.Visible = true
                espObjects.Box.Position = UDim2.new(0, pos.X - boxWidth / 2, 0, headPos.Y)
                espObjects.Box.Size = UDim2.new(0, boxWidth, 0, boxHeight)
                
                espObjects.TopLeft.BackgroundColor3 = esp.Settings.BoxColor
                espObjects.TopRight.BackgroundColor3 = esp.Settings.BoxColor
                espObjects.BottomLeft.BackgroundColor3 = esp.Settings.BoxColor
                espObjects.BottomRight.BackgroundColor3 = esp.Settings.BoxColor
            else
                espObjects.Box.Visible = false
            end
            
            -- Update name
            if esp.Settings.ShowName then
                espObjects.Name.Visible = true
                espObjects.Name.Position = UDim2.new(0, pos.X, 0, headPos.Y - 15)
                espObjects.Name.Text = player.Name
                espObjects.Name.TextColor3 = esp.Settings.NameColor
            else
                espObjects.Name.Visible = false
            end
            
            -- Update distance
            if esp.Settings.ShowDistance then
                espObjects.Distance.Visible = true
                espObjects.Distance.Position = UDim2.new(0, pos.X, 0, legPos.Y + 5)
                espObjects.Distance.Text = math.floor(distance) .. " studs"
                espObjects.Distance.TextColor3 = esp.Settings.NameColor
            else
                espObjects.Distance.Visible = false
            end
            
            -- Update health
            if esp.Settings.ShowHealth then
                espObjects.Health.Visible = true
                espObjects.Health.Position = UDim2.new(0, pos.X - 50, 0, legPos.Y + 20)
                espObjects.Health.Size = UDim2.new(0, 100, 0, 5)
                
                espObjects.HealthFill.Visible = true
                espObjects.HealthFill.Size = UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0)
                
                -- Change health color based on health percentage
                local healthPercent = humanoid.Health / humanoid.MaxHealth
                if healthPercent > 0.6 then
                    espObjects.HealthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                elseif healthPercent > 0.3 then
                    espObjects.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
                else
                    espObjects.HealthFill.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
                end
            else
                espObjects.Health.Visible = false
                espObjects.HealthFill.Visible = false
            end
        else
            for _, obj in pairs(espObjects) do
                if obj and obj.Parent then
                    obj.Visible = false
                end
            end
        end
    end
    
    -- Update all ESP
    function esp:UpdateAll()
        for player, _ in pairs(esp.Objects) do
            esp:UpdatePlayer(player)
        end
    end
    
    -- Toggle ESP
    function esp:Toggle()
        esp.Settings.Enabled = not esp.Settings.Enabled
        
        if not esp.Settings.Enabled then
            for player, espObjects in pairs(esp.Objects) do
                for _, obj in pairs(espObjects) do
                    if obj and obj.Parent then
                        obj.Visible = false
                    end
                end
            end
        end
    end
    
    -- Update ESP settings
    function esp:UpdateSettings(settings)
        for key, value in pairs(settings) do
            esp.Settings[key] = value
        end
        
        -- Update existing ESP objects with new settings
        for player, espObjects in pairs(esp.Objects) do
            if espObjects.Box then
                espObjects.TopLeft.BackgroundColor3 = esp.Settings.BoxColor
                espObjects.TopRight.BackgroundColor3 = esp.Settings.BoxColor
                espObjects.BottomLeft.BackgroundColor3 = esp.Settings.BoxColor
                espObjects.BottomRight.BackgroundColor3 = esp.Settings.BoxColor
            end
            
            if espObjects.Name then
                espObjects.Name.TextColor3 = esp.Settings.NameColor
            end
            
            if espObjects.Distance then
                espObjects.Distance.TextColor3 = esp.Settings.NameColor
            end
            
            esp:UpdatePlayer(player)
        end
    end
    
    -- ESP update loop
    local espConnection
    function esp:Start()
        espConnection = RunService.RenderStepped:Connect(function()
            esp:UpdateAll()
        end)
        
        -- Player added/removed events
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function()
                esp:AddPlayer(player)
            end)
        end)
        
        Players.PlayerRemoving:Connect(function(player)
            esp:RemovePlayer(player)
        end)
        
        -- Add existing players
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= player and player.Character then
                esp:AddPlayer(player)
            end
        end
    end
    
    function esp:Stop()
        if espConnection then
            espConnection:Disconnect()
            espConnection = nil
        end
        
        -- Remove all ESP objects
        for player, _ in pairs(esp.Objects) do
            esp:RemovePlayer(player)
        end
    end
    
    -- Start ESP
    esp:Start()
    
    return esp
end

-- Set theme
function gg:SetTheme(theme)
    if gg.Themes[theme] then
        gg.CurrentTheme = gg.Themes[theme]
        
        -- Update all UI elements with new theme
        self.MainFrame.BackgroundColor3 = gg.CurrentTheme.Background
        self.TopBar.BackgroundColor3 = gg.CurrentTheme.Primary
        self.Title.TextColor3 = gg.CurrentTheme.Text
        self.Status.TextColor3 = gg.CurrentTheme.TextSecondary
        self.Content.BackgroundColor3 = gg.CurrentTheme.Background
        self.LeftSidebar.BackgroundColor3 = gg.CurrentTheme.Primary
        self.MainContent.BackgroundColor3 = gg.CurrentTheme.Background
        
        -- Update tabs
        for name, tab in pairs(self.Tabs) do
            if name == self.CurrentTab then
                tab.Button.BackgroundColor3 = gg.CurrentTheme.Accent
            else
                tab.Button.BackgroundColor3 = gg.CurrentTheme.Secondary
            end
            tab.Button.TextColor3 = gg.CurrentTheme.Text
            tab.Content.BackgroundColor3 = gg.CurrentTheme.Background
        end
        
        -- Update components
        for _, component in pairs(self.Components) do
            if component.Type == "Toggle" then
                local toggle = component.Instance
                local toggleTitle = toggle:FindFirstChild("Title")
                local toggleButton = toggle:FindFirstChild("Button")
                local toggleIndicator = toggleButton:FindFirstChild("Indicator")
                
                if toggleTitle then
                    toggleTitle.TextColor3 = gg.CurrentTheme.Text
                end
                
                if component.State then
                    toggleButton.BackgroundColor3 = gg.CurrentTheme.ToggleOn
                else
                    toggleButton.BackgroundColor3 = gg.CurrentTheme.ToggleOff
                end
                
                if toggleIndicator then
                    toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                end
            elseif component.Type == "Slider" then
                local slider = component.Instance
                local sliderTitle = slider:FindFirstChild("Title")
                local sliderValue = slider:FindFirstChild("Value")
                local sliderBar = slider:FindFirstChild("Bar")
                local sliderFill = sliderBar:FindFirstChild("Fill")
                local sliderButton = sliderBar:FindFirstChild("Button")
                
                if sliderTitle then
                    sliderTitle.TextColor3 = gg.CurrentTheme.Text
                end
                
                if sliderValue then
                    sliderValue.TextColor3 = gg.CurrentTheme.TextSecondary
                end
                
                if sliderBar then
                    sliderBar.BackgroundColor3 = gg.CurrentTheme.Border
                end
                
                if sliderFill then
                    sliderFill.BackgroundColor3 = gg.CurrentTheme.Accent
                end
                
                if sliderButton then
                    sliderButton.BackgroundColor3 = gg.CurrentTheme.Text
                end
            elseif component.Type == "Dropdown" then
                local dropdown = component.Instance
                local dropdownTitle = dropdown:FindFirstChild("Title")
                local dropdownButton = dropdown:FindFirstChild("Button")
                local dropdownArrow = dropdownButton:FindFirstChild("Arrow")
                local optionsContainer = dropdown:FindFirstChild("OptionsContainer")
                
                if dropdownTitle then
                    dropdownTitle.TextColor3 = gg.CurrentTheme.Text
                end
                
                if dropdownButton then
                    dropdownButton.BackgroundColor3 = gg.CurrentTheme.Border
                    dropdownButton.TextColor3 = gg.CurrentTheme.Text
                end
                
                if dropdownArrow then
                    dropdownArrow.ImageColor3 = gg.CurrentTheme.Text
                end
                
                if optionsContainer then
                    optionsContainer.BackgroundColor3 = gg.CurrentTheme.Primary
                    
                    for _, option in pairs(optionsContainer:GetChildren()) do
                        if option:IsA("TextButton") then
                            option.BackgroundColor3 = gg.CurrentTheme.Secondary
                            option.TextColor3 = gg.CurrentTheme.Text
                        end
                    end
                end
            elseif component.Type == "Button" then
                local button = component.Instance
                button.BackgroundColor3 = gg.CurrentTheme.Accent
                button.TextColor3 = Color3.fromRGB(255, 255, 255)
            elseif component.Type == "ColorPicker" then
                local colorPicker = component.Instance
                local pickerTitle = colorPicker:FindFirstChild("Title")
                local pickerButton = colorPicker:FindFirstChild("Button")
                
                if pickerTitle then
                    pickerTitle.TextColor3 = gg.CurrentTheme.Text
                end
                
                if pickerButton then
                    pickerButton.BackgroundColor3 = component.Color
                end
            elseif component.Type == "Label" then
                local label = component.Instance
                label.BackgroundColor3 = gg.CurrentTheme.Secondary
                label.TextColor3 = gg.CurrentTheme.Text
            elseif component.Type == "Textbox" then
                local textbox = component.Instance
                local textboxTitle = textbox:FindFirstChild("Title")
                local textboxInput = textbox:FindFirstChild("Input")
                
                if textboxTitle then
                    textboxTitle.TextColor3 = gg.CurrentTheme.Text
                end
                
                if textboxInput then
                    textboxInput.BackgroundColor3 = gg.CurrentTheme.Border
                    textboxInput.TextColor3 = gg.CurrentTheme.Text
                end
            elseif component.Type == "Keybind" then
                local keybind = component.Instance
                local keybindTitle = keybind:FindFirstChild("Title")
                local keybindButton = keybind:FindFirstChild("Button")
                
                if keybindTitle then
                    keybindTitle.TextColor3 = gg.CurrentTheme.Text
                end
                
                if keybindButton then
                    keybindButton.BackgroundColor3 = gg.CurrentTheme.Border
                    keybindButton.TextColor3 = gg.CurrentTheme.Text
                end
            end
        end
        
        -- Update notifications
        for _, notification in pairs(self.Notifications) do
            if notification and notification.Parent then
                notification.BackgroundColor3 = gg.CurrentTheme.Primary
                
                local topBar = notification:FindFirstChild("TopBar")
                if topBar then
                    local title = topBar:FindFirstChild("Title")
                    if title then
                        title.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end
                
                local text = notification:FindFirstChild("Text")
                if text then
                    text.TextColor3 = gg.CurrentTheme.Text
                end
            end
        end
    end
end

-- Destroy UI
function gg:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
    
    -- Stop ESP if it's running
    if self.ESP and self.ESP.Stop then
        self.ESP:Stop()
    end
end

return gg