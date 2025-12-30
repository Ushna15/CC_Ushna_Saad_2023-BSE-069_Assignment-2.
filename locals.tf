# This fetches your current public IP address automatically
data "http" "my_ip" {
  url = "https://icanhazip.com"
}

locals {
  # Chomp removes the newline character from the IP fetch
  my_ip = "${chomp(data.http.my_ip.response_body)}/32"

  # Resource naming convention
  name_prefix = "${var.env_prefix}-assignment2"

  # Common tags used across all resources
  common_tags = {
    Environment = var.env_prefix
    Project     = "Assignment-2"
    ManagedBy   = "Terraform"
  }

  # This logic adds a 'suffix' to your backend servers 
  # which you will use to create unique SSH Key Pairs.
  backend_servers = [
    {
      name        = "web-1"
      suffix      = "1"
      script_path = "./scripts/apache-setup.sh"
    },
    {
      name        = "web-2"
      suffix      = "2"
      script_path = "./scripts/apache-setup.sh"
    },
    {
      name        = "web-3"
      suffix      = "3"
      script_path = "./scripts/apache-setup.sh"
    }
  ]
}