function meshgrid(vx::AbstractVector{T}, vy::AbstractVector{T}) where {T}
    m, n = length(vy), length(vx)
    gx = reshape(repeat(vx, inner = m, outer = 1), m, n)
    gy = reshape(repeat(vy, inner = 1, outer = n), m, n)
    return gx, gy
end

function plotedges(edges)::Tuple{Array{Float64,1}, Array{Float64,1}}
    x = Array{Float64,1}()
    y = Array{Float64,1}()
    for edge in edges
        push!(x, getx(geta(edge)))
        push!(x, getx(getb(edge)))
        push!(x, NaN)
        push!(y, gety(geta(edge)))
        push!(y, gety(getb(edge)))
        push!(y, NaN)
    end
    return x, y
end
