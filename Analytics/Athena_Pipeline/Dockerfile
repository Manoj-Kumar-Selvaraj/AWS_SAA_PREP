FROM public.ecr.aws/lambda/python:3.11

# Install dependencies
RUN yum install -y gcc zip && \
    yum clean all

# Create deployment package structure
RUN mkdir -p /var/task/lib

# Install dependencies to lib folder (instead of directly in site-packages)
RUN pip install --target /var/task/lib pgpy cryptography

# Create zip file
WORKDIR /var/task
RUN zip -r /tmp/lambda_package.zip lib/ lambda_function.py

# Keep container running so we can copy files
CMD ["tail", "-f", "/dev/null"]