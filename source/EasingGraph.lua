class("EasingGraph").extends()

local gfx <const> = playdate.graphics

EasingGraph.outerSize = 240
EasingGraph.innerSize = 130
EasingGraph.innerOffset = playdate.geometry.point.new(0, (EasingGraph.outerSize - EasingGraph.innerSize) / 2)

function EasingGraph:init(position)
	self.position = position
	self.img = gfx.image.new(EasingGraph.innerSize, EasingGraph.outerSize)
end

function EasingGraph:redraw(gameState)
	self.img:clear(gfx.kColorClear)

	local currentEasingFn = allEasings[gameState.easingIndex]
	local currentEasingName = easingNames[gameState.easingIndex]

	gfx.pushContext(self.img)
	gfx.setColor(gfx.kColorWhite)

	-- Square outline
	gfx.drawRect(EasingGraph.innerOffset.x, EasingGraph.innerOffset.y, EasingGraph.innerSize, EasingGraph.innerSize)

	--
	local lastPoint = EasingGraph.innerOffset + playdate.geometry.vector2D.new(0, EasingGraph.innerSize)
	for ot = 0, self.innerSize do
		local pctComplete = ot / EasingGraph.innerSize
		local t = pctComplete * gameState.easeDuration
		local b = 0
		local c = 1
		local d = gameState.easeDuration

		local et = 0
		if string.find(currentEasingName, "Elastic") then
			et = currentEasingFn(t, b, c, d, gameState.springAmplitude, gameState.springPeriod)
		elseif string.find(currentEasingName, "Back") then
			et = currentEasingFn(t, b, c, d, gameState.overshootAmount)
		else
			et = currentEasingFn(t, b, c, d)
		end

		local point = EasingGraph.innerOffset + playdate.geometry.vector2D.new(
			pctComplete * EasingGraph.innerSize,
			EasingGraph.innerSize - et * EasingGraph.innerSize
		)

		gfx.drawLine(
			lastPoint.x,
			lastPoint.y,
			point.x,
			point.y
		)

		lastPoint = point
	end

	gfx.popContext()
end

function EasingGraph:draw()
	self.img:draw(self.position)
end
