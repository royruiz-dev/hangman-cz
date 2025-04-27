#!/bin/bash

terraform destroy $(terraform state list | grep -v 'module.backend_resources' | sed 's/^/-target=/') -auto-approve