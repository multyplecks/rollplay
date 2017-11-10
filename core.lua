--master toggle
local msTog=false
local bheight=-90
local hheight=160
local faction=UnitFactionGroup('player')
local train_state='off'
local pf_warn=false
local pending_request=false
local inviter=''
 -- character init
local dev_mode=false -- will reset player stats every /reload if 'true'
local allocated=0
local miss_tally=0
local btn_sz=30
local btn_szx=34
local btn_szy=50
local hh=UnitSex('player')
local hisher={'their', 'his', 'her'}
local hb_wid=139
local tW=900
local tH=200
local accepting_combat=true
local able_combat=true
local cooldown=false
local help_state=false
local targets={} --targets[player][bool can_be_attacked][str player_status - waiting / accepted / declined]
local function tbar(x) end
local function hs(x) end
local function trainTggl() end
local function strip_name(x)
	local name=x
	local dash=string.find(name, '-')
	local send=''
	if dash~=nil then
		send=string.sub(name, 1, dash-1)
	else
		send=name
	end
	return name
end
local plyr=strip_name(UnitName('player'))
local colors={
	Strength={r=.8, g=0, b=0},
	Charisma={r=1, g=1, b=.2},
	Wisdom={r=.7, g=.6, b=.2},
	Dexterity={r=.6, g=1, b=.4},
	Intelligence={r=.8, g=.3, b=1},
	reset={r=.1, g=1, b=.7},
	white={r=1, g=1, b=1},
	black={r=0, g=0, b=0},
	msg={r=.8, g=.8, b=.3},
	warn={r=1, g=.4, b=0}
}
local hand='Interface\\CURSOR\\openhand'
local point='Interface\\CURSOR\\Point'
local qmark='Interface\\TUTORIALFRAME\\TutorialFrame-QuestionMark'
local shield_d='Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Shield-Desaturated'
local shield='Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Shield'

local spfx='Sound\\Interface\\'
local bookup=spfx..'PickUp\\PickUpBook.ogg'
local warning=''
local goblin_coin='Sound\\Spells\\SPELL_Treasure_Goblin_Coin_Burst_07.OGG'
local coin_toss='Sound\\Spells\\SPELL_Treasure_Goblin_Coin_Toss_10.OGG'
local gusty='Interface\\Spells\\SPELL_Gusty_Wind_Blast_01.OGG'
local prayer='Sound\\Spells\\SPELL_MK_HEALTHGLOBE_DARK_IMPACT0'
local horn='Sound\\Events\\gruntling_horn_bb.ogg'
local bookdown=spfx..'PickUp\\PutDownBook.ogg'
local ping=spfx..'PickUp\\PutDownRing.ogg'
local parch=spfx..'PickUp\\PickUpParchment_Paper.ogg'
local mists='Sound\\Spells\\SPELL_MK_ENVELOPINGMISTS_HEAL.OGG'
local cloudbg="Interface\\GLUES\\Models\\UI_MainMenu_Pandaria\\VEB_Cloud_static_01"
local tiles={
	'Sound\\DOODAD\\FX_BoardTilesDice_02.OGG'
}
local dice={
	'Sound\\DOODAD\\FX_BoardTilesDice_04.OGG',
	'Sound\\DOODAD\\FX_BoardTilesDice_03.OGG'
}
local wound={
	'',
	'Sound\\character\\Human\\Male\\HumanMaleWoundB.ogg',
	'Sound\\character\\DraeneiFemalePC\\DraeneiFemalePCWoundG.ogg'
}
local function rcol(x)
	return math.random(x, 10)/10
end

local pending={}

local cathedral={.499, .453}
local spirits={.327, .648}

local the_log=''
local optArr={}
optArr[1]={'',{1,1,1}}
optArr[2]={'',{1,1,1}}
optArr[3]={'',{1,1,1}}
optArr[4]={'',{1,1,1}}
local function pf_tggl(x, y, z)
	if UnitAffectingCombat('player')==true then
		C_Timer.After(1, function() pf_tggl(x, y, z) end)
		if pf_warn==false then
			pf_warn=true
		end
	else
		if y=='show' then
			x:Show()
			if z~=nil then PlaySoundFile(z) end
		elseif y=='hide' then
			x:Hide()
			if z~=nil then PlaySoundFile(z) end
		end
		pf_warn=false
	end
end
local function prnt(x, col)
	if col==nil then col=colors.white end
	if col==colors.warn then PlaySoundFile(parch) end
	local opt=#optArr
	local insert={x, col}
    table.insert(optArr, 1, insert)
    table.remove(optArr, opt+1)
    for k,v in pairs(optArr) do
    	textFr.txt[k]:SetText(optArr[k][1])
    	textFr.txt[k]:SetTextColor(optArr[k][2].r,optArr[k][2].g,optArr[k][2].b)
    end
end

local function dist(a, b) 
	local c; 
	local x, y=GetPlayerMapPosition("player"); 
	if x~=nil and y~=nil then 
		c=math.sqrt(((a-x)*(a-x))+((b-y)*(b-y))); 
	else c=99999 
	end 
	return c 
end



	local GHFlashFrame
	local flashAnims, isAni
	-- ** color is {r=1,g=1,b=1 **}
	local function ffrm(fadeIn, fadeOut, duration, color, alpha, texture, blend, repeating)
		local blendTypes = {"ADD","BLEND","MOD","ALPHAKEY","DISABLE"}
		if alpha == 1 then alpha = 0.99 end

		if not (color) and not (texture) then

				-- print("[RollPlay]: You must define a texture or color.")
		return
		end

		local delay = duration - (fadeIn + fadeOut)
		if repeating == nil then
			repeating = 1
		end

		if not (GHFlashFrame) then
			GHFlashFrame = CreateFrame("Frame", "GHFlashFrame", UIParent);
			GHFlashFrame:SetFrameStrata("BACKGROUND");
			GHFlashFrame:SetAllPoints(UIParent);
			GHFlashFrame.bg = GHFlashFrame:CreateTexture(nil, "CENTER")
			GHFlashFrame.bg:SetAllPoints(GHFlashFrame)
		end
		if not (flashAnims) then
			flashAnims = GHFlashFrame:CreateAnimationGroup("Flashing")
			flashAnims.fadingIn = flashAnims:CreateAnimation("Alpha")
			flashAnims.fadingIn:SetOrder(1)
			flashAnims.fadingIn:SetSmoothing("NONE")
			flashAnims.fadingIn:SetToAlpha(1)
			
			flashAnims.fadingOut = flashAnims:CreateAnimation("Alpha")
			flashAnims.fadingOut:SetOrder(2)
			flashAnims.fadingOut:SetSmoothing("NONE")
			flashAnims.fadingOut:SetFromAlpha(1)
			
			flashAnims:SetScript("OnFinished",function(self,requested)
				GHFlashFrame:Hide()
				GHFlashFrame.bg:SetBlendMode("DISABLE")
				isAni = false
			end)
			flashAnims:SetScript("OnPlay",function(self)
				GHFlashFrame:Show()
				GHFlashFrame:SetAlpha(0)
				isAni = true
			end)
		end

		flashAnims.fadingIn:SetDuration(fadeIn)
		flashAnims.fadingIn:SetEndDelay(delay)
		flashAnims.fadingOut:SetDuration(fadeOut)
		if repeating > 1 then
			flashAnims:SetLooping("REPEAT")
		else
			flashAnims:SetLooping("NONE")
		end
		local timestart = GetTime()
		local looptime = duration * repeating

		flashAnims:SetScript("OnLoop", function(self, loopstate)
			if loopstate == "FORWARD" then
				local curtime = GetTime()
				if difftime(curtime, timestart) == looptime - duration then
					flashAnims:SetLooping("NONE")
				end
			end
		end)

		if texture then
			GHFlashFrame.bg:SetTexture(texture)
			GHFlashFrame.bg:SetBlendMode(blend or "ADD")
			GHFlashFrame.bg:SetAlpha(alpha or 1)
			flashAnims.fadingIn:SetToAlpha(alpha or 1)
			flashAnims.fadingOut:SetFromAlpha(alpha or 1)

			if color then
				GHFlashFrame.bg:SetVertexColor(
						color.r or color[1],
						color.g or color[2],
						color.b or color[3]
					)
			else
				GHFlashFrame.bg:SetVertexColor(1,1,1,1)
			end
		else
			if not (blend) then
				blend = 5
			end
			GHFlashFrame.bg:SetColorTexture(color.r or color[1], color.g or color[2], color.b or color[3])
			GHFlashFrame.bg:SetBlendMode(blendTypes[blend]) --setblendmode error blorb, on victory
			GHFlashFrame.bg:SetAlpha(alpha or 1)
		end

		if isAni == true then -- if sone is already animating, stop it and do the new one
			GHFlashFrame:StopAnimating()
			GHFlashFrame.bg:SetAlpha(0)
			flashAnims.fadingIn:SetToAlpha(alpha or 1)
			flashAnims.fadingOut:SetFromAlpha(alpha or 1)
			flashAnims:Play()
		else -- otherwise animate
			flashAnims.fadingIn:SetToAlpha(alpha or 1)
			flashAnims.fadingOut:SetFromAlpha(alpha or 1)
			flashAnims:Play()
		end
	end



-- if self, Tyler Durden
local function RlPl_roll(cat, pos, opp)
	local dst_ck=false
	if UnitIsPlayer(opp) then
		dst_ck=CheckInteractDistance(opp, 3)
	else
		dst_ck=CheckInteractDistance('target', 3)
	end
	if dst_ck==true then
		cooldown=true
		C_Timer.After(5, function() cooldown=false end)
		local id,name=GetChannelName('xtensionxtooltip2')
		if id==0 then JoinTemporaryChannel('xtensionxtooltip2') end
		local roll=math.random(1,20)+RllPly[cat]
		if pos=='atk' then
			prnt('You attack '..opp..': '..roll, colors.white)
			pending[opp]=roll
		end
		if pos=='dfd' then
			prnt('You roll: '..roll..' in defense against '..opp, colors.white)
		end
		SendChatMessage('RlPl '..cat..' '..pos..' '..opp..' '..roll, 'CHANNEL', nil, id)
	else
		prnt('Too far!', colors.warn)
	end
end

local rlpl_stats={
	str=1,
	int=1,
	chr=1,
	wis=1,
	dex=1,
	health=5,
	train=10
}
local cats={
	str='Strength',
	int='Intelligence',
	chr='Charisma',
	wis='Wisdom',
	dex='Dexterity'
}

local mPane=CreateFrame("Frame", nil, UIParent)
mPane:SetSize(40, 40)
mPane:SetPoint('CENTER', UIParent, 'CENTER')
mPane:RegisterEvent('ADDON_LOADED')
mPane:RegisterEvent('PLAYER_LOGOUT')

mPane.tggl=CreateFrame("Button", nil, mPane, "SecureHandlerClickTemplate" ) 
mPane.tggl:SetSize(30, 30)
mPane.tggl:SetPoint("CENTER", mPane, "CENTER", 200, 350)
mPane.tggl:RegisterForClicks("AnyUp")
mPane.tggl:SetNormalTexture("Interface\\BUTTONS\\UI-GroupLoot-Dice-Up")
mPane.tggl:SetPushedTexture("Interface\\BUTTONS\\UI-GroupLoot-Dice-Up")
mPane.tggl:SetHighlightTexture("Interface\\BUTTONS\\GLOWSTAR")
mPane.tggl:SetMovable(true)
mPane.tggl:EnableMouse(true)
mPane.tggl:RegisterForDrag("LeftButton")
mPane.tggl:SetScript("OnDragStart", mPane.StartMoving)
mPane.tggl:SetScript("OnDragStop", mPane.StopMovingOrSizing)

mPane.bg=mPane:CreateTexture()
mPane.bg:SetTexture('Interface\\UNITPOWERBARALT\\MetalBronze_Circular_Frame')
mPane.bg:SetSize(55, 55)
mPane.bg:SetPoint('CENTER', mPane.tggl, 'CENTER', 0, 5)

local UIShow=CreateFrame("Frame", nil, mPane)
UIShow:SetSize(tW, tH)
UIShow:SetPoint('TOP', mPane.tggl, 'TOP', 0, -10)
local backdrop = {
	bgFile = cloudbg,
    insets = {
        left = 11,
        right = 12,
        top = -12,
        bottom = 11
    }
}
UIShow:SetBackdrop(backdrop)
UIShow:SetBackdropColor(1, 1, 1, .8)
UIShow:Hide()

local incFrRply=CreateFrame("Frame", nil, UIShow)


local function RlPl_layout()
textFr = CreateFrame("Frame",nil,UIShow)
textFr:SetSize((tW/2)+40,150)
textFr:SetPoint("LEFT",UIShow,"CENTER",-40,30)

textFr.bg=textFr:CreateTexture()
textFr.bg:SetTexture('Interface\\GLUES\\Models\\UI_Worgen\\gradient5Circle')
textFr.bg:SetSize(700, 300)
textFr.bg:SetPoint('LEFT', UIShow, 'CENTER', -150, 0)
textFr.bg:SetVertexColor(1, 1, 1, .7)

textFr.txt={}
for k,v in pairs(optArr) do
	textFr.txt[k] = textFr:CreateFontString()
	textFr.txt[k]:SetPoint("BOTTOMLEFT",textFr,"BOTTOMLEFT",0,20*k)
	textFr.txt[k]:SetFont('Interface\\Addons\\RollPlay\\FONTS\\IMFeENsc28P.TTF', 16, nil)
	textFr.txt[k]:SetTextColor(1, 1, 1, .8)
	textFr.txt[k]:SetText("")
	-- textFr.txt[k]:SetSize(textFr:GetWidth(),textFr:GetHeight()+100)
	textFr.txt[k]:SetSize(tW,20)
	textFr.txt[k]:SetJustifyV("BOTTOM")
	textFr.txt[k]:SetJustifyH("LEFT")
end

UIShow.hFr=CreateFrame('Frame', nil, UIShow)
UIShow.hFr:SetPoint('TOP', UIShow, 'BOTTOM', 0, 40)
UIShow.hFr:SetSize(tW/1.4, hheight)
UIShow.hFr:Hide()

UIShow.hFr.b=UIShow.hFr:CreateTexture()
UIShow.hFr.b:SetTexture(cloudbg)
UIShow.hFr.b:SetPoint('BOTTOM', UIShow.hFr, 'BOTTOM', 0, 0)
UIShow.hFr.b:SetSize(tW/1.4, hheight)
UIShow.hFr.b:SetVertexColor(.3, .3, .3, .6)

UIShow.hFr.t=UIShow.hFr:CreateFontString()
UIShow.hFr.t:SetPoint("BOTTOM",UIShow.hFr,"BOTTOM",0,0)
UIShow.hFr.t:SetFont('Interface\\Addons\\RollPlay\\FONTS\\IMFeENsc28P.TTF', 16, nil)
UIShow.hFr.t:SetTextColor(colors.msg.r, colors.msg.g, colors.msg.b, .8)--blorb
UIShow.hFr.t:SetText("")
UIShow.hFr.t:SetSize(UIShow.hFr:GetWidth()/1.5,hheight)
UIShow.hFr.t:SetJustifyV("MIDDLE")
UIShow.hFr.t:SetJustifyH("CENTER")

UIShow.htggl=CreateFrame("Button", nil, UIShow, "SecureHandlerClickTemplate")
UIShow.htggl:SetPoint('CENTER', UIShow, 'TOP', tW/3, 0)
UIShow.htggl:SetSize(30, 30)
UIShow.htggl:SetNormalTexture(qmark)
UIShow.htggl:SetPushedTexture(qmark)
UIShow.htggl:SetHighlightTexture("Interface\\BUTTONs\\GLOWSTAR")
UIShow.htggl:RegisterForClicks('AnyUp')
UIShow.htggl:SetScript('OnClick', function() if help_state==true then help_state=false; UIShow.htggl:SetSize(30, 30); prnt('Tooltips disabled', colors.warn) else help_state=true UIShow.htggl:SetSize(50, 50) prnt('Tooltips enabled', colors.warn) end PlaySoundFile(ping) end)
UIShow.htggl.bg=UIShow.htggl:CreateTexture()
UIShow.htggl.bg:SetTexture('Interface\\UNITPOWERBARALT\\MetalBronze_Circular_Frame')
UIShow.htggl.bg:SetSize(55, 55)
UIShow.htggl.bg:SetPoint('CENTER', UIShow.htggl, 'CENTER', 0, 5)

UIShow.actggl=CreateFrame("Button", nil, UIShow, "SecureHandlerClickTemplate")
UIShow.actggl:SetPoint('CENTER', UIShow, 'TOP', (tW/3)-80, 0)
UIShow.actggl:SetSize(70, 70)
-- UIShow.actggl:SetNormalTexture('Interface\\CURSOR\\UnableAttack')
UIShow.actggl:SetNormalTexture(shield_d)
UIShow.actggl:SetPushedTexture(shield)
UIShow.actggl:SetHighlightTexture(shield)
UIShow.actggl:RegisterForClicks('AnyUp')
UIShow.actggl:SetScript('OnClick', function() 
	if accepting_combat==false then 
		UIShow.actggl:SetSize(80, 80); UIShow.actggl:SetNormalTexture(shield_d); prnt('Accepting combat requests', colors.warn); accepting_combat=true 
	else 
		--blorb if allowed to leave combat, then ('in combat' entry for each opponent?)
			accepting_combat=false UIShow.actggl:SetSize(100, 100); UIShow.actggl:SetNormalTexture(shield) prnt('Now blocking combat requests', colors.warn) 
		-- end
	end 
	PlaySoundFile(ping) 
	end)
UIShow.actggl:SetScript('OnEnter', function() hs('Combat request blocker.') end)
UIShow.actggl:SetScript('OnLeave', function() UIShow.hFr:Hide() end)
UIShow.actggl.bg=UIShow.actggl:CreateTexture()
UIShow.actggl.bg:SetTexture('Interface\\UNITPOWERBARALT\\MetalBronze_Circular_Frame')
UIShow.actggl.bg:SetSize(55, 55)
UIShow.actggl.bg:SetPoint('CENTER', UIShow.actggl, 'CENTER', 0, 5)

UIShow.inv=CreateFrame("Button", nil, UIShow, "SecureHandlerClickTemplate")
UIShow.inv:SetPoint('CENTER', UIShow, 'TOP', (tW/3)-130, 0)
UIShow.inv:SetSize(30, 30)
UIShow.inv:SetNormalTexture("Interface\\ICONS\\INV_Misc_Horn_04")
UIShow.inv:SetPushedTexture("Interface\\ICONS\\INV_Misc_Horn_04")
UIShow.inv:SetHighlightTexture("Interface\\BUTTONS\\ButtonHilight-Square")
UIShow.inv:RegisterForClicks('AnyUp')
UIShow.inv:SetScript('OnEnter', function() hs('Invite someone to combat\nAny combat must begin with this.') end)
UIShow.inv:SetScript('OnLeave', function() pf_tggl(UIShow.hFr, 'hide', nil) end)
UIShow.inv:SetScript('OnClick', function() 
	local id,name=GetChannelName('xtensionxtooltip2')
	if UnitName('target')~=nil then
		local tar=strip_name(UnitName('target'))
		local isplay=UnitIsPlayer('target')
		if isplay==true then
			if targets[tar]==nil then targets[tar]={} end
			if targets[tar][2]==nil then
				SendChatMessage('RlPl '..plyr..' inv '..tar, 'CHANNEL', nil, id)
				targets[tar][2]='waiting'
				prnt('>> You have challenged '..tar..' to a contest.', colors.msg)
				UIShow.inv:SetSize(40, 40)
				PlaySoundFile(horn)
			elseif targets[tar][2]=='declined' then
				prnt('Must wait 10 seconds before inviting '..tar..' again', colors.warn)
			else
				prnt('Already waiting on, or in combat with this player', colors.warn)
			end
		else
			prnt('You must target sentient beings', color.warn)
		end
	else
		prnt('You toot your own horn.', colors.warn)
		PlaySoundFile(horn)
	end
end)
UIShow.inv.bg=UIShow.inv:CreateTexture()
UIShow.inv.bg:SetTexture('Interface\\UNITPOWERBARALT\\MetalBronze_Circular_Frame')
UIShow.inv.bg:SetSize(55, 55)
UIShow.inv.bg:SetPoint('CENTER', UIShow.inv, 'CENTER', 0, 5)

incFrRply:SetSize(tW, tH)
incFrRply:SetPoint('TOP', mPane, 'TOP')

local hbar_L=200
local hbar_V=30
local tbar_L=hbar_L
local tbar_V=hbar_V-20
UIShow.h = CreateFrame("Frame", nil, UIShow)
UIShow.h:SetPoint('TOP', UIShow, 'TOP', 0, 0)
UIShow.h:SetSize(tW, tH)

UIShow.h.fr=UIShow.h:CreateTexture('')
UIShow.h.fr:SetTexture('Interface\\COMMON\\friendship-parts')
UIShow.h.fr:SetSize(300, 40)
UIShow.h.fr:SetPoint('TOPLEFT', UIShow.h, 'TOPLEFT', hbar_L+10, hbar_V-40)
UIShow.h.fr:SetTexCoord(.01, 1, 0, 1)
UIShow.h.fr:SetDrawLayer('BACKGROUND', 2)

UIShow.h.bg=UIShow.h:CreateTexture('')
UIShow.h.bg:SetTexture('Interface\\BUTTONS\\YELLOWORANGE64')
UIShow.h.bg:SetPoint('TOPLEFT', UIShow.h, 'TOPLEFT', hbar_L+26, hbar_V-51)
UIShow.h.bg:SetSize(hb_wid, 9)
UIShow.h.bg:SetDrawLayer('BACKGROUND', 1)
UIShow.h.bg:SetVertexColor(.8, .3, .3)

UIShow.t = CreateFrame("Frame", nil, UIShow)
UIShow.t:SetPoint('TOP', UIShow, 'TOP', 0, 0)
UIShow.t:SetSize(tW, tH)
UIShow.t.fr=UIShow.t:CreateTexture('')
UIShow.t.fr:SetTexture('Interface\\COMMON\\friendship-parts')
UIShow.t.fr:SetSize(300, 40)
UIShow.t.fr:SetPoint('TOPLEFT', UIShow.t, 'TOPLEFT', tbar_L+10, tbar_V-40)
UIShow.t.fr:SetTexCoord(.01, 1, 0, 1)
UIShow.t.fr:SetDrawLayer('BACKGROUND', 2)

UIShow.t.bg=UIShow.t:CreateTexture('')
UIShow.t.bg:SetTexture('Interface\\BUTTONS\\YELLOWORANGE64')
UIShow.t.bg:SetPoint('TOPLEFT', UIShow.t, 'TOPLEFT', tbar_L+26, tbar_V-51)
UIShow.t.bg:SetSize(hb_wid, 9)
UIShow.t.bg:SetDrawLayer('BACKGROUND', 1)
UIShow.t.bg:SetVertexColor(.8, 1, .4)

UIShow.rqfr=CreateFrame('Frame', nil, UIShow)
UIShow.rqfr:SetPoint('BOTTOM', UIParent, 'BOTTOM', 0, 300)
UIShow.rqfr:SetSize(tW/1.4, hheight)
pf_tggl(UIShow.rqfr, 'hide', nil)

UIShow.rqfr.b=UIShow.rqfr:CreateTexture()
UIShow.rqfr.b:SetTexture(cloudbg)
UIShow.rqfr.b:SetPoint('BOTTOM', UIShow.rqfr, 'BOTTOM', 0, 0)
UIShow.rqfr.b:SetSize(tW/1.4, hheight)

UIShow.rqfr.t=UIShow.rqfr:CreateFontString()
UIShow.rqfr.t:SetPoint("BOTTOM",UIShow.rqfr,"BOTTOM",0,0)
UIShow.rqfr.t:SetFont('Interface\\Addons\\RollPlay\\FONTS\\IMFeENsc28P.TTF', 16, nil)
UIShow.rqfr.t:SetTextColor(.8, .3, 0, 1)
UIShow.rqfr.t:SetText("Accept rqst from....")
UIShow.rqfr.t:SetSize(UIShow.rqfr:GetWidth()/1.5,hheight)
UIShow.rqfr.t:SetJustifyV("MIDDLE")
UIShow.rqfr.t:SetJustifyH("CENTER")

UIShow.rqfr.ok=CreateFrame("Button", nil, UIShow.rqfr, "SecureHandlerClickTemplate")
UIShow.rqfr.ok:SetPoint('BOTTOM', UIShow.rqfr, 'BOTTOM', -20, 40)
UIShow.rqfr.ok:SetSize(24, 24)
UIShow.rqfr.ok:SetNormalTexture("Interface\\BUTTONS\\UI-CheckBox-Check-Disabled")
UIShow.rqfr.ok:SetPushedTexture("Interface\\BUTTONS\\UI-CheckBox-Check")
UIShow.rqfr.ok:SetHighlightTexture("Interface\\BUTTONS\\UI-CheckBox-Check")
UIShow.rqfr.ok:RegisterForClicks('AnyUp')

UIShow.rqfr.no=CreateFrame("Button", nil, UIShow.rqfr, "SecureHandlerClickTemplate")
UIShow.rqfr.no:SetPoint('BOTTOM', UIShow.rqfr, 'BOTTOM', 20, 40)
UIShow.rqfr.no:SetSize(24, 24)
UIShow.rqfr.no:SetNormalTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Down")
UIShow.rqfr.no:SetPushedTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
UIShow.rqfr.no:SetHighlightTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
UIShow.rqfr.no:RegisterForClicks('AnyUp')

--accept compbat error here blorb
UIShow.rqfr.ok:SetScript('OnClick', function() local id,channel=GetChannelName('xtensionxtooltip2'); pf_tggl(UIShow.rqfr, 'hide', ping) SendChatMessage('RlPl '..plyr..' acp '..inviter, 'CHANNEL', nil, id); inviter=''; if targets[inviter]==nil then targets[inviter]={} end targets[inviter][3]='first Contact' end)
UIShow.rqfr.no:SetScript('OnClick', function() local id,channel=GetChannelName('xtensionxtooltip2'); pf_tggl(UIShow.rqfr, 'hide', ping) SendChatMessage('RlPl '..plyr..' dcl '..inviter, 'CHANNEL', nil, id); inviter='' end)

local resetS=CreateFrame("Button", nil, UIShow, "SecureHandlerClickTemplate")
resetS:SetPoint('TOPLEFT', UIShow.t, 'TOPLEFT', tbar_L+10, tbar_V-42)
resetS:SetSize(24, 24)
resetS:SetNormalTexture("Interface\\GLUES\\CharacterSelect\\RestoreButton")
resetS:SetPushedTexture("Interface\\TARGETINGFRAME\\UI-PhasingIcon")
resetS:SetHighlightTexture("Interface\\COMMON\\RingBorder")
resetS:RegisterForClicks('AnyUp')
resetS:SetScript('OnEnter', function() hs('Skill points.\nClick the reset arrow to toggle training mode.  When you refill the training bar you may reassign all your skill points.') end)
resetS:SetScript('OnLeave', function() UIShow.hFr:Hide() end)

local resetH=CreateFrame("Button", nil, UIShow, "SecureHandlerClickTemplate")
resetH:SetPoint('TOPLEFT', UIShow.h, 'TOPLEFT', hbar_L+11, hbar_V-40)
resetH:SetSize(24, 24)
resetH:SetNormalTexture("Interface\\COMMON\\friendship-heart")
resetH:SetHighlightTexture("Interface\\COMMON\\RingBorder")
resetH:SetPushedTexture("Interface\\TARGETINGFRAME\\UI-PhasingIcon")
resetH:RegisterForClicks('AnyUp')
resetH.pts=resetH:CreateFontString()
resetH.pts:SetFont('Interface\\Addons\\RollPlay\\FONTS\\IMFeENsc28P.TTF', 16)
resetH.pts:SetTextColor(1, .9, .7)
resetH.pts:SetPoint('TOPLEFT', resetH, 'TOPLEFT', 20, -9)
resetH.pts:SetSize(50, 12)

resetH:SetScript('OnEnter', function() hs('Click the heart to heal, if you are in a healing area.'); if help_state==false then  resetH.pts:SetText(RllPly.health.."/"..rlpl_stats.health); resetH.pts:Show() end end)
resetH:SetScript('OnLeave', function() UIShow.hFr:Hide(); resetH.pts:Hide() end)

local function hbar(x)
	if x<0 then x=0 end
	if x>=rlpl_stats.health then x=rlpl_stats.health end
	RllPly.health=x
	local z=(x/rlpl_stats.health)*hb_wid
	if z<=0 then z=.01 end
	UIShow.h.bg:SetSize(z, 9)
end

function tbar(x)
	if x<=0 then x=.01 end
	if x>=rlpl_stats.train then 
		x=rlpl_stats.train 
	end
	RllPly.train=x
	local z=(x/10)*hb_wid
	if z<=0 then z=.01 end
	UIShow.t.bg:SetSize(z, 9)
end

function hs(x)
	if help_state==true then UIShow.hFr.t:SetText(x); UIShow.hFr:Show() end
end

local function frCreate(cat, catNum, iconName)
	UIShow[cat]=CreateFrame("Button", nil, UIShow, "SecureHandlerClickTemplate" ) 
	UIShow[cat]:SetSize(btn_sz, btn_sz)
	UIShow[cat]:SetPoint("TOP", UIShow, "TOP", -280+catNum*40, bheight)
	UIShow[cat]:RegisterForClicks("AnyUp")
	UIShow[cat]:SetNormalTexture("Interface\\ICONS\\"..iconName)
	UIShow[cat]:SetPushedTexture("Interface\\BUTTONS\\UI-Quickslot-Depress")
	UIShow[cat]:SetHighlightTexture("Interface\\BUTTONS\\ButtonHilight-Square")
	UIShow[cat]:SetScript("OnEnter", function() hs(cats[cat]..'\nClick to attack another player using this trait.\nThey will defend using the same trait.') end)
	UIShow[cat]:SetScript('OnLeave', function() pf_tggl(UIShow.hFr, 'hide', nil) end)
	UIShow[cat]:SetScript("OnClick", function() 
		if UnitName('target')~=nil then --and 
			tgt=strip_name(UnitName('target'))
			if RllPly.health>0 and able_combat==true then 
				if targets[tgt]==nil then targets[tgt]={} end
				-- if targets[tgt]
				if targets[tgt][2]=='accepted' then
					if targets[tgt][1]==nil then targets[tgt][1]=true end
					if targets[tgt][1]==true then
						if cooldown==false then
							local r=math.random(1,2)
							PlaySoundFile(dice[r])
							RlPl_roll(cat, 'atk', tgt)
						else
							ffrm(.3, .3, 1, colors.Dexterity, .5, nil, 5, nil)
							prnt('You must wait five seconds between attacks', colors.warn)
						end
					else
						prnt('You must let '..tgt..' attack back first.', colors.warn)
					end
				elseif targets[tgt][2]=='waiting' then
					prnt('Still waiting on this player', colors.warn)
				else
					prnt('You are not in combat with '..tgt..' - use the horn to invite them.')
				end
			else
				ffrm(.3, .3, 1, colors.Dexterity, .5, nil, 5, nil)
				prnt('You are too weakened to attack!', colors.warn)
			end
		else
			prnt('You use your '..string.lower(cats[cat])..' to no avail.', colors.warn)
		end
	end)
	UIShow[cat].name=UIShow:CreateFontString()
	UIShow[cat].name:SetPoint("BOTTOM",UIShow[cat],"TOP",0,0)
	UIShow[cat].name:SetFont('Interface\\Addons\\RollPlay\\FONTS\\IMFeENsc28P.TTF', 16, nil)
	-- UIShow[cat].name:SetTextColor(.3, .2, .1, .8)
	UIShow[cat].name:SetTextColor(colors[cats[cat]].r, colors[cats[cat]].g, colors[cats[cat]].b)
	UIShow[cat].name:SetText(cats[cat]:sub(1,3)..":")
	UIShow[cat].name:SetSize(100, 20)

	UIShow[cat].amt=UIShow:CreateFontString()
	UIShow[cat].amt:SetPoint("TOP",UIShow[cat],"BOTTOM",0,2)
	UIShow[cat].amt:SetFont("Interface\\Addons\\RollPlay\\FONTS\\IMFeENsc28P.TTF", 15, nil)
	UIShow[cat].amt:SetTextColor(.1, .1, .1, .8)
	UIShow[cat].amt:SetText(RllPly[cat])
	UIShow[cat].amt:SetSize(100, 20)	

	UIShow[cat].inc=CreateFrame("Button", nil, incFrRply, "SecureHandlerClickTemplate")
	UIShow[cat].inc:SetNormalTexture("Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageUp-Up")
	UIShow[cat].inc:SetPushedTexture("Interface\\PaperDollInfoFrame\\UI-Character-SkillsPageUp-Down")
	UIShow[cat].inc:SetHighlightTexture('Interface\\BUTTONS\\GLOWSTAR')

	UIShow[cat].inc:SetPoint('BOTTOM', UIShow[cat], 'BOTTOM', 0, 0)
	UIShow[cat].inc:SetSize(btn_sz, btn_sz)
	UIShow[cat].inc:RegisterForClicks("AnyUp")
	UIShow[cat].inc:SetScript("OnEnter", function () hs(cats[cat]..'\nClick to attack another player using this trait.\nThey will defend using the same trait.') end)--blorb
	UIShow[cat].inc:SetScript("OnLeave", function () pf_tggl(UIShow.hFr, 'hide', nil) end)
	UIShow[cat].inc:SetScript("OnClick", function ()
		local t=0 
		for k,v in pairs(cats) do t=t+(RllPly[k]-1) end-- -1 bc they all init w/1
		if t>=(rlpl_stats.train) then 
			prnt('You are at max points', colors.warn)
			-- incFrRply:Hide()
			pf_tggl(incFrRply, 'hide', ping)
		else
			if RllPly[cat]<5 and RllPly.train>=1 then
				PlaySoundFile(ping)
				RllPly[cat]=RllPly[cat]+1
				RllPly.train=RllPly.train-1
				tbar(RllPly.train)
				UIShow[cat].amt:SetText(RllPly[cat])
				if RllPly.train <= 0 then 
					pf_tggl(incFrRply, 'hide', ping)
				end
			else
				ffrm(.3, .3, 1, colors.Dexterity, .5, nil, 5, nil)
				prnt('capped', colors.warn)			
			end
		end
	end)
end

frCreate('str', 1, "Spell_Nature_Strength")
frCreate('dex', 2, "INV_sword_1h_garrison_a_05")
frCreate('chr', 3, "Achievement_Halloween_Smiley_01")--Spell_Shadow_Charm
frCreate('wis', 4, "TRADE_ARCHAEOLOGY_HIGHBORNE_SCROLL")
frCreate('int', 5, "Spell_Shadow_Brainwash")

mPane.tggl:SetScript("OnClick", function ()
 	if msTog==false then
 		UIShow:Show()
 		PlaySoundFile(dice[2])
 		if UIShow:IsVisible()==false then
 			print('[RollPlay]: Can\'t toggle frame during combat')
 		else
 			msTog=true
 		end
 	else
 		UIShow:Hide()
 		PlaySoundFile(dice[1])
 		if UIShow:IsVisible()==true then
 			print('[RollPlay]: Can\'t toggle frame during combat')
 		else
 			msTog=false
 		end
 	end
 end)

 if RllPly.train<=0 then
 	pf_tggl(incFrRply, 'hide', nil)
 end

if RllPly.health<=0 then
	able_combat=false
end
hbar(RllPly.health)
tbar(RllPly.train)

 local function multyPlecksR(self, event, msg, snd, hm, cnName, shortName, hmm)
	local chan='xtensionxtooltip2'
	local id,name=GetChannelName(chan)
	local data={}
	local itr=0
	if event=='CHAT_MSG_CHANNEL' and string.find(cnName, chan) then
		local dash=string.find(snd, '-')
		local send=''
		if dash~=nil then
			send=string.sub(snd, 1, dash-1)
		else
			send=snd
		end
		for word in string.gmatch(msg, '%S+') do
			itr=itr+1
			data[itr]=word
		end
		if data[1]=='RlPl' then
			if data[2]=='bcast' then
				local distan=CheckInteractDistance(send, 4)
				if distan==true then --1 = inspect, 4 = follow
					if data[3]=='dft' then -- RESULTS FOR EVERONE
						prnt(data[5]..' is victorious! '..data[4]..' is too weak to continue.')
						if plyr==data[4] then -- end combat / rm opp
							-- (you lost)
							targets[data[5]][2]=nil
							ffrm(.3, .3, 1, colors.black, .7, nil, 'ALPHAKEY', nil)
						elseif plyr==data[5] then
							-- (you won)
							PlaySoundFile('Sound\\Spells\\AchievementSound1.ogg')
							targets[data[4]][2]=nil
						end
						-- [Multy] RlPl bcast Dillenreed -1 chr
						-- [Multy] RlPl bcast dft Multy Multy
					else -- ONE ROUND RESULT FOR EVERYONE
						local diff=tonumber(data[4])
						if diff>0 then
							wld='beaten'; iject=' by a margin of ('..math.abs(diff)..')' -- send has beaten data[3]
						elseif diff<0 then
							wld='lost to'; iject=' by a margin of ('..math.abs(diff)..')' -- send has lost to data[3]
						else
							wld='come to a draw with'; iject=''
						end
						local result=send..' has '..wld..' '..data[3]..iject..' in a contest of '..cats[data[5]]..'!' -- send is always the attacker, announcing results of their own fight
						local loss=false
						if diff<0 and data[3]==plyr then loss=true end
						if loss==true then
							PlaySoundFile(wound[hh])
							ffrm(.5, .5, 2, colors[cats[data[5]]], .5, nil, 5, nil)
							RllPly.health=RllPly.health-1
							-- if RllPly
							hbar(RllPly.health)
							if RllPly.health<=0 then
								SendChatMessage('RlPl bcast dft '..plyr..' '..send, 'CHANNEL', nil, id)
								prnt('You\'ve been utterly defeated... for now.', colors.Strenth)
							end
						end
						prnt(result, colors[cats[data[5]]])
					end
				end
			elseif data[4]==plyr then
				-- print('ya', data[3])
				if data[3]=='atk' then
					-- print('attacked')
					if accepting_combat==true then
						-- print(targets[send][1])
						-- blorba BLOOORRB.. first time around targets is all nil or something... 
						if targets[send][1]==nil or targets[send][1]==false or targets[send][3]=='first contact' then -- new target, or, you were last attacker.  prevents false atk client side.
							targets[send][3]=''
							if able_combat==true then	
								RlPl_roll(data[2], 'dfd', send) 
								targets[send][1]=true -- (you may now attack this target, having defended yourself)
							else
								prnt(send..' ruthlessly presses their attack.', colors.Strength)
							end
						else
							prnt('It seems '..send..' may have tried to attack out of turn.', colors.warn)
						end
					else
						print('not accepting combat')
						prnt('Blocked combat request from '..send)
						SendChatMessage('RlPl '..plyr..' dcl '..send, 'CHANNEL', nil, id)
					end
				elseif data[3]=='dfd' then
					if targets[send][3]~=nil then targets[send][3]='' end
					if pending[send]~=nil then
						targets[send][1]=false--your attack was defended - can no longer attack them
						local diff=pending[send]-data[5]
						SendChatMessage('RlPl bcast '..send..' '..diff.. ' '..data[2], 'CHANNEL', nil, id)
					end
				elseif data[3]=='inv' and pending_request==false then
					inviter=send; UIShow.rqfr.t:SetText('Accept combat from '..send..'?'); pf_tggl(UIShow.rqfr, 'show', ping)
				elseif data[3]=='acp' then
					if targets[send]==nil then targets[send]={} end
					targets[send][3]='first contact'
					UIShow.inv:SetSize(30, 30)
					targets[send][2]='accepted'
					prnt('>> '..send..' has accepted combat.', colors.msg)
					PlaySoundFile(horn)
					ffrm(.3, .3, 1, colors.Wisdom, .5, nil, 5, nil)
				elseif data[3]=='dcl' then
					UIShow.inv:SetSize(30, 30)
					targets[send][2]='declined'
					C_Timer.After(10, function() targets[send][2]=nil end)
					prnt(send..' has declined combat.', colors.warn)
				end
			end
		end
	end
end

-- if your pts tally is full, hide incfrrply
-- 
local function train_check()
	for k,v in pairs(cats) do
		allocated=(RllPly[k]-1)+allocated--(minus init)
	end
	if allocated>=rlpl_stats.train then 
		pf_tggl(incFrRply, 'hide', ping)
	end
end
train_check()

if not roll_listener then
	roll_listener=CreateFrame('Frame', nil, mPane)
	roll_listener:RegisterEvent('CHAT_MSG_CHANNEL')
	roll_listener:SetScript('OnEvent', multyPlecksR)
end

-- local function resetStats()
-- 	for k,v in pairs(RllPly) do
-- 		RllPly[k]=rlpl_stats[k];
-- 	end
-- 	for k,v in pairs(cats) do
-- 		UIShow[k].amt:SetText(RllPly[k])
-- 	end
-- 	pf_tggl(incFrRply, 'show', parch)
-- 	tbar(RllPly.train)
-- end

local function refillHealth()
	local function fillup()
			hbar(RllPly.health+1)
			able_combat=true
			PlaySoundFile(mists)
			ffrm(.5, .5, 2, colors.reset, .5, nil, 5, nil)
		if RllPly.health < rlpl_stats.health then
			C_Timer.After(2, function() refillHealth() end)
		elseif RllPly.health >= rlpl_stats.health then
			prnt('You feel much better', colors.reset) 
			PlaySoundFile('Sound\\Spells\\Teleport.ogg')
		end
	end
	if faction=='Horde' then
		if dist(spirits[1], spirits[2])<.003 then
			fillup()
		else
			ffrm(.3, .3, 1, colors.Dexterity, .5, nil, 5, nil)
			prnt('You must find Sijambi in the Valley of Spirits for rejuvenation!', colors.warn)
		end
	else --Alliance
		if dist(cathedral[1], cathedral[2])<.006 then 
			fillup()
		else
			ffrm(.3, .3, 1, colors.Dexterity, .5, nil, 5, nil)
			prnt('You must go to the altar in the Cathedral of Stormwind for rejuvenation!', colors.warn)
		end
	end
end

function trainTggl()
	if train_state=='off' then
		-- blorb if not all pts assigned, 
		mPane:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
		prnt('Training mode!  Whack a dummy.  A wooden one.', colors.msg)
		resetS:SetNormalTexture("Interface\\COMMON\\Indicator-Green")
		train_state='on'
	elseif train_state=='on' then
		mPane:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
		prnt('You relax from training.', colors.msg)
		resetS:SetNormalTexture("Interface\\COMMON\\Indicator-Yellow")
		train_state='off'
	end
end

resetS:SetScript('OnClick', function() 
	PlaySoundFile(tiles[1])
	if RllPly.train>=rlpl_stats.train and train_state=='off' then
		RllPly.train=rlpl_stats.train
		prnt('You are fully trained - set your stats.', colors.warn)
	else
		trainTggl()
	end
end)
resetH:SetScript('OnClick', function()
	PlaySoundFile(tiles[1])
	if RllPly.health<rlpl_stats.health then
		refillHealth()
	else 
		PlaySoundFile(mists)
		ffrm(.5, .5, 2, colors.reset, .5, nil, 5, nil)
		prnt('Is this not your final form?  You are already in peak shape.', colors.reset)
	end
end)

prnt('Bailey bids you welcome, traveler.', colors.msg)
prnt('Spend your skill points.  Reset at training dummies.', colors.msg)
prnt('Start combat by clicking the horn, then choose', colors.msg)
prnt('a category to attack in.', colors.msg)

end --RlPl_layout


function mPaneOnEvent(table_val, event, addon, ...)
	if event=='ADDON_LOADED' and addon=='RollPlay' then
		if RllPly==nil then 
			RllPly={}
		end
		for k,v in pairs(rlpl_stats) do
			if RllPly[k]==nil or dev_mode==true then
				RllPly[k]=v
			end
		end
		RlPl_layout()
	elseif event=='PLAYER_LOGOUT' and addon=='RollPlay' then
	elseif event=='COMBAT_LOG_EVENT_UNFILTERED' then
		local spell, maybe_isEnemy, plyGUID, playName, maybe_spellID, who_knows, tarGUI, tarName, xx, yy, zz= ...
		if playName~=nil and playName==plyr then
			if tarName~=nil then
				if string.find(tarName, 'ummy') then
					-- if spell=='SPELL_CAST_SUCCESS' or spell=='SWING_DAMAGE' then
					if spell=='SWING_DAMAGE' or spell=='SWING_MISSED' then
						if RllPly.train<rlpl_stats.train then
							if spell=='SWING_DAMAGE' then
								RllPly.train=RllPly.train+1
							elseif spell=='SWING_MISSED' then
								miss_tally=miss_tally+1
								if miss_tally%2==0 then
									RllPly.train=RllPly.train+1
								end
							end
							tbar(RllPly.train)
							if RllPly.train==rlpl_stats.train then
								PlaySoundFile('Sound\\Spells\\Teleport.ogg')
								for k,v in pairs(RllPly) do
									RllPly[k]=rlpl_stats[k];
								end
								for k,v in pairs(cats) do
									UIShow[k].amt:SetText(RllPly[k])
								end
								tbar(RllPly.train)
								ffrm(.3, .3, 1, colors.Charisma, .6, nil, 5, nil)
								prnt('Training complete.', colors.msg)
								prnt('Stats will reset upon exiting combat', colors.warn)
								trainTggl()
								pf_tggl(incFrRply, 'show', parch) 
							else
								ffrm(.4, .1, .5, colors.Charisma, .3, nil, 5, nil)
								PlaySoundFile('Sound\\Spells\\HolyWard.ogg')
							end
						else
							prnt('Already max trained!'); mPane:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
						end
						-- print(spell, maybe_isEnemy, plyGUID, playName, maybe_spellID, who_knows, tarGUI, tarName, xx, yy, zz)
					end
				end
			end
		end
	end
end

mPane:SetScript('OnEvent', mPaneOnEvent)
mPane.tggl:SetScript('OnEnter', function() hs('One button to rule them all, One button to find them; \nOne button to bring them all and in the darkness bind them.') end)
mPane.tggl:SetScript('OnLeave', function() pf_tggl(UIShow.hFr, 'hide', nil) end)
