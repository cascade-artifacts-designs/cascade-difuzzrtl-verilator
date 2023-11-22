# Copyright 2023 Flavien Solt, ETH Zurich.
# Licensed under the General Public License, Version 3.0, see LICENSE for details.
# SPDX-License-Identifier: GPL-3.0-only

# Imports the ELFS from the specified directory to the disco-elfs directory.

import os
from tqdm import tqdm

PATH_TO_SRC_ELFS_DIR = '/data/flsolt/tmp/manyelfs'
PATH_TO_DST_ELFS_DIR_ROCKET = 'difuzz-rtl/disco-elfs/RocketTile'
PATH_TO_DST_ELFS_DIR_BOOM = 'difuzz-rtl/disco-elfs/BoomTile'

# Make the destination directories if they don't exist
if not os.path.exists(PATH_TO_DST_ELFS_DIR_ROCKET):
    os.makedirs(PATH_TO_DST_ELFS_DIR_ROCKET, exist_ok=True)
if not os.path.exists(PATH_TO_DST_ELFS_DIR_BOOM):
    os.makedirs(PATH_TO_DST_ELFS_DIR_BOOM, exist_ok=True)

# Find all the elfs in the source directory, whose name starts with rocket or by boom
rocket_elfs = []
boom_elfs = []
for filename in os.listdir(PATH_TO_SRC_ELFS_DIR):
    if filename.startswith('rocket'):
        rocket_elfs.append(filename)
    elif filename.startswith('boom'):
        boom_elfs.append(filename)

# Copy the rocket and boom elfs to the destination directory
for filename in tqdm(rocket_elfs):
    src_path = os.path.join(PATH_TO_SRC_ELFS_DIR, filename)
    dst_path = os.path.join(PATH_TO_DST_ELFS_DIR_ROCKET, filename)
    os.system('cp {} {}'.format(src_path, dst_path))
for filename in tqdm(boom_elfs):
    src_path = os.path.join(PATH_TO_SRC_ELFS_DIR, filename)
    dst_path = os.path.join(PATH_TO_DST_ELFS_DIR_BOOM, filename)
    os.system('cp {} {}'.format(src_path, dst_path))
    
