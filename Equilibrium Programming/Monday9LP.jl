#using Pkg
#Pkg.add("JuMP")
#Pkg.add("GLPK")

## Packages needed for solving MIPs
using Pkg, JuMP, Gurobi, Ipopt, Printf #Complementarity
using LinearAlgebra

U = collect(1:1)
L = collect(2:3)

# ------------- MODEL 1: Player 1 as market leader, players 2 and 3 as followers (MPEC) -------------

model = Model(Gurobi.Optimizer)
set_optimizer_attribute(model, "NonConvex", 2)
#model = Model(Ipopt.Optimizer)

# Profits

function p(x)
    return alpha - beta*sum(x[i] for i in union(L,U))
end

function profit(x, i)
    return c[i]*x[i] - x[i]*p(x)
end

function SW(x)
    return p(x)*sum(x[i] for i in union(U,L)) + 1/2 * (alpha - p(x)) * sum(x[i] for i in union(U,L)) - sum(c[i]*x[i] for i in union(U,L))
end

# Parameters (see slide 14 from topic 3)
alpha = 10
beta = 1

gamma = zeros(2)
gamma[1] = 1
gamma[2] = 2

X_max = zeros(3)
X_max[1] = 3
X_max[2] = 4
X_max[3] = 2

c = zeros(3)
c[1] = 3
c[2] = 4
c[3] = 5

# Definition of Optimization Variables
@variable(model, x[union(U, L)] >= 0)

# -------- UPPER-LEVEL ----------

# Definition of Objective
@objective(model, Min, c[1]*x[1] - x[1]*(alpha - beta*sum(x[i] for i in union(L,U))))
@constraint(model, X_max[1] - x[1] >= 0)

# -------- LOWER-LEVEL ----------

#Introduce big-M
@variable(model, y1[L], Bin)
@variable(model, y2[L], Bin)
M = 1e1

# Define dual variables
@variable(model, u_max[L] >= 0)
@variable(model, lambda[L] >= 0)

# Definition of Gradient of Lagrangian (wrt. x[i])
@constraint(model, [i in L], c[i] + beta*x[i] - (alpha - beta*sum(x[i] for i in union(L,U))) + u_max[i] - lambda[i] == 0)
@constraint(model, [i in L], X_max[i] - x[i] >= 0)

# Definition of Complementary Slackness (either max out production or dual variables is 0)
@constraint(model, [i in L], u_max[i] <= M*y1[i])
@constraint(model, [i in L], (X_max[i] - x[i]) <= M*(1-y1[i]))

@constraint(model, [i in L], lambda[i] <= M*y2[i])
@constraint(model, [i in L], x[i] <= M*(1-y2[i]))

optimize!(model)

println("\n\n4) MPEC (1 leader, 2 followers)\n")

if termination_status(model) == MOI.OPTIMAL

    println("\n---------- DUAL VARIABLES ----------")

    for i in 2:3
        println("u_max[",i,"]: ", value.(u_max[i]))
    end

    for i in 2:3
        println("lambda[",i,"]: ", value.(lambda[i]))
    end

    println("\n---------- TABLE RESULTS ----------")

    vals = [value.(x[1]), value.(x[2]), value.(x[3])]

    for i in 1:3
            @printf "Production level x[%0.0f]: %0.3f\n" i value.(x[i])
    end

    for i in 1:3
        @printf "Profits for company %0.0f: %0.3f\n" i -profit(vals, i)
    end

    @printf "Market price: %0.3f\n" p(vals)
    @printf "Social welfare: %0.3f\n" SW(vals)

else
    error("No solution.")
end