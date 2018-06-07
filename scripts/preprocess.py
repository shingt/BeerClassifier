import os
import numpy as np
import cv2

from utils import make_dir, is_img

def crop_and_resize(img, side):
    (rows, cols, channels) = img.shape
    if cols > rows:
        offset = (cols - rows) / 2
        crop_img = img[0:rows, offset:offset + rows]
    else:
        offset = (rows - cols) / 2
        crop_img = img[offset:offset + cols, 0:cols]
    resize = (side, side)
    try:
        resized = cv2.resize(crop_img, resize, interpolation=cv2.INTER_AREA)
        return resized
    except Exception as err:
        print("Resizing error. image shape:" + str(crop_img.shape))
        raise err

input_dir = "./images/original/"
output_dir = "./images/preprocessed/"
size = 32

for root, _, files in os.walk(input_dir):
    for file in files:
        if not is_img(file):
            continue
        sem_root = root.replace(input_dir, "")
        sem_file = os.path.join(sem_root, file)
        input_img_path = os.path.join(input_dir, sem_file)
        output_img_path = os.path.join(output_dir, sem_file)
        
        print("Converting " + input_img_path + " => " + output_img_path)

        img = cv2.imread(input_img_path, cv2.IMREAD_COLOR)
        try:
            cropped_img = crop_and_resize(img, size)
        except Exception as err:
            print(err)
            break
   
        if not cv2.imwrite(output_img_path, cropped_img):
            print("Oops failed to writing image!")
