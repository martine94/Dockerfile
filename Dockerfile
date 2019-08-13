#FROM nvidia/cuda:8.0-cudnn7-devel
FROM nvidia/cuda:10.0-cudnn7-devel
LABEL maintainer="Martin Eriksson"
ENV DEBIAN_FRONTEND=noninteractive

###################################################

WORKDIR /
# Installing python2 and python3
RUN apt-get update && \
	apt install -y --no-install-recommends \
		python3-pip \
		python-pip \
		python3 \
		python
# Uppgrade pip and pip3
RUN pip3 install --upgrade pip setuptools && \
	pip install --upgrade pip

# Install git, p7zip (to extract 7z zip files),
# X and xvfb so we can SEE the action using a remote desktop access (VNC)
# and more.
RUN apt-get update && apt-get install -y \
	git \
	p7zip-full \
	x11vnc \
	xvfb \
	fluxbox \
	wmctrl \
	wget \
	vim 

# Installing a bunch of Python Packages
RUN pip3 install \
	pandas \
	scikit-learn \
	joblib==0.11 \
	wget \
	open3d \
	open3d-python 
	
# Installing Tensorflow (GPU)
# see here https://www.tensorflow.org/install/install_linux#InstallingNativePip
RUN pip3 install tensorflow-gpu
#==1.4.0

# Build Open3d from source, needed for the tangent convolutional network
WORKDIR /home/student/
RUN git clone https://github.com/tatarchm/Open3D.git
RUN set -ev && apt-get install -y \
	xorg-dev \
	libglu1-mesa-dev \
	libgl1-mesa-glx \
	libglew-dev \
	libglfw3-dev \
	libjsoncpp-dev \
	libeigen3-dev \
	libpng-dev \
	libjpeg-dev \
	python-dev \
	python3-dev \
	python-tk \
	python3-tk
	
WORKDIR /home/student/Open3D/build
RUN apt-get update && \
	apt-get -y install cmake protobuf-compiler && \
	cmake ../src && \
	make

# Clean up
RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /cudnn-8.0-linux-x64-v7.tgz && \
	rm -rf /cuda/

# Clone tangent convolutional network from copied repository SummerInternship
WORKDIR /home/student/
RUN git clone https://github.com/martine94/SummerInternship
WORKDIR /home/student/SummerInternship

# 
# Copy files for the tangent convolutional network
# outputFiles is needed to run tc.py --precompute
#COPY outputFiles /home/student/SummerInternship/outputFiles
# data contains the files generated by tc.py --precompute (dhnrgb) 
# and is needed for tc.py --train
#COPY data /home/student/SummerInternship/data

# Copy files for CoRob
#COPY flight1.xyz /home/student/
#COPY flight2.xyz /home/student/

# Test /Martin
COPY outputFiles.7z /home/student/SummerInternship/
