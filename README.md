# TCPM (Tree Structured Parts Model) Tutorial


----

## Table of Contents

----

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

