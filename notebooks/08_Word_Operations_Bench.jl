### A Pluto.jl notebook ###
# v0.19.14

using Markdown
using InteractiveUtils

# ╔═╡ 9ee80f66-966e-11ed-0e70-3f12170afd56
begin
    using Pkg
    Pkg.activate("..")
    using Test
    using CGT_KIT_WS2022
    const CGT = CGT_KIT_WS2022
end

# ╔═╡ 0e584a50-294a-4e47-8e24-5a44e2c808d9
using BenchmarkTools

# ╔═╡ 1012e239-ac85-4c12-aa28-1297aaa997f5
begin
	using Random
	function rand_words(;T=UInt16, seed=1234, n=2^10)
		Random.seed!(seed)
		w = CGT.Word{T}(rand(1:10, n))
		v = copy(w)
		v[end] += 1
		u = copy(w)
		u[7] += 1
		return (w, v, u)
	end
end

# ╔═╡ ceee9f7e-7f5b-4bc9-8c4b-950cf6769471
begin
	using LoopVectorization
	LoopVectorization.check_type(::Type{<:CGT.Word}) = true
	Base.pointer(w::CGT.Word) = pointer(w.letters)
	Base.strides(w::CGT.Word) = strides(w.letters)
end

# ╔═╡ 447a8b45-902f-41c9-a437-0e05471a23fc
import CGT_KIT_WS2022: AbstractWord

# ╔═╡ e121c6db-2c30-416f-ae9a-2c9a00cf3c2b
begin
    function Base.popfirst!(w::AbstractWord)
        @assert !isone(w)
        letter = w[begin] # first(w)
        for i in firstindex(w):lastindex(w)-1
            w[i] = w[i+1]
        end
        resize!(w, length(w) - 1)
        return letter
    end

    let w = CGT.Word([1, 2, 3])
        @assert popfirst!(w) == 1
        @assert w == [2, 3]
        @assert popfirst!(w) == 2
        @assert w == [3]
        @assert popfirst!(w) == 3
        @assert isone(w)

        try
            popfirst!(w)
            @assert false
        catch
            @assert true
        end
    end
end

# ╔═╡ 8e75bee5-c678-4079-90e4-7b9227c111d4
let w = CGT.Word(rand(1:10, 2^10)) #[1,2,3]
    @benchmark popfirst!($w)
end

# ╔═╡ dab2df3b-2c29-4c45-bba2-7f49cbf90c86
b1 = @benchmark popfirst!(ww) setup = (ww = CGT.Word(rand(1:10, 2^10))) evals =
    2^9

# ╔═╡ d121e148-67b4-451c-b6fe-36c022c32fe3
b2 =
    @benchmark popfirst!(ww.letters) setup = (ww = CGT.Word(rand(1:10, 2^9))) evals =
        2^9

# ╔═╡ 9c98ee04-2119-4701-af60-26adeec18fcb
BenchmarkTools.judge(median(b1), median(b2))

# ╔═╡ 23f65e86-3921-498e-bd48-f14a00a59bf2
# Base.popfirst!(w::CGT.Word) = popfirst!(w.letters)

# ╔═╡ daf4527a-822d-4814-9fb7-9867b7527f63
begin
    function Base.prepend!(w::AbstractWord, v::AbstractWord)
        fi = firstindex(w)
        li = lastindex(w)
        resize!(w, length(w) + length(v))
        @inbounds for idx in li:-1:fi
            w[idx+length(v)] = w[idx]
        end
        @inbounds for (idx, l) in pairs(v)
            w[idx] = l
        end
        return w
    end
    let ww = CGT.Word([1, 2, 3]), vv = CGT.Word([4, 5])
        # @info prepend!(w, v)
        @assert prepend!(ww, vv) == [4, 5, 1, 2, 3]
    end
end

# ╔═╡ b8e606e5-896e-43e4-884b-fbd8752e3c49
b3 = @benchmark prepend!(ww, vv) setup =
    (ww = CGT.Word(rand(1:10, 2^6)); vv = CGT.Word(rand(1:10, 2^4))) evals =
    500

# ╔═╡ 54341a70-9f31-4428-932c-a8b5b875c8b9
b4 = @benchmark prepend!(ww.letters, vv) setup =
    (ww = CGT.Word(rand(1:10, 2^8)); vv = CGT.Word(rand(1:10, 2^4))) evals =
    500

# ╔═╡ ec44fc0e-71ce-49ef-bcd4-252b6d75557a
BenchmarkTools.judge(median(b3), median(b4))

# ╔═╡ cd8a8ce3-7d2c-46cf-a67d-b4cd9e23dfcd
b5 = @benchmark prepend!(ww.letters, vv.letters) setup =
    (ww = CGT.Word(rand(1:10, 2^8)); vv = CGT.Word(rand(1:10, 2^4))) evals =
    500

# ╔═╡ 4ef2bd81-6e9f-44ab-8ceb-d0fa23b84c11
BenchmarkTools.judge(median(b3), median(b5))

# ╔═╡ 93f7d635-c57f-4597-9aaf-243eddde0fb0


# ╔═╡ 79f1aa28-55fe-495c-ad9a-92e0de3ee5fb
function prepend2!(w::AbstractWord, v::AbstractWord)
    lw = length(w)
    lv = length(v)
    w = resize!(w, lw + lv)
    w = @inbounds copyto!(w, lv + 1, w, firstindex(w), lw)
    w = @inbounds copyto!(w, v)
    return w
end

# ╔═╡ 6d3b6ea0-ddcf-41a2-ac57-744ba46666f7
b6 = @benchmark prepend2!(ww, vv) setup =
    (ww = CGT.Word(rand(1:10, 2^6)); vv = CGT.Word(rand(1:10, 2^4))) evals =
    500

# ╔═╡ 14b236d7-f857-4444-ae00-fd1ee282e0c4
BenchmarkTools.judge(median(b6), median(b5))

# ╔═╡ 0e032568-5529-4b80-8684-199a4bf50539
"""
    issuffix(v::AbstractWord, w::AbstractWord)
Check if `v` is a suffix of `w`.
"""
function issuffix(v::AbstractWord, w::AbstractWord)
    length(v) > length(w) && return false
    offset = length(w) - length(v)
    for i in eachindex(v)
        v[i] == w[offset+i] || return false
    end
    return true
end

# ╔═╡ 48583577-5f41-48e5-99d9-02c078ce5ea5
function issuffix(v::AbstractVector, w::AbstractVector)
    length(v) > length(w) && return false
    offset = length(w) - length(v)
    return v == @view w[offset+1:end]
end

# ╔═╡ 34be6256-f893-4a25-a681-0a4343af3ac6
let w = CGT.Word(rand(1:10, 2^10)), v = CGT.Word(w[end-2^7-1:end])
    @benchmark issuffix($v, $w)
end

# ╔═╡ 14e048bb-4701-4835-8cd2-2d33b9e9aab7
let w = CGT.Word(rand(1:10, 2^10)), v = CGT.Word(w[end-2^7+1:end])
    @benchmark issuffix($(v.letters), $(w.letters))
end

# ╔═╡ d0d15551-ec3a-46ac-90bc-a7ae2953d04e
function issuffix2(v::AbstractVector, w::AbstractVector)
    length(v) > length(w) && return false
    offset = length(w) - length(v)
	ans = true
    @inbounds for i in eachindex(v)
        ans &= v[i] == w[offset+i]
    end
    return ans
end

# ╔═╡ d3a6ad01-a3bb-4cf4-88e5-cf3858c0c9f5
let w = CGT.Word(rand(1:10, 2^10)), v = CGT.Word(w[end-2^7+1:end])
    @benchmark issuffix2($(v), $(w))
end

# ╔═╡ 5c10c2f0-047b-4ca3-8581-253139c98759
w,v,u = rand_words()

# ╔═╡ 22b69511-dd9b-4524-b2f4-5b2d69c5ba0a
@benchmark $w == $v

# ╔═╡ 4d6b8d9a-9f54-4d29-aa18-5bccbbed879c
@benchmark $(w.letters) == $(v.letters)

# ╔═╡ 57f9a27a-66ab-4399-9424-f10c875957d6
function test_eq1(v, w)
    length(v) ≠ length(w) && return false
	ans = true
	@inbounds for i in eachindex(v)
		v[i] == w[i] || return false
	end
	return true
end

# ╔═╡ a27dfa37-7c89-4d9b-8274-63b8c722cd60
let 
	b1 = @benchmark test_eq1($w, $w)
	b2 = @benchmark test_eq1($w, $v)
	b3 = @benchmark test_eq1($w, $u)
	tww, twv, twu = time.(median.((b1,b2,b3)))
	@info eltype(w) tww twv twu
end

# ╔═╡ 30b91a44-0716-4e54-a3de-731eb26cbab8
let 
	b1 = @benchmark test_eq1($(w.letters), $(w.letters))
	b2 = @benchmark test_eq1($(w.letters), $(v.letters))
	b3 = @benchmark test_eq1($(w.letters), $(u.letters))
	tww, twv, twu = time.(median.((b1,b2,b3)))
	@info eltype(w) tww twv twu
end

# ╔═╡ 396301be-f383-4595-b8cd-4cb881cf1118
let 
	b1 = @benchmark ==($(w.letters), $(w.letters))
	b2 = @benchmark ==($(w.letters), $(v.letters))
	b3 = @benchmark ==($(w.letters), $(u.letters))
	tww, twv, twu = time.(median.((b1,b2,b3)))
	@info eltype(w) tww twv twu
end

# ╔═╡ 8f23a9a0-8a4c-48aa-ae3a-d62c7bfc0e98
begin
	function _unsafe_cmp(w, woffset, v, voffset, n)
	    ans = true
	    @inbounds for i in 1:n
	        ans &= w[woffset+i] == v[voffset+i]
	    end
	    return ans
	end
	@assert _unsafe_cmp(w, 0, v, 0, 32)
	@assert !_unsafe_cmp(w, 0, u, 0, 32)
	@code_warntype _unsafe_cmp(w, 0, v, 0, 32)
end

# ╔═╡ 005502e2-5c9b-4b90-82eb-4061f68405d2
# uncomment this and inspect the assembly above
Base.@propagate_inbounds Base.getindex(w::CGT.Word, n::Int) = w.letters[n]

# ╔═╡ b194c438-6d84-4716-92f4-a8d4f0df08b4
md"
```julia
function rewrite!(v::AbstractWord, w::AbstractWord, rws::AbstractVector{<:Rule})
    v = resize!(v, 0)
    while !isone(w)
        push!(v, popfirst!(w))
        for (lhs, rhs) in rws
            if issuffix(lhs, v)
                prepend!(w, rhs)
                resize!(v, length(v) - length(lhs))
                break
            end
        end
    end
    return v
end
```
"

# ╔═╡ ed7f8cc2-87ad-40e8-94ea-486e88ffd27e
md"# First: `popfirst!`"

# ╔═╡ db8a5fdb-2ad8-4434-b48c-2e4725eebfd6
md"# Second: `prepend!`"

# ╔═╡ 22c1f332-242b-45ee-9766-894915c74b24
md"# Third: `issuffix`"

# ╔═╡ fc92df01-080e-42b7-8755-2690cb06c8a1
md" ## Third and a half: equality"

# ╔═╡ 6387d6b1-238c-4fc4-9177-e0939d67185e
md"## Intermezzo: `_unsafe_cmp`"

# ╔═╡ 355d788b-b814-4c00-a0a0-9210864557a7
md" ### Fixing the loop length"

# ╔═╡ 3ec10512-4144-427a-b3c8-3c8223dc0aae
for n in (2, 4, 8, 16, 32, 64, 128, 256, 512)
    f = Symbol(:_unsafe_cmp, n)
	# e.g. _unsafe_cmp64 is defined by passing __constant__ 64 at compile time!
    @eval $f(w, woffset, v, voffset) = _unsafe_cmp(w, woffset, v, voffset, $n)
end

# ╔═╡ 6d7ab003-4828-4810-a206-ab5ddf8df764
map(enumerate((_unsafe_cmp2,_unsafe_cmp4,_unsafe_cmp8,_unsafe_cmp16,_unsafe_cmp32,_unsafe_cmp64,_unsafe_cmp128,_unsafe_cmp256,_unsafe_cmp512))) do (i,f)
    b = @benchmark $f($w, 0, $v, 0)
	(length=2^i, time=time(median(b)))
end

# ╔═╡ b881a1f3-c3ea-4d3b-8715-29d6f9fed19e
md"""
Such generation could be also obtained (and is arguably more idiomatic) by defining
```julia
	@generated function _unsafe_cmp(w, woffset, v, voffset, ::Val{N}) where N
		# @info "generating `_unsafe_cmp` for N = $N"
		return :(_unsafe_cmp(w, woffset, v, voffset, $N))
	end
```

This function needs to be called e.g. with `Val(32)` as the last argument. `Val(x)` is a way to turn a value (`x`) into a unique type `Val(x)` is of type `Val{x}`, hence the value is known __at compile time__ and the loop can be transformed by the compiler!
"""

# ╔═╡ f641e61b-4503-40f4-a2f3-7cce715b89db
@code_native debuginfo = :none _unsafe_cmp32(w, 0, v, 0)

# ╔═╡ a73506da-0f37-48f6-b74e-2aa0a573b7ca
# ╠═╡ show_logs = false
@code_native debuginfo = :none _unsafe_cmp128(w, 0, v, 0)

# ╔═╡ 3dec8941-e7af-45e5-a4c2-8527266037f9
md"# Four: our version of equality"

# ╔═╡ e1ebe24b-3b6b-4969-abd3-a04f7d0fd169
let 
	b1 = @benchmark ==($(w.letters), $(w.letters))
	b2 = @benchmark ==($(w.letters), $(v.letters))
	b3 = @benchmark ==($(w.letters), $(u.letters))
	@info typeof(w.letters) time(median(b1)) time(median(b2)) time(median(b3))
end

# ╔═╡ ea5641ae-71bc-4c3f-94a4-a525597dadab
@which w.letters == v.letters

# ╔═╡ cb354dd3-fdb1-4a38-8064-6859c4961c2d
@generated function _unsafe_cmp(w, woffset, v, voffset, ::Val{N}) where N
	# @info "generating `_cmp_unsafe` for N = $N"
	return :(_unsafe_cmp(w, woffset, v, voffset, $N))
end

# ╔═╡ 19db41bd-da2f-4175-a3c9-464d5817f43e
@code_native debuginfo = :none _unsafe_cmp(w.letters, 0, v.letters, 0, 64)

# ╔═╡ 03276f0f-54d6-4770-8658-ec1e6a3dd3cd
let
	b1 = @benchmark _unsafe_cmp($w, 0, $v, 0, 32)
	b2 = @benchmark _unsafe_cmp($w, 0, $u, 0, 32)
	@info "_unsafe_cmp, $(typeof(w)), n=32" time(median(b1)) time(median(b2))
end

# ╔═╡ 3c253994-534c-46c2-a787-1c3ebe912567
let
	b1 = @benchmark _unsafe_cmp($(w.letters), 0, $(v.letters), 0, 32)
	b2 = @benchmark _unsafe_cmp($(w.letters), 0, $(u.letters), 0, 32)
	@info "_unsafe_cmp, $(typeof(w.letters)), n=32" time(median(b1)) time(median(b2))
end

# ╔═╡ 6abc65f2-0509-4ed4-8915-739dbf8d4e2e
map((2,4,8,16,32,64,128,256,512)) do n
    b = @benchmark _unsafe_cmp($w, 0, $v, 0, $n)
	(length=n, time=time(median(b)))
end

# ╔═╡ f5d15d6a-485f-4bef-95b8-b91b1858dbc9


# ╔═╡ 1bf0756f-d330-4fe1-b62d-6eb60d904534
function _unsafe_tail_cmp1(w, woffset, v, voffset, k)
	# ans = true
	# @turbo for i in 1:k
	# 	ans &= w[woffset+i] == v[voffset+i]
	# end
	# return ans
	return _unsafe_cmp(w, woffset, v, voffset, k)
end

# ╔═╡ e05b8a92-f613-4c12-a276-69a0c3c88603


# ╔═╡ 5991946a-fa5e-484f-8dcf-d3bcd51e8f84


# ╔═╡ f09419a0-cf1e-4df6-bb7b-6e9b49ad4adc
function _unsafe_tail_cmp2(w, woffset, v, voffset, k, step)
	ans = true
	while k > 0
		while k < step
			step = step >> 1
		end
		if k < 16
			ans &= _unsafe_cmp(w, woffset, v, voffset, Val(k))
			return ans
		else
			ans &= _unsafe_cmp(w, woffset, v, voffset, Val(step))
		end
		woffset += step
		voffset += step
		k -= step
	end
	return ans
end

# ╔═╡ db03fecc-974f-495f-9921-262c066d8bf6
begin	
    function test_eq2(w::AbstractVector{T}, v::AbstractVector{S}) where {T,S}
        lv = length(v)
        lv ≠ length(w) && return false

		ans = true
		step = 128 ÷ max(sizeof(T), sizeof(S))
		offset = 0
        
        while lv - offset ≥ step
            ans &= _unsafe_cmp(w, offset, v, offset, Val(step))
			ans || return false
            offset += step
        end
		return _unsafe_tail_cmp1(w, offset, v, offset, lv-offset)
		# return _unsafe_tail_cmp2(w, offset, v, offset, lv-offset, step)
    end

    @assert test_eq2(w, w)
    @assert !test_eq2(w, v)
    @assert test_eq2(w[1:end-1], v[1:end-1])
    @assert !test_eq2(w, u)
end

# ╔═╡ 1870f24a-5858-426e-a815-8dc65a511eb9
let 
	b1 = @benchmark test_eq2($(w.letters), $(w.letters))
	b2 = @benchmark test_eq2($(w.letters), $(v.letters))
	b3 = @benchmark test_eq2($(w.letters), $(u.letters))
	@info typeof(w.letters) time(median(b1)) time(median(b2)) time(median(b3))
end

# ╔═╡ 13bf38eb-346a-4367-9d70-c4f9735282d3
let 
	b1 = @benchmark test_eq2($(w), $(w))
	b2 = @benchmark test_eq2($(w), $(v))
	b3 = @benchmark test_eq2($(w), $(u))
	@info typeof(w) time(median(b1)) time(median(b2)) time(median(b3))
end

# ╔═╡ be684620-15e3-433c-a7c4-2cd2395f0637
w8, v8, u8 = rand_words(T=UInt8, n=2^10-1)

# ╔═╡ 1cb4e09e-5c34-4ac1-a234-e0cdfd883bc8
let 
	b1 = @benchmark ==($(w8.letters), $(w8.letters))
	b2 = @benchmark ==($(w8.letters), $(v8.letters))
	b3 = @benchmark ==($(w8.letters), $(u8.letters))
	@info typeof(w8.letters) time(median(b1)) time(median(b2)) time(median(b3))
end

# ╔═╡ 4036aec3-0ba2-4a85-82be-49820f73a1a9
let 
	b1 = @benchmark test_eq2($(w8), $(w8))
	b2 = @benchmark test_eq2($(w8), $(v8))
	b3 = @benchmark test_eq2($(w8), $(u8))
	@info typeof(w8) time(median(b1)) time(median(b2)) time(median(b3))
end

# ╔═╡ fdbcd278-571c-4961-9f99-341b6723d128
let 
	b1 = @benchmark ==($(w8), $(w8))
	b2 = @benchmark ==($(w8), $(v8))
	b3 = @benchmark ==($(w8), $(u8))
	@info typeof(w8) time(median(b1)) time(median(b2)) time(median(b3))
end

# ╔═╡ 884f1dc7-1e8e-4ef3-8a38-22279d48c5ca


# ╔═╡ 631f6dbc-535b-41ab-afc4-1b11edcfff81


# ╔═╡ 56c60dcd-a8f3-4fb5-9663-21669a1188df
md"
> **Exercise**: Implement fast versions of `==`, `isprefix` and `issuffix` for `AbstractWords` based on `_unsafe_cmp`.
"

# ╔═╡ Cell order:
# ╠═9ee80f66-966e-11ed-0e70-3f12170afd56
# ╠═0e584a50-294a-4e47-8e24-5a44e2c808d9
# ╠═447a8b45-902f-41c9-a437-0e05471a23fc
# ╟─b194c438-6d84-4716-92f4-a8d4f0df08b4
# ╟─ed7f8cc2-87ad-40e8-94ea-486e88ffd27e
# ╠═e121c6db-2c30-416f-ae9a-2c9a00cf3c2b
# ╠═8e75bee5-c678-4079-90e4-7b9227c111d4
# ╠═dab2df3b-2c29-4c45-bba2-7f49cbf90c86
# ╠═d121e148-67b4-451c-b6fe-36c022c32fe3
# ╠═9c98ee04-2119-4701-af60-26adeec18fcb
# ╠═23f65e86-3921-498e-bd48-f14a00a59bf2
# ╟─db8a5fdb-2ad8-4434-b48c-2e4725eebfd6
# ╠═daf4527a-822d-4814-9fb7-9867b7527f63
# ╠═b8e606e5-896e-43e4-884b-fbd8752e3c49
# ╠═54341a70-9f31-4428-932c-a8b5b875c8b9
# ╠═ec44fc0e-71ce-49ef-bcd4-252b6d75557a
# ╠═cd8a8ce3-7d2c-46cf-a67d-b4cd9e23dfcd
# ╠═4ef2bd81-6e9f-44ab-8ceb-d0fa23b84c11
# ╠═93f7d635-c57f-4597-9aaf-243eddde0fb0
# ╠═79f1aa28-55fe-495c-ad9a-92e0de3ee5fb
# ╠═6d3b6ea0-ddcf-41a2-ac57-744ba46666f7
# ╠═14b236d7-f857-4444-ae00-fd1ee282e0c4
# ╟─22c1f332-242b-45ee-9766-894915c74b24
# ╠═0e032568-5529-4b80-8684-199a4bf50539
# ╠═34be6256-f893-4a25-a681-0a4343af3ac6
# ╠═48583577-5f41-48e5-99d9-02c078ce5ea5
# ╠═14e048bb-4701-4835-8cd2-2d33b9e9aab7
# ╠═d0d15551-ec3a-46ac-90bc-a7ae2953d04e
# ╠═d3a6ad01-a3bb-4cf4-88e5-cf3858c0c9f5
# ╟─fc92df01-080e-42b7-8755-2690cb06c8a1
# ╠═1012e239-ac85-4c12-aa28-1297aaa997f5
# ╠═5c10c2f0-047b-4ca3-8581-253139c98759
# ╠═22b69511-dd9b-4524-b2f4-5b2d69c5ba0a
# ╠═4d6b8d9a-9f54-4d29-aa18-5bccbbed879c
# ╠═57f9a27a-66ab-4399-9424-f10c875957d6
# ╠═a27dfa37-7c89-4d9b-8274-63b8c722cd60
# ╠═30b91a44-0716-4e54-a3de-731eb26cbab8
# ╠═396301be-f383-4595-b8cd-4cb881cf1118
# ╟─6387d6b1-238c-4fc4-9177-e0939d67185e
# ╠═8f23a9a0-8a4c-48aa-ae3a-d62c7bfc0e98
# ╠═19db41bd-da2f-4175-a3c9-464d5817f43e
# ╠═005502e2-5c9b-4b90-82eb-4061f68405d2
# ╠═03276f0f-54d6-4770-8658-ec1e6a3dd3cd
# ╠═3c253994-534c-46c2-a787-1c3ebe912567
# ╠═6abc65f2-0509-4ed4-8915-739dbf8d4e2e
# ╟─355d788b-b814-4c00-a0a0-9210864557a7
# ╠═3ec10512-4144-427a-b3c8-3c8223dc0aae
# ╠═6d7ab003-4828-4810-a206-ab5ddf8df764
# ╟─b881a1f3-c3ea-4d3b-8715-29d6f9fed19e
# ╠═f641e61b-4503-40f4-a2f3-7cce715b89db
# ╠═a73506da-0f37-48f6-b74e-2aa0a573b7ca
# ╟─3dec8941-e7af-45e5-a4c2-8527266037f9
# ╠═e1ebe24b-3b6b-4969-abd3-a04f7d0fd169
# ╠═ea5641ae-71bc-4c3f-94a4-a525597dadab
# ╠═cb354dd3-fdb1-4a38-8064-6859c4961c2d
# ╠═f5d15d6a-485f-4bef-95b8-b91b1858dbc9
# ╠═1bf0756f-d330-4fe1-b62d-6eb60d904534
# ╠═ceee9f7e-7f5b-4bc9-8c4b-950cf6769471
# ╠═e05b8a92-f613-4c12-a276-69a0c3c88603
# ╠═5991946a-fa5e-484f-8dcf-d3bcd51e8f84
# ╠═f09419a0-cf1e-4df6-bb7b-6e9b49ad4adc
# ╠═db03fecc-974f-495f-9921-262c066d8bf6
# ╠═1870f24a-5858-426e-a815-8dc65a511eb9
# ╠═13bf38eb-346a-4367-9d70-c4f9735282d3
# ╠═be684620-15e3-433c-a7c4-2cd2395f0637
# ╠═1cb4e09e-5c34-4ac1-a234-e0cdfd883bc8
# ╠═4036aec3-0ba2-4a85-82be-49820f73a1a9
# ╠═fdbcd278-571c-4961-9f99-341b6723d128
# ╠═884f1dc7-1e8e-4ef3-8a38-22279d48c5ca
# ╠═631f6dbc-535b-41ab-afc4-1b11edcfff81
# ╟─56c60dcd-a8f3-4fb5-9663-21669a1188df
