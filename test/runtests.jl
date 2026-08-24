#=
 * @ author: chenyubao <chenyu.bao@outlook.com>
 * @ date: 2026-08-24 17:40:24
 * @ license: MIT
 =#

using Test

using KernelDevices
using KernelAbstractions

@testset "KernelDevices" begin
    kd1 = KernelDevice{Int32, Float32, CPU}()
    kd2 = KernelDevice{Int64, Float16, CPU}()
    @test get_backend(kd1) == CPU()
    @test get_backend(kd2) == CPU()
    KernelAbstractions.synchronize(kd1)
    KernelAbstractions.synchronize(kd2)
    @syncd kd1 1+1
    @syncd kd2 1+1
    @test kd1(1) isa Int32
    @test kd2(1) isa Int64
    @test kd1(1.0) isa Float32
    @test kd2(1.0f0) isa Float16
    @test kd1(zeros(Int64, 2, 2)) isa Matrix{Int32}
    @test kd2(zeros(Int32, 2, 2)) isa Matrix{Int64}
    @test kd1(zeros(Float64, 2, 2)) isa Matrix{Float32}
    @test kd2(zeros(Float32, 2, 2)) isa Matrix{Float16}
end