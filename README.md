# DistMesh2D.jl
![CI](https://github.com/jstarczewski/DistMesh2D.jl/workflows/CI/badge.svg)
[![codecov](https://codecov.io/gh/jstarczewski/DistMesh2D.jl/main/graph/badge.svg)](https://codecov.io/gh/jstarczewski/DistMesh2D.jl)
<br/><br/>
<b>This package is still under heavy development, and not yet officially released</b>
The package provides Julia implementation of [DistMesh](http://persson.berkeley.edu/distmesh/) algorithm developed by [Per-Olof Persson](http://persson.berkeley.edu/) and [Gilbert Strang](http://www-math.mit.edu/~gs/) allowing to generate meshes on 2D plane, using [DelDir.jl](https://github.com/robertdj/Deldir.jl) which is a Julia wrapper for Delaunay triangulations and Voronoi/Dirichlet tessellations. Before using the package <b>I highly recommend to read [this document](http://persson.berkeley.edu/distmesh/persson04mesh.pdf) covering MATLAB's use-cases, because this packages tries to provide similar runtime interface to original one.</b>
<br/><br/>
## Installation
To use DistMesh2D.jl clone the repository and add it to the local package registry.
## Usage 
To generate a mesh, define a [signed distance function](http://persson.berkeley.edu/distmesh/persson04mesh.pdf), desired edge length function and run the meshing algorithm. 
```Julia
julia> fd(p) = sqrt(sum(p .^ 2)) - 1
fd (generic function with 1 method)

julia> fh(p) = 1.0
fh (generic function with 2 methods)

julia> x, y = distmesh2d(fd, fh, [-1.0 -1.0; 1.0 1.0], 0.2)
([-0.8408297336717067, -0.6993829085766673, NaN, -0.5315455685570857, -0.6993829085766673, NaN, -0.5822722080639808, -0.6993829085766673, NaN, -0.5822722080639808  …  NaN, -0.60618605865758, -0.36756281453508466, NaN, -0.60618605865758, -0.7846917737263828, NaN, -0.60618605865758, -0.5633752938295506, NaN], [-0.5412996931425073, -0.7147471921795109, NaN, -0.8470296986801119, -0.7147471921795109, NaN, -0.5521369576265936, -0.7147471921795109, NaN, -0.5521369576265936  …  NaN, 0.795322867083831, 0.92999869760509, NaN, 0.795322867083831, 0.6198861346071187, NaN, 0.795322867083831, 0.5800262182849156, NaN])
```
The output of a given function are points that are ready to be plotted with one of the available plotting libraries.
```Julia
julia> using Gadfly

julia> Gadfly.plot(x = x, y = y, Geom.path, Coord.cartesian(fixed = true))
```
The output mesh<br/><br/>
![image](https://user-images.githubusercontent.com/36159919/101280105-6a843180-37c7-11eb-91f4-79a589714bf1.png)
## Generating more complex meshes
Library provides simple generic signed distance functions to define popular shapes like `dcircle` and `drectangle`.
```Julia
function drectangle(
    p,
    x1::T,
    x2::T,
    y1::T,
    y2::T,
)::T where {T<:Float64}
    return -min(min(min(-y1 + p[2], y2 - p[2], -x1 + p[1], x2 - p[1])))
end

function dcircle(
    p,
    xc::T,
    yc::T,
    r::T
)::T where {T<:Float64}
    return sqrt((p[1] - xc) .^ 2 + (p[2] - yc) .^ 2) - r
end
```
### Non-uniform height function
```Julia
julia> fd(p) = max(drectangle(p, -100.0, 100.0, -100.0, 100.0), -dcircle(p, 0.0, 0.0, 40.0))
fd (generic function with 1 method)

julia> fh(p) = min(4 * sqrt(sum(p.^2)) - 100)
fh (generic function with 2 methods)

julia> bbox = [-100.0 -100.0; 100.0 100.0]
2×2 Array{Float64,2}:
 -100.0  -100.0
  100.0   100.0

julia> h0 = 10.0
10.0

julia> pfix = [-100.0 -100.0; -100.0 100.0; 100.0 -100.0; 100.0 100.0]
4×2 Array{Float64,2}:
 -100.0  -100.0
 -100.0   100.0
  100.0  -100.0
  100.0   100.0

julia> dptol = 0.003
0.003

julia> x, y = distmesh2d(fd, fh, bbox, h0, pfix, dptol)
([-100.0, -76.71718215838415, NaN, -62.29844095886764, -76.71718215838415, NaN, -100.0, -76.71718215838415, NaN, -100.0  …  NaN, 100.0, 100.0, NaN, 100.0, 78.01048490854643, NaN, 100.0, 80.72224653575613, NaN], [-80.56252474196684, -77.31440723125387, NaN, -62.263859671319544, -77.31440723125387, NaN, -65.15571042094268, -77.31440723125387, NaN, -65.15571042094268  …  NaN, 79.78462487451092, 63.972558404391755, NaN, 79.78462487451092, 76.7946778947107, NaN, 79.78462487451092, 100.0, NaN])

julia> Gadfly.plot(x = x, y = y, Geom.path, Coord.cartesian(fixed = true))
```
The output mesh<br/><br/>
![image](https://user-images.githubusercontent.com/36159919/101280559-1cbcf880-37ca-11eb-9d11-ab49f109d4d9.png)
### Composing shapes
```Julia
julia> fd(p) = max(drectangle(p, -200.0, 200.0, -100.0, 100.0),
                   -dcircle(p, 80.0, -30.0, 40.0),
                   -dcircle(p, -80.0, 30.0, 40.0),
                   -dcircle(p, -130.0, -50.0, 20.0),
             )
fd (generic function with 1 method)

julia> fh(p) = 1.0
fh (generic function with 2 methods)

julia> x, y = distmesh2d(fd, fh, [-200.0 -200.0; 200.0 200.0], 10.0, [-200.0 -100.0; -200.0 100.0; 200.0 -100.0; 200.0 100.0])
([161.0210862620033, 166.12998826924863, NaN, 200.0, 194.3247285424707, NaN, 200.0, 194.3247285424707, NaN, 200.0  …  NaN, 200.0, 189.74430159744796, NaN, 200.0, 200.0, NaN, 200.0, 200.0, NaN], [-81.3691159177671, -72.36916222551373, NaN, -88.61856691079599, -81.32959572629619, NaN, -73.8754302313204, -81.32959572629619, NaN, -73.8754302313204  …  NaN, 90.74551828933312, 100.0, NaN, 90.74551828933312, 80.15154249597565, NaN, 90.74551828933312, 100.0, NaN])

julia> Gadfly.plot(x = x, y = y, Geom.path, Coord.cartesian(fixed = true))
```
The output mesh<br/><br/>
![image](https://user-images.githubusercontent.com/36159919/101280144-a6b79200-37c7-11eb-807e-9249317febaa.png)
## Limitations
Considering the fact that this package relies on [DelDir.jl](https://github.com/robertdj/Deldir.jl) to triangulate points, some errors occurring in triangulation process can be hard to solve, because they can occur in original triangulation package itself. Note that when filling an issue it is highly recommended to check whether the error comes from meshing algorithm or directly from triangulation.  
