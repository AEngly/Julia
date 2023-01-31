using JuMP
using Gurobi
using Printf

modelPepita = Model(Gurobi.Optimizer)

@variable(modelPepita, 0<=y1)
@variable(modelPepita, 0<=y2)

@objective(modelPepita, Max, 30y1 + 18y2)
@constraint(modelPepita, NaturalOil1, 2y1 + y2 <= 70)
@constraint(modelPepita, NaturalOil2, y1 + 3y2 <= 35)
@constraint(modelPepita, NaturalOil3, 5y1 + y2 <= 84)

optimize!(modelPepita)


if termination_status(modelPepita) == MOI.OPTIMAL
    println("Optimal solution found")

    println("Variable values:")
    @printf "y1: %0.3f\n" value.(y1)
    @printf "y2: %0.3f\n" value.(y2)
    @printf "\nObjective value: %0.3f\n" objective_value(modelPepita)
else
    error("No solution.")
end
