local mods = rom.mods
mods['SGG_Modding-ENVY'].auto()

---@diagnostic disable: lowercase-global
rom = rom
_PLUGIN = _PLUGIN
game = rom.game
modutil = mods['SGG_Modding-ModUtil']
chalk = mods['SGG_Modding-Chalk']
reload = mods['SGG_Modding-ReLoad']
local lib = mods['adamant-Modpack_Lib']

config = chalk.auto('config.lua')
public.config = config

local backup, restore = lib.createBackupSystem()

-- =============================================================================
-- MODULE DEFINITION
-- =============================================================================

public.definition = {
    id       = "OmegaCastEffectsFix",
    name     = "Omega Cast Effects Fix",
    category = "BugFixes",
    group    = "Boons & Hammers",
    tooltip  = "Fixes OCast moves not counting as cast damage.",
    default  = true,
    dataMutation = true,
}

-- =============================================================================
-- MODULE LOGIC
-- =============================================================================

local function apply()
    backup(WeaponSets, "CastProjectileNames")
    local missingCastProjectiles = {
        "ApolloCastRapid",
        "AresProjectile",
        "ZeusApolloSynergyStrike",
        "DemeterCastStorm",
        "AthenaCastProjectile",
    }
    for _, projectileName in ipairs(missingCastProjectiles) do
        table.insert(WeaponSets.CastProjectileNames, projectileName)
    end
end

local function registerHooks()
end

-- =============================================================================
-- Wiring
-- =============================================================================

public.definition.enable = apply
public.definition.disable = restore

local loader = reload.auto_single()

modutil.once_loaded.game(function()
    loader.load(function()
        import_as_fallback(rom.game)
        registerHooks()
        if lib.isEnabled(config) then apply() end
        if public.definition.dataMutation and not mods['adamant-Modpack_Core'] then
            SetupRunData()
        end
    end)
end)

local uiCallback = lib.standaloneUI(public.definition, config, apply, restore)
rom.gui.add_to_menu_bar(uiCallback)
