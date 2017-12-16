# BeerClassifier

Classify your beer bottles using Core ML and Keras.

<img width=200 src="https://user-images.githubusercontent.com/1391330/34070717-640ea360-e2ae-11e7-99ec-7f370b6c353d.gif">

Note that after I touched `Download New Model` app starts recognizing `Ho*gaarden` as well.

## Requirements

* Swift 4.0
* Xcode 9.2
* Python 2.7
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
python scripts/scraper.py
```

### `preprocess.py`

Crop and resize all images.

```sh
python scripts/preprocess.py
```

### `create_data_csv.py`

Create `train_data.csv` and `test_data.csv`.

```sh
python scripts/create_data_csv.py
```

### `train.py`

Train using collected images and create model file.

```sh
python scripts/train.py
```

### `convert.py`

Convert keras model file to `.mlmodel` format.

```sh
python scripts/convert.py
```

