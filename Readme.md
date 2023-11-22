# Cascade artifacts regarding the collection of the DifuzzRTL coverage metric

This is a part of the Artifact Evaluation for the paper _Cascade: CPU Fuzzing via Intricate Program Generation_ (presented at USENIX Security 2024).

Please note that at the time of this writing, Cascade's codename was Disco.
We provide a step-by-step guide of how to create the logs that are used in the main Cascade artifacts repository.

First, create the Docker image for the DifuzzRTL experiment by running the following command:

```
make build
```

Then, specify the path to the shared folder so that the Docker image and your base filesystem can communicate:

```
CASCADE_DOCKER_MNT_DIR=$(pwd)/difuzz-rtl
```

Please note that mounting a shared volume requires a correct configuration of Docker.
Please refer to the Docker documentation for more information.

Then, you can run a Docker container with the following command:

```
make run
```

## Evaluating DifuzzRTL on the DifuzzRTL coverage metric

To select DifuzzRTL as the fuzzer to test, ensure that the following line in the `difuzz-rtl/Fuzzer/RTLSim/src/adapters/tilelink/adapter.py` file is as below.
Otherwise, Cascade (aka. Disco) will be executed instead of DifuzzRTL.
```
IS_DISCO = False
```

DifuzzRTL will autonomously generate its input files, hence the only command that you should require, inside the Docker container, is:
```
cd /difuzzrtl/Fuzzer && make SIM_BUILD=builddir VFILE=RocketTile_state TOPLEVEL=RocketTile NUM_ITER=100000 OUT=outdir SPIKE=/opt/riscv/bin/spike -j $(nproc)
```

## Evaluating Cascade on the DifuzzRTL coverage metric

To select Cascade as the fuzzer to test, ensure that the following line in the `difuzz-rtl/Fuzzer/RTLSim/src/adapters/tilelink/adapter.py` file is as below.
```
IS_DISCO = True
```

Cascade will rely on input files that were created by the Cascade fuzzer.
Hence, you will first have to create a good number of input files (10000 are enough for 72h of fuzzing).

To do so, we suggest to first generate the ELFs using:
```
# In the `ethcomsec/cascade-artifacts` Docker container (or natively)
python3 do_genmanyelfs <num_elfs_to_generate> <target_dir>
```
in the `cascade-meta/fuzzer` repository in the main `ethcomsec/cascade-artifacts` Docker container, or natively if you run Cascade natively.
Note that the step size, i.e., the Cascade program size, is modulable through `cascade.fuzzfromdescriptor.NUM_MAX_BBS_UPPERBOUND` in the `cascade-meta/fuzzer` directory.
The experiment was originally performed with `NUM_MAX_BBS_UPPERBOUND=1000`. The speedup result does not significantly vary in function of this parameter in a reasonable range (between 50 and 10000), while there is some convenience with prototyping with relatively shorter programs.

Then, if you generated these ELFs in the main `ethcomsec/cascade-artifacts` Docker container, you will have to extract them from the container to your machine's file system, for example using `docker cp` or a shared volume.
Please refer to the Docker documentation for more details.

Now that you have the ELFs somewhere in your machine, please specify this path in `import_disco_elfs.py` as the `PATH_TO_SRC_ELFS_DIR` variable and run this script natively on your machine.
```
# Natively (not in any Docker container)
pip3 install tqdm
python3 import_disco_elfs.py
```
This will populate the `difuzz-rtl/disco-elfs/RockerTile/` directory with the ELFs that you generated.
Please note, as specified in Section 7.4.1, that we are only interested in Rocket, hence you can ignore the BOOM part.

The data is now accessible to the `ethcomsec/cascade-difuzzrtl` container.
To comply with the DifuzzRTL toolchain requirements, you will have to run the following command to transform the ELFs into an hexadecimal format:
```
# In the `ethcomsec/cascade-difuzzrtl` Docker container
cd difuzzrtl
python3 disco_elf_to_hex.py
```

Finally execute
```
cd /difuzzrtl/Fuzzer && make SIM_BUILD=builddir VFILE=RocketTile_state TOPLEVEL=RocketTile NUM_ITER=100000 OUT=outdir SPIKE=/opt/riscv/bin/spike -j $(nproc)
```
