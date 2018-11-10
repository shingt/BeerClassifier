import os
import sys
import numpy as np
import cv2

sys.path.append(os.path.join(os.path.dirname(__file__), '..'))
from utils import make_dir, is_img

input_dir = "./images/original/"
output_dir = "./images/format_converted/"
make_dir(output_dir)

for root, _, files in os.walk(input_dir):
    for file in files:
        if not is_img(file):
            continue
        sem_root = root.replace(input_dir, "")
        sem_file = os.path.join(sem_root, file)
        input_img_path = os.path.join(input_dir, sem_file)
        output_img_path = os.path.join(output_dir, sem_file)
       
        print("Converting " + input_img_path + " => " + output_img_path)

        make_dir(os.path.dirname(output_img_path))
        img = cv2.imread(input_img_path, cv2.IMREAD_COLOR)

        if not cv2.imwrite(output_img_path, img, cv2.IMWRITE_JPEG_QUALITY):
            print("Oops failed to writing image!")

