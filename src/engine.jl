abstract type Engine end

struct DD <: Engine
    scaler::Scaler
    edges::Function

    function DD(bbox::Array{Float64, 2})
        _scaler = Scaler(bbox)
        new(Scaler(bbox), dd)
    end
end

function dd(
    p,
    iteration::Int64,
    fd::Function,
    scaler::Scaler,
    geps::Float64
)::Array{GeometricalPredicates.Line2D{GeometricalPredicates.Point2D},1}
    del, vor, summ = deldir(p[:, 1], p[:, 2])
    trigs = triangles(del, summ)
    edges =  [Line(Point(r[1], r[2]), Point(r[3], r[4])) for r in eachrow(del)]
    return validedges(trigs, edges, scaler, fd, geps)
end


struct VD <: Engine
    scaler::Scaler
    edges::Function

    function VD(bbox::Array{Float64, 2})
        new(Scaler(bbox, basetrans = 1.0), vd)
    end
end

function vd(
    p,
    iteration::Int64,
    fd::Function,
    scaler::Scaler,
    geps::Float64
)::Array{GeometricalPredicates.Line2D{GeometricalPredicates.Point2D},1}
    tess = DelaunayTessellation()
    p = [Point2D(pp[1], pp[2]) for pp in eachrow(p)]
    push!(tess, p)
    trigs = triangles(tess)
    edges = Array{GeometricalPredicates.Line2D{GeometricalPredicates.Point2D},1}()
    for edge in delaunayedges(tess)
        push!(edges, Line(geta(edge), getb(edge)))
    end
    return validedges(trigs, edges, scaler, fd, geps)
end
