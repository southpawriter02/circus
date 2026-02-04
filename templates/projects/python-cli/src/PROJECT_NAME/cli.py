"""CLI entry point for {{PROJECT_NAME}}."""

import click


@click.command()
@click.option("--name", default="World", help="Name to greet")
@click.version_option()
def main(name: str) -> None:
    """{{PROJECT_NAME}} - A CLI application."""
    click.echo(f"Hello, {name}!")


if __name__ == "__main__":
    main()
