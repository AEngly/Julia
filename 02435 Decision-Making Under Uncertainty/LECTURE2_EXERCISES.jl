
include("./LECTURE2_CODE_FILES/production_model.jl")


println("\n\n-------------------------------------------------------------------------------------------- ")
println("\n\n  Task 1. Deterministic mixed-integer program (assume the demand is known)")
println("\n\n-------------------------------------------------------------------------------------------- ")

# Pick an arbitrary scenario
SCEN = 2

@printf("Running scenario %0.0f.\n", SCEN)

using JuMP
using Gurobi
using Printf

modelAmericanProducer = Model(Gurobi.Optimizer)

#Definition of variables with lower bound 0
@variable(modelAmericanProducer, xP[1:length(P), 1:length(M), 1:length(S)] >= 0)
@variable(modelAmericanProducer, xI[1:length(P), 1:length(S)] >= 0)
@variable(modelAmericanProducer, xE[1:length(P), 1:length(S)] >= 0)
@variable(modelAmericanProducer, y[1:length(M)] >= 0, Int)

# Definition of objective function
@objective(modelAmericanProducer, Min, sum(investment_cost[m]*y[m] for m=1:length(M)) + sum(production_cost[p]*sum(xP[p,m,SCEN] for m=1:length(M)) + import_cost[p]*xI[p,SCEN] - revenue[p]*(xI[p,SCEN] - xE[p,SCEN] + sum(xP[p,m,SCEN] for m=1:length(M))) - revenue_low[p]*xE[p,SCEN] for p=1:length(P)))

# Constraints on machines
@constraint(modelAmericanProducer, sum(y[m] for m=1:length(M)) <= maximum_machines)

# Budget constraints
@constraint(modelAmericanProducer, sum(y[m]*investment_cost[m] for m=1:length(M)) <= maximum_budget)

# Demand need to be fulfilled
@constraint(modelAmericanProducer, demandConstraint[p=1:length(P)], sum(xP[p,m,SCEN] for m=1:length(M)) + xI[p,SCEN] - xE[p,SCEN] <= demand[p][1])

# Production time limit
@constraint(modelAmericanProducer, productionConstraints[m=1:length(M)], sum(production_time[p]*xP[p,m,SCEN] for p=1:length(P)) <= y[m]*working_time[m])

# Make sure products and machine are compatible
bigM = maximum([working_time[m]/production_time[p] for m=1:length(M), p=1:length(P)])
@constraint(modelAmericanProducer, compatibleConstraints[p=1:length(P), m=1:length(M)], xP[p,m,SCEN] <= machine_compatibility[p][m] * bigM)

optimize!(modelAmericanProducer)

if termination_status(modelAmericanProducer) == MOI.OPTIMAL

    println("\n\n----------------------------------------------------------- ")
    println("\n\nStatus: Optimal solution found")

    println("\nDecision variables:\n")
    for p in 1:length(P)
        for m in 1:length(M)
            @printf("xP[%0.0f, %0.0f]: %0.03f\n", p, m, value.(xP[p,m,SCEN]))
        end
    end

    println("\n")
    for p in 1:length(P)
            @printf("xI[%0.0f]: %0.03f\n", p, value.(xI[p,SCEN]))
    end

    println("\n")
    for p in 1:length(P)
        @printf("xE[%0.0f]: %0.03f\n", p, value.(xE[p,SCEN]))
    end

    println("\n")
    for m in 1:length(M)
        @printf("y[%0.0f]: %0.0f\n", m, value.(y[m]))
    end

    @printf "\nObjective value: %0.3f\n\n" -objective_value(modelAmericanProducer)

else
    error("No solution.")
end

println("\n\n-------------------------------------------------------------------------------------------- ")
println("\n\n  Task 2. First- and second stage")
println("\n\n-------------------------------------------------------------------------------------------- ")

println("\nIn the first stage, we decide on the number of machines (i.e., y[m])")
println("\nIn the second stage, we decide on production (i.e., xP[p,m,s], xI[p,s], xE[p,s])\n")

println("\n\n-------------------------------------------------------------------------------------------- ")
println("\n\n  Task 3. Reformulate the above described planning problem as a two-stage stochastic program")
println("\n\n-------------------------------------------------------------------------------------------- ")

modelAmericanProducer = Model(Gurobi.Optimizer)

#Definition of variables with lower bound 0
@variable(modelAmericanProducer, xP[1:length(P), 1:length(M), 1:length(S)] >= 0)
@variable(modelAmericanProducer, xI[1:length(P), 1:length(S)] >= 0)
@variable(modelAmericanProducer, xE[1:length(P), 1:length(S)] >= 0)
@variable(modelAmericanProducer, y[1:length(M)] >= 0, Int)

#Maximize profit
@objective(modelAmericanProducer, Max, sum(-1*investment_cost[m]*y[m] for m in M)
            + sum(probabilities[s]*sum((sum(xP[p,m,s] for m in M) - xE[p,s] + xI[p,s])*revenue[p] for p in P) for s in S)
            - sum(probabilities[s]*production_cost[p]*sum(xP[p,m,s] for m in M) for p in P for s in S)
            - sum(probabilities[s]*import_cost[p]*xI[p,s] for p in P for s in S)
            + sum(probabilities[s]*revenue_low[p]*xE[p,s] for p in P for s in S)
    )

# Constraints on machines
@constraint(modelAmericanProducer, sum(y[m] for m=1:length(M)) <= maximum_machines)

# Budget constraints
@constraint(modelAmericanProducer, sum(y[m]*investment_cost[m] for m=1:length(M)) <= maximum_budget)

# Demand need to be fulfilled
@constraint(modelAmericanProducer, demandConstraints[p=1:length(P), s=1:length(S)], sum(xP[p,m,s] for m=1:length(M)) + xI[p,s] - xE[p,s] == demand[p][s])

# Production time limit
@constraint(modelAmericanProducer, productionConstraints[m=1:length(M), s=1:length(S)], sum(production_time[p]*xP[p,m,s] for p=1:length(P)) <= y[m]*working_time[m])

# Make sure products and machine are compatible
@constraint(modelAmericanProducer, compatibleConstraints[p=1:length(P), m=1:length(M), s=1:length(S)], xP[p,m,s] <= machine_compatibility[p][m]*(working_time[m]/production_time[p])*maximum_machines)

optimize!(modelAmericanProducer)

if termination_status(modelAmericanProducer) == MOI.OPTIMAL

    println("\n\n------------------------------------------------------------------------------------------ ")
    println("\n\nStatus: Optimal solution found for two-stage stochastic programming problem")

    println("\nDecision variables:\n")

    for m in 1:length(M)
        @printf("y[%0.0f]: %0.0f\n", m, value.(y[m]))
    end

    @printf "\nObjective value: %0.0f\n\n" objective_value(modelAmericanProducer)

else
    error("No solution.")
end