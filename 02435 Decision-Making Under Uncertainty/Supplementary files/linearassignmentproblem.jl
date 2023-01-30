## Packages needed for solving MIPs

using JuMP
using GLPK

mo = Model(GLPK.Optimizer) #Setting up the model

#Solved as a binary problem
@variable(mo,x[1:6,1:6], Bin)
# number of people and jobs
n = 6

# defining the cost matrix of the problem
c = [1 2 3 4 5 6;
4 2 1 4 5 6;
9 8 7 6 5 4;
1 3 6 4 1 2;
8 6 4 2 1 1;
2 3 4 5 6 3]

# Defining the objective function - minimizing overall cost of the solution
@objective(mo, Min, sum(c[i, j] * x[i,j] for i = 1:n for j = 1:n))

# Defining the constraints
# First constraint: for each person select exactly one job
@constraint(mo, [i = 1:n], sum(x[i,j] for j = 1:n) == 1)
# Second constraint: for each job select exactly one person
@constraint(mo, [j = 1:n], sum(x[i,j] for i = 1:n) == 1)

optimize!(mo)                   #Solving the model

println("Objective value = ", objective_value(mo)) ## Printing the solution

println("X = ")
for i in 1:n
    for j in 1:n
        print(value(x[i,j]) , " ")
    end
    println()
end

println("Solver status: ", termination_status(mo))
println("Solution status: ", primal_status(mo))
