from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, List, Optional

DEFAULT_SUFFIX = ".txt"


def read_classes(classes: Optional[List[str]] | Optional[Path]) -> List[str]:
    if classes is None:
        return []
    if isinstance(classes, list):
        return classes
    if isinstance(classes, (str, Path)) and Path(classes).exists():
        with open(classes) as f:
            return [c.strip() for c in f.readlines() if c.strip()]
    raise ValueError("Invalid classes parameter")


def read_yolo(path: Path, *, width: Optional[int] = None, height: Optional[int] = None, classes: Optional[List[str]] = None) -> List[Dict[str, Any]]:
    cls_names = read_classes(classes)
    objs = []
    with open(path) as f:
        for line in f:
            if not line.strip():
                continue
            parts = line.split()
            cls_id = int(parts[0])
            xc, yc, w, h = [float(p) for p in parts[1:5]]
            if width and height:
                xmin = (xc - w / 2) * width
                ymin = (yc - h / 2) * height
                xmax = (xc + w / 2) * width
                ymax = (yc + h / 2) * height
                bbox = [xmin, ymin, xmax, ymax]
            else:
                bbox = [xc, yc, w, h]
            name = cls_names[cls_id] if cls_names and cls_id < len(cls_names) else str(cls_id)
            objs.append({"name": name, "bbox": bbox})
    filename = path.with_suffix('.jpg').name
    return [{"filename": filename, "width": width, "height": height, "objects": objs}]


def write_yolo(ann: Dict[str, Any], path: Path, *, classes: Optional[List[str]] = None) -> None:
    cls_names = read_classes(classes)
    with open(path, 'w') as f:
        for obj in ann["objects"]:
            try:
                cls_id = cls_names.index(obj["name"])
            except ValueError:
                cls_names.append(obj["name"])
                cls_id = len(cls_names) - 1
            bbox = obj["bbox"]
            if ann.get("width") and ann.get("height") and len(bbox) == 4 and bbox[0] < bbox[2]:
                width = ann["width"]
                height = ann["height"]
                xc = (bbox[0] + bbox[2]) / 2 / width
                yc = (bbox[1] + bbox[3]) / 2 / height
                w = (bbox[2] - bbox[0]) / width
                h = (bbox[3] - bbox[1]) / height
                yolo_box = [xc, yc, w, h]
            else:
                yolo_box = bbox
            f.write(f"{cls_id} {' '.join(str(x) for x in yolo_box)}\n")
