FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install --no-install-recommends -y apt-utils software-properties-common curl nano unzip openssh-server
RUN apt-get install -y python python-dev python-distribute python-pip
RUN apt-get install -y git libblas-dev liblapack-dev gfortran

RUN pip install --upgrade pip
RUN pip install jupyter
RUN pip install numpy scipy matplotlib scikit-learn pandas seaborn jupyter tqdm
RUN pip install nose statsmodels xgboost supervisor

RUN jupyter notebook --allow-root --generate-config -y
RUN echo "c.NotebookApp.password = ''" >> ~/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.token = ''" >> ~/.jupyter/jupyter_notebook_config.py
RUN jupyter nbextension enable --py --sys-prefix widgetsnbextension

# == JAVA ==
# Set locale to UTF-8
# Set limits
# Configure APT
# Install JDK
# Cleanup
RUN locale-gen en_US.UTF-8 && echo LANG=\"en_US.UTF-8\" > /etc/default/locale && \
    printf '%s\n%s\n%s\n%s\n' \
        '* - memlock unlimited' \
        '* - nofile 65536' \
        '* - nproc 65536' \
        '* - as unlimited' \
        >> /etc/security/limits.conf && \
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | \
        /usr/bin/debconf-set-selections && \
    add-apt-repository -y ppa:webupd8team/java && \
    apt-get -y update && \
    apt-get install --no-install-recommends -y oracle-java8-installer oracle-java8-set-default && \
    apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /var/cache/oracle-jdk8-installer

# == Zeppelin ==
RUN cd /tmp && \
    curl -L http://apache-mirror.rbc.ru/pub/apache/zeppelin/zeppelin-0.7.1/zeppelin-0.7.1-bin-netinst.tgz \
        > zeppelin-0.7.1-bin-netinst.tgz && \
    tar xzf ./zeppelin-0.7.1-bin-netinst.tgz && \
    mv ./zeppelin-0.7.1-bin-netinst /usr/local/ && \
    rm ./zeppelin-0.7.1-bin-netinst.tgz && \
    ln -s /usr/local/zeppelin-0.7.1-bin-netinst /usr/local/zeppelin && \
    /usr/local/zeppelin/bin/install-interpreter.sh --name md,angular,shell,jdbc,python,file

COPY entry-point.sh supervisor-all.conf /

# Final setup: directories, permissions, ssh login, etc
RUN mkdir -p /home/user && \
    mkdir -p /var/run/sshd && \
    echo 'root:12345' | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    chmod a+x /entry-point.sh
WORKDIR /home/user
EXPOSE 22 5000 8080

ENTRYPOINT ["/entry-point.sh"]
CMD ["shell"]
