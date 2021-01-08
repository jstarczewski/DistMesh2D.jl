using Test
using DataFrames
using Deldir
using GeometricalPredicates
using DistMesh2D
using VoronoiDelaunay

include("edgestests.jl")
include("scalertests.jl")
include("triangletests.jl")
include("distmeshtests.jl")
include("distancefunctionstests.jl")
include("triangulationexceptiontests.jl")
