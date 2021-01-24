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

function unscaleedges(edges, scaler)
    nedges = Array{Array{Point2D, 1}, 1}()
    for edge in edges
        push!(nedges,
                    [
                        unscaledpoint2d(geta(edge), scaler),
                        unscaledpoint2d(getb(edge), scaler)
                    ]
        )
    end
    return nedges
end

function plottable(x, y)
    nx = Array{Float64, 1}()
    ny = Array{Float64, 1}()
    iterator = 3
    i = 1
    len = length(x)
    while i <= len
        if i == iterator
            push!(nx, NaN)
            push!(ny, NaN)
            iterator = iterator + 2
        end
        push!(nx, x[i])
        push!(ny, y[i])
        i = i + 1
    end
    return nx, ny
end

function xy(edges)
    x = Array{Float64, 1}()
    y = Array{Float64, 1}()
    for edge in edges
        push!(x, getx(geta(edge)))
        push!(x, getx(getb(edge)))
        push!(y, gety(geta(edge)))
        push!(y, gety(getb(edge)))
    end
    return x, y
end
