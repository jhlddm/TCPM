# TCPM (Tree Structured Parts Model) Tutorial


----

## Table of Contents

----

### Designing a mixture of models

We use a mixture of models for face detection. Let's first look into the original model implemented in the code. As for the original mixture of models, total of 13 models form a mixture. Model 1 to 3 have the same tree structure, and are of purpose of detecting human faces which are heading left. Model 4 to 10, in sequence, have the same tree structure, and these 7 are for detecting the frontal faces. The remaining 3 (model 11 to 13) have the same tree structure, and are for detecting the faces heading right.

For better understanding, structure of the model 7 is constructed like below:

![Model 7: Frontal facial model]
(https://app.box.com/representation/file_version_46881226973/image_2048/1.png?shared_name=iexa0gvaqo0d93upayrr6jyqds2hy2bn)

Note that there are two kind of labeling (numbering) systems. One is **annotation order** and the other is **tree order**. **Annotation order** is the ordering system under which the annotations (coordinates of landmark points) on the training images were made, while **tree order** is of the actual tree structure of a model used on the score evaluation stage.

If you want to use a new facial model, follow the next steps.

1) Design a tree structure which maps to the human faces.
2) Give labels to nodes of tree. As mentioned earlier, each node should be labeled with two numbers, one for annotation ordering system, and the other for tree ordering system.
* Annotation order: If you have annotations within the training data, then you have to follow the labeling order of those annotations.
* Tree order: Be aware that the id number of parent nodes should be larger than their children's.

### Preparing the training data


### Edit "multipie_init.m"

As the first step, open **"multipie_init.m"** file located at the project root directory, and modify as follows.

First of all, see the following part of the code.

    opts.viewpoint = 90:-15:-90;
    opts.partpoolsize = 39+68+39;

**opts.viewpoint** is a list consisting of the viewpoint angles which the objects face towards. As for the original setting above, for example, it means that we aim to detect the human faces each of which is heading at 90 degree, 75 degree, ..., -90 degree respectively. (zero degree corresponds to the frontal view.)

**opts.partpoolsize** is a sum over the number of parts of every different model. In the original setting, we have total of 3 different models for detecting the left, front, and right side of faces. These three models are composed of 39, 68, and 39 parts respectively. Thus we have the value of 39+68+39 in result.

Change these two properly to work well with your model. For instance, if we want to use a single model composed of 15 parts, and viewpoints to detect are 15, 0, and -15 degree, then the code above should be modified like:

    opts.viewpoint = [15, 0, -15];
    opts. partpoolsize = 15;

And then, we specify the structure of our single or mixtured models concretly. Considering the original code again, we have mixture of 13 models, and model 1 to 3 are of left side view, 4 to 9 are front view, and the rest of them, 10 to 13 are of right side view. For better understanding, illustration of model 7 is like:

![front view model among the original mixture of models]
(https://app.box.com/representation/file_version_46475297905/image_2048/1.png?shared_name=gzgx1r7gjffb1f9ebjhyng73ezg0gt5u)

Note that every point in the figure above is labeled with an unique ID number. For the convenience of annotation work, we have two types of labeling orders, one of which is **annotation order** (left), and the other is **tree order** (right).


