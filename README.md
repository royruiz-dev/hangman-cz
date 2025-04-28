## Hangman Game Web App Deployment

This repository is used for deploying the Hangman Game Web App. To deploy it, you'll need to do the following:

1. Fork or clone this repository to your GitHub account.
2. Set up your AWS Account to provision infrastructure with Terraform.
3. Configure your AWS CLI (recommended).
4. Set up your SSH Key for Ansible to perform configurations.
5. Set up your domain name to access the app after deployment (optional).
6. Set up your GitHub Secrets (accessed via the **Settings** tab of your cloned/forked repository)

For instructions on how to set up, play, and interact with the game locally, refer to the [Hangman Game Web App README](https://github.com/royruiz-dev/hangman-game).

---

### Set up your AWS Account for Terraform

Before using Terraform, make sure your AWS user account has the following permissions:

- AmazonEC2FullAccess
- AmazonVPCFullAccess
- IAMFullAccess
- AmazonRoute53FullAccess (optional, if using a custom domain)

You can either:

- Use an existing AWS user with administrator access,
- Create a new IAM group and User, attach the necessary permissions, and configure your AWS CLI credentials (recommended).

```bash
# Create IAM group
aws iam create-group --group-name tf-admins

# Attach managed policies to the group
aws iam attach-group-policy --group-name tf-admins --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess
aws iam attach-group-policy --group-name tf-admins --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess
aws iam attach-group-policy --group-name tf-admins --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess
aws iam attach-group-policy --group-name tf-admins --policy-arn arn:aws:iam::aws:policy/IAMFullAccess

# Create IAM user
aws iam create-user --user-name tf-user

# Add user to group
aws iam add-user-to-group --user-name tf-user --group-name tf-admins

# Create Access Key ID and Secret Access Key for user
aws iam create-access-key --user-name tf-user
```

Save the Access Key ID and Secret Access Key for AWS CLI configuration and GitHub Secrets setup.

---

### Configure your AWS CLI

Configure your local AWS CLI with the credentials you just created:

```bash
aws configure
```

You will be prompted to enter:

- AWS Access Key ID (obtained from IAM output)
- AWS Secret Access Key (obtained from IAM output)
- Default region (region where resources will be deployed, e.g., `eu-central-1`)
- Default output format (e.g., `json`)

**Note**: If you deploy **exclusively** via GitHub Actions and don't plan to run Terraform locally, AWS CLI configuration is optional.

---

### Set up SSH Key for Ansible

Generate a local SSH key pair:

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible-ec2-key.pem
```

Import the public key into AWS:

```bash
aws ec2 import-key-pair --key-name "ansible-ec2-key" --public-key-material fileb://~/.ssh/ansible-ec2-key.pub
```

Base64-encode the private key to store into GitHub Secrets at a later step:

```bash
base64 -i ~/.ssh/ansible-ec2-key.pem > encoded-key.txt

# Copy the encoded key (Mac users; Linux users can use xclip)
cat encoded-key.txt | pbcopy
```

**Note**: The private key is stored in GitHub Secrets (e.g., ANSIBLE_SSH_PRIVATE_KEY) and used by Ansible to SSH into the deployed EC2 instances.

---

### Use a Custom Domain Name (Optional)

You may access your app using a custom domain. To do this:

- Add your domain name as a GitHub Secret called `CUSTOM_DOMAIN_NAME`
- Format: `example.com` (without `http://` prefix)

**Note**: If you don't use a custom domain, you can still access the app using the Application Load Balancer (ALB) DNS name provided after deployment.

#### ⚠︎ DNS Update (If Using a Custom Domain)

If using a custom domain, update your DNS with the **name servers** provided by Terraform.

1. Go to your domain registrar (e.g., GoDaddy, Namecheap).
2. Replace your current **name servers** with the ones from the Terraform `route53_name_servers` output.
3. Save the changes. DNS updates may take up to 48 hours.

Find the name servers in the logs from the **"Show Terraform outputs"** step in your GitHub Actions workflow.

Your custom domain will point to the app after DNS propagation is complete.

---

### Set up GitHub Secrets

Add the following secrets to your GitHub repository:

| Secret Name               | Description                                       |
| ------------------------- | ------------------------------------------------- |
| `AWS_ACCESS_KEY_ID`       | Your AWS IAM Access Key ID                        |
| `AWS_SECRET_ACCESS_KEY`   | Your AWS IAM Secret Access Key                    |
| `ANSIBLE_SSH_PRIVATE_KEY` | Your base64-encoded SSH private key               |
| `CUSTOM_DOMAIN_NAME`      | (Optional) Your domain name (e.g., `example.com`) |

**Note**: Make sure there are **no spaces** in secret values.

---

### Triggering the Deployment

Once your GitHub Secrets are set up:

- Trigger the deployment manually via the **Actions** tab of your repository.
- (Optional) Enable **automatic deployment** on push to the `main` branch by **uncommenting the relevant section** in `.github/workflows/deploy.yml` .

✅ **DONE!** The Hangman Game Web App is now accessible either via ALB DNS or your custom domain.

---

### Destroying the Infrastructure

To destroy the infrastructure and clean up all resources provisioned by Terraform, run:

```bash
cd terraform/
./scripts/terraform-destroy.sh
```

**Note**: Ensure you are in the `terraform/` directory where state files are located before running the script.
