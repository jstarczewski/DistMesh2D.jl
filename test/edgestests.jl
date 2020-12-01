using Test
using DataFrames
using Deldir
using Gadfly
using GeometricalPredicates

include("../src/scaler.jl")
include("../src/edges.jl")

bbox = [0.0 0.0; 1.0 1.0]

function plotexample()
    x = [0.2, 0.3, 0.4, 0.4, 0.5, 0.6]
    y = [0.0, 0.2, 0.0, 0.4, 0.2, 0.0]
    del, vor, sum = deldir(x, y)
    x, y = edges(del)
    println(del)
    println("-----------------------------")
    println(sum)
    Gadfly.plot(x = x, y = y, Geom.path, Coord.cartesian(fixed = true))
end

@testset "Compute centroid from scaled triangle" begin
    a = Point(0.0, 0.0)
    b = Point(0.5, 0.0)
    c = Point(0.0, 0.5)
    triangle = [a, b, c]
    scaler = Scaler(bbox)
    expectedcenterpoint = Point(0.16666666666666666, 0.16666666666666666)
    @test unscaledcenterpoint(triangle, scaler) == expectedcenterpoint
end

@testset "Build vectoriezed edges" begin
    a = Point(0.0, 0.0)
    b = Point(0.5, 0.0)
    c = Point(0.0, 0.5)
    triangle = [a, b, c]
    expectedvectorizededges = [
        [0.0 0.0; 0.5 0.0],
        [0.5 0.0; 0.0 0.5],
        [0.0 0.5; 0.0 0.0],
        [0.0 0.0; 0.0 0.5],
        [0.0 0.5; 0.5 0.0],
        [0.5 0.0; 0.0 0.0]
    ]
    vedges = vectorizededges(triangle)
    @test size(vedges, 1) == size(findall(in(expectedvectorizededges), vedges), 1)
end
