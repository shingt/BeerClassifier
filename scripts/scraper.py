import os
import math
import httplib
import urllib
import requests
import json
import hashlib
import sha3
import colorama
from colorama import Fore

import settings
from utils import make_dir, is_img

def create_image_path(dir_path, url):
    if not is_img(url):
        print Fore.RED + "Inappropriate file extension: " + url
        return
    encoded_url = url.encode('utf-8')
    hashed_url = hashlib.sha3_256(encoded_url).hexdigest()
    file_extension = os.path.splitext(url)[-1]
    full_path = os.path.join(dir_path, hashed_url + file_extension.lower())
    return full_path

def fetch_image(url):
    headers = {'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36'}
    response = requests.get(
            url, 
            allow_redirects = True, 
            timeout = 10,
            headers = headers
            )
    if response.status_code != 200:
        error = Exception("HTTP status: " + str(response.status_code))
        raise error

    content_type = response.headers["content-type"]
    if 'image' not in content_type:
        error = Exception("Content-Type: " + content_type)
        raise error

    return response.content

def save_image(filename, image):
    fout = open(filename, "wb")
    fout.write(image)

colorama.init(autoreset = True)
azure_key = settings.AZURE_KEY

query = 'Hoegaarden bottle'
num_images = 1000
num_per_transaction = 100
offset_count = math.floor(num_images / num_per_transaction)

print "--- Generating a url list.."

url_list = []
headers = {
    'Content-Type': 'multipart/form-data',
    'Ocp-Apim-Subscription-Key': azure_key,
}

for offset in range(int(offset_count)):
    params = urllib.urlencode({
        'q': query,
        'mkt': 'en-US',
        'count': num_per_transaction,
        'offset': offset * num_per_transaction
    })

    try:
        conn = httplib.HTTPSConnection('api.cognitive.microsoft.com')
        conn.request("GET", "/bing/v7.0/images/search?%s" % params, "{body}", headers)
        response = conn.getresponse()
        data = response.read()
        conn.close()
    except Exception as err:
        print Fore.RED + "Failed to fetch data from cognitive API."
        print("%s" % (err))
    else:
        decode_res = data.decode('utf-8')
        data = json.loads(decode_res)

        if 'value' in data:
            for values in data['value']:
                img_url = urllib.unquote(values['contentUrl'])
                if img_url:
                    url_list.append(img_url)
                else:
                    print Fore.RED + "Unexpected response: contentUrl not found."
                    print data
        else:
            print Fore.RED + "Unexpected response"
            print data

print "--- Fetching images..."

save_dir_path = os.path.join('./images/crawled/', query)
make_dir(save_dir_path)

for url in url_list:
    try:
        img_path = create_image_path(save_dir_path, url)
        image = fetch_image(url)
        save_image(img_path, image)
    except Exception as err:
        print Fore.RED + "Error: " + url
        print("%s" % (err))

