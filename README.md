# Lysoquant server - in docker

The GPU version is tested to work on NVIDIA GTX 2070, GTX 2060, GTX 1080 and GTX 940 MX. It may not work on newer GPU cards (possibly after Turing architecture). In this case, use the CPU version (see below).

## Running the container

### GPU version

1. Pull image from dockerhub:

```
docker pull dmorone/lysoquant:latest
```

1. Run container

```
docker run --rm -p 2222:22 --gpus all -it dmorone/lysoquant:latest
```

The config will ask you to provide a password for user `unetuser` (just put a very simple one, it won't be asked again afterwards), then will create a client key. Copy all text to a new text file on client

### CPU version

1. Pull image from dockerhub:

```
docker pull dmorone/lysoquant:cpu
```

1. Run container

```
docker run --rm -p 2222:22 --cpus 24 -e threads 24 -it dmorone/lysoquant:cpu
```

The config will ask you to provide a password for user `unetuser` (just put a very simple one, it won't be asked again afterwards), then will create a client key. Copy all text to a new text file on client

## Client config

1. Download latest release from github.com/irb-imagingfacility/lysoquant and unpack

1. In ImageJ/FIJI install lysoquant and U-NET plugin. 

1. Open an RGB image (any will work), run U-NET > Segment Current Image (Hyperstack). Set as follows:

	- Model: find modeldef file 
	- Weight file: enter `/home/unetuser/lysoquant/2D-7-16.caffemodel.h5`
	- Process folder: `/tmp`
	- Use GPU: select which GPU you wish to user (if more), otherwise choose `GPU 0`
	- Tile shape size: this depends on the amount of memory available. Start low. For an 8GB card, a typical value is 1024x1024
	- Use remote host: yes
	- Host: `localhost`
	- Port: `2222`
	- User: `unetuser`
	- Change authentication to "RSA key" and locate the previously save text file

Run this as test. If working, you should get a grey image. You can close both this result and the RGB image.

1. In ImageJ menu, go to Edit > Options > Lysoquant Settings... and check that all settings have been copied from U-Net. Save and close

1. Open a multichannel image and run Analyze > Lysoquant


## To compile from scratch

Make sure you have nvidia drivers and docker.

Download the latest release of this repo, containing supporting files. 

Run 

```
cd lysoquant-docker
docker buildx build . -f Dockerfile
```

Then run container and proceed with configuration as above 
