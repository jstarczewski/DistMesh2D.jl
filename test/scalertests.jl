
include("../src/scaler.jl")

bbox = [-1.0 -1.0; 1.0 1.0]
@info "Boundy box = " bbox
@info "x1 = " bbox[1]
@info "y1 = " bbox[2]

scaler = Scaler(bbox)

@testset "Scale some random points" begin
    a = Point2D(-1.0, 0.0)
    b = Point2D(0.0, 1.0)
    c = Point2D(0.5, 0.5)
    esa = Point2D(0.0, 0.5)
    esb = Point2D(0.5, 1.0)
    esc = Point2D(0.75, 0.75)
    sa = scaledpoint2d(a, scaler)
    sb = scaledpoint2d(b, scaler)
    sc = scaledpoint2d(c, scaler)
    @test esa == sa
    @test esb == sb
    @test esc == sc
end

@testset "Proper scale" begin
    expected_scale = 0.5
    @test expected_scale == scaler.scale
end

@testset "Scale then unscale point" begin
    p = Point2D(-1.0, -1.0)
    sp = Point2D(0.0, 0.0)
    spt = scaledpoint2d(p, scaler)
    @test sp == spt
    uspt = unscaledpoint2d(spt, scaler)
    @test p == uspt
end

@testset "scaledpoint is equal to scaledpoint2d" begin
    p2d = Point2D(-0.3212, 0.6654)
    p = [-0.3212, 0.6654]
    sp2d = scaledpoint2d(p2d, scaler)
    sp = scaledpoint(p, scaler)
    @test getx(sp2d) == sp[1]
    @test gety(sp2d) == sp[2]
end

@testset "unscaledpoint is equal to unscaledpoint2d" begin
    p2d = Point2D(0.3212, 0.6654)
    p = [0.3212, 0.6654]
    up2d = unscaledpoint2d(p2d, scaler)
    up = unscaledpoint(p, scaler)
    @test getx(up2d) == up[1]
    @test gety(up2d) == up[2]
end

@testset "unscale x and y" begin
    p = [-0.3212, 0.6654]
    sp = scaledpoint(p, scaler)
    @test abs(unscalex(sp[1], scaler) - p[1]) < eps(Float64)
    @test abs(unscaley(sp[2], scaler) - p[2]) < eps(Float64)
end
