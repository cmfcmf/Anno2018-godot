import os
import re
import json
from PIL import Image

export_directory = os.path.join('..', 'tiles')
image_directory = os.path.join(export_directory, 'anno-stadtfld')
tilemap = {
    "columns": 0,
    "grid": {
        "height": 31,
        "orientation": "isometric",
        "width": 64
    },
    "margin": 0,
    "name": "anno-stadtfld",
    "spacing": 0,
    "tilecount": None,
    "tileheight": None,
    "tilewidth": None,
    "type": "tileset",
    "version":1.2,
    "tiles": [],
}

cnt = 0
max_width = 0
max_height = 0

for file in os.listdir(image_directory):
    if file.endswith(".import"):
        continue
    result = re.match(r"^Bild(\d+)\.png$", file)
    if not result:
        raise Exception('Unknown file: ' + file)

    id = result.group(1)

    with Image.open(os.path.join(image_directory, file)) as img:
        width, height = img.size

    max_width = max(max_width, width)
    max_height = max(max_height, height)

    tilemap['tiles'].append({
        'id': id,
        'image': 'anno-stadtfld/' + file,
        'imageheight': height,
        'imagewidth': width,
    })

    cnt += 1

tilemap['tilecount'] = cnt
tilemap['tileheight'] = max_height
tilemap['tilewidth'] = max_width

json.dump(tilemap, open(os.path.join(export_directory, 'anno-stadtfld.json'), encoding='utf-8', mode='w'), sort_keys=True, indent=2)
