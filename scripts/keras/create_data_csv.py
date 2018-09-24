import os
import random
import sys

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from utils import make_dir, is_img

source_dir = "./images/preprocessed/"
beer_indexes = {
        "Budweiser": 0,
        "Corona": 1,
        "Heineken": 2,
        "Hoegaarden": 3,
        }

train_csv_path = "./texts/train_data2.csv"
test_csv_path = "./texts/test_data2.csv"
f_train = open(train_csv_path, 'w')
f_test = open(test_csv_path, 'w')

for (beer, index) in beer_indexes.items():
    beer_root = os.path.join(source_dir, beer)
    for root, _, files in os.walk(beer_root):
        for file in files:
            path = os.path.join(root, file)
            if is_img(path):
                line = str(index) + ","  + path + "\n"
                if random.random() < 0.8:
                    f_train.write(line)
                else:
                    f_test.write(line)

f_train.close()
f_test.close()

