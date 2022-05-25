from __future__ import print_function
from functools import partial
import numpy as np
import argparse
import os
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torch.utils.data import random_split
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
from torch.autograd import Variable
from models.binarized_modules import  BinarizeLinear,BinarizeConv2d
from models.binarized_modules import  Binarize,HingeLoss
import matplotlib.pyplot as plt
from ray import tune
from ray.tune import CLIReporter
from ray.tune.schedulers import ASHAScheduler

# first lets define again the function for binarizing the image 

class ThresholdTransform(object):
    def __init__(self, thr_255):
        self.thr = thr_255  

    def __call__(self, x):
        return (x >= self.thr).to(x.dtype) 
    
#declare the transform  with a shared dir 
def load_data(data_dir="./data"):
   # transform = transforms.Compose([transforms.ToTensor(),transforms.Normalize((0.1307,), (0.3081,)),ThresholdTransform(thr_255=0)],Resize((28, 28)))
    # Get data from torchvision.datasets
    transform = transforms.Compose([transforms.ToTensor(),transforms.Normalize((0.1307,), (0.3081,)),ThresholdTransform(thr_255=0)])
    train_data = datasets.MNIST(data_dir, train=True, download=True, transform=transform)
    test_data = datasets.MNIST(data_dir, train=False, download=True, transform=transform)

    return train_data,test_data

# I will now create a definition of my model as the previous one  
class MY_BNN(nn.Module):
    
    def __init__(self, hidden_neuron = 100, dropout = 0.5):
        super(MY_BNN, self).__init__()
        self.fc1 = BinarizeLinear(28*28, hidden_neuron, bias = False)
        self.htanh1 = nn.Hardtanh()
        self.bn1 = nn.BatchNorm1d(hidden_neuron)
        self.fc2 = BinarizeLinear(hidden_neuron, hidden_neuron, bias = False)
        self.htanh2 = nn.Hardtanh()
        self.bn2 = nn.BatchNorm1d(hidden_neuron)
        self.fc3 = BinarizeLinear(hidden_neuron, hidden_neuron, bias = False)
        self.htanh3 = nn.Hardtanh()
        self.bn3 = nn.BatchNorm1d(hidden_neuron)
        self.fc4 = BinarizeLinear(hidden_neuron, 10, bias = False)
        self.drop=nn.Dropout(dropout)

    def forward(self, x):
        x = x.view(-1, 28*28)
        x = self.fc1(x)    
        x = self.bn1(x)    
        x = self.htanh1(x) 
        x = self.fc2(x)    
        x = self.bn2(x)    
        x = self.htanh2(x)
        x = self.fc3(x)
        x = self.drop(x)
        x = self.bn3(x)
        x = self.htanh3(x)
        x = self.fc4(x)
        return torch.nn.functional.log_softmax(x, -1)


def train_bnn(config, checkpoint_dir=None, data_dir=None):
    
    net = MY_BNN(config["hidden_neuron"],config["dropout"])
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(net.parameters(), lr=config["lr"])
    
    if checkpoint_dir:
        model_state, optimizer_state = torch.load(
        os.path.join(checkpoint_dir, "checkpoint"))
        net.load_state_dict(model_state)
        optimizer.load_state_dict(optimizer_state)
        
    trainset, testset = load_data(data_dir)
    
    test_abs = int(len(trainset) * 0.8)
    train_subset, val_subset = random_split(
        trainset, [test_abs, len(trainset) - test_abs])

    trainloader = torch.utils.data.DataLoader(
        train_subset,
        batch_size=int(config["batch_size"]),
        shuffle=True)
    valloader = torch.utils.data.DataLoader(
        val_subset,
        batch_size=int(config["batch_size"]),
        shuffle=True)
    
    for epoch in range(10):  # loop over the dataset multiple times
        running_loss = 0.0
        epoch_steps = 0
        for i, data in enumerate(trainloader, 0):
            # get the inputs; data is a list of [inputs, labels]
            inputs, labels = data

            # zero the parameter gradients
            optimizer.zero_grad()

            # forward + backward + optimize
            outputs = net(inputs)
            loss = criterion(outputs, labels)
            if epoch%40==0:
                optimizer.param_groups[0]['lr']=optimizer.param_groups[0]['lr']*0.1

            optimizer.zero_grad()
            loss.backward()
            for p in list(net.parameters()):
                if hasattr(p,'org'):
                    p.data.copy_(p.org)
            optimizer.step()
            for p in list(net.parameters()):
                if hasattr(p,'org'):
                    p.org.copy_(p.data.clamp_(-1,1))

            # print statistics
            running_loss += loss.item()
            epoch_steps += 1
            if i % 2000 == 1999:  # print every 2000 mini-batches
                print("[%d, %5d] loss: %.3f" % (epoch + 1, i + 1,
                                                running_loss / epoch_steps))
                running_loss = 0.0

        # Validation loss
        val_loss = 0.0
        val_steps = 0
        total = 0
        correct = 0
        for i, data in enumerate(valloader, 0):
            with torch.no_grad():
                inputs, labels = data

                outputs = net(inputs)
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()

                loss = criterion(outputs, labels)
                val_loss += loss.cpu().numpy()
                val_steps += 1

        with tune.checkpoint_dir(epoch) as checkpoint_dir:
            path = os.path.join(checkpoint_dir, "checkpoint")
            torch.save((net.state_dict(), optimizer.state_dict()), path)

        tune.report(loss=(val_loss / val_steps), accuracy=correct / total)
    print("Finished Training")


def test_accuracy(net, device="cpu"):
    trainset, testset = load_data()

    testloader = torch.utils.data.DataLoader(
        testset, batch_size=4, shuffle=False)

    correct = 0
    total = 0
    with torch.no_grad():
        for data in testloader:
            images, labels = data
            images, labels = images.to(device), labels.to(device)
            outputs = net(images)
            _, predicted = torch.max(outputs.data, 1)
            total += labels.size(0)
            correct += (predicted == labels).sum().item()

    return correct / total


config = {
    #"neurons_l1": tune.sample_from(lambda _: 2**np.random.randint(8, 11)),
    #"neurons_l2": tune.sample_from(lambda _: 2**np.random.randint(8, 11)),
    #"neurons_l3": tune.sample_from(lambda _: 2**np.random.randint(8, 11)),
    "hidden_neuron": tune.choice([256,512,1024,2048]),
    "lr": tune.loguniform(1e-4, 1e-1),
    "dropout": tune.choice([0.25,0.5,0.75]),
    "batch_size": tune.choice([32,64,128,248])
}



def main(num_samples=20, max_num_epochs=10):
    data_dir = os.path.abspath("./data")
    load_data(data_dir)

    scheduler = ASHAScheduler(
        metric="loss",
        mode="min",
        max_t=max_num_epochs,
        grace_period=1,
        reduction_factor=2)
    reporter = CLIReporter(
         #parameter_columns=["neurons_l1", "neurons_l2", "neurons_l1","lr", "batch_size"],
        metric_columns=["loss", "accuracy", "training_iteration"])
    result = tune.run(
        partial(train_bnn, data_dir=data_dir),
        config=config,
        num_samples=num_samples,
        scheduler=scheduler,
        progress_reporter=reporter)

    best_trial = result.get_best_trial("loss", "min", "last")
    print("Best trial config: {}".format(best_trial.config))
    print("Best trial final validation loss: {}".format(
        best_trial.last_result["loss"]))
    print("Best trial final validation accuracy: {}".format(
        best_trial.last_result["accuracy"]))

    best_trained_model = MY_BNN(best_trial.config["hidden_neuron"],best_trial.config["dropout"])
    device = "cpu"
    if torch.cuda.is_available():
        device = "cuda:0"
        if gpus_per_trial > 1:
            best_trained_model = nn.DataParallel(best_trained_model)
    best_trained_model.to(device)

    best_checkpoint_dir = best_trial.checkpoint.value
    model_state, optimizer_state = torch.load(os.path.join(
        best_checkpoint_dir, "checkpoint"))
    best_trained_model.load_state_dict(model_state)

    test_acc = test_accuracy(best_trained_model, device)
    print("Best trial test set accuracy: {}".format(test_acc))


if __name__ == "__main__":
    # You can change the number of GPUs per trial here:
    main(num_samples=10, max_num_epochs=10)