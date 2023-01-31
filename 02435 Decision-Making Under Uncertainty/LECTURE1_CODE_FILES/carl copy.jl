#Import packages
using JuMP
using Gurobi
using Printf

#Declare model with Gurobi solver
model_carl = Model(Gurobi.Optimizer)

#Declare INTEGER variables with lower bound 0 and upper bound
@variable(model_carl, 0<=X<=50, Int)
@variable(model_carl, 0<=Y<=200, Int)

#Declare maximization of profits objective function
@objective(model_carl, Max, 250X + 45Y)
#Constraint on available acres
@constraint(model_carl, Acres, X + 0.2Y <= 72)
#Constraint on maximum working hours
@constraint(model_carl, WorkingHours, 150X + 25Y <= 10000)

#Optimize model
optimize!(model_carl)

#Check if optimal solution was found
if termination_status(model_carl) == MOI.OPTIMAL
    println("Optimal solution found")

    #Print out variable values and objective value
    println("Variable values:")
    @printf "X: %0.3f\n" value.(X)
    @printf "Y: %0.3f\n" value.(Y)
else
    error("No solution.")
end
