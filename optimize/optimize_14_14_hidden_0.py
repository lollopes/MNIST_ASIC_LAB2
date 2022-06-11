from __future__ import print_function
import argparse
import torch
from tqdm import tqdm
import numpy as np
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import pandas as pd
from torch.utils.data import DataLoader
from torchvision import datasets, transforms
from torch.autograd import Variable
from models.binarized_modules import  BinarizeLinear,BinarizeConv2d
from models.binarized_modules import  Binarize,HingeLoss
import matplotlib.pyplot as plt
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning) 

IMAGE_SIZE = 14

HL_1 = [32,64,128,256]
LR = [0.003,0.001]
DO = [0.5]
EPOCH_N = [10,20]
BATCH_N = [32,64]

class BNN_SW(nn.Module):
    
    def __init__(self, in_features = 28*28, HL_1=100, out_features=10,dropout = 0.5):
        super(BNN_SW, self).__init__()
        self.in_features = in_features
        self.fc1 = BinarizeLinear(in_features, HL_1, bias = False)
        self.drop=nn.Dropout(dropout)
        self.bn1 = nn.BatchNorm1d(HL_1)
        self.htanh1 = nn.Hardtanh()
        self.fc2 = BinarizeLinear(HL_1, out_features, bias = False)
        self.logsoftmax=nn.LogSoftmax()

    def forward(self, x):
        x = x.view(-1, self.in_features)
        x = self.fc1(x)  
        x = self.drop(x)  
        x = self.bn1(x)    
        x = self.htanh1(x) 
        x = self.fc2(x)
        return self.logsoftmax(x)

class BNN_HW(nn.Module):

    def __init__(self, in_features = 28*28, HL_1=100, out_features=10):
        super(BNN_HW, self).__init__()
        self.in_features = in_features
        self.fc1 = BinarizeLinear(in_features, HL_1, bias = False)
        self.fc2 = BinarizeLinear(HL_1, out_features, bias = False)

    def forward(self, x):
        x = x.view(-1, self.in_features)
        x = self.fc1(x)
        x = my_sign(x)
        x = self.fc2(x)
        return x


def train(epoch,model_hw,space_idx,learning_rate):
    
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model_hw.parameters(), learning_rate) # Adam algorithm to optimize change of learning_rate


    model_hw.train()
    
    for batch_idx, (data, target) in enumerate(train_loader):
        
        data, target = Variable(data), Variable(target)
        optimizer.zero_grad()
        output = model_hw(data)
        #print("shape is ",data.shape)
        loss = criterion(output, target)

        if epoch%40==0:
            optimizer.param_groups[0]['lr']=optimizer.param_groups[0]['lr']*0.1

        optimizer.zero_grad()
        loss.backward()
        for p in list(model_hw.parameters()):
            if hasattr(p,'org'):
                p.data.copy_(p.org)
        optimizer.step()
        for p in list(model_hw.parameters()):
            if hasattr(p,'org'):
                p.org.copy_(p.data.clamp_(-1,1))

            
def my_sign(a):
    
    a_buff = torch.empty(a.shape)
    for idx, element in enumerate(a):
        for idy, sub_element in enumerate(element):
            if(sub_element >= 0):
                a_buff[idx][idy] = 1
            else:
                a_buff[idx][idy] = -1
            
    return a_buff


def test_sw(model):
    
    model.eval()
    criterion = nn.CrossEntropyLoss()
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
       
            data, target = Variable(data), Variable(target)
            output = model(data)
            test_loss += criterion(output, target).item() # sum up batch loss
            pred = output.data.max(1, keepdim=True)[1] # get the index of the max log-probability
            correct += pred.eq(target.data.view_as(pred)).cpu().sum()

    test_loss /= len(test_loader.dataset)
    
    return 100. * correct / len(test_loader.dataset)


def test_hw(model):
    model.eval()
    criterion = nn.CrossEntropyLoss()
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = Variable(data), Variable(target)
            #print(data)
            output = model(data)
            test_loss += criterion(output, target).item() # sum up batch loss
            pred = output.data.max(1, keepdim=True)[1] # get the index of the max log-probability
            correct += pred.eq(target.data.view_as(pred)).cpu().sum()

    test_loss /= len(test_loader.dataset)
    
    return 100. * correct / len(test_loader.dataset)


class ThresholdTransform(object):
    def __init__(self, thr_255):
        self.thr = thr_255   # input threshold for [0..255] gray level, convert to [0..1]

    def __call__(self, x):
        x[x >= 0] = 1
        x[x <= 0] = 0      
        return x  
    
transform = transforms.Compose([transforms.ToTensor(),
                                transforms.Normalize((0.1307,), (0.3081,)),
                                transforms.Resize((IMAGE_SIZE, IMAGE_SIZE)),
                                ThresholdTransform(thr_255=0)])


res = []

search_space = []
import itertools
#search_space[   0    1  2    3     4     ]
#search_space[layer1,LR,DO,EPOCH_N,BATCH_N]
for r in itertools.product(HL_1,LR,DO,EPOCH_N,BATCH_N): search_space.append((r[0],r[1],r[2],r[3],r[4]))

print(search_space)
# Outer loop with the search space
for space_idx, space in  enumerate(search_space):
    
    model_sw = BNN_SW(in_features = IMAGE_SIZE*IMAGE_SIZE,
                      HL_1 = space[0],
                      dropout = space[2])
    
    model_hw = BNN_HW(in_features = IMAGE_SIZE*IMAGE_SIZE,
                      HL_1 = space[0],)

    train_data = datasets.MNIST('../data', train=True, download=True, transform=transform)
    test_data = datasets.MNIST('../data', train=False, download=True, transform=transform)

    train_loader = DataLoader(train_data, batch_size=space[4], shuffle=True)
    test_loader = DataLoader(test_data)

    # Inner loop for epochs 
    for epoch in range(1, space[3] + 1):
        train(epoch,model_sw,space_idx,space[3])
    
    accuracy_sw = test_sw(model_sw)
    
    model_hw.fc1.weight = model_sw.fc1.weight
    model_hw.fc2.weight = model_sw.fc2.weight
       
    accuracy_hw = test_hw(model_hw)
    
    print(space,'space {}/{}'.format(space_idx,len(search_space)-1),"HW_acc:",accuracy_hw.item(),"SW_acc:",accuracy_sw.item())
    res.append(('H1:{} LR:{} DO:{} EPOCH:{} BATCH:{}'.format(space[0],space[1],space[2],space[3],space[4]),accuracy_sw.item(),accuracy_hw.item()))
    
    del model_sw
    del model_hw 


res = np.array(res,dtype=object)
np.savetxt("optimize_14_14_hidden_0_res.csv", res, fmt = '%s,%f,%f', delimiter = ",")
fig = plt.figure(figsize=(15,10))
x = np.arange(len(res))
plt.plot(x,res[:,1],label="HW")
plt.plot(x,res[:,2],label="SW")
my_xticks = res[:,0]
plt.ylabel("Accuracy")
plt.xticks(x, my_xticks)
plt.legend(loc="best")
degrees = 70
plt.xticks(rotation=degrees)
plt.savefig("optimize_14_14_hidden_0_plt.jpg",bbox_inches='tight', dpi=150)



