# BeerClassifier

Classify your beer bottles using Core ML and Keras.  
Demo app for this presentation: [Core ML 🏃 iOS Engineer](https://speakerdeck.com/_shingt/core-ml-ios-engineer)

<img width=200 src="https://user-images.githubusercontent.com/1391330/34070759-3e81a024-e2af-11e7-95c8-6f63297d8688.gif">

Note that after I tap `Download New Model`, app starts recognizing `Ho*gaarden` as well.

## Requirements

* Swift 4.2
* Xcode 10.0
* Python 3.6
* virtualenv
* pip

## Setup

```sh
virtualenv --system-site-packages ./
source ./bin/activate
pip install -r requirements.txt
```

## Overview

Before running scripts 

```sh
source ./bin/activate
```

### `scraper.py`

Download images using Microsoft Cognitive API.
Note that you need to register Azure and set your azure key as `AZURE_KEY` in `.env`.

```sh
python scripts/general/scraper.py
```

### `preprocess.py`

Crop and resize all images.

```sh
python scripts/keras/preprocess.py
```

### `create_data_csv.py`

Create `train_data.csv` and `test_data.csv`.

```sh
python scripts/keras/create_data_csv.py
```

### `train.py`

Train using collected images and create model file.

```sh
python scripts/keras/train.py
```

### `convert_to_mlmodel.py`

Convert keras model file to `.mlmodel` format.

```sh
python scripts/general/convert_to_mlmodel.py
```

---

## Using turicreate

### `convert_image_format.py`

```sh
python scripts/turicreate/convert_image_format.py
```

### `create_sframe.py`

```sh
python scripts/turicreate/create_sframe.py
```

### `train.py`

```sh
python scripts/turicreate/train.py
```

