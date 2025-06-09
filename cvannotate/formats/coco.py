from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, List
import json

DEFAULT_SUFFIX = ".json"


def read_coco(path: Path) -> List[Dict[str, Any]]:
    with open(path) as f:
        data = json.load(f)

    id_to_filename = {img['id']: img['file_name'] for img in data.get('images', [])}
    id_to_size = {img['id']: (img.get('width'), img.get('height')) for img in data.get('images', [])}
    id_to_category = {cat['id']: cat['name'] for cat in data.get('categories', [])}

    images = {}
    for ann in data.get('annotations', []):
        img_id = ann['image_id']
        filename = id_to_filename[img_id]
        width, height = id_to_size[img_id]
        obj = {
            "name": id_to_category[ann['category_id']],
            "bbox": [ann['bbox'][0], ann['bbox'][1], ann['bbox'][0] + ann['bbox'][2], ann['bbox'][1] + ann['bbox'][3]],
        }
        images.setdefault(filename, {"filename": filename, "width": width, "height": height, "objects": []})
        images[filename]["objects"].append(obj)
    return list(images.values())


def write_coco(anns: List[Dict[str, Any]], path: Path) -> None:
    images = []
    annotations = []
    categories = {}
    ann_id = 1
    for img_id, ann in enumerate(anns, start=1):
        images.append({"id": img_id, "file_name": ann["filename"], "width": ann["width"], "height": ann["height"]})
        for obj in ann["objects"]:
            cat_id = categories.setdefault(obj["name"], len(categories) + 1)
            x1, y1, x2, y2 = obj["bbox"]
            annotations.append({
                "id": ann_id,
                "image_id": img_id,
                "category_id": cat_id,
                "bbox": [x1, y1, x2 - x1, y2 - y1],
                "area": (x2 - x1) * (y2 - y1),
                "iscrowd": 0,
            })
            ann_id += 1
    cats_list = [{"id": cid, "name": name, "supercategory": "none"} for name, cid in categories.items()]
    data = {"images": images, "annotations": annotations, "categories": cats_list}
    with open(path, 'w') as f:
        json.dump(data, f)
