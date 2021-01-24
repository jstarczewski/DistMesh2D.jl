# VoronoiDelaunay
function triangles(tess::DelaunayTessellation2D)
    trigs = Array{Array{Point2D,1},1}()
    for t in tess
        st = [geta(t), getb(t), getc(t)]
        push!(trigs, st)
    end
    return trigs
end

function triangles(del::DataFrame, summ::DataFrame)
    generators = emptygenerators(summ)
    fillgenerators!(generators, del)
    indextriangles = buildindextriangles(generators)
    return buildvaluetriangles(indextriangles, summ)
end

function emptygenerators(summ::DataFrame)::Dict{Int64,Array{Int,1}}
    generators = Dict{Int64,Array{Int,1}}()
    for (index, row) in enumerate(eachrow(summ))
        generators[index] = []
    end
    return generators
end

function fillgenerators!(
    gen::Dict{Int64,Array{Int,1}},
    del::DataFrame
)
    for row in eachrow(del)
        gen[row[5]] = append!(gen[row[5]], row[6])
        gen[row[6]] = append!(gen[row[6]], row[5])
    end
end

function buildindextriangles(generators::Dict{Int64,Array{Int,1}})::Array{Array{Int,1},1}
    triangles = Array{Array{Int,1},1}()
    for k in keys(generators)
        for e in generators[k]
            i = findall(in(generators[e]), generators[k])
            common = generators[k][i]
            for c in common
                tri = sort([c, k, e])
                if !(tri in triangles)
                    push!(triangles, tri)
                end
            end
        end
    end
    return triangles
end

function buildvaluetriangles(
    indextriangles::Array{Array{Int,1},1},
    summ::DataFrame,
)::Array{Array{Point2D,1},1}
   return [
        [
            Point(summ[t[1], 1], summ[t[1], 2]),
            Point(summ[t[2], 1], summ[t[2], 2]),
            Point(summ[t[3], 1], summ[t[3], 2]),
        ] for t in indextriangles
    ]
end
