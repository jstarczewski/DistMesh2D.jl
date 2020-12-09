@testset "Check if error data is printed properly" begin
    expectederror = BoundsError()
    expectedpoints = [1, 2, 3]
    expectediteration = 3
    e = TriangulationException(expectedpoints, expectediteration, expectederror)
    expectedmessage = "Triangulation failed with given data: \n Points = $(e.points) \n Iteration = $(e.iteration) \n Original triangulation library error = $(e.originalError)"
    buffer = IOBuffer()
    showerror(buffer, e)
    emessage = String(take!(buffer))
    @test expectedmessage == emessage
end
