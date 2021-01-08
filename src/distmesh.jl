function distmesh2d(
    fd::Function,
    fh::Function,
    bbox,
    h0::Float64;
    pfix = [],
    dptol = 0.001,
    ttol = 0.1,
    geps = 0.001 * h0,
    Fscale = 1.2,
    deltat = 0.2,
    deps = sqrt(eps(Float64)) * h0,
    logmi = false,
    engine = DD(bbox)
)::Tuple{Array{Float64, 1}, Array{Float64, 1}}
    pold = Inf
    scaler = engine.scaler
    v1, v2 = extractbox(bbox, h0, calculateh1(h0))
    x, y = meshgrid(v1, v2)
    shiftevenrows!(x, h0)
    p = buildinitialpoints(x, y, fd, fh, scaler, geps)
    pfix = [vcat(scaledpoint(vcat(row), scaler)) for row in eachrow(pfix)]
    pfix = transpose(reshape(vcat(pfix...), 2, length(pfix)))
    iteration = 0
    moveindexes = Array{Float64,1}()
    trigs = Array{Array{Point2D,1},1}()
    line_edges = Array{GeometricalPredicates.Line2D{GeometricalPredicates.Point2D},1}()
    pold = p .+ Inf
    while true
        if max(sqrt(sum((p - pold).^2))/h0)>ttol
            pold = p
            try
                line_edges = engine.edges(p, iteration, fd, scaler, geps)
                iteration += 1
            catch e
                throw(TriangulationException(p, iteration, e))
            end
        end
        pointstofvces = pointstoforces(line_edges, scaler, Fscale, pfix, fh)
        finalp, moveindex =
            finalpositions(pointstofvces, scaler, deltat, fd, geps, deps, h0)
        if moveindex < dptol
            x, y = plotedges(line_edges)
            break
        else
            if logmi
                saveiterationdata!(moveindexes, moveindex)
            end
            p = finalp
        end
    end
    return [unscalex(x, scaler) for x in x], [unscaley(y, scaler) for y in y]
end

function buildinitialpoints(
    x::Array{Float64, 2},
    y::Array{Float64, 2},
    fd::Function,
    fh::Function,
    scaler::Scaler,
    geps::Float64
)::Array{Float64, 2}
    p = [x[:] y[:]]
    p = [vcat(row) for row in eachrow(p) if fd(row) < -geps]
    r0 = [1 ./ fh(row) .^ 2 for row in p]
    r0max = maximum(r0 ./ maximum(r0))
    p = [vcat(scaledpoint(row, scaler)) for row in p if (rand(Float64, size(p)))[1] < r0max]
    p = transpose(reshape(vcat(p...), 2, length(p)))
    return p
end

function calculateh1(h0::Float64)::Float64
    return h0 * (sqrt(3) / 2)
end

function extractbox(
    bbox::Array{Float64,2},
    h0::Real,
    h1::Real
)::Tuple{Array{Float64, 1}, Array{Float64, 1}}
    v1 = bbox[1, 1]:h0:bbox[2, 1]
    v2 = bbox[1, 2]:h1:bbox[2, 2]
    return v1, v2
end

function shiftevenrows!(x::Array{Float64, 2}, h0::Float64)
    x[2:2:end, :] = x[2:2:end, :] .+ h0 / 2
end

function saveiterationdata!(
    moveindexes::Array{Float64,1},
    moveindex::Float64
)
    if !isempty(moveindexes)
        minv = min(moveindexes...)
        if moveindex < minv
            push!(moveindexes, moveindex)
            @info "Minimal move index is $moveindex"
        end
    else
        push!(moveindexes, moveindex)
    end
end
