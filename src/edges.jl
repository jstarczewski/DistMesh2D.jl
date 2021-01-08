function validedges(
    triangles::Array{Array{Point2D,1},1},
    edgesprovider,
    scaler::Scaler,
    fd::Function,
    geps::Float64,
)::Array{GeometricalPredicates.Line2D{GeometricalPredicates.Point2D},1}
    inedges = Array{Array{Float64,2},1}()
    outedges = Array{Array{Float64,2},1}()
    for triangle in triangles
        center = unscaledcenterpoint(triangle, scaler)
        edges = vectorizededges(triangle)
        if fd([getx(center), gety(center)]) > -geps
            push!(inedges, edges...)
        else
            push!(outedges, edges...)
        end
    end
    return buildedges(inedges, outedges, edgesprovider)
end

function unscaledcenterpoint(triangle::Array{Point2D,1}, scaler::Scaler)::Point2D
    return unscaledpoint2d(
        centroid(Primitive(triangle[1], triangle[2], triangle[3])),
        scaler,
    )
end

function vectorizededges(triangle::Array{Point2D,1})::Array{Array{Float64,2},1}
    a = triangle[1]
    b = triangle[2]
    c = triangle[3]
    ab = [getx(a) gety(a); getx(b) gety(b)]
    ba = [getx(b) gety(b); getx(a) gety(a)]
    bc = [getx(b) gety(b); getx(c) gety(c)]
    cb = [getx(c) gety(c); getx(b) gety(b)]
    ac = [getx(a) gety(a); getx(c) gety(c)]
    ca = [getx(c) gety(c); getx(a) gety(a)]
    return [ab, ba, bc, cb, ac, ca]
end

function validedges(
    triangles::Array{Array{Point2D,1},1},
    tess::DelaunayTessellation2D,
    scaler::Scaler,
    fd::Function,
    geps::Float64,
)::Array{GeometricalPredicates.Line2D{GeometricalPredicates.Point2D},1}
    inedges = Array{Array{Float64,2},1}()
    outedges = Array{Array{Float64,2},1}()
    for triangle in triangles
        center = unscaledcenterpoint(triangle, scaler)
        edges = vectorizededges(triangle)
        if fd([getx(center), gety(center)]) > -geps
            push!(inedges, edges...)
        else
            push!(outedges, edges...)
        end
    end
    return buildedges(inedges, outedges, tess)
end

function buildedges(
    inedges::Array{Array{Float64,2},1},
    outedges::Array{Array{Float64,2},1},
    edges::Array{GeometricalPredicates.Line2D{GeometricalPredicates.Point2D},1}
)::Array{GeometricalPredicates.Line2D{GeometricalPredicates.Point2D},1}
    inedges = filter(edge -> !(edge in outedges), inedges)
    edges = filter(edge -> !(edge in inedges), edges)
    return [edge for edge in edges]
end
