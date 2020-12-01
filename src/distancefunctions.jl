function drectangle(
    p,
    x1::T,
    x2::T,
    y1::T,
    y2::T,
)::T where {T<:Float64}
    return -min(min(min(-y1 + p[2], y2 - p[2], -x1 + p[1], x2 - p[1])))
end

function dcircle(
    p,
    xc::T,
    yc::T,
    r::T
)::T where {T<:Float64}
    return sqrt((p[1] - xc) .^ 2 + (p[2] - yc) .^ 2) - r
end
