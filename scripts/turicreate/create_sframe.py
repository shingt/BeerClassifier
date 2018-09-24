import turicreate as tc
import os

# Load images
data = tc.image_analysis.load_images('./images/format_converted', with_path=True)

# Create label column based on folder name
data['category_name'] = data['path'].apply(lambda path: os.path.basename(os.path.dirname(path)))

# Save as .sframe
data.save('./resources/data.sframe')

