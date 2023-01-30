#Dependencies
using JuMP

#using Gurobi

#Data
alpha_d   = [10 15 20]
alpha_s   = [0  0  0]

beta_d    = [-1 -2 -3]
beta_s    = [ 2  3  1]

# ECB rate sensitivity
Gamma = -5

# Government spendings sensitivity
gamma = [1 1 1]

# Pareto param
theta = [0.5 0.5 0.5]

# Price
P = 5

#Sets
I = 1:3

#Big M
M = 100

# utility fun
eta = 0.1
function ufun(x)
    if eta<1
        return ((x^(1-eta)-1)/(1-eta))
    end
    return log(x)
end


#Declare model with Gurobi solver
model = Model(Gurobi.Optimizer)
set_optimizer_attribute(model, "NonConvex", 2)

#Declare variables
@variable(model, 15>=R>=-10)
@variable(model, 5>=g[I]>=-5)
@variable(model, tau[I]>=0)
@variable(model, 0<=u[I])
@variable(model, b[I], Bin)

#Define objective
@objective(model, Min, sum( theta[i]*g[i]*g[i] + (1-theta[i])*tau[i] for i=I))

#Top level constraints
# NIL

#Stationariy (KKT)
@constraint(model, [i=I], 2*g[i]*theta[i] + 2*u[i]*(alpha_d[i]-alpha_s[i] + (beta_d[i]-beta_s[i])*P + Gamma*R + gamma[i]*g[i])*gamma[i] == 0)
@constraint(model, [i=I], 1-theta[i]-u[i] == 0)

#Primal feasibility
@constraint(model, [i=I], (alpha_d[i]-alpha_s[i] + (beta_d[i]-beta_s[i])*P + Gamma*R + gamma[i]*g[i])^2 - tau[i] <= 0)

#Dual feasibility
@constraint(model, [i=I], u[i] >= 0)

#Complemtary slackness
@constraint(model, [i=I],  (alpha_d[i]-alpha_s[i] + (beta_d[i]-beta_s[i])*P + Gamma*R + gamma[i]*g[i])^2 - tau[i] >= -M*b[i])
@constraint(model, [i=I], u[i] <= M*(1-b[i]))



#Optimize model
optimize!(model)

#Print solution
println("Model: ", model)

println("Objective value: ", objective_value(model))
println("R: ", value.(R))
println("g: ", value.(g))
println("tau: ", value.(tau))
println("u: ", value.(u))






