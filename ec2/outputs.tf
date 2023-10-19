output "alb_id" {
  value = module.blog_alb.lb_id
}

output "instance_arn" {
  value = module.blog_autoscaling.iam_instance_profile_arn
}
