-- this file is loaded by ETGMod
-- and it's used to setup a base environment for mods
-- editing this file has a high chance of breaking mods

-- There's a MOD global available in here
-- with the current mod's ModInfo

local _MOD = MOD -- make it an upvalue
local env = {
  Triggers = {},
  Mod = MOD,
  Logger = MOD.Logger,
  Assemblies = {}
}

local gungeon = interop.assembly "Assembly-CSharp"
local unity = interop.assembly "UnityEngine"

env.Assemblies.Gungeon = gungeon;
env.Assemblies.UnityEngine = unity;
env.Assemblies.System = interop.assembly "System";
env.Assemblies.Mscorlib = interop.assembly "mscorlib";

local ns_etgmod = interop.namespace(gungeon, 'ETGMod')
local function namespace(ass, name, tab)
  return setmetatable(tab, {
    __index = interop.namespace(ass, name)
  })
end

local _GAME = namespace(gungeon, "-", {
  ETGMod = namespace(gungeon, "ETGMod", {
    GUI = interop.namespace(gungeon, 'ETGMod.GUI'),
    Lua = interop.namespace(gungeon, 'ETGMod.Lua'),
    Console = namespace(gungeon, "ETGMod.Console", {
      Parser = interop.namespace(gungeon, 'ETGMod.Console')
    }),
    TexMod = interop.namespace(gungeon, 'ETGMod.TexMod')
  })
})
env._GAME = _GAME

-- for k, v in pairs(luanet.namespace {'ETGMod.Lua'}) do
--   env[k] = v
-- end

local lua = interop.namespace(gungeon, 'ETGMod.Lua')
env = setmetatable(env, {
  __index = function(self, k)
    if k == "PrimaryPlayer" then
      return lua.Globals.PrimaryPlayer
    elseif k == "SecondaryPlayer" then
      return lua.Globals.SecondaryPlayer
    end
  end
})

local gui = interop.namespace(gungeon, 'ETGMod.GUI')
local etgmod = interop.namespace(gungeon, 'ETGMod')

function env.Color(r, g, b, a)
  if a == nil then
    return etgmod.UnityUtil.NewColorRGB(r, g, b)
  else
    return etgmod.UnityUtil.NewColorRGBA(r, g, b, a)
  end
end

function env.Notify(data)
  if type(data) ~= "table" then
    error("Notification data must be a table")
  end

  if data.title == nil or data.content == nil then
    error("Notification must have a title and content")
  end
  local notif = gui.Notification(data.title, data.content)

  if data.image then
    notif.Image = data.image
  end
  if data.background_color then
    notif.BackgroundColor = data.background_color
  end
  if data.title_color then
    notif.TitleColor = data.title_color
  end
  if data.content_color then
    notif.ContentColor = data.content_color
  end

  gui.GUI.NotificationController:Notify(notif)
end

function env.Hook(method, func)
  _MOD.Hooks:Add(method, func)
end

require("sandbox")(env)

return env;
