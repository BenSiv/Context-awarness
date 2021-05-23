Context Awarness
cd("C:\\Users\\Ben_Sivan\\Documents\\Context_awareness_dataset_web\\Others")

] activate "C:/Users/Ben_Sivan/Google Drive/Julia"

using CSV, DataFrames, DataFramesMeta, Plots, StatsPlots, StatsBase, Statistics, Flux, Zygote, Weave

cd("C:/Users/Ben_Sivan/Google Drive/Julia/Context_awareness_dataset_web/RawData")
Participants = readdir()

cd(Participants[1])
Activities = readdir()
filter!(e->e != ".ipynb_checkpoints",Activities)
for i in 1:length(Activities)
    Activities[i] = split(Activities[i], ".")[1]
    Activities[i] = split(Activities[i], "aysu")[2]
end

cd("C:\\Users\\Ben_Sivan\\Documents\\Context_awareness_dataset_web\\Others")

Activities_Eng = ["cleaning window","chopping","writing with a pen","eating soup","using a computer mouse","writing with a keyboard","cleaning table","drinking water","using a tablet computer","kneading dough"]

files = []
for i in 1:length(Participants)
    for j in 1:length(Activities)
        append!(files,[Participants[i]*"/"*Participants[i]*Activities[j]*".csv"])
    end
end

Back_Data = Dict("Activities" => Activities,
                 "Activities_Eng" => Activities_Eng,
                 "Participants" => Participants,
                 "files" => files)

cd("C:\\Users\\Ben_Sivan\\Documents\\Context_awareness_dataset_web\\RawData")

All_Data = DataFrame()
Row_Num = Int[]
for file in files
    data = CSV.read(file,DataFrame,header = false)
    print(file)
    append!(All_Data,data[:,1:28])
    append!(Row_Num,nrow(data))
end

Sort = DataFrame(Row_Num = Row_Num, 
                 Participant = vcat(fill.(Participants, length(Activities))...),
                 Activity = vcat(fill(Activities, length(Participants))...)
                )

# All_Sort DataFrame

Participant = []
i = 1
for (cnt,Nrow) in zip(1:length(Row_Num),Row_Num)  
    append!(Participant,vcat(fill.(Participants[i], length(["x","y","z"])*Nrow)...))
    if cnt % length(Activities) == 0
         i += 1
    end
end

Activity = []
i = 1
for Nrow in Row_Num  
    append!(Activity,vcat(fill(Activities_Eng[i], length(["x","y","z"])*Nrow)...))
    if i < length(Activities)
        i += 1
    else
        i = 1
    end
end

Activity_Num = []
i = 1
Act_Num = 1:length(Activities_Eng)
for Nrow in Row_Num  
    append!(Activity_Num,vcat(fill(Act_Num[i], length(["x","y","z"])*Nrow)...))
    if i < length(Activities)
        i += 1
    else
        i = 1
    end
end

Axis = []
for Nrow in Row_Num  
    append!(Axis, vcat(fill.(["x","y","z"], Nrow)...))
end

Axis_Num = []
for Nrow in Row_Num  
    append!(Axis_Num, vcat(fill.([1,2,3], Nrow)...))
end

Low_Noise = [All_Data[row,column] for column in [4,6,8] for row in 1:nrow(All_Data)]
Wide_Range = [All_Data[row,column] for column in [10,12,14] for row in 1:nrow(All_Data)]
Gyroscope = [All_Data[row,column] for column in [16,18,20] for row in 1:nrow(All_Data)]
Magnetometer = [All_Data[row,column] for column in [22,24,26] for row in 1:nrow(All_Data)]

Timestamp = []
for Nrow in Row_Num  
    append!(Timestamp, vcat(fill(All_Data[1:Nrow,2], 3)...))
end

All_Sort = DataFrame(
            Participant = Participant,
            Activity = Activity,
            Activity_Num = Activity_Num,
            Axis = Axis,
            Axis_Num = Axis_Num,
            Low_Noise = Low_Noise,
            Wide_Range = Wide_Range,
            Gyroscope = Gyroscope,
            Magnetometer = Magnetometer,
            Timestamp = Timestamp
)


Participants = unique(All_Sort.Participant)
Activities = unique(All_Sort.Activity)
Axis = unique(All_Sort.Axis)
Names = names(All_Sort)

ColumnNames = []
for D in ["Avg","Std"]
    for axis in Axis
        for name in Names[6:9]
            append!(ColumnNames, [D*"_"*name*"_"*axis])
        end
    end
end

Summary = DataFrame(zeros(1,24))
rename!(Summary, Symbol.(ColumnNames))

for participant in Participants
    for activity in Activities
        Avgs = []
        Stds = []
        for axis in Axis
            TempData = @where(All_Sort, :Participant .== participant, :Activity .== activity, :Axis .== axis)
            for name in Names[6:9]
                append!(Avgs, mean(TempData[name]))
                append!(Stds, std(TempData[name]))
            end
        end
        push!(Summary, [Avgs; Stds])
    end
end

Summary = Summary[2:end,:]

Summary = @transform(Summary, Participants = vcat(fill.(Participants, length(Activities))...),
                              Activities = vcat(fill(Activities, length(Participants))...))
CSV.write("Summary.csv",Summary)

Summary = CSV.read("Summary.csv", DataFrame) 

All_Sort = CSV.read("All_Sort.csv", DataFrame) 


Train_Data = @where(Summary, in.(:Participants,Ref(unique(:Participants)[1:15])))

Test_Data = @where(Summary, in.(:Participants,Ref(unique(:Participants)[16:30])))

using Flux: onehotbatch

Y_train = onehotbatch(Train_Data.Activities, unique(Train_Data.Activities))

Y_test = onehotbatch(Test_Data.Activities, unique(Test_Data.Activities))

x_train = convert(Matrix, Train_Data[1:end-2])
X_train = Matrix(x_train')

x_train = convert(Matrix, @select(Train_Data, :Activity_Num, :Axis_Num, :Low_Noise, :Wide_Range, :Gyroscope, :Magnetometer, :Timestamp))
X_train = Matrix(x_train')

x_test = convert(Matrix, Test_Data[1:end-2])
X_test = Matrix(x_test')

x_test = convert(Matrix, @select(Test_Data, :Activity_Num, :Axis_Num, :Low_Noise, :Wide_Range, :Gyroscope, :Magnetometer, :Timestamp))
X_test = Matrix(x_test')

n_inputs = size(X_train)[1]

n_outputs = size(Y_train)[1]

n_hidden = 16

model = Chain(Dense(n_inputs, n_hidden, relu),
              Dense(n_hidden, n_hidden, relu),
              Dense(n_hidden, n_outputs, identity), softmax)

Loss(x,y) = Flux.crossentropy(model(x), y)

opt = ADAM()

function update_loss!()
    push!(train_loss, Loss(X_train,Y_train))
    push!(test_loss, Loss(X_test,Y_test))
    if length(train_loss) > 1
        delta_train = train_loss[end] - train_loss[end-1]
        delta_test = test_loss[end] - test_loss[end-1]
        
        print("train loss = ", train_loss[end],"  ", delta_train,
            " ,  test loss = ", test_loss[end],"  ", delta_test, "\n")
        if delta_train < 0 && delta_test > 0
            Flux.stop()
        end
    else
        print("train loss = ", train_loss[end]," ,  test loss = ", test_loss[end], "\n")
    end   
end

using Base.Iterators: repeated

trainset = repeated((X_train, Y_train), 10000)

testset = repeated((X_test, Y_test), 10000)

train_loss = Float64[]
test_loss = Float64[]
Flux.train!(Loss, params(model), trainset, opt;
            cb = Flux.throttle(update_loss!, 1))


plot(1:length(train_loss), train_loss, xlabel="~seconds of training", ylabel="loss", label="train")
plot!(1:length(test_loss), test_loss, label="test")

function accuracy(x,y)
    i = []
    for (output,expected) in zip(eachcol(model(x)), eachcol(y))
        j = argmax(output) == argmax(expected)
        append!(i,j)
    end
    return(mean(i))
end

TrainAccuracy = accuracy(X_train,Y_train)

TestAccuracy = accuracy(X_test,Y_test)


