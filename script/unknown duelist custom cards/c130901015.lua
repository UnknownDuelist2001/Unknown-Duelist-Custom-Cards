--Hypermassive Dark Hole
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE+EFFECT_FLAG_CANNOT_INACTIVATE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_DUEL)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetLP(tp,Duel.GetLP(tp)//2)
end
function s.monsfilter(c)
	return c:IsMonster() and c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT)
end
function s.sptrfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove(tp,POS_FACEDOWN,REASON_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g1=Duel.GetMatchingGroup(s.monsfilter,tp,0,LOCATION_MZONE,1,c)
	local g2=Duel.GetMatchingGroup(s.sptrfilter,tp,0,LOCATION_ONFIELD,1,c)
	local b1=#g1>0
	local b2=#g2>0
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)})
	e:SetLabel(op)
	local g=(op==1 and g1 or g2)
	Duel.SetChainLimit(s.chlimit)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.chlimit(e,ep,tp)
	return tp==ep
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local g=Duel.GetMatchingGroup(s.monsfilter,tp,0,LOCATION_MZONE,e:GetHandler())
			if #g>0 then Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		if Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() then
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(function(e) return Duel.GetTurnCount()~=e:GetLabel() end)
			e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,1)
		end
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_SKIP_DP)
		e2:SetTargetRange(1,0)
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW then
			e2:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,2)
		else
			e2:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
		end
		Duel.RegisterEffect(e2,tp)
	else
		local g=Duel.GetMatchingGroup(s.sptrfilter,tp,0,LOCATION_ONFIELD,e:GetHandler())
			if #g>0 then Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		end
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		if Duel.IsTurnPlayer(tp) and Duel.IsBattlePhase() then
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(function(e) return Duel.GetTurnCount()~=e:GetLabel() end)
			e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE|PHASE_BATTLE|RESET_SELF_TURN,1)
		end
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_SKIP_DP)
		e2:SetTargetRange(1,0)
		if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW then
			e2:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN,2)
		else
			e2:SetReset(RESET_PHASE+PHASE_DRAW+RESET_SELF_TURN)
		end
		Duel.RegisterEffect(e2,tp)
	end
end