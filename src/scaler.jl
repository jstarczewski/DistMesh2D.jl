struct Scaler
    scale::Float64
    transx::Float64
    transy::Float64

    function Scaler(bbox::Array{Float64, 2})
        _scale = (abs(1 / (bbox[2] - bbox[1])))
        new(_scale, (0 - bbox[1] * _scale), (0 - bbox[1, 2] * _scale))
    end
end

function scaledpoint(p::Array{Float64,1}, scaler::Scaler)
    return [(p[1] * scaler.scale) + scaler.transx, (p[2] * scaler.scale) + scaler.transy]
end

function unscaledpoint(p::Array{Float64,1}, scaler::Scaler)
    return [(p[1] - scaler.transx) / scaler.scale, (p[2] - scaler.transy) / scaler.scale]
end

function scaledpoint2d(unscaled_point::Point2D, scaler::Scaler)
    return Point(
        ((getx(unscaled_point) * scaler.scale) + scaler.transx),
        ((gety(unscaled_point) * scaler.scale) + scaler.transy),
    )
end

function unscaledpoint2d(scaled_point::Point2D, scaler::Scaler)
    return Point(
        (getx(scaled_point) - scaler.transx) / scaler.scale,
        (gety(scaled_point) - scaler.transy) / scaler.scale,
    )
end

function unscaley(y::Float64, scaler::Scaler)
    return (y - scaler.transy) / scaler.scale
end

function unscalex(x::Float64, scaler::Scaler)
    return (x - scaler.transx) / scaler.scale
end
