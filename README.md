# MNIST_ASIC_LAB2
MNIST classification using binary neural nets in pytorch. Made for LAB2 of Hardware AI of TUDelft

## INSTALLATION PROCEDURE 

1. Install Conda in your computer to manage the python environment from [here](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html#installing-conda-on-a-system-that-has-other-python-installations-or-packages).
2. Verify installation was succesful by issuing `conda list` in the terminal. 
3. Create a new environment  with `conda create -n binary_net python=3.9`, where binary_net is the name of your environment. 
4. Activate enviroment with  `conda activate binary_net`
5. Install pytorch and torchvision with with `pip3 install torch torchvision`. 
6. Install juppyter notebook in your environment with `conda install jupyter`.
7. Install matplotlib with `conda install -c conda-forge matplotlib`. 
8. You should now be able to use jupyter notebook without having issue with libraries.
9. Lunch the notebook with `jupyter notebook`.
10. We will work on the file called our_network.ipynb.
` 

## Files to use for hardware testing 

### Files below are the weights for a 4 layer network with 2 hidden layer. Considered as baseline 

W_fc1.csv -> input layer (IN=784,OUT=100)

W_fc2.csv -> hidden1 layer (IN=100,OUT=100)

W_fc3.csv -> hidden2 layer (IN=100,OUT=100)

W_fc4.csv -> output layer (IN=100,OUT=10)

### File below is the flatten(vectorized) input of the image 2

input_image_flatten.csv -> input image (ROW=1,COL=784)

With this files we should be able to validate that our machine can classify the image of number 2. This is verified in software. 

