FROM cookielab/slim:12.10 AS build

RUN apt update && apt install -y wget zip

ARG TARGETARCH

ARG TERRAFORM_VERSION

RUN wget -q -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${TARGETARCH}.zip
RUN unzip /tmp/terraform.zip -d /usr/local/bin
RUN rm /tmp/terraform.zip

ARG TFLINT_VERSION

RUN wget -q -O /tmp/tflint.zip https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_${TARGETARCH}.zip
RUN unzip /tmp/tflint.zip -d /usr/local/bin
RUN rm -f /tmp/tflint.zip

ARG TFSEC_VERSION

RUN wget -q -O /tmp/tfsec.tar.gz https://github.com/aquasecurity/tfsec/releases/download/v${TFSEC_VERSION}/tfsec_${TFSEC_VERSION}_linux_${TARGETARCH}.tar.gz
RUN mkdir -p /tmp/tfsec
RUN tar -xzf /tmp/tfsec.tar.gz -C /tmp/tfsec
RUN cp /tmp/tfsec/tfsec /usr/local/bin
RUN cp /tmp/tfsec/tfsec-checkgen /usr/local/bin
RUN rm -rf /tmp/tfsec /tmp/tfsec.tar.gz

ARG TF_SUMMARIZE_VERSION

RUN wget -q -O /tmp/tf-sum.tar.gz https://github.com/dineshba/tf-summarize/releases/download/v${TF_SUMMARIZE_VERSION}/tf-summarize_linux_${TARGETARCH}.tar.gz
RUN tar -xzf /tmp/tf-sum.tar.gz -C /usr/local/bin
RUN rm -f /tmp/tf-sum.tar.gz

ARG GITLAB_TERRAFORM

RUN wget -q -O /usr/local/bin/gitlab-terraform https://gitlab.com/gitlab-org/terraform-images/-/raw/v${GITLAB_TERRAFORM}/src/bin/gitlab-terraform.sh
RUN chmod +x /usr/local/bin/gitlab-terraform

FROM cookielab/slim:12.10

RUN apt update && apt install -y openssl wget curl zip python3 tzdata jq git idn2 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bin /usr/local/bin

ARG GITHUB_TOKEN

USER 1987

COPY --chown=container:container .tflint.hcl /container/
RUN tflint --init

RUN touch /container/.terraformrc

ONBUILD USER root
