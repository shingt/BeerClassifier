import coremltools
import sklearn
from coremltools.models.neural_network.quantization_utils import *
import sys, getopt

input_file = ''
output_file = ''

def print_usage():
    print("Usage: quantize.py -i <input_file> -o <output_file>")

argv = sys.argv[1:]
opts, args = getopt.getopt(argv, "hi:o:", ["ifile=", "ofile="])
for opt, arg in opts:
    if opt == '-h':
        print_usage()
        sys.exit()
    elif opt in ("-i", "--ifile"):
        input_file = arg
    elif opt in ("-o", "--ofile"):
        output_file = arg

if len(input_file) == 0 or len(output_file) == 0:
    print_usage()
    sys.exit(1)

print("Input: " + input_file)
print("Output: " + output_file)

model = coremltools.models.MLModel(input_file)

lut_quant_model = quantize_weights(model, 8, "kmeans")
lut_quant_model.save(output_file)

