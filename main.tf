# 1. THE NETWORK
module "networking" {
  source              = "./modules/networking"
  vpc_cidr_block      = var.vpc_cidr_block
  subnet_cidr_block   = var.subnet_cidr_block
  availability_zone   = var.availability_zone
  env_prefix          = var.env_prefix
}

# 2. THE SECURITY (FENCES)
module "security" {
  source     = "./modules/security"
  vpc_id     = module.networking.vpc_id
  env_prefix = var.env_prefix
  my_ip      = local.my_ip
}

# 3. THE NGINX PROXY SERVER
module "nginx_server" {
  source            = "./modules/webserver"
  env_prefix        = var.env_prefix
  instance_name     = "nginx-proxy"
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  vpc_id            = module.networking.vpc_id
  subnet_id         = module.networking.subnet_id
  security_group_id = module.security.nginx_sg_id
  public_key        = var.public_key
  
  # CHANGE THIS LINE:
  user_data         = file("./scripts/nginx-setup.sh") 
  
  instance_suffix   = "nginx"
  common_tags       = local.common_tags
}

# 4. THE BACKEND SERVERS
module "backend_servers" {
  for_each = { for server in local.backend_servers : server.name => server }

  source            = "./modules/webserver"
  env_prefix        = var.env_prefix
  instance_name     = each.value.name
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  vpc_id            = module.networking.vpc_id
  subnet_id         = module.networking.subnet_id
  security_group_id = module.security.backend_sg_id
  public_key        = var.public_key
  
  user_data = templatefile(each.value.script_path, {
    server_name   = each.value.name
    server_status = each.value.name == "web-3" ? "🛡️ Backup Server" : "✅ Primary Active"
  })

  instance_suffix   = each.value.suffix
  common_tags       = local.common_tags
}