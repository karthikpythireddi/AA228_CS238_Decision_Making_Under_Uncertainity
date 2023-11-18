#define the initial utility of too hot and just right
U_th = 0
U_jr = 0


#discount factor
gamma = 0.9

#transition probability of the th and jr
p_th_jr = 0.8
p_jr_th = 0.1

#rewards and penalties
th_r = -1
jr_r = 1

#tolerance
tol = 0.01

while True:

    U_jr_new = jr_r + gamma * (p_jr_th * U_th + p_th_jr * U_jr)
    U_th_new = th_r + gamma * (p_th_jr * U_jr + p_jr_th * U_th)


    if abs(U_jr_new - U_jr) < tol and abs(U_th_new - U_th) < tol:
        break
    else:
        U_jr = U_jr_new
        U_th = U_th_new
print("The expected utility of just right is: ", U_jr)