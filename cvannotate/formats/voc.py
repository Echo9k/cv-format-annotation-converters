from __future__ import annotations

from pathlib import Path
from typing import Any, Dict, List

from lxml import etree

DEFAULT_SUFFIX = ".xml"


def read_voc(path: Path) -> List[Dict[str, Any]]:
    tree = etree.parse(str(path))
    root = tree.getroot()
    filename = root.findtext("filename") or path.with_suffix(".jpg").name
    size = root.find("size")
    width = int(size.findtext("width")) if size is not None and size.findtext("width") else None
    height = int(size.findtext("height")) if size is not None and size.findtext("height") else None
    anns = []
    objects = root.findall("object")
    objs = []
    for obj in objects:
        name = obj.findtext("name")
        bbox = obj.find("bndbox")
        xmin = int(float(bbox.findtext("xmin")))
        ymin = int(float(bbox.findtext("ymin")))
        xmax = int(float(bbox.findtext("xmax")))
        ymax = int(float(bbox.findtext("ymax")))
        objs.append({"name": name, "bbox": [xmin, ymin, xmax, ymax]})
    anns.append({"filename": filename, "width": width, "height": height, "objects": objs})
    return anns


def write_voc(ann: Dict[str, Any], path: Path) -> None:
    root = etree.Element("annotation")
    etree.SubElement(root, "filename").text = ann["filename"]
    size_el = etree.SubElement(root, "size")
    etree.SubElement(size_el, "width").text = str(ann["width"])
    etree.SubElement(size_el, "height").text = str(ann["height"])
    etree.SubElement(size_el, "depth").text = "3"
    for obj in ann["objects"]:
        obj_el = etree.SubElement(root, "object")
        etree.SubElement(obj_el, "name").text = obj["name"]
        bndbox = etree.SubElement(obj_el, "bndbox")
        xmin, ymin, xmax, ymax = obj["bbox"]
        etree.SubElement(bndbox, "xmin").text = str(xmin)
        etree.SubElement(bndbox, "ymin").text = str(ymin)
        etree.SubElement(bndbox, "xmax").text = str(xmax)
        etree.SubElement(bndbox, "ymax").text = str(ymax)

    tree = etree.ElementTree(root)
    tree.write(str(path), pretty_print=True)
