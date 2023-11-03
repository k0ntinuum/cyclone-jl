using Random
using Printf
using LinearAlgebra


key(n) = copy(transpose(reduce(hcat, [Random.randperm(n) for i in 1:n])))

str_from_vec(v)  = join(map(i -> alph[i:i], v))

function printkey(k)
	for i in 1:n print(join(map(i -> alph[i:i]*" ", k[i,:])),"\n") end
	print("\n")
end

str_from_vec(v,c)  = join(map(i -> alph[i+1:i+1]*c, v))

vec_from_str(s) = map(i -> findfirst(isequal(i),alph),collect(s))

rgb(r,g,b) =  "\e[38;2;$(r);$(g);$(b)m"

red() = rgb(255,0,0);
yellow() = rgb(255,255,0);
white() = rgb(255,255,255);
gray(h) = rgb(h,h,h)

inv(f) = map(i -> findfirst(isequal(i),f),collect(1:length(f)))

function get_f(k)
    f = Int64[]
    n = size(k)[begin]
    for i in 1:n
        x = i
        for j in 1:n x = k[j,x ] end
        push!(f, x)
    end
    f
end


function encode(p,q,F)
    k = copy(q)
    c = Int64[]
    s = zeros(Int64,n)
    for i in eachindex(p)
        f = get_f(k)
        push!(c,f[p[i]] )
        #c[i] = f[p[i]]
        f = circshift(f,p[i])
        push!(F,f)
        for j in 1:n k[j,:] = circshift(k[j,:], f[j]) end
    end
    c
end

function decode(c,q)
    k = copy(q)
    p = Int64[]
    for i in eachindex(c)
        f = get_f(k)
        g = inv(f)
        push!(p,g[c[i]])
        f = circshift(f,p[i])
        for j in 1:n k[j,:] = circshift(k[j,:], f[j]) end
    end
    p
end
function spin(k,r)
    n = size(k)[begin]
    s = zeros(Symbol,n)
    for i in 1:r
        f = getf(k,s)
        for j in 1:n s[j] = (f[j]+s[j])%n end
    end
    K = zeros(Symbol,(n,n))
    for j in 1:n
            K[j,:] = circshift(k[j,:],s[j])
    end
    K
end

function spin(q,r)
    k = copy(q)
    for i in 1:r
        f = get_f(k)
        for j in 1:size(k)[begin]
            k[j,:] = circshift(k[j,:],f[j])
        end
    end
    k
end

function encrypt(p, q, r, F)
    for i in 1:r
        k = spin(q,i)
        p = encode(p,k,F)
        p = reverse(p)
    end
    p
end

function decrypt(p, q, r)
    for i in 1:r
        k = spin(q,r + 1 - i)
        p = reverse(p)
        p = decode(p,k)
    end
    p
end
function demo()
	print(white(),"k =\n",gray(100))
    printkey(k)
    for i in 1:20
        F = Set()
    	p = Random.randperm(n)
    	c  = encrypt(p,k,r,F)
    	d  = decrypt(c,k,r)
    	print(white(),"f( ", red(), str_from_vec(p), white()," ) = ")
    	print(yellow(),str_from_vec(c))
        print(white(),@sprintf("  %d/%d\n", length(F), r*length(p)))
    	print(white())
    	if p != d @printf "ERROR" end
    end
end

alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ_"
n = length(alph)
k = key(n)
r = 5
