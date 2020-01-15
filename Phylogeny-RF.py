from random import seed
from random import randrange
from csv import reader
from math import sqrt
from sklearn import metrics
import  statistics
import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
#https://www.dataquest.io/blog/learning-curves-machine-learning/
 
# Load a CSV file
def load_csv(filename):
        dataset = list()
        with open(filename, 'r') as file:
                csv_reader = reader(file)
                for row in csv_reader:
                        if not row:
                                continue
                        dataset.append(row)
        return dataset
 
# Convert string column to float
def str_column_to_float(dataset, column):
            for row in dataset:
                #print(row)
                #print("hello")
                #print(column)
                row[column] = float(row[column].strip())

def str_row_to_int(dataset):
        for row in dataset:
                for column in range(0, len(row)-1):
                        #print(row[column])
                        row[column] = int(row[column])

# Convert string column to integer
def str_column_to_int(dataset, column):
        class_values = [row[column] for row in dataset]
        unique = set(class_values)
        lookup = dict()
        for i, value in enumerate(unique):
                lookup[value] = i
        for row in dataset:
                row[column] = lookup[row[column]]
        return lookup
 
# Split a dataset into k folds
def cross_validation_split(dataset, n_folds):
        dataset_split = list()
        dataset_copy = list(dataset)
        fold_size = int(len(dataset) / n_folds)
        for i in range(n_folds):
                fold = list()
                while len(fold) < fold_size:
                        index = randrange(len(dataset_copy))
                        fold.append(dataset_copy.pop(index))
                dataset_split.append(fold)
        return dataset_split
    
def accuracy_metric2(actual, predicted):
        params = list()
        kappa = 0
        accuracys = 0
        pr=0
        rc=0
        accuracys=accuracy_metric(actual, predicted)
        kappa = metrics.cohen_kappa_score(actual,predicted)
        pr = metrics.precision_score(actual,predicted,average=None)
        rc=metrics.recall_score(actual,predicted,average=None)
        #roc=metrics.roc_auc_score(actual,predicted)
        #params.append(kappa)
        params.append(accuracys)
        params.append(kappa)
        params.append(pr)
        params.append(rc)
        return params
        
 
# Calculate accuracy percentage
def accuracy_metric(actual, predicted):
        correct = 0
        kappa = metrics.cohen_kappa_score(actual,predicted)
        #print(kappa)
        for i in range(len(actual)):
                if actual[i] == predicted[i]:
                        correct += 1
        return correct / float(len(actual)) * 100.0
 
# Evaluate an algorithm using a cross validation split
def evaluate_algorithm(dataset, algorithm, clusters, n_folds, *args):
        folds = cross_validation_split(dataset, n_folds)
        scores = list()
        param = list()
        kappac = list()
        accuracyc = list()
        prc=list()
        rc=list()
        accur = list()
        accur_allTree = list()
        tree_pred = list()
       #rocc=list()
        for fold in folds:
                train_set = list(folds)
                train_set.remove(fold)
                train_set = sum(train_set, [])
                test_set = list()
                for row in fold:
                        row_copy = list(row)
                        test_set.append(row_copy)
                        row_copy[-1] = None
                predicted, Parray = algorithm(train_set, test_set, clusters, *args)
                #predicted = algorithm(train_set, test_set, clusters, *args)
                actual = [row[-1] for row in fold]
                for t in range(len(Parray[0])):
                    tree_pred.clear()
                    for j in range(len(Parray) ):
                        tree_pred.append(Parray[j][t])
                    accur_allTree.append(accuracy_metric(actual, tree_pred))
                accuracy = accuracy_metric(actual, predicted)
                param = accuracy_metric2(actual, predicted)
                #kappac.append(param[1])
                accuracyc.append(param[0])
                kappac.append(param[1])
                accur.append(accuracy)
                prc.append(param[2])
                rc.append(param[3])
                #print(accur)
                #print(len(accur))
                #plt.boxplot(accur_allTree)
                #rocc.append(param[2])
        #scores.append(statistics.mean(accur))
        scores.append(statistics.mean(accuracyc))
        scores.append(statistics.mean(kappac))
        scores.append(prc)
        scores.append(rc)
            #print(scores.append((sum(accur)/float(len(accur)))))
                #scores.append((sum(accuracyc)/float(len(accuracyc))))
                #scores.append((sum(rocc)/float(len(rocc))))
                #print(accur_allTree)
                #scores.append(statistics.mean(accur_allTree))
                #scores.append(statistics.stdev(accur_allTree))
        print(*accuracyc)
        print(*kappac)
        print("precision is ",*prc)
        print("recall is ",*rc)
        #scores.append(statistics.mean(kappac))
        #scores.append(statistics.mean(accur))
        return scores,accur ;
 
# Split a dataset based on an attribute and an attribute value
def test_split(index, value, dataset):
        left, right = list(), list()
        for row in dataset:
                if row[index] < value:
                        left.append(row)
                else:
                        right.append(row)
        return left, right
 
# Calculate the Gini index for a split dataset
def gini_index(groups, classes):
        # count all samples at split point
        n_instances = float(sum([len(group) for group in groups]))
        # sum weighted Gini index for each group
        gini = 0.0
        for group in groups:
                size = float(len(group))
                # avoid divide by zero
                if size == 0:
                        continue
                score = 0.0
                # score the group based on the score for each class
                for class_val in classes:
                        p = [row[-1] for row in group].count(class_val) / size
                        score += p * p
                # weight the group score by its relative size
                gini += (1.0 - score) * (size / n_instances)
        return gini
 
# Select the best split point for a dataset
def get_split(dataset, n_features, clusters):
        class_values = list(set(row[-1] for row in dataset))
        b_index, b_value, b_score,b_groups = 999, 999, 999, None
        features = list()
        clust_nu  = 0
        #print(clust_nu)
       # print(n_features)
        while clust_nu < n_features:
                #index = randrange(len(dataset[0])-1)
                index1 = randrange(len(clusters[clust_nu])-1)
                #print(index1)
                index  = clusters[clust_nu][index1]
                #print("post")
                #print(index)
                index_total = len(dataset[0])
                #print(index_total)
                features.append(index)
                clust_nu  =  clust_nu + 1
                #print(features)
        for index in features:
                for row in dataset:
                        #print(index,row[index])
                        groups = test_split(index, row[index], dataset)
                        #print('harry')
                        #print(index)
                        #print(*groups)
                        #print(*class_values)
                        #print(*row)
                        #k_factor = ((index * 0.5)/index_total) +  0.5
                        gini = gini_index(groups, class_values)
                        if gini < b_score:
                                b_index, b_value, b_score, b_groups = index, row[index], gini, groups
        #print(features)
        return {'index':b_index, 'value':b_value, 'groups':b_groups}
# Create a terminal node value
def to_terminal(group):
        outcomes = [row[-1] for row in group]
        return max(set(outcomes), key=outcomes.count)
 
# Create child splits for a node or make terminal
def split(node, max_depth, min_size, n_features, depth):
       # print("split")
       # print(n_features)
        left, right = node['groups']
        del(node['groups'])
        # check for a no split
        if not left or not right:
                node['left'] = node['right'] = to_terminal(left + right)
                return
        # check for max depth
        if depth >= max_depth:
                node['left'], node['right'] = to_terminal(left), to_terminal(right)
                return
        # process left child
        if len(left) <= min_size:
                node['left'] = to_terminal(left)
        else:
                node['left'] = get_split(left, n_features, clusters)
                split(node['left'], max_depth, min_size, n_features, depth+1)
        # process right child
        if len(right) <= min_size:
                node['right'] = to_terminal(right)
        else:
                node['right'] = get_split(right, n_features, clusters)
                split(node['right'], max_depth, min_size, n_features, depth+1)
 
# Build a decision tree
def build_tree(train, max_depth, min_size, n_features,clusters):
        root = get_split(train, n_features, clusters)
        split(root, max_depth, min_size, n_features, 1)
        return root
 
# Make a prediction with a decision tree
def predict(node, row):
        #print(node['index'])
        #print(row[node['index']])
        #print(node['value'])
        if row[node['index']] < node['value']:
                if isinstance(node['left'], dict):
                        return predict(node['left'], row)
                else:
                        return node['left']
        else:
                if isinstance(node['right'], dict):
                        return predict(node['right'], row)
                else:
                        return node['right']
 
# Create a random subsample from the dataset with replacement
def subsample(dataset, ratio):
        sample = list()
        n_sample = round(len(dataset) * ratio)
        while len(sample) < n_sample:
                index = randrange(len(dataset))
                sample.append(dataset[index])
        return sample
 
# Make a prediction with a list of bagged trees
def bagging_predict(trees, row):
        predictions = [predict(tree, row) for tree in trees]
        return max(set(predictions), key=predictions.count)
    
def bagging_predict1(trees, row):
        predictions = [predict(tree, row) for tree in trees]
        pred = max(set(predictions), key=predictions.count)
        #print(predictions)
        return predictions
 
# Random Forest Algorithm
def random_forest(train, test, clusters, max_depth, min_size, sample_size, n_trees, n_features):
        trees = list()
        predictionsS = list()
        for i in range(n_trees):
                sample = subsample(train, sample_size)
                tree = build_tree(sample, max_depth, min_size, n_features, clusters)
                trees.append(tree)
        #predictions = [bagging_predict(trees, row) for row in test]
        predS = [bagging_predict(trees, row) for row in test]
        for row in test:
                p_one = bagging_predict1(trees, row)
                #print(p_one)
                predictionsS.append(p_one)
        #return(predictions)
        return(predS,predictionsS)
 
# Test the random forest algorithm
seed(2)
# load and prepare data
#filename = 'throtaIAPINAdata.csv'
#filename = 'C:\Perl64\HMPO.csv'
#filename2 = 'C:\Perl64\humancluster.csv' 
#filename = 'C:\Perl64\HTSIP_OTUabun.csv'
#filename2 = 'C:\Perl64\cbhclust52.csv' 
#filename = 'C:\Perl64\cbhotu2683.csv'
filename= "C:\Perl64\level-7_dex.csv"
filename2 ="C:\Perl64\omdexf.csv"
t=1
#filename2 = 'C:\Perl64\tcl29.csv' 
print(filename)
print(filename2)
print(t)
dataset = load_csv(filename)
clusters = load_csv(filename2)
#print(len(clusters))
# convert string attributes to integers
for i in range(0, len(dataset[0])-1):
        str_column_to_float(dataset, i)

str_row_to_int(clusters)
#print(type(clusters[3][1]))
#print(len(clusters))

# convert class column to integers
str_column_to_int(dataset, len(dataset[0])-1)
# evaluate algorithm
n_folds = 5
max_depth = 6 
min_size = 1
sample_size = 1.0
#n_features = int(sqrt(len(dataset[0])-1))
n_features = int(len(clusters))
#print(*dataset[1])
#for n_trees in [64,100,128,164,200,225,300]:
for n_trees in [64,100,128,164,200,225,300]:
        scores,accur = evaluate_algorithm(dataset, random_forest, clusters, n_folds, max_depth, min_size, sample_size, n_trees, n_features)
        print('Trees: %s ' % n_trees)
        #print('Scores: %s' % scores)
        #print( *accur)
        print('Mean Accuracy: %.3f%%'  % scores[0])
        print('Mean kappa: %.3f%%'  % scores[1])
        print('Final Precision:', scores[2])
        print('Final Recall:', scores[3])
        #print(*accur)
        #print('Mean roc: %.3f%%'  % scores[2])
       # print('Individual Trees Mean: %.3f%%' % scores[2])
        #print('Individual Trees Std Deviation: %.3f%%' % scores[3])
        