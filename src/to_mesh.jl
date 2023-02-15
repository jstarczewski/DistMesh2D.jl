"""
    to_graph(x,y)
Assumes that `x,y` are of the form [a,b,NaN,c,d,NaN,....], representing line segments
"""
function to_graph(x,y)
    Z = [x y]
    Z_pts = Vector{Tuple{Float64,Float64}}(undef, 2size(Z,1)÷3)
    for j in 1:size(Z,1)÷3
        Z_pts[2j-1] = (Z[3j-2,1],Z[3j-2,2])
        Z_pts[2j] = (Z[3j-1,1],Z[3j-1,1])
    end
    Z_pts = [(z[1],z[2]) for z in eachrow(Z[Not(3:3:end),:])]
    verts = unique(Z_pts)
    g=[Int[] for _ in eachindex(verts)]
    N_edges = size(Z_pts,1)÷2
    edges = Vector{Tuple{Int,Int}}(undef, N_edges)
    for j in eachindex(edges)
        z1,z2 = Z_pts[[2j-1,2j]]
        z1_v = findfirst(==(z1), verts)
        z2_v = findfirst(==(z2), verts)
        push!(g[z1_v], z2_v)
        push!(g[z2_v], z1_v)
    end
    verts, g
end

function sort3(a,b,c)
    t = a
    if a>b
        a = b
        b = t
    end
    if b > c
        t = b
        b = c
        c = t
    end
    if a > b
        t = a
        a = b
        b = t
    end
    a,b,c
end

function counterclockwise(v1::Int,v2::Int,v3::Int, verts)
    v1,v2,v3 = sort3(v1,v2,v3)
    ax,ay = verts[v1]
    bx,by = verts[v2]
    cx,cy = verts[v3]
    det_tri = (bx-ax)*(cy-ay)-(cx-ax)*(by-ay)
    is_cc = det_tri > 0
    is_cc ? (v1,v2,v3) : (v2,v1,v3)
end

function tris_from_graph(g::Vector{Vector{Int}}, verts)
    tris = NTuple{3,Int}[]
    for v in eachindex(g)
        for v1 in g[v]
            for v2 in g[v1]
                for v3 in g[v2]
                    if v3 == v
                        tri = counterclockwise(v1,v2,v3, verts)
                        push!(tris, tri)
                    end
                end
            end
        end
    end
    tris
end

"""
    to_mesh(x,y)
Given line segments with coordinates in x,y of form [x1,x2,NaN,x3,x4,NaN,...] and similar for y,
construct a mesh using vertices and a conductivity matrix.
Returns:
`verts`: list of Tuple{Float64,Float64}s representing points
`tris`: list of unique triangles of the form Tuple(v1,v2,v3), where v1,v2,v3 are indices in counter clockwise order
"""
function to_mesh(x,y)
    verts, g = to_graph(x,y)
    tris = tris_from_graph(g,verts)
    p = reduce(vcat, [v[1] v[2]] for v in verts)
    t = reduce(vcat, [t[1] t[2] t[3]] for t in unique(tris))
    p,t
end
