# https://community.hex-rays.com/t/using-a-virtualenv-for-idapython/261/9
from pathlib import Path
import builtins
import os
import sys
import site

IDAUSR = Path(idaapi.get_user_idadir())
VENV = IDAUSR / "venv"

_SENTINEL = "_hcli_idapython_venv_initialized"

def activate_venv_once(venv: Path):
    # already initialized in this process
    if getattr(builtins, _SENTINEL, False):
        return

    # already effectively active
    if Path(sys.prefix).resolve() == venv.resolve():
        setattr(builtins, _SENTINEL, True)
        return

    ver = f"{sys.version_info.major}.{sys.version_info.minor}"
    site_packages = venv / "lib" / f"python{ver}" / "site-packages"
    if site_packages.exists():
        site.addsitedir(str(site_packages))

    sys.prefix = str(venv)
    setattr(builtins, _SENTINEL, True)

activate_venv_once(VENV)
