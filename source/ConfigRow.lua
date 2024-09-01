class("ConfigRow").extends()

local gfx <const> = playdate.graphics

ConfigRow.width = 190

function ConfigRow:init(title, key, index, position)
	self.title = title
	self.key = key
	self.index = index
	self.position = position
end

function ConfigRow:update(gameState)
	gfx.pushContext(nil)

	local isSelected = gameState.configRowIndex == self.index
	local font = isSelected and nicoBold or nicoClean

	gfx.setFont(font)
	gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
	gfx.setColor(gfx.kColorWhite)

	-- Title
	gfx.drawText(self.title, self.position.x, self.position.y)

	-- Arrows
	if isSelected then
		local titleWidth = font:getTextWidth(self.title)

		gfx.fillTriangle(
			self.position.x - 10,
			self.position.y + 7,
			self.position.x - 4,
			self.position.y + 3,
			self.position.x - 4,
			self.position.y + 11
		)

		gfx.fillTriangle(
			self.position.x + titleWidth + 10,
			self.position.y + 7,
			self.position.x + titleWidth + 4,
			self.position.y + 3,
			self.position.x + titleWidth + 4,
			self.position.y + 11
		)
	end

	gfx.popContext()
end

--
class("EasingConfigRow").extends(ConfigRow)

function EasingConfigRow:update(gameState)
	EasingConfigRow.super.update(self, gameState)

	gfx.pushContext(nil)
	gfx.setFont(nicoClean)
		-- Value
	gfx.drawTextAligned(easingNames[gameState[self.key]], self.position.x + ConfigRow.width, self.position.y, kTextAlignment.right)
	gfx.popContext()

	if gameState.configRowIndex == self.index then
		self:updateActive(gameState)
	end
end

function EasingConfigRow:updateActive(gameState)
	if playdate.buttonJustPressed(playdate.kButtonRight) then
		gameState.easingIndex = (gameState.easingIndex % #allEasings) + 1
	elseif playdate.buttonJustPressed(playdate.kButtonLeft) then
		gameState.easingIndex = (gameState.easingIndex - 2) % #allEasings + 1
	end
end

--
class("FloatConfigRow").extends(ConfigRow)

function FloatConfigRow:update(gameState)
	EasingConfigRow.super.update(self, gameState)

	gfx.pushContext(nil)
	gfx.setFont(nicoClean)
		-- Value
	gfx.drawTextAligned(mathRound(gameState[self.key], 2), self.position.x + ConfigRow.width, self.position.y, kTextAlignment.right)
	gfx.popContext()

	if gameState.configRowIndex == self.index then
		self:updateActive(gameState)
	end
end

function FloatConfigRow:updateActive(gameState)
	local delta = playdate.buttonIsPressed(playdate.kButtonB) and 0.2 or 0.01

	if playdate.buttonIsPressed(playdate.kButtonRight) then
		gameState[self.key] = gameState[self.key] + delta
	elseif playdate.buttonIsPressed(playdate.kButtonLeft) then
		gameState[self.key] = math.max(gameState[self.key] - delta, 0.1)
	end
end
