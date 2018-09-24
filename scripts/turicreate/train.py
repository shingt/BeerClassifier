import turicreate as tc

data = tc.SFrame('resources/data.sframe')

# Split to train and test data
train_data, test_data = data.random_split(0.8)

# Create model
model = tc.image_classifier.create(train_data, target='category_name', max_iterations=50)

# Save predictions to an SArray
predictions = model.predict(test_data)

# Evaluate the model and save the results into a dictionary
metrics = model.evaluate(test_data)
print(metrics['accuracy'])

model.save('./models/BeerClassifierTuri.model')
model.export_coreml('./models/BeerClassifierTuri.mlmodel')

