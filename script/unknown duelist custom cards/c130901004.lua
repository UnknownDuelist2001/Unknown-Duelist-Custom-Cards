--Meklord Destruction Zone
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Cannot be banished
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.rmlimitcon)
	e2:SetTarget(s.rmlimit)
	c:RegisterEffect(e2)
	--Cannot be destroyed
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTarget(function(_,c) return (c:IsSetCard(0x3013) or c:IsSetCard(0x9013)) and c:IsFaceup() end)
	e3:SetCondition(s.rmlimitcon)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	--Cannot be targeted
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	--Cannot be Tributed
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UNRELEASABLE_SUM)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(s.unrecon)
	e5:SetTarget(s.unretar)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e6)
	--Cannot be used as Fusion Material
	local e7=e6:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	c:RegisterEffect(e7)
	--Cannot be used as Synchro Material
	local e8=e6:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	c:RegisterEffect(e8)
	--Cannot be used as Xyz Material, except for a Xyz Summon of "Meklord" monsters
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e9:SetRange(LOCATION_FZONE)
	e9:SetTargetRange(LOCATION_MZONE,0)
	e9:SetCondition(s.cannxyzmacon)
	e9:SetTarget(s.cannxyzmatar)
	e9:SetValue(s.xyzlimit)
	c:RegisterEffect(e9)
	--Cannot be used as Link Material, except for a Link Summon of "Meklord" monsters
	local e10=e9:Clone()
	e10:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	c:RegisterEffect(e10)
	--Negate the effects of Synchro Monsters
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetCode(EFFECT_DISABLE)
	e11:SetRange(LOCATION_FZONE)
	e11:SetTargetRange(0,LOCATION_MZONE)
	e11:SetCondition(s.negcon)
	e11:SetTarget(function(e,c) return c:IsType(TYPE_SYNCHRO) and (c:IsType(TYPE_EFFECT) or c:IsOriginalType(TYPE_EFFECT)) end)
	c:RegisterEffect(e11)
end
s.listed_series={0x13,0x3013,0x9013}
function s.cfilter(c)
	return (c:IsSetCard(0x3013) or c:IsSetCard(0x9013)) and c:IsMonster() and c:IsFaceup()
end
function s.rmlimitcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil)
end
function s.rmlimit(e,c,tp,r)
	return (c:IsSetCard(0x3013) or c:IsSetCard(0x9013)) and c:IsLocation(LOCATION_MZONE) and c:IsFaceup()
		and c:IsControler(e:GetHandlerPlayer()) and not c:IsImmuneToEffect(e) and r&REASON_EFFECT>0
end
function s.unrecon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,3,nil)
end
function s.unretar(e,c)
	return c:IsSetCard(0x13) and c:IsMonster() and c:IsFaceup()
end
function s.cannxyzmacon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,3,nil)
end
function s.cannxyzmatar(e,c)
	return c:IsSetCard(0x13) and c:IsMonster() and c:IsFaceup()
end
function s.xyzlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x13)
end
function s.negcon(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,4,nil)
end