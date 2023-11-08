using Random
using Printf

function str_from_vec(v,c)
    #alph = "O|"
    #alph = "abcdefghijklmnopqrstuvwxyz_"
    alph = "ABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    join(map(i -> alph[i:i]*c, v))
end

function printkey(k)
    n = size(k)[begin]
	for i in 1:n print(str_from_vec( k[i,:]," " ),"\n") end
	print("\n")
end

function vec_from_str(s)
    map(i -> findfirst(isequal(i),alph),collect(s))
end

function rgb(r,g,b)
    "\e[38;2;$(r);$(g);$(b)m"
end

function red()
    rgb(255,0,0)
end

function yellow()
    rgb(255,255,0)
end

function white()
    rgb(255,255,255)
end

function gray(h)
    rgb(h,h,h)
end



function key(n)
    copy(transpose(reduce(hcat, [Random.randperm(n) for i in 1:n])))
end

function inv(f)
    map(i -> findfirst(isequal(i),f),collect(1:length(f)))
end 

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
    n = size(q)[begin]
    k = copy(q)
    c = Int64[]
    s = zeros(Int64,n)
    for i in eachindex(p)
        f = get_f(k)
        push!(c,f[p[i]] )
        f = circshift(f,p[i])
        push!(F,f)
        for j in 1:n k[j,:] = circshift(k[j,:], f[j]) end
    end
    c
end

function decode(c,q)
    n = size(q)[begin]
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

function encrypt(p, q, F)
    n = size(q)[begin]
    for i in 1:n
        k = spin(q,i)
        p = encode(p,k,F)
        p = reverse(p)
    end
    p
end

function decrypt(p, q)
    n = size(q)[begin]
    for i in 1:n
        k = spin(q,n + 1 - i)
        p = reverse(p)
        p = decode(p,k)
    end
    p
end

function demo()
    n = 27
    k = key(n)
	print(white(),"k =\n",gray(100))
    printkey(k)
    for i in 1:20
        F = Set()
    	p = Random.randperm(n)
    	c  = encrypt(p,k,F)
    	d  = decrypt(c,k)
    	print(white(),"f( ", red(), str_from_vec(p,""), white()," ) = ")
    	print(yellow(),str_from_vec(c,""))
        print(white(),@sprintf("  %d/%d\n", length(F), n*length(p)))
    	print(white())
    	if p != d @printf "ERROR" end
    end
end


