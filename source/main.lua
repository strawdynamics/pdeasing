import "CoreLibs/graphics"
import "CoreLibs/object"
import "CoreLibs/easing"
import "CoreLibs/ui"

import "easingGlobals"
import "fonts"
import "util"

import "ConfigRow"
import "EasingGraph"

local gfx <const> = playdate.graphics

local gameState = {
	easeDuration = 3,
	easingIndex = 1,
	configRowIndex = 1,
	springAmplitude = 0,
	springPeriod = 1,
	overshootAmount = 1.70158,
}

local easeTime = 0
local lastElapsedTime = 0

local easingGraph = EasingGraph(playdate.geometry.point.new(30, 0))

easingGraph:redraw(gameState)

gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
local timeLabel = gfx.imageWithText("Time", 400, 240, gfx.kColorClear, 0, "", kTextAlignment.left, nicoPups)
local valueLabel = gfx.imageWithText("Value", 400, 240, gfx.kColorClear, 0, "", kTextAlignment.left, nicoPups):rotatedImage(-90)

local configRows = {
	EasingConfigRow("Easing", "easingIndex", 1, playdate.geometry.point.new(190, 40)),
	FloatConfigRow("Duration", "easeDuration", 2, playdate.geometry.point.new(190, 65)),
	-- Spring
	FloatConfigRow("Amplitude", "springAmplitude", 3, playdate.geometry.point.new(190, 110)),
	FloatConfigRow("Period", "springPeriod", 4, playdate.geometry.point.new(190, 135)),
	-- Overshoot
	FloatConfigRow("Overshoot", "overshootAmount", 5, playdate.geometry.point.new(190, 180)),
}

function playdate.update()
	local elapsedTime = playdate.getElapsedTime()
	local deltaTime = elapsedTime - lastElapsedTime
	lastElapsedTime = elapsedTime

	gfx.clear(gfx.kColorBlack)

	easeTime = (easeTime + deltaTime) % gameState.easeDuration

	if playdate.buttonJustPressed(playdate.kButtonDown) then
		gameState.configRowIndex = (gameState.configRowIndex % #configRows) + 1
	elseif playdate.buttonJustPressed(playdate.kButtonUp) then
		gameState.configRowIndex = (gameState.configRowIndex - 2) % #configRows + 1
	end

	local lastDuration = gameState.easeDuration
	local lastEasingIndex = gameState.easingIndex
	local lastAmplitude = gameState.springAmplitude
	local lastPeriod = gameState.springPeriod
	local lastOvershoot = gameState.overshootAmount

	for i, configRow in ipairs(configRows) do
		configRow:update(gameState)
	end

	gfx.pushContext(nil)
	gfx.setFont(nicoPups)
	gfx.drawText("Elastic (spring)", 190, 90)
	gfx.drawText("Back (overshoot)", 190, 160)
	gfx.popContext()

	if gameState.easeDuration ~= lastDuration or gameState.easingIndex ~= lastEasingIndex or gameState.springAmplitude ~= lastAmplitude or gameState.springPeriod ~= lastPeriod or gameState.overshootAmount ~= lastOvershoot then
		easingGraph:redraw(gameState)
	end

	easingGraph:draw()

	local currentEasingFn = allEasings[gameState.easingIndex]
	local currentEasingName = easingNames[gameState.easingIndex]

	local t = easeTime
	local b = 0
	local c = 1
	local d = gameState.easeDuration

	local eased = 0
	if string.find(currentEasingName, "Elastic") then
		eased = currentEasingFn(t, b, c, d, gameState.springAmplitude, gameState.springPeriod)
	elseif string.find(currentEasingName, "Back") then
		eased = currentEasingFn(t, b, c, d, gameState.overshootAmount)
	else
		eased = currentEasingFn(t, b, c, d)
	end

	gfx.pushContext(nil)

	valueLabel:draw(7, 152)
	timeLabel:draw(29, 190)

	gfx.setColor(gfx.kColorXOR)

	-- Eased value (y)
	local yPos = 184 - (eased * EasingGraph.innerSize)
	-- Left
	gfx.fillEllipseInRect(
		27,
		yPos - 3,
		7,
		7
	)
	-- Right
	gfx.fillEllipseInRect(
		26 + EasingGraph.innerSize,
		yPos - 3,
		7,
		7
	)

	-- Value line (horizontal)
	gfx.setColor(gfx.kColorWhite)
	gfx.drawLine(
		30,
		yPos,
		29 + EasingGraph.innerSize,
		yPos
	)

	-- Time position (x)
	local xPos = (EasingGraph.innerSize * (easeTime / gameState.easeDuration)) + 30

	gfx.setColor(gfx.kColorXOR)
	-- Bottom
	gfx.fillEllipseInRect(
		xPos - 3,
		181,
		7,
		7
	)
	-- Top
	gfx.fillEllipseInRect(
		xPos - 3,
		182 - EasingGraph.innerSize,
		7,
		7
	)

	gfx.setColor(gfx.kColorWhite)
	-- Time line (vertical)
	gfx.drawLine(
		xPos,
		0,
		xPos,
		240
	)

	gfx.popContext()

	playdate.drawFPS(0, 0)
end
