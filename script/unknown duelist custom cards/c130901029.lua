--Blue-Flames Underworld
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0xf10)
	c:SetCounterLimit(0xf10,10)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Increase ATK/DEF
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xf10))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	--Add Blue-Flames Demonic DemonicCounter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_FZONE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.ctcon)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetCondition(s.ctcon2)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(s.ctcon2)
	c:RegisterEffect(e6)
	--Prevent destruction and banishment by effects
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCondition(s.ptcon)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetCode(EFFECT_CANNOT_REMOVE)
	e8:SetRange(LOCATION_FZONE)
	e8:SetTargetRange(1,1)
	e8:SetCondition(s.ptcon)
	e8:SetTarget(function(e,c,tp,r) return c==e:GetHandler() and r==REASON_EFFECT end)
	c:RegisterEffect(e8)
	--Search "Blue-Flames" Ritual Monster and "Blue-Flames" Ritual Spell
	local e9=Effect.CreateEffect(c)
	e9:SetDescription(aux.Stringid(id,1))
	e9:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e9:SetType(EFFECT_TYPE_IGNITION)
	e9:SetRange(LOCATION_FZONE)
	e9:SetCountLimit(1,{id,1})
	e9:SetCost(s.thcost)
	e9:SetTarget(s.thtg)
	e9:SetOperation(s.thop)
	c:RegisterEffect(e9)
end
s.listed_series={0xf10}
s.counter_place_list={0xf10}
function s.thfilter(c)
	return (c:IsMonster() and c:IsLevel(8) and c:IsSetCard(0xf10) and not c:IsType(TYPE_RITUAL)) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_EFFECT) and re:GetHandler():IsSetCard(0xf10) and rp==tp
end
function s.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.FaceupFilter(Card.IsSetCard,0xf10),1,nil) and rp==tp
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0xf10,1)
end
function s.ptcon(e)
	return e:GetHandler():GetCounter(0xf10)==10
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0xf10,6,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0xf10,6,REASON_COST)
end
function s.filter1(c)
	return c:IsSetCard(0xf10) and c:IsRitualMonster()
end
function s.filter2(c)
	return c:IsSetCard(0xf10) and c:IsRitualSpell()
end
function s.thfilter1(c)
	return c:IsAbleToHand() and s.filter1(c)
end
function s.thfilter2(c)
	return c:IsAbleToHand() and s.filter2(c)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil)
		or Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(s.filter1,nil)<=1
		and sg:FilterCount(s.filter2,nil)<=1
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g1,g2=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,nil),Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,nil)
	g1:Merge(g2)
	local sg=aux.SelectUnselectGroup(g1,e,tp,1,2,s.rescon,1,tp,HINTMSG_ATOHAND)
	if #sg>0 then
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end