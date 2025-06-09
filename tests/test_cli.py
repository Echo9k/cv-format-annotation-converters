from pathlib import Path
from typer.testing import CliRunner

from cvannotate.cli import app

runner = CliRunner()

def test_convert_voc_to_yolo(tmp_path):
    input_xml = Path('tests/data/annotations/img1.xml')
    result = runner.invoke(app, [
        '-i', str(input_xml),
        '-o', str(tmp_path),
        '--format-from', 'voc',
        '--format-to', 'yolo',
        '-w', 'auto',
        '--height', 'auto',
        '-c', 'person',
        '--overwrite',
    ])
    assert result.exit_code == 0
    out_file = tmp_path / 'img1.txt'
    assert out_file.exists()
    text = out_file.read_text().strip()
    assert text.startswith('0 ')


def test_convert_yolo_to_voc(tmp_path):
    input_txt = Path('tests/data/annotations/img1.txt')
    result = runner.invoke(app, [
        '-i', str(input_txt),
        '-o', str(tmp_path),
        '--format-from', 'yolo',
        '--format-to', 'voc',
        '-w', '200',
        '--height', '100',
        '-c', 'person',
        '--overwrite',
    ])
    assert result.exit_code == 0
    out_file = tmp_path / 'img1.xml'
    assert out_file.exists()
    text = out_file.read_text()
    assert '<object>' in text


def test_convert_coco_to_yolo(tmp_path):
    input_json = Path('tests/data/annotations/coco.json')
    result = runner.invoke(app, [
        '-i', str(input_json),
        '-o', str(tmp_path),
        '--format-from', 'coco',
        '--format-to', 'yolo',
        '-w', 'auto',
        '--height', 'auto',
        '-c', 'person',
        '--overwrite',
    ])
    assert result.exit_code == 0
    out_file = tmp_path / 'img1.txt'
    assert out_file.exists()
