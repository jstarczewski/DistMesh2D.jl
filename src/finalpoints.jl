function finalpositions(
    pointstofvecs::Dict{Point2D,Array{Float64,1}},
    scaler::Scaler,
    deltat::Float64,
    fd::Function,
    geps::Float64,
    deps::Float64,
    h0::Float64
)::Tuple{Any, Float64}
    newp, dpoints = buildnewpoints(pointstofvecs, scaler, deltat, geps, fd)
    finalp = buildfinalpoints(newp, scaler, fd, deps)
    return finalp, moveindex(dpoints, deltat, h0)
end

function buildnewpoints(
    pointstofvecs::Dict{Point2D,Array{Float64,1}},
    scaler::Scaler,
    deltat::Float64,
    geps::Float64,
    fd::Function
)::Tuple{Array{Array{Float64, 1},1},  Array{Array{Float64, 1},1}}
    newp = Array{Array{Float64, 1},1}()
    dpoints = Array{Array{Float64, 1},1}()
    for (point, force) in pointstofvecs
        p = unscaledpoint2d(point, scaler)
        np = [getx(p), gety(p)] + deltat * force
        push!(newp, [np[1], np[2]])
        if fd(np) < -geps
            push!(dpoints, force)
        end
    end
    return newp, dpoints
end

function buildfinalpoints(
    newp::Array{Array{Float64, 1},1},
    scaler::Scaler,
    fd::Function,
    deps::Float64
)
    finalp = Array{Array{Float64, 1}, 1}()
    for p in newp
        x = p[1]
        y = p[2]
        d = fd([x, y])
        if d > 0
            dgradx = (fd([x + deps, y]) - d) / deps
            dgrady = (fd([x, y + deps]) - d) / deps
            res = [x, y] - [d * dgradx, d * dgrady]
            push!(finalp, res)
        else
            push!(finalp, [x, y])
        end
    end
    finalp = map(p -> scaledpoint([p[1], p[2]], scaler), unique(finalp))
    finalp = permutedims(reshape(vcat(finalp...), 2, length(finalp)))
end

function moveindex(
    dpoints::Array{Array{Float64,1},1},
    deltat::Float64,
    h0::Float64
)::Float64
    d = map(row -> sum(deltat * row .^ 2), dpoints)
    push!(d, 0)
    return maximum(sqrt.(d) / h0)
end
