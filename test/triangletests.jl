using Test
using DataFrames
using Deldir
using Gadfly
using GeometricalPredicates

include("../src/triangle.jl")


x = [0.2, 0.3, 0.4, 0.4, 0.5, 0.6]
y = [0.0, 0.2, 0.0, 0.4, 0.2, 0.0]

del, vor, sum = deldir(x, y)

function plotexample()
    x, y = edges(del)
    println(del)
    println("-----------------------------")
    println(sum)
    Gadfly.plot(x = x, y = y, Geom.path, Coord.cartesian(fixed = true))
end

@testset "Proper generators are generated" begin
    xsize = size(x)
    ysize = size(y)
    d, v, s = deldir(x, y)
    generators = emptygenerators(s)
    collectedgenerators = collect(generators)
    @test xsize == ysize
    @test size(keys(collectedgenerators)) == xsize
    nonemptygenerators = filter(g -> g == [], values(collectedgenerators))
    @test size(nonemptygenerators, 1) == 0
end

@testset "Generators are filled properly" begin
    expectedfilledgeneratos =
        Dict([
            (1, [2, 3]),
            (2, [1, 3, 4, 5]),
            (3, [1, 2, 5, 6]),
            (4, [2, 5]),
            (5, [4, 2, 6, 3]),
            (6, [3, 5])
        ])
    d, v, s = deldir(x, y)
    generators = emptygenerators(s)
    generatorstogenerated!(generators, d)
    collectedgenerators = collect(generators)
    cexpectedgenerators = collect(expectedfilledgeneratos)
    @test size(keys(collectedgenerators)) == size(keys(cexpectedgenerators))
    @test keys(collectedgenerators) == keys(cexpectedgenerators)
    i = 1
    while i <= size(keys(collectedgenerators), 1)
        sortedgenerators = sort(generators[i])
        sortedexpectedgenerators = sort(expectedfilledgeneratos[i])
        @test sortedgenerators == sortedexpectedgenerators
        i += 1
    end
 end

 @testset "Generators are transformed to triangles build with indexes" begin
    expectedtriangles = [
        [1, 2, 3],
        [2, 4, 5],
        [3, 5, 6],
        [2, 4, 5]
    ]
    d, v, s = deldir(x, y)
    generators = emptygenerators(s)
    generatorstogenerated!(generators, d)
    triangles = buildindextriangles(generators)
    @test size(triangles) == size(expectedtriangles)
    for expectedtriangle in expectedtriangles
        @test expectedtriangle in triangles
    end
end

@testset "Index triangles are transofmed to value triangles" begin
    expectedtriangles = [
        [Point2D(0.2, 0.0), Point2D(0.3, 0.2), Point2D(0.4, 0.0)],
        [Point2D(0.3, 0.2), Point2D(0.4, 0.4), Point2D(0.5, 0.2)],
        [Point2D(0.4, 0.0), Point2D(0.5, 0.2), Point2D(0.6, 0.0)],
        [Point2D(0.3, 0.2), Point2D(0.4, 0.4), Point2D(0.5, 0.2)]
    ]
    d, v, s = deldir(x, y)
    generators = emptygenerators(s)
    generatorstogenerated!(generators, d)
    triangles = buildindextriangles(generators)
    triangles = buildvaluetriangles(triangles, s)
    println(typeof(triangles))
    @test size(triangles) == size(expectedtriangles)
    for expectedtriangle in expectedtriangles
        @test expectedtriangle in triangles
    end
end

@testset "Build triangles" begin
    expectedtriangles = [
        [Point2D(0.2, 0.0), Point2D(0.3, 0.2), Point2D(0.4, 0.0)],
        [Point2D(0.3, 0.2), Point2D(0.4, 0.4), Point2D(0.5, 0.2)],
        [Point2D(0.4, 0.0), Point2D(0.5, 0.2), Point2D(0.6, 0.0)],
        [Point2D(0.3, 0.2), Point2D(0.4, 0.4), Point2D(0.5, 0.2)]
    ]
    d, v, s = deldir(x, y)
    tr = triangles(d, s)
    @test size(tr) == size(expectedtriangles)
    for expectedtriangle in expectedtriangles
        @test expectedtriangle in  tr
    end
end
