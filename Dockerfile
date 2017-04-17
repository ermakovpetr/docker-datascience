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

# == Maven ==
RUN cd /tmp && \
    curl -L http://apache-mirror.rbc.ru/pub/apache/maven/maven-3/3.5.0/binaries/apache-maven-3.5.0-bin.tar.gz \
        > apache-maven-3.5.0-bin.tar.gz && \
    tar xzf apache-maven-3.5.0-bin.tar.gz && \
    mv ./apache-maven-3.5.0 /usr/local/ && \
    rm apache-maven-3.5.0-bin.tar.gz && \
    ln -s /usr/local/apache-maven-3.5.0 /usr/local/maven && \
    ln -s /usr/local/maven/bin/mvn /usr/local/bin

# == H2O ==
RUN cd /tmp && \
    curl -L http://h2o-release.s3.amazonaws.com/h2o/rel-ueno/4/h2o-3.10.4.4.zip \
        > h2o-3.10.4.4.zip && \
    unzip h2o-3.10.4.4.zip && \
    mv ./h2o-3.10.4.4 /usr/local/ && \
    rm h2o-3.10.4.4.zip && \
    ln -s /usr/local/h2o-3.10.4.4 /usr/local/h2o

# == SBT ==
RUN cd /tmp && \
    curl -L http://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.1/sbt-launch.jar \
        > sbt-launch.jar && \
    mkdir -p /usr/local/sbt/ && \
    mv sbt-launch.jar /usr/local/sbt/

# == Sparkling water ==
RUN cd /tmp && \
    curl -L http://h2o-release.s3.amazonaws.com/sparkling-water/rel-2.1/3/sparkling-water-2.1.3.zip \
        > sparkling-water-2.1.3.zip && \
    unzip sparkling-water-2.1.3.zip && \
    mv ./sparkling-water-2.1.3 /usr/local/ && \
    rm sparkling-water-2.1.3.zip && \
    ln -s /usr/local/sparkling-water-2.1.3 /usr/local/sparkling-water

COPY entry-point.sh /
COPY supervisord.conf /etc/
COPY zeppelin-env.sh /usr/local/zeppelin/conf/
COPY sbt h2o /usr/local/bin/

# Final setup: directories, permissions, ssh login, symlinks, etc
RUN mkdir -p /home/user && \
    mkdir -p /var/run/sshd && \
    echo 'root:12345' | chpasswd && \
    sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd && \
    ln -s /usr/local/sparkling-water/assembly/build/libs/sparkling-water-assembly_2.11-2.1.3-all.jar \
        /usr/local/zeppelin/interpreter/spark/dep/ && \
    chmod a+x /usr/local/bin/h2o && \
    chmod a+x /usr/local/bin/sbt && \
    chmod a+x /entry-point.sh

WORKDIR /home/user
EXPOSE 22 4040 5000 8080 54321

ENTRYPOINT ["/entry-point.sh"]
CMD ["shell"]
