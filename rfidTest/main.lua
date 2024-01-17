-- Toggle GPIO pins with keystrokes

--[[local GPIO = require('periphery').GPIO



local gpio_in = GPIO("/dev/gpiochip0", 10, "in")
local gpio_out = GPIO("/dev/gpiochip0", 12, "out")

newValue = true
--gpio_out:write(newValue)

function love.draw()
	love.graphics.setBackgroundColor(1,1,1)
	love.graphics.setColor(0,0,1) 
	love.graphics.setFont(love.graphics.newFont(24)) 
	love.graphics.print(tostring(newValue), 200, 200)

	gpio_out:write(newValue)

	
	--local value = gpio_in:read()
	--gpio_out:write(not value)

	

end

function love.keypressed( key )
	print(key)
	local value
	if key == "0" then
		--gpio_in:read()
		newValue = false
		gpio_out:write(newValue)
		print(gpio_out:read())
		--print(string.format("\tdirection: %s", gpio_in.direction))

	end
	if key == "1" then
		newValue = true
		gpio_out:write(newValue)
		print(gpio_out:read())
		--print(string.format("\tdirection: %s", gpio_in.direction))
	end
   	if key == "q" then
		print( "Q - quit has been pressed!")
		gpio_in:close()
		gpio_out:close()
		love.event.quit()
   	end
	newValue = gpio_out:read()
	return newValue
end--]]

socket = require("socket")
response = "nothing yet"

function love.keypressed(key)
	if key == "0" then
		if myclient == nil then
			myclient = socket.connect('localhost', 12346)
		end
		myclient:send("RFID\n")
		response = myclient:receive('*l')
		print("made it here")
		print(response)
		return response
	end
	if key == "1" then
		response = 1
		return response
	end
	if key == "q" then
		print( "Q - quit has been pressed!")
		--gpio_in:close()
		--gpio_out:close()
		if myclient ~= nil then
			myclient:close()
		end
		love.event.quit()
   	end
end

function love.draw()
	love.graphics.setFont(love.graphics.newFont(24)) 
	love.graphics.print(tostring(response), 200, 200)
end