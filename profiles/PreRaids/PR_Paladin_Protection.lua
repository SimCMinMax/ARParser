--- ============================ HEADER ============================
--- ======= LOCALIZE =======
-- Addon
local addonName, addonTable = ...
-- HeroLib
local HL     = HeroLib
local Cache  = HeroCache
local Unit   = HL.Unit
local Player = Unit.Player
local Target = Unit.Target
local Pet    = Unit.Pet
local Spell  = HL.Spell
local Item   = HL.Item
-- HeroRotation
local HR     = HeroRotation

--- ============================ CONTENT ===========================
--- ======= APL LOCALS =======
-- luacheck: max_line_length 9999

-- Spells
if not Spell.Paladin then Spell.Paladin = {} end
Spell.Paladin.Protection = {
  LightsJudgment                        = Spell(255647),
  Fireblood                             = Spell(265221),
  AvengingWrathBuff                     = Spell(31884),
  Seraphim                              = Spell(152262),
  ShieldoftheRighteous                  = Spell(53600),
  AvengingWrath                         = Spell(31884),
  SeraphimBuff                          = Spell(152262),
  BastionofLight                        = Spell(204035),
  AvengersValorBuff                     = Spell(),
  Consecration                          = Spell(26573),
  Judgment                              = Spell(20271),
  CrusadersJudgment                     = Spell(),
  AvengersShield                        = Spell(31935),
  BlessedHammer                         = Spell(204019),
  HammeroftheRighteous                  = Spell(53595)
};
local S = Spell.Paladin.Protection;

-- Items
if not Item.Paladin then Item.Paladin = {} end
Item.Paladin.Protection = {
  BattlePotionofStamina            = Item(),
  MerekthasFang                    = Item(),
  RazdunksBigRedButton             = Item()
};
local I = Item.Paladin.Protection;

-- Rotation Var
local ShouldReturn; -- Used to get the return string

-- GUI Settings
local Everyone = HR.Commons.Everyone;
local Settings = {
  General = HR.GUISettings.General,
  Commons = HR.GUISettings.APL.Paladin.Commons,
  Protection = HR.GUISettings.APL.Paladin.Protection
};


local EnemyRanges = {}
local function UpdateRanges()
  for _, i in ipairs(EnemyRanges) do
    HL.GetEnemies(i);
  end
end


local function num(val)
  if val then return 1 else return 0 end
end

local function bool(val)
  return val ~= 0
end

--- ======= ACTION LISTS =======
local function APL()
  local Precombat, Cooldowns
  UpdateRanges()
  Everyone.AoEToggleEnemiesUpdate()
  Precombat = function()
    -- flask
    -- food
    -- augmentation
    -- snapshot_stats
    -- potion
    if I.BattlePotionofStamina:IsReady() and Settings.Commons.UsePotions then
      if HR.CastSuggested(I.BattlePotionofStamina) then return "battle_potion_of_stamina 4"; end
    end
    -- lights_judgment
    if S.LightsJudgment:IsCastableP() and HR.CDsON() then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 6"; end
    end
  end
  Cooldowns = function()
    -- fireblood,if=buff.avenging_wrath.up
    if S.Fireblood:IsCastableP() and HR.CDsON() and (Player:BuffP(S.AvengingWrathBuff)) then
      if HR.Cast(S.Fireblood, Settings.Commons.OffGCDasOffGCD.Racials) then return "fireblood 8"; end
    end
    -- seraphim,if=cooldown.shield_of_the_righteous.charges_fractional>=2
    if S.Seraphim:IsCastableP() and (S.ShieldoftheRighteous:ChargesFractionalP() >= 2) then
      if HR.Cast(S.Seraphim) then return "seraphim 12"; end
    end
    -- avenging_wrath,if=buff.seraphim.up|cooldown.seraphim.remains<2|!talent.seraphim.enabled
    if S.AvengingWrath:IsCastableP() and (Player:BuffP(S.SeraphimBuff) or S.Seraphim:CooldownRemainsP() < 2 or not S.Seraphim:IsAvailable()) then
      if HR.Cast(S.AvengingWrath) then return "avenging_wrath 16"; end
    end
    -- bastion_of_light,if=cooldown.shield_of_the_righteous.charges_fractional<=0.5
    if S.BastionofLight:IsCastableP() and (S.ShieldoftheRighteous:ChargesFractionalP() <= 0.5) then
      if HR.Cast(S.BastionofLight) then return "bastion_of_light 24"; end
    end
    -- potion,if=buff.avenging_wrath.up
    if I.BattlePotionofStamina:IsReady() and Settings.Commons.UsePotions and (Player:BuffP(S.AvengingWrathBuff)) then
      if HR.CastSuggested(I.BattlePotionofStamina) then return "battle_potion_of_stamina 28"; end
    end
    -- use_items,if=buff.seraphim.up|!talent.seraphim.enabled
    -- use_item,name=merekthas_fang,if=!buff.avenging_wrath.up&(buff.seraphim.up|!talent.seraphim.enabled)
    if I.MerekthasFang:IsReady() and (not Player:BuffP(S.AvengingWrathBuff) and (Player:BuffP(S.SeraphimBuff) or not S.Seraphim:IsAvailable())) then
      if HR.CastSuggested(I.MerekthasFang) then return "merekthas_fang 33"; end
    end
    -- use_item,name=razdunks_big_red_button
    if I.RazdunksBigRedButton:IsReady() then
      if HR.CastSuggested(I.RazdunksBigRedButton) then return "razdunks_big_red_button 41"; end
    end
  end
  -- call precombat
  if not Player:AffectingCombat() then
    local ShouldReturn = Precombat(); if ShouldReturn then return ShouldReturn; end
  end
  if Everyone.TargetIsValid() then
    -- auto_attack
    -- call_action_list,name=cooldowns
    if (true) then
      local ShouldReturn = Cooldowns(); if ShouldReturn then return ShouldReturn; end
    end
    -- shield_of_the_righteous,if=(buff.avengers_valor.up&cooldown.shield_of_the_righteous.charges_fractional>=2.5)&(cooldown.seraphim.remains>gcd|!talent.seraphim.enabled)
    if S.ShieldoftheRighteous:IsCastableP() and ((Player:BuffP(S.AvengersValorBuff) and S.ShieldoftheRighteous:ChargesFractionalP() >= 2.5) and (S.Seraphim:CooldownRemainsP() > Player:GCD() or not S.Seraphim:IsAvailable())) then
      if HR.Cast(S.ShieldoftheRighteous) then return "shield_of_the_righteous 47"; end
    end
    -- shield_of_the_righteous,if=(buff.avenging_wrath.up&!talent.seraphim.enabled)|buff.seraphim.up&buff.avengers_valor.up
    if S.ShieldoftheRighteous:IsCastableP() and ((Player:BuffP(S.AvengingWrathBuff) and not S.Seraphim:IsAvailable()) or Player:BuffP(S.SeraphimBuff) and Player:BuffP(S.AvengersValorBuff)) then
      if HR.Cast(S.ShieldoftheRighteous) then return "shield_of_the_righteous 57"; end
    end
    -- shield_of_the_righteous,if=(buff.avenging_wrath.up&buff.avenging_wrath.remains<4&!talent.seraphim.enabled)|(buff.seraphim.remains<4&buff.seraphim.up)
    if S.ShieldoftheRighteous:IsCastableP() and ((Player:BuffP(S.AvengingWrathBuff) and Player:BuffRemainsP(S.AvengingWrathBuff) < 4 and not S.Seraphim:IsAvailable()) or (Player:BuffRemainsP(S.SeraphimBuff) < 4 and Player:BuffP(S.SeraphimBuff))) then
      if HR.Cast(S.ShieldoftheRighteous) then return "shield_of_the_righteous 67"; end
    end
    -- lights_judgment,if=buff.seraphim.up&buff.seraphim.remains<3
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (Player:BuffP(S.SeraphimBuff) and Player:BuffRemainsP(S.SeraphimBuff) < 3) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 79"; end
    end
    -- consecration,if=!consecration.up
    if S.Consecration:IsCastableP() and (not bool(consecration.up)) then
      if HR.Cast(S.Consecration) then return "consecration 85"; end
    end
    -- judgment,if=(cooldown.judgment.remains<gcd&cooldown.judgment.charges_fractional>1&cooldown_react)|!talent.crusaders_judgment.enabled
    if S.Judgment:IsCastableP() and ((S.Judgment:CooldownRemainsP() < Player:GCD() and S.Judgment:ChargesFractionalP() > 1 and S.Judgment:CooldownUpP()) or not S.CrusadersJudgment:IsAvailable()) then
      if HR.Cast(S.Judgment) then return "judgment 87"; end
    end
    -- avengers_shield,if=cooldown_react
    if S.AvengersShield:IsCastableP() and (S.AvengersShield:CooldownUpP()) then
      if HR.Cast(S.AvengersShield) then return "avengers_shield 99"; end
    end
    -- judgment,if=cooldown_react|!talent.crusaders_judgment.enabled
    if S.Judgment:IsCastableP() and (S.Judgment:CooldownUpP() or not S.CrusadersJudgment:IsAvailable()) then
      if HR.Cast(S.Judgment) then return "judgment 105"; end
    end
    -- lights_judgment,if=!talent.seraphim.enabled|buff.seraphim.up
    if S.LightsJudgment:IsCastableP() and HR.CDsON() and (not S.Seraphim:IsAvailable() or Player:BuffP(S.SeraphimBuff)) then
      if HR.Cast(S.LightsJudgment) then return "lights_judgment 113"; end
    end
    -- blessed_hammer,strikes=3
    if S.BlessedHammer:IsCastableP() then
      if HR.Cast(S.BlessedHammer) then return "blessed_hammer 119"; end
    end
    -- hammer_of_the_righteous
    if S.HammeroftheRighteous:IsCastableP() then
      if HR.Cast(S.HammeroftheRighteous) then return "hammer_of_the_righteous 121"; end
    end
    -- consecration
    if S.Consecration:IsCastableP() then
      if HR.Cast(S.Consecration) then return "consecration 123"; end
    end
  end
end

HR.SetAPL(66, APL)
