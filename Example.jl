# EXERICSE 1

# Importing packages need to solve MIP's
using JuMP, GLPK

# Define the model
m = Model(GLPK.Optimizer)

# We define the variables in the model
@variable(m, x <= 10)
@variable(m, y >= 0)
@variable(m, u >= 0) # Multiplier
@variable(m, b1, Bin)
@variable(m, b2, Bin)

# Defining the objective function
@objective(m, Min, x - y)

# Then we implement the individual constraints

M = 10000

# Incompatible projects
@constraint(m, 2*y + 4*u == 0)
@constraint(m, 2*y + 4*u <= M * b1)
@constraint(m, y <= M * (1 - b1))

@constraint(m, 0 <= x - 5 - 4 * y)
@constraint(m, x - 5 - 4 * y <= M * b2)
@constraint(m, u <= M * (1- b2))

# Optimize
JuMP.optimize!(m)

test = 5;

# Display results
println("Objective Value: ", objective_value(m), "\nVariables: ", "x = ", value.(x), "; y = ", value.(y), "; u = ", value.(u), "; b1 = ", value.(b1), "; b2 = ", value.(b2))


