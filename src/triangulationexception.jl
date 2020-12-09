struct TriangulationException <: Exception
    points::Any
    iteration::Int64
    originalError::Any
end

Base.showerror(io::IO, e::TriangulationException) = print(
     io,
    "Triangulation failed with given data: \n Points = $(e.points) \n Iteration = $(e.iteration) \n Original triangulation library error = $(e.originalError)"
)
