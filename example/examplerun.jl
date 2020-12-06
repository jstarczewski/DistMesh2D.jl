using Gadfly
using DistMesh2D

function fh(p)::Real
    return min(4 * sqrt(sum(p.^2)) - 100)
end

function dc(p)
    return -1 + abs(4 - sqrt(sum(p .^ 2)))
end

function dca(p)
    return sqrt(sum(p .^ 2)) - 2
end

function dcrcc(p)
    return max(drectangle(p, -200.0, 200.0, -100.0, 100.0),
            -dcircle(p, 80.0, -30.0, 40.0),
            -dcircle(p, -80.0, 30.0, 40.0),
            -dcircle(p, -130.0, -50.0, 20.0),
      )
end

function dcrcc2(p)
    return max(drectangle(p, -100.0, 100.0, -100.0, 100.0),
            -dcircle(p, 0.0, 0.0, 40.0),
      )
end

function dcrcc3(p)
    return max(drectangle(p, -100.0, 100.0, -100.0, 100.0),
            -drectangle(p, -10.0, 100.0, 40.0, 80.0)
      )
end

function eplot(x,y)
    Gadfly.plot(x = x, y = y, Geom.path, Coord.cartesian(fixed = true))
end

x, y = distmesh2d(dcrcc, fh, [-200.0 -200.0; 200.0 200.0], 10.0, [-200.0 -100.0; -200.0 100.0; 200.0 -100.0; 200.0 100.0])
#x, y = distmesh2d(dcrcc2, fh, [-100.0 -100.0; 100.0 100.0], 10.0, [-100.0 -100.0; -100.0 100.0; 100.0 -100.0; 100.0 100.0])
#x, y = distmesh2d(dcrcc3, fh, [-100.0 -100.0; 100.0 100.0], 5.0, [-100.0 -100.0; -100.0 100.0; 100.0 -100.0; 100.0 100.0])
function fdd(p)
    return dcircle(p, 0.0, 0.0, 1.0)
end

function fdr(p)
    return drectangle(p, -100.0, 100.0, -100.0, 100.0)
end

#x, y = distmesh2d(fdr, fh, [-1.0 -1.0; 1.0 1.0], 0.1, [-1.0 -1.0; -1.0 1.0; 1.0 -1.0; 1.0 1.0])
eplot(x,y)
