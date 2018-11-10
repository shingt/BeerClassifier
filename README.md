# BeerClassifier

Classify your beer bottle images using Core ML and Keras / Turi Create.  
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
virtualenv -p python3 ./
source ./bin/activate
pip install -r requirements.txt
```

## Usage

Before running any script, run:

```sh
source ./bin/activate
```

## General scripts

### `scraper.py`

Downloads images using Microsoft Cognitive API.
Note that you need to register Azure and set your azure key as `AZURE_KEY` in `.env`.

```sh
python scripts/scraper.py
```

### `quantize.py`

```sh
python scripts/quantize.py -i ./models/BeerClassifier.mlmodel -o ./models/BeerClassifierQuantized.mlmodel
```

## Keras-targetted scripts

### `keras/preprocess.py`

Crops and resize all images.

```sh
python scripts/keras/preprocess.py
```

### `keras/create_data_csv.py`

Creates `train_data.csv` and `test_data.csv`.

```sh
python scripts/keras/create_data_csv.py
```

### `keras/train.py`

Trains using collected images to create model file.

```sh
python scripts/keras/train.py
```

### `keras/hdf5_to_mlmodel.py`

Converts keras model (in HDF5) file to `.mlmodel` format.

```sh
python scripts/keras/hdf5_to_mlmodel.py
```

## TuriCreate-targetted scripts

### `turicreate/convert_image_format.py`

Convert images to turicreate-supporting formats.

```sh
python scripts/turicreate/convert_image_format.py
```

### `turicreate/create_sframe.py`

Create an sframe file from prepared images.

```sh
python scripts/turicreate/create_sframe.py
```

### `turicreate/train.py`

Trains using prepared images and and sframe file to create model file.

```sh
python scripts/turicreate/train.py
```

