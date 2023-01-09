@testset "Words" begin
    A = CGT.Alphabet([:a, :b, :A])
    CGT.setinverse!(A, :a, :A)

    w = CGT.Word([1, 2, 3])
    @test one(w) == CGT.Word(Int[])
    @test w == [1, 2, 3]
    @test w * w == [1, 2, 3, 1, 2, 3]

    @test_throws ArgumentError inv(w, A)
    @test inv(CGT.Word([1, 3, 1]), A) == [3, 1, 3]
    @test sprint(show, MIME"text/plain"(), one(w)) == "ε"
    @test sprint(show, MIME"text/plain"(), w) == "1·2·3"

    @test CGT.string_repr(w, A) == "a·b·A"

    A = CGT.Alphabet([:x, :X, :y, :Y])
    CGT.setinverse!(A, :x, :X)

    x, X = CGT.Word([A[:x]]), CGT.Word([A[:X]])
    y, Y = CGT.Word([A[:y]]), CGT.Word([A[:Y]])
    ε = one(x)

    @test CGT.free_rewrite(ε, A) == ε
    @test CGT.free_rewrite(ε, A) !== ε
    @test CGT.free_rewrite(x, A) == x
    @test CGT.free_rewrite(x, A) !== x
    @test CGT.free_rewrite(X, A) == X
    @test CGT.free_rewrite(x * X, A) == ε
    @test CGT.free_rewrite(y * x * X, A) == y
    @test CGT.free_rewrite(x * y * X, A) == x * y * X
    @test CGT.free_rewrite(x * X * y, A) == y
    @test CGT.free_rewrite(y * Y, A) == y * Y

    CGT.setinverse!(A, :y, :Y)
    @test CGT.free_rewrite(y * Y, A) == ε
    @test CGT.free_rewrite(y * x * X * Y, A) == ε
    @test CGT.free_rewrite(x * y * X * Y, A) == x * y * X * Y
end
