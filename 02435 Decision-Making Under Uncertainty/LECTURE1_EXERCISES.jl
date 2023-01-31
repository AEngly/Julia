# SETUP

import Pkg

# For the specific JuMP version, we need to uninstall the package Complementary.
Pkg.rm("Complementarity")

# Then we can add the specific version (newest version is v1.6.0).
Pkg.add(name="JuMP", version="0.23.2")

# Then we can add Gurobi.


using JuMP, GLPK

# EXERCISE 1

profit = [5, 3, 2, 7, 4]
weight = [2, 8, 4, 2, 5]
capacity = 10

amodel = Model(GLPK.Optimizer)

@variable(model, x[1:5], Bin)

@objective(model, Max, sum(profit[i]*x[i] for i=1:5))
@constraint(model, sum(weight[i]*x[i] for i=1:5) <= capacity)

JuMP.optimize!(model)

println("Objective is: ", JuMP.objective_value(model))
println("Solution is: ")
for i=1:5
    print(JuMP.value(x[i]), " ")
end
