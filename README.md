# TCPM (Tree Structured Parts Model) Tutorial


----

## Table of Contents

* [Copyright](#copyright)
* [Design a mixture of models](#design-a-mixture-of-models)
* [Prepare dataset](#prepare-dataset)
* [Edit multipie_init.m](#edit-multipie_initm)
* [Edit multipie_data.m](#edit-multipie_datam)
* [Edit multipie.mat](#edit-multipiemat)
* [Run multipie_main.m](#run-multipie_mainm)


----

### Copyright

This code is entirely based on the published code [1]. This document is a tutorial that instructs how to exploit this code with the mixture of models in the original code replaced with yours.

[1] Xiangxin Zhu, Deva Ramanan. Face detection, pose estimation, and landmark localization in the wild. Computer Vision and Pattern Recognition (CVPR) Providence, Rhode Island, June 2012. 


### Design a mixture of models

We use a mixture of models for face detection. Let's first look into the original model implemented in the code. As for the original mixture of models, total of 13 models form a mixture. Model 1 to 3 have the same tree structure, and are of purpose of detecting human faces which are heading left. Model 4 to 10, in sequence, have the same tree structure, and these 7 are for detecting the frontal faces. The remaining 3 (model 11 to 13) have the same tree structure, and are for detecting the faces heading right.

For better understanding, structure of the model 7 is constructed like below:

![Model 7: Frontal facial model]
(https://app.box.com/representation/file_version_46881226973/image_2048/1.png?shared_name=iexa0gvaqo0d93upayrr6jyqds2hy2bn)

Note that there are two kinds of labeling (numbering) systems. One is **annotation order** and the other is **tree order**. **Annotation order** is the ordering system under which the annotations (coordinates of landmark points) on the training images were made, while **tree order** is of the actual tree structure of a model used on the score evaluation stage.

If you want to use a new facial model, follow the next steps.

1.  Construct a mixture of models. Decide how many models the mixture consists of.
2.  Design a tree structure which fit to the human faces for each model.
3.  Give labels to nodes of trees. As mentioned earlier, each node should be labeled with two numbers, one for annotation ordering system, and the other for tree ordering system.

* Annotation order: If you have annotations within the training data, then you have to follow the labeling order of those annotations.
* Tree order: Be aware that the id number of parent nodes should be larger than their children's.

For example, simpler model might be like:

![Simpler model example]
(https://app.box.com/representation/file_version_46455296141/image_2048/1.png?shared_name=32riry0hs11tbf4dah13djvwqh5p1rji)

The following material of this document is based on a mixture of models which consists of 3 models. Each of three models corresponds to viewpoints of 30, 0, -30 degree, respectively. And all the models have the same tree structure as shown above.


### Prepare dataset

For training set, we need data of following files to be prepared:
* Image files that include the human faces which we aim to detect.
* Annotation files on images that include the coordinate values of landmark points (same as the center of parts in the models)

For each of all the image files, there should be an annotation file named "[Image file name]_lb.mat" in the certain directory for annotation files. These are .mat files, where the coordinate values of landmark points are stored using a matrix variable named "pts". As for our simple model, size of the matrix "pts" is 15 by 2, cause we have 15 landmark points per an image. The first column refers to the x values of landmark points, and the second column refers to the y values, and each of 15 rows corresponds to each landmark point.

The training data might be structured like:

    [ Image files ]
    *image_dir*/*image_name_1.jpg*
    ...
    *image_dir*/*image_name_n.jpg*
    
    [ Annotation files ]
    *anno_dir*/*image_name_1_lb.mat*
    ...
    *anno_dir*/*image_name_n_lb.mat*


### Edit multipie_init.m

As the first step of change in codes, open **"multipie_init.m"** file located at the project root directory, and modify as follows.

First of all, see the following part of the code.

    opts.viewpoint = 90:-15:-90;
    opts.partpoolsize = 39+68+39;

**opts.viewpoint** is a list consisting of the viewpoint angles which the objects face towards. As for the original setting above, for example, it means that we aim to detect the human faces each of which is heading at 90 degree, 75 degree, ..., -90 degree respectively. (zero degree corresponds to the frontal view.)

**opts.partpoolsize** is a sum over the number of parts of every different model. In the original setting, we have total of 3 different models for detecting the left, front, and right side of faces. These three models are composed of 39, 68, and 39 parts respectively. Thus we have the value of 39+68+39 in result.

Change these two properly to work well with our model. Then the code above should be modified to be like:

    opts.viewpoint = [30, 0, -30];
    opts. partpoolsize = 15;

And then, we specify mixture of models concretly. We have three models in our mixture of models, so what we have to do in this section is to define **opts.mixture(1), opts.mixture(2), and opts.mixture(3)** which correspond to our three models.

Let's define a **opts.mixture(1)** first.

At first, **poolid** should be a list of integer from 1 to 15, because every single model of our mixture has 15 parts.

Next, the variable **I** and **J** define a transformation relation between the annotation and tree order labels. Let **I** have a array of integer range from 1 to the number of parts. And then, take a close look at **J**. The k'th number in array J, say n<sub>k</sub>, means that the node labeled with k in tree order is labeled with n<sub>k</sub> in annotation order.

**S** in the next line should be modified to be the array consisting of ones that takes the number of parts as it's length.

Using the variables defined above, we set the **anno2treeorder** to represent the transformation matrix from annotation to tree order. Just replace the 4th, and 5th argument of the sparse() function with the number of parts.

Finally, **pa** specifies the id number of parent of each nodes. Note that you should follow the tree order in refering to a node here.

As a result, the original codes might be changed as follows:

    % Global mixture 1 to 3, left, frontal, and right face
    opts.mixture(1).poolid = 1:15;
    I = 1:15;
    J = [9 10 11 8 7 3 2 1 6 5 4 12 13 14 15];
    S = ones(1,15);
    opts.mixture(1).anno2treeorder = full(sparse(I,J,S,15,15)); % label transformation
    opts.mixture(1).pa = [0 1 1 1 4 5 6 7 5 9 10 1 12 12 12];
    
    opts.mixture(2) = opts.mixture(1);
    opts.mixture(3) = opts.mixture(1);


### Edit multipie_data.m

This **"multipie_data.m"** file does the data preparation work.

First, define what images in our dataset will be used for training set, and what images for test set. Modify the lists **trainlist** and **testlist** properly based on the prepared dataset.

Next, set the pathes where the image and annotation in the dataset are located. **multipiedir** is a path for image files, and **annodir** is a path for annotation files.


### Edit multipie.mat

This .mat file includes a struct variable named **multipie** which includes the name of the image files classified by the models in our mixture. You may consult the **"make_multipie_info"** script in **tools/** directory to make your own **multipie** variable more easily.


### Run multipie_main.m

1. Run **"compile.m"** file first.
2. Run **"multipie_main"** file. This script trains the model using the prepared dataset, evaluate the trained model, and even shows the result graphically.
