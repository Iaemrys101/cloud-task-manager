module "network" {
  source = "../../modules/network"

  project_name               = var.project_name
  environment                = var.environment
  aws_region                 = var.aws_region
  vpc_cidr                   = var.vpc_cidr
  public_subnets             = var.public_subnets
  private_subnets            = var.private_subnets
  enable_container_endpoints = var.deploy_container_runtime
}

module "container_registry" {
  source = "../../modules/container_registry"

  project_name = var.project_name
  environment  = var.environment
}

module "container_service" {
  count  = var.deploy_container_runtime ? 1 : 0
  source = "../../modules/container_service"

  project_name          = var.project_name
  environment           = var.environment
  aws_region            = var.aws_region
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = values(module.network.public_subnet_ids)
  private_subnet_ids    = values(module.network.private_subnet_ids)
  alb_security_group_id = module.network.alb_security_group_id
  api_security_group_id = module.network.api_security_group_id
  container_image       = "${module.container_registry.repository_url}:${var.container_image_tag}"

  depends_on = [module.network]
}
