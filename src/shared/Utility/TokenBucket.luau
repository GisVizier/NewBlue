--!strict

local Workspace = game:GetService("Workspace")

export type TokenBucket = {
	capacityScaled: number,
	refillPerMsScaled: number,
	tokensScaled: number,
	lastRefillMs: number,

	TryConsume: (self: TokenBucket, count: number?, nowMs: number?) -> (boolean, number),
	Available: (self: TokenBucket, nowMs: number?) -> number,
	Refund: (self: TokenBucket, count: number) -> (),
	SetRate: (self: TokenBucket, capacity: number?, refillPerSecond: number?) -> (),
	Reset: (self: TokenBucket, tokens: number?) -> (),
}

local MS_PER_SEC: number = 1000
local TOKEN_SCALE: number = 1000 -- 1 token = 1000 milli-tokens

local min = math.min
local floor = math.floor
local clamp = math.clamp

local function toScaled(tokens: number): number
	return floor(tokens * TOKEN_SCALE + 0.5)
end

local function getNowMs(): number
	return Workspace:GetServerTimeNow() * MS_PER_SEC
end

local TokenBucket = {}
TokenBucket.__index = TokenBucket

function TokenBucket.new(capacity: number, refillPerSec: number, startFilled: boolean?): TokenBucket
	assert(capacity > 0, "capacity must be > 0")
	assert(refillPerSec >= 0, "refillPerSec must be >= 0")

	local capacityScaled = toScaled(capacity)
	local refillPerMsScaled = toScaled(refillPerSec) / MS_PER_SEC
	local now = getNowMs()

	local self = {
		capacityScaled = capacityScaled,
		refillPerMsScaled = refillPerMsScaled,
		tokensScaled = startFilled and capacityScaled or 0,
		lastRefillMs = now,
	}
	setmetatable(self, TokenBucket)
	return (self :: any) :: TokenBucket -- necessary evil. TODO: fix
end

function TokenBucket._Refill(self: TokenBucket, nowMs: number)
	local dt = nowMs - self.lastRefillMs
	if dt <= 0 then
		return
	end
	self.lastRefillMs = nowMs

	local add = dt * self.refillPerMsScaled
	if add > 0 then
		self.tokensScaled = min(self.capacityScaled, self.tokensScaled + add)
	end
end

function TokenBucket:TryConsume(count: number?, nowMs: number?): (boolean, number)
	local needScaled = toScaled(count or 1)
	local now = nowMs or getNowMs()

	self:_Refill(now)

	if self.tokensScaled >= needScaled then
		self.tokensScaled -= needScaled
		return true, 0
	end

	if self.refillPerMsScaled <= 0 then
		return false, math.huge
	end

	local msNeeded = (needScaled - self.tokensScaled) / self.refillPerMsScaled
	return false, msNeeded / MS_PER_SEC
end

function TokenBucket.Available(self: TokenBucket, nowMs: number?): number
	local now = nowMs or getNowMs()
	TokenBucket._Refill(self, now)
	return self.tokensScaled / TOKEN_SCALE
end

function TokenBucket.Refund(self: TokenBucket, count: number)
	if count > 0 then
		self.tokensScaled = min(self.capacityScaled, self.tokensScaled + toScaled(count))
	end
end

function TokenBucket:SetRate(capacity: number?, refillPerSec: number?)
	if capacity then
		self.capacityScaled = toScaled(capacity)
		self.tokensScaled = min(self.tokensScaled, self.capacityScaled)
	end
	if refillPerSec then
		self.refillPerMsScaled = toScaled(refillPerSec) / MS_PER_SEC
	end
end

function TokenBucket:Reset(tokens: number?)
	local target = tokens or 0
	self.tokensScaled = clamp(toScaled(target), 0, self.capacityScaled)
	self.lastRefillMs = getNowMs()
end

return TokenBucket
