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

function dunion(
    p,
    dfs::Function...,
)::Float64
    return min([fun(p) for fun in dfs]...)
end

function ddiff(
    p,
    d1::Function,
    dfs::Function...
)::Float64
    return max(d1(p), [-fun(p) for fun in dfs]...)
end

function dintersect(
        p,
        dfs::Function...
)::Float64
    return max([fun(p) for fun in dfs]...)
end

function huniform(p)::Float64
    return ones(size(p, 1), 1)[1]
end

function protate(p,phi)
    return p*[cos(phi) -sin(phi); sin(phi) cos(phi)]
end
