# --------------- SETUP ---------------
#ENV["GUROBI_HOME"] = "/Library/gurobi903/mac64/"
import Pkg

# For the specific JuMP version, we need to uninstall the package Complementary.
# Pkg.rm("Complementarity")

# Then we can add the specific version (newest version is v1.6.0).
# Pkg.add(name="JuMP", version="0.23.2")

# Then we can add Gurobi.
# Pkg.add("Gurobi")
# Pkg.build("Gurobi")
# Load dependencies
using JuMP
using Gurobi
using Printf

println("\n\n------------- EXERCISE 1: Flower Nusery -------------\n\n")

println("\n\n------------- TASK 1 -------------\n\n")

# --------------- Task 1 ---------------

price = [25, 30, 20] # EUR/m2
workingHours = [2.5, 5, 2] # h/m2
water = [90, 100, 120] # l/m2
fertilizer = [0.3, 0.5, 0.2] # kg/m2

n_flowers = length(price)

maxSpace = 5000
maxWorkingHours = 20000
maxWater = 700000
maxFertilizer = 2500

maximizeRevenue = Model(Gurobi.Optimizer)

# --------------- Variables ---------------

# Decision variables
@variable(maximizeRevenue, flowers[1:n_flowers] >= 0)

# --------------- Objective ---------------

@objective(maximizeRevenue, Max, sum(price[i] * flowers[i] for i=1:n_flowers))

# --------------- Constraints ---------------

@constraint(maximizeRevenue, maxSpaceConstraint, sum(flowers[i] for i=1:n_flowers) <= maxSpace)
@constraint(maximizeRevenue, maxWorkingConstraint, sum(workingHours[i] * flowers[i] for i=1:n_flowers) <= maxWorkingHours)
@constraint(maximizeRevenue, maxWaterConstraint, sum(water[i] * flowers[i] for i=1:n_flowers) <= maxWater)
@constraint(maximizeRevenue, maxFertilizerConstraint, sum(fertilizer[i] * flowers[i] for i=1:n_flowers) <= maxFertilizer)

optimize!(maximizeRevenue)


if termination_status(maximizeRevenue) == MOI.OPTIMAL
    println("Optimal solution found")

    println("Variable values:\n")
    @printf "Roses: %0.3f\n" value.(flowers[1])
    @printf "Dahlia: %0.3f\n" value.(flowers[2])
    @printf "Garden pinks: %0.3f\n" value.(flowers[3])
    @printf "\nObjective value: %0.3f\n" objective_value(maximizeRevenue)
else
    error("No solution.")
end

println("\n\n------------- TASK 2 -------------\n\n")

# --------------- Task 2 ---------------

price = [25, 30, 20] # EUR/m2
workingHours = [2.5, 5, 2] # h/m2
water = [90, 100, 120] # l/m2
fertilizer = [0.3, 0.5, 0.2] # kg/m2
startupExpenses = [20000, 0, 0] # One time expense
startupArea = [700, 0, 0] # One time expense

n_flowers = length(price)

maxSpace = 5000
maxWorkingHours = 20000
maxWater = 700000
maxFertilizer = 2500

maximizeRevenue = Model(Gurobi.Optimizer)

# --------------- Variables ---------------

# Decision variables
@variable(maximizeRevenue, flowers[1:n_flowers] >= 0)
@variable(maximizeRevenue, start[1:n_flowers], Bin)

# --------------- Objective ---------------

@objective(maximizeRevenue, Max, sum(price[i] * flowers[i] - start[i] * startupExpenses[i] for i=1:n_flowers))

# --------------- Constraints ---------------

@constraint(maximizeRevenue, maxSpaceConstraint, sum(flowers[i] for i=1:n_flowers) <= maxSpace)
@constraint(maximizeRevenue, maxRoses, flowers[1] <= startupArea[1]*start[1])
@constraint(maximizeRevenue, maxWorkingConstraint, sum(workingHours[i] * flowers[i] for i=1:n_flowers) <= maxWorkingHours)
@constraint(maximizeRevenue, maxWaterConstraint, sum(water[i] * flowers[i] for i=1:n_flowers) <= maxWater)
@constraint(maximizeRevenue, maxFertilizerConstraint, sum(fertilizer[i] * flowers[i] for i=1:n_flowers) <= maxFertilizer)

optimize!(maximizeRevenue)


if termination_status(maximizeRevenue) == MOI.OPTIMAL
    println("Optimal solution found")

    println("Variable values:\n")
    @printf "Roses: %0.3f\n" value.(flowers[1])
    @printf "Dahlia: %0.3f\n" value.(flowers[2])
    @printf "Garden pinks: %0.3f\n" value.(flowers[3])
    @printf "\nObjective value: %0.3f\n" objective_value(maximizeRevenue)
else
    error("No solution.")
end

println("\n\n------------- TASK 3 -------------\n\n")

# --------------- Task 2 ---------------

price = [25, 30, 20] # EUR/m2
workingHours = [2.5, 5, 2] # h/m2
water = [90, 100, 120] # l/m2
fertilizer = [0.3, 0.5, 0.2] # kg/m2
startupExpenses = [20000, 0, 0] # One time expense
startupArea = [700, 0, 0] # One time expense

n_flowers = length(price)

maxSpace = 5000
maxWorkingHours = 20000
maxWater = 700000
maxFertilizer = 2500

maximizeRevenue = Model(Gurobi.Optimizer)

# --------------- Variables ---------------

# Decision variables
@variable(maximizeRevenue, flowers[1:n_flowers] >= 0)
@variable(maximizeRevenue, start[1:n_flowers], Bin)

# --------------- Objective ---------------

@objective(maximizeRevenue, Max, sum(price[i] * flowers[i] - start[i] * startupExpenses[i] for i=1:n_flowers))

# --------------- Constraints ---------------

@constraint(maximizeRevenue, maxSpaceConstraint, sum(flowers[i] for i=1:n_flowers) <= maxSpace)
@constraint(maximizeRevenue, maxRoses1, flowers[1] <= startupArea[1]*start[1])
@constraint(maximizeRevenue, maxRoses2, 200*start[1] <= flowers[1])
@constraint(maximizeRevenue, maxWorkingConstraint, sum(workingHours[i] * flowers[i] for i=1:n_flowers) <= maxWorkingHours)
@constraint(maximizeRevenue, maxWaterConstraint, sum(water[i] * flowers[i] for i=1:n_flowers) <= maxWater)
@constraint(maximizeRevenue, maxFertilizerConstraint, sum(fertilizer[i] * flowers[i] for i=1:n_flowers) <= maxFertilizer)

optimize!(maximizeRevenue)

if termination_status(maximizeRevenue) == MOI.OPTIMAL
    println("Optimal solution found")

    println("Variable values:\n")
    @printf "Roses: %0.3f\n" value.(flowers[1])
    @printf "Dahlia: %0.3f\n" value.(flowers[2])
    @printf "Garden pinks: %0.3f\n" value.(flowers[3])
    @printf "\nObjective value: %0.3f\n" objective_value(maximizeRevenue)
else
    error("No solution.")
end

println("\n\n------------- TASK 4 -------------\n\n")

# --------------- Task 2 ---------------

price = [25, 30, 20] # EUR/m2
workingHours = [2.5, 5, 2] # h/m2
water = [90, 100, 120] # l/m2
fertilizer = [0.3, 0.5, 0.2] # kg/m2
startupExpenses = [20000, 0, 0] # One time expense
startupArea = [700, 0, 0] # One time expense

n_flowers = length(price)

maxSpace = 5000
maxWorkingHours = 20000
maxWater = 700000
maxFertilizer = 2500

maximizeRevenue = Model(Gurobi.Optimizer)

# --------------- Variables ---------------

# Decision variables
@variable(maximizeRevenue, flowers[1:n_flowers] >= 0)
@variable(maximizeRevenue, start[1:n_flowers], Bin)

# --------------- Objective ---------------

@objective(maximizeRevenue, Max, sum(price[i] * flowers[i] - start[i] * startupExpenses[i] for i=1:n_flowers))

# --------------- Constraints ---------------

@constraint(maximizeRevenue, maxSpaceConstraint, sum(flowers[i] for i=1:n_flowers) <= maxSpace)
@constraint(maximizeRevenue, maxRoses1, flowers[1] <= startupArea[1]*start[1])
@constraint(maximizeRevenue, maxRoses2, 200*start[1] <= flowers[1])
@constraint(maximizeRevenue, maxDahlia, flowers[2] <= maxSpace - startupArea[1]*start[1])
@constraint(maximizeRevenue, maxWorkingConstraint, sum(workingHours[i] * flowers[i] for i=1:n_flowers) <= maxWorkingHours)
@constraint(maximizeRevenue, maxWaterConstraint, sum(water[i] * flowers[i] for i=1:n_flowers) <= maxWater)
@constraint(maximizeRevenue, maxFertilizerConstraint, sum(fertilizer[i] * flowers[i] for i=1:n_flowers) <= maxFertilizer)

optimize!(maximizeRevenue)

if termination_status(maximizeRevenue) == MOI.OPTIMAL
    println("Optimal solution found")

    println("Variable values:\n")
    @printf "Roses: %0.3f\n" value.(flowers[1])
    @printf "Dahlia: %0.3f\n" value.(flowers[2])
    @printf "Garden pinks: %0.3f\n" value.(flowers[3])
    @printf "\nObjective value: %0.3f\n" objective_value(maximizeRevenue)
else
    error("No solution.")
end

println("\n\n------------- EXERCISE 2: Primal-dual-transformation -------------\n\n")

# At first, we find the solution to the primal LP.

cost = [-5 4 -3] # EUR/m2

A = [2 -3 -1;
     -4 1 -2;
     -3 4 2;
     6 -5 1]

b = [5; -11; 8; 1]

minimizeCostPrimal = Model(Gurobi.Optimizer)

# --------------- Variables ---------------

# Decision variables
@variable(minimizeCostPrimal, x[1:3])
@constraint(minimizeCostPrimal, x[1] >= 0)
@constraint(minimizeCostPrimal, x[2] >= 0)

# --------------- Objective ---------------

@objective(minimizeCostPrimal, Min, sum(x[i]*cost[i] for i=1:3))

# --------------- Constraints ---------------

@constraint(minimizeCostPrimal, inequalityConstraint[i=1:3], sum(A[i,j]*x[j] for j=1:3) <= b[i])
@constraint(minimizeCostPrimal, equalityConstraint, sum(A[4,j]*x[j] for j=1:3) == b[4])


optimize!(minimizeCostPrimal)

println("\n\n------------- PRIMAL -------------\n")

if termination_status(minimizeCostPrimal) == MOI.OPTIMAL
    println("Optimal solution found\n")

    println("Variable values:\n")
    for i in 1:length(x)
        @printf "x[%0.0f]: %0.3f\n" i value.(x[i])
    end
    @printf "\nObjective value: %0.3f\n" objective_value(minimizeCost)
else
    error("No solution.")
end


# ----- DUAL (does not work currently) -------

maximizeCostDual = Model(Gurobi.Optimizer)

# --------------- Variables ---------------

# Decision variables
@variable(maximizeCostDual, y[1:4] >= 0)

# --------------- Objective ---------------

@objective(maximizeCostDual, Max, sum(y[i]*b[i] for i=1:4))

# --------------- Constraints ---------------

AT = transpose(A)
@constraint(maximizeCostDual, inequalityConstraint[i=1:2], sum(AT[i,j]*y[j] for j=1:4) >= cost[i])
@constraint(maximizeCostDual, equalityConstraint, sum(AT[3,j]*y[j] for j=1:4) == cost[3])


optimize!(maximizeCostDual)

println("\n\n------------- DUAL -------------\n")

if termination_status(maximizeCostDual) == MOI.OPTIMAL
    println("Optimal solution found\n")

    println("Variable values:\n")
    for i in 1:length(y)
        @printf "y[%0.0f]: %0.3f\n" i value.(x[i])
    end
    @printf "\nObjective value: %0.3f\n" objective_value(maximizeCostDual)
else
    error("No solution.")
end

# This command can be used to produce the needed Latex code.
# latex_formulation(minimizeCost)