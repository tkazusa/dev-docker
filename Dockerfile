FROM nikolaik/python-nodejs:latest
MAINTAINER Taketoshi Kazusa <takekazusa@gmail.com>

ENV USER ubuntu
ENV HOME /home/${USER}  
ENV SHELL /bin/bash  

# -------------------- Setup OpenSSH -------------------- #
RUN apt-get update && apt-get install -y openssh-server \
 && mkdir /var/run/sshd \
 && echo "root:screencast" | chpasswd \
 && sed -i "s/PermitRootLogin prohibit-password/PermitRootLogin yes/" /etc/ssh/sshd_config

## Add user
RUN useradd -m -s /bin/bash ${USER} \ 
 && gpasswd -a ${USER} sudo \
 && echo "${USER}:screencast" | chpasswd

# SSH login fix. Otherwise user is kicked off after login
RUN sed "s@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g" -i /etc/pam.d/sshd

# --------------------- Install Rust --------------------- #
# Use bash for RUN/CMD 
SHELL ["/bin/bash", "-c"] 
WORKDIR /home/${USER} 
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y  \
 && source /home/${USER}/.cargo/env  
ENV PATH $PATH:/home/${USER}/.cargo/bin  

# -------------------- Install AWS CLI -------------------- #
RUN mkdir .awscli \ 
 && curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o ".awscli/awscliv2.zip" \
 && unzip .awscli/awscliv2.zip -d .awscli \
 && .awscli/aws/install
ENV PATH $PATH:/home/${USER}/.awscli/aws

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
