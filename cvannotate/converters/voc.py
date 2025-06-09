import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Iterable
from ..types import ImageAnnotation, BoundingBox


def read_voc(path: Path) -> ImageAnnotation:
    tree = ET.parse(path)
    root = tree.getroot()
    size = root.find("size")
    width = int(size.find("width").text)
    height = int(size.find("height").text)
    filename = root.findtext("filename") or path.stem
    boxes = []
    for obj in root.findall("object"):
        name = obj.findtext("name")
        bndbox = obj.find("bndbox")
        xmin = float(bndbox.findtext("xmin"))
        ymin = float(bndbox.findtext("ymin"))
        xmax = float(bndbox.findtext("xmax"))
        ymax = float(bndbox.findtext("ymax"))
        class_id = int(obj.findtext("name_id") or 0)
        boxes.append(BoundingBox(class_id, xmin, ymin, xmax, ymax))
    return ImageAnnotation(filename, width, height, boxes)


def write_voc(ann: ImageAnnotation, path: Path, class_map: Iterable[str]):
    root = ET.Element("annotation")
    ET.SubElement(root, "filename").text = ann.filename
    size = ET.SubElement(root, "size")
    ET.SubElement(size, "width").text = str(ann.width)
    ET.SubElement(size, "height").text = str(ann.height)
    ET.SubElement(size, "depth").text = "3"

    for box in ann.boxes:
        obj = ET.SubElement(root, "object")
        name = class_map[box.class_id]
        ET.SubElement(obj, "name").text = name
        bndbox = ET.SubElement(obj, "bndbox")
        ET.SubElement(bndbox, "xmin").text = str(int(box.xmin))
        ET.SubElement(bndbox, "ymin").text = str(int(box.ymin))
        ET.SubElement(bndbox, "xmax").text = str(int(box.xmax))
        ET.SubElement(bndbox, "ymax").text = str(int(box.ymax))
    tree = ET.ElementTree(root)
    path.parent.mkdir(parents=True, exist_ok=True)
    tree.write(path)
