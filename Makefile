# Copyright 2023 Flavien Solt, ETH Zurich.
# Licensed under the General Public License, Version 3.0, see LICENSE for details.
# SPDX-License-Identifier: GPL-3.0-only

IMAGE_TAG ?= ethcomsec/cascade-difuzzrtl

build:
	docker build -t $(IMAGE_TAG) .

run:
	docker run -it -v $(CASCADE_DOCKER_MNT_DIR):/difuzzrtl $(IMAGE_TAG)
