function pointstoforces(
    edges::Array{GeometricalPredicates.Line2D{GeometricalPredicates.Point2D},1},
    scaler::Scaler,
    fscale::Float64,
    pfix,
    fh::Function,
)::Dict{Point2D,Array{Float64,1}}
    bars = Array{Point2D,1}()
    barvec = Array{Array{Float64,1},1}()
    pointstofvec = Dict{Point2D,Array{Float64,1}}()
    for edge in edges
        b = unscaledpoint2d(getb(edge), scaler)
        a = unscaledpoint2d(geta(edge), scaler)
        push!(bars, barcenter(a, b))
        push!(barvec, barvector(a, b))
        push!(pointstofvec, geta(edge) => [0, 0])
        push!(pointstofvec, getb(edge) => [0, 0])
    end
    fvec = forcevectors(bars, barvec, fscale, fh)
    return pointstoforces(edges, pointstofvec, fvec, pfix)
end

function barcenter(a::Point2D, b::Point2D)::Point2D
    return Point(getx(a) + ((getx(b) - getx(a)) / 2), gety(a) + ((gety(b) - gety(a)) / 2))
end

function barvector(a::Point2D, b::Point2D)::Array{Float64, 1}
    return [getx(b) - getx(a), gety(b) - gety(a)]
end

function forcevectors(
    bars::Array{Point2D,1},
    barvec::Array{Array{Float64,1},1},
    fscale::Float64,
    fh::Function,
)
    L = [sqrt(sum(vsum .^ 2)) for vsum in barvec]
    hbars = [fh([getx(p), gety(p)]) for p in bars]
    L0 = hbars * fscale * sqrt(sum(L .^ 2) / sum(hbars .^ 2))
    fvec = maximum.(L0 - L) ./ L .* barvec
end

function pointstoforces(
    edges::Array{GeometricalPredicates.Line2D{GeometricalPredicates.Point2D},1},
    pointstofvec::Dict{Point2D,Array{Float64,1}},
    fvec,
    pfix
)::Dict{Point2D,Array{Float64,1}}
    iterator = 1
    for edge in edges
        a = geta(edge)
        b = getb(edge)
        push!(pointstofvec, a => pointstofvec[a] + (-fvec[iterator]))
        push!(pointstofvec, b => pointstofvec[b] + (fvec[iterator]))
        iterator += 1
    end
    for p in eachrow(pfix)
        p = Point(p[1], p[2])
        delete!(pointstofvec, p)
        push!(pointstofvec, p => [0, 0])
    end
    return pointstofvec
end
