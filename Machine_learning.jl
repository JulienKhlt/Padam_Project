using Flux
using Statistics
using Tracker
using Plots; pyplot()

# Load the data
X = rand(100, 100)
Y = zeros(2, 100)
for i in 1:2
    for j in 1:100
        Y[i, j] = i*0.5*sum(X[:, j])
    end
end
println(Y)
println(typeof(Y))
# Xd = reduce(hcat,X)
# Yd = reduce(hcat,Y)
data = [(X,Y)]
# data = zip(X, Y)

mod = Dense(100, 2)
# Initial mapping
Yd_0 = Tracker.data(mod(X))
# Setting up loss/cost function
loss(x, y) = mean((mod(x).-y).^2)
# Selecting parameter optimization method
opt = ADAM(0.01, (0.99, 0.999))
# Extracting parameters from model
par = params(mod);

nE = 1_000
for i in 1:nE
    Flux.train!(loss, par, data, opt)
end
# Final mapping
Yd_nE = Tracker.data(mod(X))
println(Y)
println(Yd_nE)