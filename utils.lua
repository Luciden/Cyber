Utils = {}

function math.sign(x)
    if     x < 0  then return -1
    elseif x == 0 then return 0
    else               return 1
    end
end