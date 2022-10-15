function bh.getHealthBarColor(ratio)
    if ratio <= 0.3 then 
        return sea.Color.red
    elseif ratio < 0.9 then
        return sea.Color.yellow
    else
        return sea.Color.green
    end
end