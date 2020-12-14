@testset "dcircle rand values outside" begin
    randomvalues = rand(5,2)
    randomvaluespositive = randomvalues .+ 2

    for p in eachrow(randomvaluespositive)
        @test dcircle(p, 0.0, 0.0, 1.0) > 0
    end
end

@testset "dcircle rand values inside" begin
    randomvalues = rand(5,2)
    for p in eachrow(randomvalues)
        @test dcircle(p, 0.0, 0.0, 2.0) <= 0
    end
end

@testset "drectangle rand values inside" begin
    randomvalues = rand(5,2)
    for p in eachrow(randomvalues)
        @test drectangle(p, 0.0, 1.0, 0.0, 1.0) <= 0
    end
end

@testset "drectangle rand values outside" begin
    randomvalues = rand(5,2) .+ 1
    for p in eachrow(randomvalues)
        @test drectangle(p, 0.0, 1.0, 0.0, 1.0) > 0
    end
end

@testset "dcircle exactly on boundry" begin
    p = [0.0, 1.0]
    @test drectangle(p, 0.0, 1.0, 0.0, 1.0) == 0
end

@testset "drectangle exactly on boundry" begin
    p = [0.5, 1.0]
    @test drectangle(p, 0.0, 1.0, 0.0, 1.0) == 0
end

function return5(p)
    return 5.0
end

function return10(p)
    return 10.0
end

function return4(p)
    return 4.0
end

@testset "ddiff" begin
    p = [1 2]
    @test ddiff(p, return5, return10, return4) == 5.0
    @test ddiff(p, return10, return5, return4) == 10.0
end


@testset "dintersect" begin
    p = [1 2]
    @test dintersect(p, return5, return10, return4) == 10.0
    @test dintersect(p, return10, return5, return4) == 10.0
end

@testset "huniform" begin
    p = [1 2]
    p2 = [-321 332211]
    @test huniform(p) == 1.0
    @test huniform(p2) == 1.0
end

@testset "dunion" begin
    p = [1 2]
    @test dunion(p, return10, return5, return5) == 5.0
    @test dunion(p, return5, return10, return4) == 4.0
end

@testset "protate" begin
    expectedrotatedpoint = [1.0 1.0]
    p = [-1.0 -1.0]
    protated = protate(p, pi)
    a = round(protated[1], digits = 10)
    b = round(protated[2], digits = 10)
    @test [a b] == expectedrotatedpoint
end
