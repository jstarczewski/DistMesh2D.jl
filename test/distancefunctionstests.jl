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
