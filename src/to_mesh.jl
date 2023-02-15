"""
    to_graph(x,y)
Assumes that `x,y` are of the form [a,b,NaN,c,d,NaN,....], representing line segments.
Create an adjacency matrix representing the graph of the mesh from the line segments,
and all the vertices
"""
function to_graph(x,y)
    Z_pts = Vector{Tuple{Float64,Float64}}(undef, 2length(x)÷3)
    idx = 1
    @inbounds for j in eachindex(x)
        if j % 3 > 0
            Z_pts[idx] = (x[j],y[j])
            idx += 1
        end
    end
    verts = unique(Z_pts)
    g=[Int[] for _ in eachindex(verts)]
    N_edges = size(Z_pts,1)÷2
    edges = Vector{Tuple{Int,Int}}(undef, N_edges)
    @inbounds for j in eachindex(edges)
        z1,z2 = Z_pts[[2j-1,2j]]
        z1_v = findfirst(==(z1), verts)
        z2_v = findfirst(==(z2), verts)
        push!(g[z1_v], z2_v)
        push!(g[z2_v], z1_v)
    end
    verts, g
end

"""
    sort3(a::T,b::T,c::T)
returns a NTuple{3,T} that gives (a,b,c) from smallest to largest
"""
function sort3(a::T,b::T,c::T)::NTuple{3,T} where {T}
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

"""
    counterclockwise(v1::Int,v2::Int,v3::Int, verts::Vector{Tuple{T,T}})
Sorts the indices in ascending order then swaps first two to ensure counterclockwise
"""
function counterclockwise(v1::Int,v2::Int,v3::Int, verts::Vector{Tuple{T,T}}) where {T}
    v1,v2,v3 = sort3(v1,v2,v3)
    ax,ay = verts[v1]
    bx,by = verts[v2]
    cx,cy = verts[v3]
    det_tri = (bx-ax)*(cy-ay)-(cx-ax)*(by-ay)
    is_cc = det_tri > 0
    is_cc ? (v1,v2,v3) : (v2,v1,v3)
end

"""
    tris_from_graph(g::Vector{Vector{Int}}, verts::Vector{Tuple{T,T}})
Takes a graph representation of a mesh (represented by a sparse adjacency matrix) and finds all the triangles.
Scales poorly with the number of edges.
"""
function tris_from_graph(g::Vector{Vector{Int}}, verts::Vector{Tuple{T,T}}) where {T}
    tris = Set{NTuple{3,Int}}()
    sizehint!(tris, 2length(verts))
    @inbounds for v in eachindex(g)
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
`p`: matrix where each row is a point on the mesh
`t`: matrix where each row gives a triangle via the indices of rows of p representing the 3 points
"""
function to_mesh(x,y)
    verts, g = to_graph(x,y)
    tris = tris_from_graph(g,verts)
    p = reduce(vcat, [v[1] v[2]] for v in verts)
    t = reduce(vcat, [t[1] t[2] t[3]] for t in tris)
    p,t
end
