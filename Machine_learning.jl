using Flux
using Flux: Data.DataLoader
using Flux: onehotbatch, onecold, crossentropy
using Flux: @epochs
using Statistics

# Load the data
x_train = [[1 1 1 1; 1 1 1 1; 1 1 1 1; 1 1 1 1], [1 1 1 1; 1 1 1 1; 1 1 1 1; 1 1 1 1]]
x_train = Flux.flatten(x_train)
y_train = [1, 1]
train_data = DataLoader(x_train, y_train, batchsize=1)

model = Chain(
    # 4x4 => 2x2
    # Conv((3, 3), 32=>32, pad=1, stride=2, relu),
    
    # Average pooling on each width x height feature map
    # GlobalMeanPool(),
    # flatten,
    
    Dense(2, 1),
    softmax)

# Getting predictions
ŷ = model(x_train)
# Decoding predictions
ŷ = onecold(ŷ)
println("Prediction of first image: $(ŷ[1])")

accuracy(ŷ, y) = mean(onecold(ŷ) .== onecold(y))
loss(x, y) = Flux.crossentropy(model(x), y)
# learning rate
lr = 0.1
opt = Descent(lr)
ps = Flux.params(model)

number_epochs = 10
@epochs number_epochs Flux.train!(loss, ps, train_data, opt)
accuracy(model(x_train), y_train)