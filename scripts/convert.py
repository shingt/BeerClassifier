import coremltools

coreml_model = coremltools.converters.keras.convert('./models/beer_model2.h5',
        input_names = 'image',
        image_input_names = 'image',
        class_labels = './texts/beer_labels2.txt'
        )
coreml_model.license = 'MIT'
coreml_model.short_description = 'Beer Classifier (4 beers version)'
coreml_model.author = 'shingt'
coreml_model.save('./models/BeerClassifier2.mlmodel')

