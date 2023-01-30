
# NOTES

# In Julia, the syntax is: if elseif else end. Hence, there should only be one "end" for each if-statement block.

using LinearAlgebra;

# First write the entire problem up

# We make the first tableau

function construct_tableau(T_11, T_12, T_13, T_14, T_21, T_22, T_23, T_24)
    return(vcat(hcat(T_11, T_12, T_13, T_14), hcat(T_21, T_22, T_23, T_24)))
end

# Then we compute the entries for each iteration

function new_T_12(A, c, basic_variables)

    B = [A I][:, basic_variables];
    c_b = [c transpose(zeros(m))][:,basic_variables];

    new_T_12 = c_b * inv(B) * A - c;

    return(new_T_12)

end

function new_T_13(A, c, basic_variables)

    B = [A I][:, basic_variables];
    c_b = [c transpose(zeros(m))][:,basic_variables];

    new_T_13 = c_b * inv(B);

    return(new_T_13)

end

function new_T_14(A, b, c, basic_variables)

    B = [A I][:, basic_variables];
    c_b = [c transpose(zeros(m))][:,basic_variables];

    new_T_14 = c_b * inv(B) * b;

    return(new_T_14)

end

function new_T_22(A, basic_variables)

    B = [A I][:, basic_variables];

    A = inv(B) * A;

    return(A)

end

function new_T_23(A, basic_variables)

    B = [A I][:, basic_variables];

    new_T_23 = inv(B);

    return(new_T_23)

end

function new_T_24(A, b, basic_variables)

    B = [A I][:, basic_variables];

    new_T_24 = inv(B) * b;

    return(new_T_24)

end

# print_tableau(initial_tableau, basic_variables);

function optimality_test(T_12, T_13)

    first_row = [T_12 T_13]

    for i in 1:size(first_row)[2]
        if first_row[i] < 0
            return false;
        end
    end
    return true;
end

function incoming_basic_variable(T_12, T_13)

    first_row = [T_12 T_13]

    index = 1;
    value_index = first_row[1];

    for i in 2:(size(first_row)[2])
        if first_row[i] < value_index
            index = i;
            value_index = first_row[i];
        end
    end

    println("The most negative coefficient is " * string(value_index) *
                            ". Hence, the variable x_{" * string(index) *"} is entering.")

    return index;
end

function leaving_basic_variable(column_index, T_22, T_23, T_24, basic_variables)

    b = T_24
    K = [T_22 T_23]

    if K[1,column_index] <= 0
        min_ratio = typemax(Int32);
        row_index = -1;
    else
        min_ratio = T_24[1] / K[1,column_index];
        row_index = 1;
    end

    for i in 2:(size(K)[1])

        if (K[i,column_index] > 0) && b[i] / K[i,column_index] < min_ratio
            min_ratio = b[i] / K[i,column_index]
            row_index = i
        end

    end

    if row_index == -1

        println("NO MINIMUM RATIO! :(")

    end

    println("The minimum ratio is " * string(min_ratio) *
                            ". Hence, the variable x_{" * string(basic_variables[row_index]) *"} is leaving.")

    return (row_index);
end

function revised_SIMPLEX(max_iter, A, b, c, non_basic_variables, basic_variables)

    n = length(non_basic_variables)
    m = length(basic_variables)
    T_11 = [1];
    T_12 = -c;
    T_13 = transpose(zeros(m));
    T_14 = [0];
    T_21 = zeros(m);
    T_22 = A;
    T_23 = I;
    T_24 = b;

    initial_tableau = construct_tableau(T_11, T_12, T_13, T_14, T_21, T_22, T_23, T_24)

    println("_______ INITIAL TABLEAU_______ \n");

    display(initial_tableau)

    for i in 1:max_iter

        println("\n_______ ITERATION " * string(i) * " _______ \n");

        if optimality_test(T_12, T_13)
            println("The tableau passes the optimality test. \n")
            println("The tableau looks as follows: \n\n");
            display(construct_tableau(T_11, T_12, T_13, T_14, T_21, T_22, T_23, T_24));
            println("\n________ Summary of results _________ \n")
            for i in 1:m
                if basic_variables[i] > n
                    println("The basic variable x_{" * string(basic_variables[i]) * "} has value 0.")
                else
                    println("The basic variable x_{" * string(basic_variables[i]) * "} has value " * string(T_24[i]) *".")
                end
            end
            println("The objective function has value " * string(T_14[1]) *".\n")
            return construct_tableau(T_11, T_12, T_13, T_14, T_21, T_22, T_23, T_24);
        else
            column_index = incoming_basic_variable(T_12, T_13);
            println("The non-basic variable " * string(column_index) * " is entering!")
            leaving_index = leaving_basic_variable(column_index, T_22, T_23, T_24, basic_variables);
            println("The basic variable " * string(basic_variables[leaving_index]) * " is leaving!")
            basic_variables[leaving_index] = column_index;

            # Selecting correct  subsets according to basic variables
            T_12 = new_T_12(A, c, basic_variables);
            T_13 = new_T_13(A, c, basic_variables);
            T_14 = new_T_14(A, b, c, basic_variables);
            T_22 = new_T_22(A, basic_variables);
            T_23 = new_T_23(A, basic_variables);
            T_24 = new_T_24(A, b, basic_variables);

            println("The tableau looks as follows: ");
            display(construct_tableau(T_11, T_12, T_13, T_14, T_21, T_22, T_23, T_24));

        end
    end
    println("\n")
end

function revised_test_SIMPLEX(tableau)

    println("_______ INITIAL TABLEAU_______ \n");

    display(tableau)

    column_index = incoming_basic_variable(tableau);
    println("The non-basic variable " * string(column_index) * " is entering!")
    leaving_index = leaving_basic_variable(column_index + 1, tableau);
    println("The basic variable " * string(basic_variables[leaving_index]) * " is leaving!")
    display(basic_variables)
    basic_variables[leaving_index] = column_index;
    display(basic_variables)

end

x_decision_variables = [1, 2];
x_slack_variables = [3, 4, 5];

A = [1 0; 0 2; 3 2];
b = [4; 12; 18];
c = [3 5];

# A few auxiliary variables.

# n is number of constraints (excluding non-negativity)
n = length(x_decision_variables);

# m is the number of slack variables
m = length(x_slack_variables);

# We define initialize the basic and non-basic variables
non_basic_variables = x_decision_variables;
basic_variables = x_slack_variables;

# We organize the overall matrix into a 2 x 3.

T_11 = [1];
T_12 = -c;
T_13 = transpose(zeros(m));
T_14 = [0];
T_21 = zeros(m);
T_22 = A;
T_23 = I;
T_24 = b;

# Iteration 0

resulting_tableau = revised_SIMPLEX(10, A, b, c, non_basic_variables, basic_variables)

#

########### USER INPUT ################

x_decision_variables = [1, 2, 3];
x_slack_variables = [4, 5, 6];

A = [2 1 -1; 4 -3 0; -3 2 1];
b = [4; 2; 3];
c = [1 -7 3];

# A few auxiliary variables.

# n is number of constraints (excluding non-negativity)
n = length(x_decision_variables);

# m is the number of slack variables
m = length(x_slack_variables);

# We define initialize the basic and non-basic variables
non_basic_variables = x_decision_variables;
basic_variables = x_slack_variables;

# We organize the overall matrix into a 2 x 3.

T_11 = [1];
T_12 = -c;
T_13 = transpose(zeros(m));
T_14 = [0];
T_21 = zeros(m);
T_22 = A;
T_23 = I;
T_24 = b;

# Iteration 0

resulting_tableau = revised_SIMPLEX(10, A, b, c, non_basic_variables, basic_variables)

############### END USER INPUT ##################
