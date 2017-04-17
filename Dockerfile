FROM ubuntu:16.04


RUN apt-get update
RUN apt-get install -y python python-dev python-distribute python-pip
RUN apt-get install -y git libblas-dev liblapack-dev gfortran

RUN pip install --upgrade pip
RUN pip install jupyter
RUN pip install numpy scipy matplotlib scikit-learn pandas seaborn jupyter tqdm 
RUN pip install nose statsmodels

RUN jupyter notebook --allow-root --generate-config -y
RUN echo "c.NotebookApp.password = ''" >> ~/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py

RUN mkdir /home/user
WORKDIR /home/user

EXPOSE 5000

ENTRYPOINT jupyter notebook --ip="*" --no-browser --port 5000 --allow-root
