@testset "free reduction" begin
    A = CGT.Alphabet([:x, :y, :X])
    CGT.setinverse!(A, :x, :X)
    x, X, y = CGT.Word([A[:x]]), CGT.Word([A[:X]]), CGT.Word([A[:y]])

    @test CGT.rewrite(x * X, A) == one(x)
    @test CGT.rewrite(y * x * X, A) == y
    @test CGT.rewrite(X * y * x, A) == X * y * x

    @test CGT.rewrite(X * x * X, A) == X

    CGT.setinverse!(A, :y, :y)
    @test isone(CGT.rewrite(y * x * X * y, A))
end
