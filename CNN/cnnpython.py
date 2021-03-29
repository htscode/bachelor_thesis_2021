#!/usr/bin/env python
# coding: utf-8

# In[ ]:


#%load_ext tensorboard

#import datetime
import numpy as np
import scipy.io as sio
#import matplotlib as plt

import os

#added
import h5py

#import tensorflow as tf

import tensorflow.compat.v1 as tf
tf.disable_v2_behavior()


# In[ ]:


#clear tensorboard logs


# ### Load the data

# In[35]:


vols = h5py.File("/scratch/hterborg/brute_force/Thesis/zero_3_runs_15_train_1_test_dataset.mat",'r')

                 #small15_1_dataset.mat)


# In[36]:


vols

list(vols.keys())


# In[37]:


X_train, y_train, X_test, y_test,trainsubjects,testsubjects = vols['train_x'], vols['train_y'], vols['test_x'], vols['test_y'],vols['trainsubjects'],vols['testsubject']
n_classes = 2


# In[1]:


X_train=np.transpose(X_train)
y_train=np.transpose(y_train)
X_test=np.transpose(X_test)
y_test=np.transpose(y_test)


# In[ ]:


X_train


# In[ ]:


trainsubjects


# In[ ]:


y_train


# In[ ]:


print(np.shape(X_train),np.shape(y_train))


# ### z-scoring to normalize the data

# In[ ]:


x_mean = np.mean(X_train)
x_std = np.std(X_train)


# In[ ]:


X_tr_centered = (X_train - x_mean)/x_std
X_ts_centered = (X_test - x_mean)/x_std


# ### 1D array for labels

# In[ ]:


y_train = y_train.flatten()
y_test = y_test.flatten()


# #### Checking out the dimension

# In[ ]:


X_tr_centered.shape,  X_ts_centered.shape


# In[ ]:


np.std(X_tr_centered)


# #### Checking out the image

# ### Batch generator: to generate mini-batches for training

# In[ ]:


def batch_generator(X, y, batch_size=50,
                    shuffle=True, random_seed=None):

    idx = np.arange(y.shape[0])

    if shuffle:
        rng = np.random.RandomState(random_seed)
        rng.shuffle(idx)
        X = X[idx]
        y = y[idx]

    for i in range(0, X.shape[0], batch_size):
        yield (X[i:i+batch_size, :], y[i:i+batch_size])


# ### 3D-CNN class

# In[ ]:


class Conv3dNN(object):
    def __init__(self, n_classes=2, batchsize=50,
                 epochs=100, learning_rate=1e-4,
                 dropout_rate=0.5,
                 shuffle=True, random_seed=None):
        np.random.seed(random_seed)
        self.batchsize = batchsize
        self.epochs = epochs
        self.learning_rate = learning_rate
        self.dropout_rate = dropout_rate
        self.shuffle = shuffle
        self.n_classes = n_classes

        g = tf.Graph()
        with g.as_default():
            ## set random-seed:
            tf.set_random_seed(random_seed)

            ## build the network:
            self.build()

            ## initializer
            self.init_op =                 tf.global_variables_initializer()

            ## saver
            self.saver = tf.train.Saver()

        ## create a session
        self.sess = tf.Session(graph=g)

    def build(self):

        ## Placeholders for X and y:
        tf_x = tf.placeholder(tf.float32,
                              shape=[None, 79, 95, 79],
                              name='tf_x')
        tf_y = tf.placeholder(tf.int32,
                              shape=[None],
                              name='tf_y')
        is_train = tf.placeholder(tf.bool,
                              shape=(),
                              name='is_train')

        ## reshape x to 5D tensor:
        ## [batchsize, x, y, z, 1]
        tf_x_vol = tf.reshape(tf_x, shape=[-1, 79, 95, 79, 1],
                             name='input_x_3d_volumes')

        ## One-hot encoding:
        tf_y_onehot = tf.one_hot(indices=tf_y, depth=2,
                              dtype=tf.float32,
                              name='input_y_onehot')

        ## 1st layer: Conv_1
        h1 = tf.layers.conv3d(tf_x_vol,
                              filters=8,
                              kernel_size=(7, 7, 7),
                              strides=(1, 1, 1),
                              padding='valid',
                              activation=tf.nn.relu)
        ## MaxPooling
        h1_pool = tf.layers.max_pooling3d(h1,
                              pool_size=(2, 2, 2),
                              strides=(2, 2, 2))

        ## 2nd layer: Conv_2
        h2 = tf.layers.conv3d(h1_pool,
                              filters=16,
                              kernel_size=(5, 5, 5),
                              strides=(1,1,1),
                              padding='valid',
                              activation=tf.nn.relu)
        ## MaxPooling
        h2_pool = tf.layers.max_pooling3d(h2,
                              pool_size=(2, 2, 2),
                              strides=(2, 2, 2))

        ## 3rd layer: Conv_3
        h3 = tf.layers.conv3d(h2_pool,
                              filters=32,
                              kernel_size=(3, 3, 3),
                              strides=(1,1,1),
                              padding='valid',
                              activation=tf.nn.relu)
        ## MaxPooling
        h3_pool = tf.layers.max_pooling3d(h3,
                              pool_size=(2, 2, 2),
                              strides=(2, 2, 2))

        ## 4th layer: Fully Connected
        input_shape = h3_pool.get_shape().as_list()
        n_input_units = np.prod(input_shape[1:])
        h3_pool_flat = tf.reshape(h3_pool,
                              shape=[-1, n_input_units])

        h4 = tf.layers.dense(h3_pool_flat, 128,
                              activation=tf.nn.relu)

        ## Dropout
        h4_drop = tf.layers.dropout(h4,
                              rate=self.dropout_rate,
                              training=is_train)

        ## 5th layer: Fully Connected (linear activation)
        h5 = tf.layers.dense(h4_drop, self.n_classes,
                              activation=tf.nn.sigmoid)

        ## Prediction
        predictions = {
            'probabilities': tf.nn.softmax(h5,
                              name='probabilities'),
            'labels': tf.cast(tf.argmax(h5, axis=1),
                              tf.int32, name='labels')}

        ## Loss Function and Optimization
        cross_entropy_loss = tf.reduce_mean(
            tf.nn.softmax_cross_entropy_with_logits(
                logits=h5, labels=tf_y_onehot),
            name='cross_entropy_loss')

        ## Optimizer:
        optimizer = tf.train.AdamOptimizer(self.learning_rate)
        optimizer = optimizer.minimize(cross_entropy_loss,
                              name='train_op')

        ## Finding accuracy
        correct_predictions = tf.equal(
            predictions['labels'],
            tf_y, name='correct_preds')

        accuracy = tf.reduce_mean(
            tf.cast(correct_predictions, tf.float32),
            name='accuracy')

    def save(self, epoch, path='./CNN3d-tflayers-model/'):
        if not os.path.isdir(path):
            os.makedirs(path)
        print('Saving model in %s' % path)
        self.saver.save(self.sess,
                        os.path.join(path, 'zero_model_50.ckpt'),
                        global_step=epoch)

    def load(self, epoch, path):
        print('Loading model from %s' % path)
        self.saver.restore(self.sess,
             os.path.join(path, 'zero_model_50.ckpt-%d' % epoch))

    def train(self, training_set,
              validation_set=None,
              initialize=True):
        ## initialize variables
        if initialize:
            self.sess.run(self.init_op)

        self.train_cost_ = []
        X_data_tr = np.array(training_set[0])
        y_data_tr = np.array(training_set[1])

        for epoch in range(1, self.epochs + 1):
            batch_gen_tr =                 batch_generator(X_data_tr, y_data_tr, batch_size=self.batchsize,
                                 shuffle=self.shuffle)
            avg_loss = 0.0
            for i, (batch_x,batch_y) in                 enumerate(batch_gen_tr):
                feed = {'tf_x:0': batch_x,
                        'tf_y:0': batch_y,
                        'is_train:0': True} ## for dropout
                loss, _ = self.sess.run(
                        ['cross_entropy_loss:0', 'train_op'],
                        feed_dict=feed)
                avg_loss += loss

            print('Epoch %02d: Training Avg. Loss: '
                  '%7.3f' % (epoch, avg_loss), end=' ')
            if validation_set is not None:

                X_data_ts = np.array(training_set[0])
                y_data_ts = np.array(training_set[1])
                # test accuracy
                batch_gen_ts =                 batch_generator(X_data_ts, y_data_ts,
                                 shuffle=False,batch_size=self.batchsize)
                avg_valid_acc = 0.0
                for i, (batch_x,batch_y) in                     enumerate(batch_gen_ts):
                    feed = {'tf_x:0': batch_x,
                            'tf_y:0': batch_y,
                            'is_train:0': False} ## for dropout
                    avg_valid_acc = avg_valid_acc + self.sess.run('accuracy:0', feed_dict=feed)
                avg_valid_acc = avg_valid_acc/(i+1)

                print('Validation Acc: %7.3f' % avg_valid_acc)
            else:
                print()

    def predict(self, X_test, return_proba = False):
        feed = {'tf_x:0': X_test,
                'is_train:0': False} ## for dropout
        if return_proba:
            return self.sess.run('probabilities:0',
                                 feed_dict=feed)
        else:
            return self.sess.run('labels:0',
                                 feed_dict=feed)


# ### Create an instance of the CNN3dNN class, train it, and save the trained model

# In[ ]:


cnn3d = Conv3dNN( random_seed=123,epochs=50, n_classes=n_classes)

cnn3d.train(training_set=(X_tr_centered, y_train),
         validation_set=(X_ts_centered, y_test))

cnn3d.save(epoch=50)


# ### To load the trained model and to test it using data

# In[ ]:


del cnn3d

cnn3d_re = Conv3dNN(random_seed=123)
cnn3d_re.load(epoch=50, path='./CNN3d-tflayers-model/')

print(cnn3d_re.predict(X_ts_centered[:10,:,:,:]))


# ### Accuray for all test data

# In[ ]:


X_ts_centered2 = X_ts_centered[0:100,:,:,:]
y_test2 =y_test[0:100]


# In[ ]:


preds = cnn3d_re.predict(X_ts_centered2)

print('Test Accuracy: {:.2f}'.format( 100 * np.sum(y_test2 == preds)/len(y_test2)))


# In[ ]:



diff = y_test2-preds
print('diff: ',diff)

# Correct is 0
# FP is -1
# FN is 1
print('Correctly classified: ', np.where(diff == 0)[0])
print('Incorrectly classified: ', np.where(diff != 0)[0])
print('False positives: ', np.where(diff == -1)[0])
print('False negatives: ', np.where(diff == 1)[0])


# In[ ]:


np.size(np.where(diff == -1)) #false positive


# In[ ]:


np.size(np.where(diff == 1)) # false negative


# In[ ]:
