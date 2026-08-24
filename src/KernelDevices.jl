#=
 * @ author: chenyubao <chenyu.bao@outlook.com>
 * @ date: 2026-08-21 10:17:03
 * @ license: MIT
 =#

module KernelDevices

export @syncd
export Device
export AbstractKernelDevice
export KernelDevice
export intType
export floatType
export deviceID

using KernelAbstractions

macro syncd(b, expr)
    return esc(:($expr;
    KernelAbstractions.synchronize($b)))
end

@inline function Device() end

# * ===== AbstractKernelDevice ===== * #

abstract type AbstractKernelDevice{Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend} end

@inline function intType(::AbstractKernelDevice{Ti, Tf, Tb}) where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    return Ti
end

@inline function floatType(::AbstractKernelDevice{Ti, Tf, Tb}) where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    return Tf
end

@inline function deviceID(kd::AbstractKernelDevice{Ti, Tf, Tb}) where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    return getfield(kd, :id_)
end

@inline function KernelAbstractions.synchronize(::AbstractKernelDevice{Ti, Tf, Tb}) where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    return KernelAbstractions.synchronize(Tb())
end

@inline function KernelAbstractions.get_backend(::AbstractKernelDevice{Ti, Tf, Tb}) where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    return Tb()
end

@inline function KernelAbstractions.device!(kd::AbstractKernelDevice{Ti, Tf, Tb}) where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    return KernelAbstractions.device!(Tb(), deviceID(kd))
end

@inline function Base.zeros(kd::AbstractKernelDevice{Ti, Tf, Tb}, T::Real, dims::Int...) where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    KernelAbstractions.device!(kd)
    return KernelAbstractions.zeros(Tb(), T, dims...)
end

@inline function (kd::AbstractKernelDevice{Ti, Tf, Tb})(x::Integer)::Ti where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    return convert(Ti, x)
end

@inline function (kd::AbstractKernelDevice{Ti, Tf, Tb})(x::AbstractFloat)::Tf where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    return convert(Tf, x)
end

@inline function (kd::AbstractKernelDevice{Ti, Tf, Tb})(xs::AbstractArray{<:Integer}) where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    if KernelAbstractions.get_backend(kd) === get_backend(xs)
        if eltype(xs) === Ti
            return deepcopy(xs)
        else
            Ti.(xs)
        end
    else
        ys = KernelAbstractions.zeros(kd, Ti, size(xs)...)
        Base.copyto!(ys, xs)
    end
end

@inline function (kd::AbstractKernelDevice{Ti, Tf, Tb})(xs::AbstractArray{<:AbstractFloat}) where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    if KernelAbstractions.get_backend(kd) === get_backend(xs)
        if eltype(xs) === Tf
            return deepcopy(xs)
        else
            Tf.(xs)
        end
    else
        ys = KernelAbstractions.zeros(kd, Tf, size(xs)...)
        Base.copyto!(ys, xs)
    end
end

# * ===== KernelDevice ===== * #

struct KernelDevice{Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend} <: AbstractKernelDevice{Ti, Tf, Tb}
    id_::Int
end

@inline function KernelDevice{Ti, Tf, Tb}(;id::Integer = 1) where {Ti<:Integer, Tf<:AbstractFloat, Tb<:Backend}
    return KernelDevice{Ti, Tf, Tb}(Int(id))
end

@inline function KernelDevice{Ti, Tf}(;id::Integer = 1) where {Ti<:Integer, Tf<:AbstractFloat}
    return KernelDevice{Ti, Tf, KernelAbstractions.CPU}(Int(id))
end

end # module KernelDevices
