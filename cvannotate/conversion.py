from pathlib import Path
from typing import List, Optional

from PIL import Image

from .formats import voc, yolo, coco

SUPPORTED_FORMATS = {"voc", "yolo", "coco"}


def convert(
    input_path: Path,
    output_dir: Path,
    format_from: str,
    format_to: str,
    *,
    width: Optional[int] = None,
    height: Optional[int] = None,
    classes: Optional[List[str]] = None,
    overwrite: bool = False,
) -> List[Path]:
    """Convert annotation files.

    Returns list of output paths created.
    """
    format_from = format_from.lower()
    format_to = format_to.lower()
    if format_from not in SUPPORTED_FORMATS or format_to not in SUPPORTED_FORMATS:
        raise ValueError("Unsupported format")

    output_dir.mkdir(parents=True, exist_ok=True)

    if format_from == "voc":
        anns = voc.read_voc(input_path)
    elif format_from == "yolo":
        anns = yolo.read_yolo(input_path, width=width, height=height, classes=classes)
    else:  # coco
        anns = coco.read_coco(input_path)

    for ann in anns:
        if (ann.get("width") is None or ann.get("height") is None) and width and height:
            ann["width"] = width
            ann["height"] = height
        if (ann.get("width") is None or ann.get("height") is None) and width is None and height is None:
            # try pillow
            img_path = input_path.with_name(ann["filename"])
            if img_path.exists():
                with Image.open(img_path) as img:
                    ann["width"], ann["height"] = img.size

    outputs = []
    for ann in anns:
        out_path = output_dir / ann["filename"].replace(Path(ann["filename"]).suffix, voc.DEFAULT_SUFFIX if format_to == "voc" else yolo.DEFAULT_SUFFIX if format_to == "yolo" else ".json")
        if not overwrite and out_path.exists():
            continue
        if format_to == "voc":
            voc.write_voc(ann, out_path)
        elif format_to == "yolo":
            yolo.write_yolo(ann, out_path, classes=classes)
        else:
            coco.write_coco([ann], out_path)
        outputs.append(out_path)
    return outputs
