local gpioFunctions = {}

function gpioFunctions.readLeftButton(GPIO)
    local gpio_in = GPIO("/dev/gpiochip0", 26, "in")
    lbValue = gpio_in:read()
    gpio_in:close()
    return lbValue
end

function gpioFunctions.readRightButton(GPIO)
    local gpio_in = GPIO("/dev/gpiochip0", 19, "in")
    rbValue = gpio_in:read()
    gpio_in:close()
    return rbValue
end

return gpioFunctions
