local gpioFunctions = {}

function gpioFunctions.readPin(GPIO)
    local gpio_in = GPIO("/dev/gpiochip0", 26, "in")
    gpioValue = gpio_in:read()
    gpio_in:close()
    return gpioValue
end

return gpioFunctions
