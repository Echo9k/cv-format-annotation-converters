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
