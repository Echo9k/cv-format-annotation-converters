from pathlib import Path
from typing import Optional

import typer
from PIL import Image

from .conversion import convert, SUPPORTED_FORMATS

app = typer.Typer(help="Convert CV annotation formats")


def parse_classes(ctx, param, value):
    if value is None:
        return None
    if Path(value).exists():
        with open(value) as f:
            return [c.strip() for c in f.readlines() if c.strip()]
    return [v.strip() for v in value.split(',') if v.strip()]


@app.command()
def convert_cmd(
    input: Path = typer.Option(..., '-i', help="Input annotation path"),
    output_dir: Path = typer.Option(..., '-o', help="Output directory"),
    format_from: str = typer.Option(..., '--format-from'),
    format_to: str = typer.Option(..., '--format-to'),
    width: Optional[str] = typer.Option('auto', '-w'),
    height: Optional[str] = typer.Option('auto', '--height'),
    classes: Optional[str] = typer.Option(None, '-c', callback=parse_classes),
    overwrite: bool = typer.Option(False, '--overwrite', help="Enable overwriting existing files"),
    verbose: bool = typer.Option(False, '--verbose', '-v'),
):
    """Convert annotations between formats."""
    if width == 'auto':
        width = None
    else:
        width = int(width)
    if height == 'auto':
        height = None
    else:
        height = int(height)

    if format_from not in SUPPORTED_FORMATS or format_to not in SUPPORTED_FORMATS:
        typer.echo(f"Supported formats: {', '.join(SUPPORTED_FORMATS)}")
        raise typer.Exit(1)

    outputs = convert(
        input_path=input,
        output_dir=output_dir,
        format_from=format_from,
        format_to=format_to,
        width=width,
        height=height,
        classes=classes,
        overwrite=overwrite,
    )
    if verbose:
        for p in outputs:
            typer.echo(f"Wrote {p}")


if __name__ == "__main__":
    app()
