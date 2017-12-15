import os

def make_dir(path):
    if not os.path.isdir(path):
        os.mkdir(path)

def is_img(path):
    extensions = {".jpg", "jpeg", ".png", ".bmp"}
    return any(path.endswith(ext) for ext in extensions)

