# -*- mode: python ; coding: utf-8 -*-
# Twenty_Tools.spec
# Place this file in the same folder as scp_tool.py and twenty_tools.ico
# Run with: python -m PyInstaller Twenty_Tools.spec

import os
SPEC_DIR = os.path.dirname(os.path.abspath(SPEC))  # folder containing this .spec

a = Analysis(
    [os.path.join(SPEC_DIR, 'Twenty_Tools.py')],
    pathex=[SPEC_DIR],
    binaries=[],
    datas=[],
    hiddenimports=[
        'paramiko',
        'paramiko.transport',
        'paramiko.auth_handler',
        'paramiko.channel',
        'paramiko.client',
        'cryptography',
        'cryptography.hazmat.primitives',
        'cryptography.hazmat.backends',
        'cryptography.hazmat.backends.openssl',
        '_cffi_backend',
    ],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=['matplotlib', 'numpy', 'pandas', 'scipy', 'PIL', 'cv2'],
    noarchive=False,
    optimize=1,
)

pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='Twenty_Tools',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,          # No black console window behind the app
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon=os.path.join(SPEC_DIR, 'twenty_tools.ico'),  # absolute path to icon
)
